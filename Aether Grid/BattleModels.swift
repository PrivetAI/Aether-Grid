import SwiftUI

struct GridPos: Hashable, Codable {
    let x: Int
    let y: Int
    init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
    func manhattan(to other: GridPos) -> Int { abs(x - other.x) + abs(y - other.y) }
    var neighbors: [GridPos] {
        [GridPos(x+1, y), GridPos(x-1, y), GridPos(x, y+1), GridPos(x, y-1)]
    }
}

enum UnitSide { case mage, enemy }

final class BattleUnit: Identifiable {
    let id = UUID()
    var side: UnitSide
    var pos: GridPos

    // For mages
    var mageClassId: String?
    // For enemies / bosses
    var enemyDefId: String?
    var bossDefId: String?
    var isBoss: Bool { bossDefId != nil }
    var bossPhase: Int = 1

    var name: String
    var hp: Int
    var maxHP: Int
    var mana: Int
    var maxMana: Int
    var manaRegen: Int

    var damage: Int
    var moveRange: Int
    var attackRange: Int
    var behavior: EnemyBehavior

    var immunities: [ElementKind]
    var weaknesses: [ElementKind]
    var splitsInto: String?
    var summons: String?

    var stunned: Bool = false
    var hasMoved: Bool = false
    var hasActed: Bool = false
    var summonCooldown: Int = 0

    var alive: Bool { hp > 0 }

    init(side: UnitSide, pos: GridPos, name: String, hp: Int, maxHP: Int) {
        self.side = side
        self.pos = pos
        self.name = name
        self.hp = hp
        self.maxHP = maxHP
        self.mana = 0; self.maxMana = 0; self.manaRegen = 0
        self.damage = 0; self.moveRange = 0; self.attackRange = 1
        self.behavior = .advance
        self.immunities = []; self.weaknesses = []
    }

    static func makeMage(_ cls: MageClass, at pos: GridPos) -> BattleUnit {
        let u = BattleUnit(side: .mage, pos: pos, name: cls.title, hp: cls.maxHP, maxHP: cls.maxHP)
        u.mageClassId = cls.id
        u.mana = cls.maxMana; u.maxMana = cls.maxMana; u.manaRegen = cls.manaRegen
        u.damage = 0; u.moveRange = 3; u.attackRange = 1
        return u
    }

    static func makeEnemy(_ def: EnemyDef, at pos: GridPos) -> BattleUnit {
        let u = BattleUnit(side: .enemy, pos: pos, name: def.name, hp: def.maxHP, maxHP: def.maxHP)
        u.enemyDefId = def.id
        u.damage = def.damage; u.moveRange = def.moveRange; u.attackRange = def.attackRange
        u.behavior = def.behavior
        u.immunities = def.immunities; u.weaknesses = def.weaknesses
        u.splitsInto = def.splitsInto; u.summons = def.summons
        return u
    }

    static func makeBoss(_ def: BossDef, at pos: GridPos) -> BattleUnit {
        let u = BattleUnit(side: .enemy, pos: pos, name: "\(def.name), \(def.title)", hp: def.phase1HP, maxHP: def.phase1HP)
        u.bossDefId = def.id
        u.damage = def.damage; u.moveRange = def.moveRange; u.attackRange = def.attackRange
        u.behavior = def.phase1Behavior
        u.immunities = def.phase1Immunities; u.weaknesses = def.weaknesses
        return u
    }
}

struct Tile {
    var terrain: TerrainKind
    var element: ElementKind?
}

// A spawn descriptor used by missions.
struct EnemySpawn {
    let defId: String     // enemy id OR boss id (if isBoss)
    let pos: GridPos
    let isBoss: Bool
    init(_ defId: String, _ x: Int, _ y: Int, isBoss: Bool = false) {
        self.defId = defId; self.pos = GridPos(x, y); self.isBoss = isBoss
    }
}

// Reinforcement waves (spawn on a given turn).
struct EnemyWave {
    let onTurn: Int
    let spawns: [EnemySpawn]
}

// A floating combat-text event for UI feedback.
struct FloatingText: Identifiable {
    let id = UUID()
    let pos: GridPos
    let text: String
    let color: Color
}
