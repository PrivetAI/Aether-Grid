import SwiftUI

enum BattlePhase {
    case playerTurn
    case resolving
    case enemyTurn
    case won
    case lost
}

final class BattleEngine: ObservableObject {
    // Grid
    let width: Int
    let height: Int
    @Published var tiles: [[Tile]]      // [y][x]
    @Published var units: [BattleUnit] = []
    @Published var floatingTexts: [FloatingText] = []

    // Turn state
    @Published var phase: BattlePhase = .playerTurn
    @Published var roundNumber: Int = 1
    @Published var selectedMageIndex: Int? = nil
    @Published var selectedSpellId: String? = nil
    @Published var statusMessage: String = ""

    // Objective / bonus tracking
    let mission: MissionDef
    @Published var objectiveProgress: Int = 0     // for survive/protect counters
    @Published var won = false
    @Published var lost = false

    // Bonus tracking (mutated from the extension in EnemyAI.swift -> internal access)
    var anyMageDamaged = false
    var anyDirectKill = false        // a kill not caused by a reaction
    var mageLost = false

    // Stats (mutated from the extension in EnemyAI.swift -> internal access)
    var reactionCount = 0
    var spellCastCount = 0
    var enemiesKilled = 0
    var maxChainStunInOneCast = 0
    var didDetonate = false
    var bossDefeatedId: String? = nil

    let store: GameStore
    var spells: [String: ResolvedSpell] = [:]   // resolved per party member's spellbook

    init(mission: MissionDef, party: [MageClass], store: GameStore) {
        self.mission = mission
        self.store = store
        self.width = mission.gridW
        self.height = mission.gridH
        // Build grid
        var grid = Array(repeating: Array(repeating: Tile(terrain: .floor, element: nil), count: mission.gridW), count: mission.gridH)
        for patch in mission.terrain {
            for p in patch.tiles where Self.inBounds(p, w: mission.gridW, h: mission.gridH) {
                grid[p.y][p.x].terrain = patch.kind
                if let seed = patch.kind.seedElement {
                    grid[p.y][p.x].element = seed
                }
            }
        }
        self.tiles = grid

        // Resolve party spells
        for cls in party {
            for sid in cls.spellIDs {
                if let base = SpellCatalog.spell(sid) {
                    spells[sid] = store.upgradedSpell(base)
                }
            }
        }

        // Spawn mages
        for (i, cls) in party.enumerated() where i < mission.mageSpawns.count {
            let u = BattleUnit.makeMage(cls, at: clampedSpawn(mission.mageSpawns[i]))
            units.append(u)
        }
        // Spawn initial enemies
        for spawn in mission.enemySpawns {
            spawnFromDescriptor(spawn)
        }

        if selectedMageIndex == nil, let first = units.firstIndex(where: { $0.side == .mage }) {
            selectedMageIndex = first
        }
        statusMessage = mission.objective.label
        markInitialSeen()
    }

    private func markInitialSeen() {
        for u in units where u.side == .enemy {
            if let eid = u.enemyDefId { store.markEnemySeen(eid) }
        }
        for (_, p) in tiles.enumerated() { _ = p }
        // mark element from terrain seeds
        for row in tiles { for t in row { if let e = t.element { store.markElementSeen(e) } } }
        // mark party spells/elements
        for sid in spells.keys {
            store.markSpellSeen(sid)
            if let s = spells[sid] { store.markElementSeen(s.element) }
        }
        store.persist()
    }

    // MARK: - Helpers

    private static func inBounds(_ p: GridPos, w: Int, h: Int) -> Bool {
        p.x >= 0 && p.x < w && p.y >= 0 && p.y < h
    }
    func inBounds(_ p: GridPos) -> Bool { Self.inBounds(p, w: width, h: height) }

    private func clampedSpawn(_ p: GridPos) -> GridPos {
        GridPos(min(max(p.x, 0), width-1), min(max(p.y, 0), height-1))
    }

    func unit(at p: GridPos) -> BattleUnit? {
        units.first { $0.alive && $0.pos == p }
    }

    func tile(at p: GridPos) -> Tile? {
        guard inBounds(p) else { return nil }
        return tiles[p.y][p.x]
    }

    func isPassable(_ p: GridPos, for side: UnitSide, phaser: Bool = false) -> Bool {
        guard inBounds(p) else { return false }
        let t = tiles[p.y][p.x]
        if t.terrain.impassable { return false }
        if unit(at: p) != nil { return false }
        if !phaser, let e = t.element, e.blocksMovement { return false }
        return true
    }

    var mages: [BattleUnit] { units.filter { $0.side == .mage && $0.alive } }
    var enemies: [BattleUnit] { units.filter { $0.side == .enemy && $0.alive } }

    var selectedMage: BattleUnit? {
        guard let i = selectedMageIndex, i < units.count else { return nil }
        let u = units[i]
        return (u.side == .mage && u.alive) ? u : nil
    }

    func resolvedSpell(_ id: String) -> ResolvedSpell? { spells[id] }

    func spellbook(for mage: BattleUnit) -> [ResolvedSpell] {
        guard let cid = mage.mageClassId, let cls = MageRoster.byId(cid) else { return [] }
        return cls.spellIDs.compactMap { spells[$0] }
    }

    // MARK: - Spawning

    func spawnFromDescriptor(_ spawn: EnemySpawn) {
        let pos = freeNearby(clampedSpawn(spawn.pos))
        if spawn.isBoss {
            if let bdef = BossCatalog.byId(spawn.defId) {
                let u = BattleUnit.makeBoss(bdef, at: pos)
                units.append(u)
            }
        } else if let edef = EnemyCatalog.byId(spawn.defId) {
            let u = BattleUnit.makeEnemy(edef, at: pos)
            units.append(u)
            store.markEnemySeen(edef.id)
        }
    }

    private func freeNearby(_ p: GridPos) -> GridPos {
        if unit(at: p) == nil && inBounds(p) && !tiles[p.y][p.x].terrain.impassable { return p }
        for r in 1...4 {
            for dx in -r...r { for dy in -r...r {
                let q = GridPos(p.x+dx, p.y+dy)
                if inBounds(q) && unit(at: q) == nil && !tiles[q.y][q.x].terrain.impassable { return q }
            }}
        }
        return p
    }

}
