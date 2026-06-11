import SwiftUI

struct BattleGridView: View {
    @ObservedObject var engine: BattleEngine
    let screenSize: CGSize   // passed from parent GeometryReader; do NOT use Canvas size

    var body: some View {
        // Inscribe the board into the available area using min() so it never overflows.
        let pad: CGFloat = 8
        let availW = max(40, screenSize.width - pad*2)
        let availH = max(40, screenSize.height - pad*2)
        let cell = min(availW / CGFloat(engine.width), availH / CGFloat(engine.height))
        let boardW = cell * CGFloat(engine.width)
        let boardH = cell * CGFloat(engine.height)

        let highlights = currentHighlights()

        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                // Tiles
                ForEach(0..<engine.height, id: \.self) { y in
                    ForEach(0..<engine.width, id: \.self) { x in
                        let pos = GridPos(x, y)
                        TileCellView(tile: engine.tiles[y][x],
                                     highlight: highlights[pos],
                                     cell: cell)
                            .frame(width: cell, height: cell)
                            .position(x: CGFloat(x)*cell + cell/2,
                                      y: CGFloat(y)*cell + cell/2)
                            .onTapGesture { handleTap(pos) }
                    }
                }
                // Objective tile markers (ignite/extinguish targets, escort exit, protected node)
                ForEach(objectiveTiles(), id: \.self) { p in
                    DiamondOutline()
                        .stroke(Theme.gold, lineWidth: 2)
                        .frame(width: cell*0.66, height: cell*0.66)
                        .position(x: CGFloat(p.x)*cell + cell/2,
                                  y: CGFloat(p.y)*cell + cell/2)
                        .allowsHitTesting(false)
                }
                // Units
                ForEach(engine.units.filter { $0.alive }, id: \.id) { u in
                    UnitTokenView(unit: u, selected: isSelectedMage(u), cell: cell)
                        .frame(width: cell, height: cell)
                        .position(x: CGFloat(u.pos.x)*cell + cell/2,
                                  y: CGFloat(u.pos.y)*cell + cell/2)
                        .allowsHitTesting(false)
                }
                // Floating texts
                ForEach(engine.floatingTexts) { ft in
                    Text(ft.text)
                        .font(.system(size: max(11, cell*0.32), weight: .heavy, design: .rounded))
                        .foregroundColor(ft.color)
                        .shadow(color: .black, radius: 1)
                        .position(x: CGFloat(ft.pos.x)*cell + cell/2,
                                  y: CGFloat(ft.pos.y)*cell + cell/2 - cell*0.3)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: boardW, height: boardH)
            .clipped()
        }
        .frame(width: min(boardW, screenSize.width), height: min(boardH, screenSize.height))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func objectiveTiles() -> [GridPos] {
        switch engine.mission.objective {
        case .igniteTiles(let ts): return ts.filter { engine.inBounds($0) }
        case .extinguishTiles(let ts): return ts.filter { engine.inBounds($0) }
        case .escort(let exit): return engine.inBounds(exit) ? [exit] : []
        case .protectLeyNode(let node, _): return engine.inBounds(node) ? [node] : []
        case .annihilate, .survive, .defeatBoss: return []
        }
    }

    private func isSelectedMage(_ u: BattleUnit) -> Bool {
        guard let idx = engine.selectedMageIndex, idx < engine.units.count else { return false }
        return engine.units[idx].id == u.id && u.side == .mage
    }

    enum HL { case move, cast, aoe }

    private func currentHighlights() -> [GridPos: HL] {
        var d: [GridPos: HL] = [:]
        guard engine.phase == .playerTurn, let mage = engine.selectedMage else { return d }
        if let sid = engine.selectedSpellId, let spell = engine.resolvedSpell(sid) {
            for t in engine.castableTiles(for: mage, spell: spell) { d[t] = .cast }
        } else {
            for t in engine.reachableTiles(for: mage) { d[t] = .move }
        }
        return d
    }

    private func handleTap(_ pos: GridPos) {
        guard engine.phase == .playerTurn, let mage = engine.selectedMage else { return }
        if let sid = engine.selectedSpellId, let spell = engine.resolvedSpell(sid) {
            if engine.castableTiles(for: mage, spell: spell).contains(pos) {
                engine.castSelected(at: pos)
            }
        } else {
            // tapping another mage selects it
            if let tappedIdx = engine.units.firstIndex(where: { $0.alive && $0.side == .mage && $0.pos == pos }) {
                engine.selectedMageIndex = tappedIdx
                return
            }
            if engine.reachableTiles(for: mage).contains(pos) {
                engine.moveSelectedMage(to: pos)
            }
        }
    }
}

struct TileCellView: View {
    let tile: Tile
    let highlight: BattleGridView.HL?
    let cell: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cell*0.08)
                .fill(tile.terrain.baseColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cell*0.08)
                        .stroke(Theme.obsidian, lineWidth: 1)
                )
            // element overlay
            if let el = tile.element {
                RoundedRectangle(cornerRadius: cell*0.08)
                    .fill(el.color.opacity(0.45))
                ElementGlyph(kind: el, size: cell*0.5)
                    .opacity(0.9)
            }
            // ley node marker
            if tile.terrain == .leyNode {
                RuneCircleGlyph(size: cell*0.6, color: Theme.gold.opacity(0.8))
            }
            if tile.terrain == .metal {
                Rectangle().stroke(Theme.storm.opacity(0.4), lineWidth: 1)
                    .frame(width: cell*0.6, height: cell*0.6)
            }
            // highlight overlay
            if let hl = highlight {
                RoundedRectangle(cornerRadius: cell*0.08)
                    .stroke(hlColor(hl), lineWidth: 2.5)
                    .background(
                        RoundedRectangle(cornerRadius: cell*0.08)
                            .fill(hlColor(hl).opacity(0.12))
                    )
            }
        }
    }

    private func hlColor(_ hl: BattleGridView.HL) -> Color {
        switch hl {
        case .move: return Theme.aqua
        case .cast: return Theme.gold
        case .aoe: return Theme.ember
        }
    }
}

struct UnitTokenView: View {
    @ObservedObject var unitBox: UnitObservable
    let selected: Bool
    let cell: CGFloat

    init(unit: BattleUnit, selected: Bool, cell: CGFloat) {
        self.unitBox = UnitObservable(unit)
        self.selected = selected
        self.cell = cell
    }

    var body: some View {
        let u = unitBox.unit
        let isMage = u.side == .mage
        let color: Color = isMage ? (u.mageClassId.flatMap { MageRoster.byId($0)?.element.color } ?? Theme.gold)
                                   : (u.isBoss ? Theme.danger : Theme.poison)
        ZStack {
            Circle()
                .fill(color.opacity(isMage ? 0.35 : 0.5))
                .overlay(Circle().stroke(selected ? Theme.gold : color, lineWidth: selected ? 3 : 1.5))
                .frame(width: cell*0.78, height: cell*0.78)
            if isMage, let cid = u.mageClassId, let cls = MageRoster.byId(cid) {
                ElementGlyph(kind: cls.element, size: cell*0.4)
            } else if u.isBoss {
                StarShape().fill(Theme.danger).frame(width: cell*0.4, height: cell*0.4)
            } else {
                EnemyGlyph(behavior: u.behavior, size: cell*0.42)
            }
            if u.stunned {
                Text("!").font(.system(size: cell*0.3, weight: .black)).foregroundColor(Theme.storm)
                    .offset(y: -cell*0.32)
            }
            // HP bar
            VStack {
                Spacer()
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.5))
                        Capsule().fill(isMage ? Theme.success : Theme.danger)
                            .frame(width: g.size.width * CGFloat(max(0, u.hp)) / CGFloat(max(1,u.maxHP)))
                    }
                }
                .frame(height: cell*0.10)
            }
            .frame(width: cell*0.7, height: cell*0.7)
        }
    }
}

// Lightweight observable wrapper so token redraws when the BattleUnit class mutates
// (BattleUnit is a class, not @Published; the engine sends objectWillChange which
// re-renders the whole grid, so this simply holds the reference).
final class UnitObservable: ObservableObject {
    let unit: BattleUnit
    init(_ u: BattleUnit) { self.unit = u }
}

struct EnemyGlyph: View {
    let behavior: EnemyBehavior
    let size: CGFloat
    var body: some View {
        Group {
            switch behavior {
            case .ranged, .turret: SwordGlyph(size: size, color: Theme.text)
            case .charger: BoltShape().fill(Theme.danger)
            case .flooder: DropShape().fill(Theme.aqua)
            case .igniter: FlameShape().fill(Theme.ember)
            case .randomizer: SnowflakeShape().stroke(Theme.storm, lineWidth: 1.4)
            case .guardian: ShieldShape().fill(Theme.text.opacity(0.7))
            case .summoner: VoidShape().fill(Theme.poison)
            case .splitter: CloudShape().fill(Theme.vine)
            default:
                Circle().fill(Theme.text.opacity(0.8))
            }
        }
        .frame(width: size, height: size)
    }
}
