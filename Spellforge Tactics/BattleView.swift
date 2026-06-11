import SwiftUI

// Hosts the engine and routes to result. The engine is built once the environment
// store is available, so progression writes target the real shared GameStore.
struct BattleHostView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.presentationMode) var presentation
    let mission: MissionDef
    let party: [MageClass]

    @State private var engine: BattleEngine? = nil
    @State private var showResult = false
    @State private var finalized = false
    @State private var resultStars = 0
    @State private var resultEssence = 0
    @State private var resultWon = false
    @State private var resultBonus = false

    var body: some View {
        ZStack {
            if let engine = engine {
                BattleView(engine: engine)
                    .onReceive(engine.$phase) { phase in
                        if (phase == .won || phase == .lost) && !finalized {
                            finalized = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                engine.finalize()
                                resultWon = engine.won
                                resultStars = engine.computeStars()
                                resultEssence = engine.won ? engine.essenceReward() : 0
                                resultBonus = engine.bonusSatisfied()
                                showResult = true
                            }
                        }
                    }
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            NavigationLink(isActive: $showResult) {
                MissionResultView(mission: mission,
                                  won: resultWon,
                                  stars: resultStars,
                                  essence: resultEssence,
                                  bonusMet: resultBonus,
                                  onRetry: { retry() })
            } label: { EmptyView() }.hidden()
        }
        .navigationBarHidden(true)
        .onAppear {
            if engine == nil {
                engine = BattleEngine(mission: mission, party: party, store: store)
            }
        }
    }

    private func retry() {
        presentation.wrappedValue.dismiss()
    }
}

struct BattleView: View {
    @ObservedObject var engine: BattleEngine
    @EnvironmentObject var store: GameStore
    @State private var showQuit = false

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 6) {
                    topBar(w: w)
                    objectiveBar(w: w)
                    GeometryReader { gridGeo in
                        BattleGridView(engine: engine, screenSize: gridGeo.size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    bottomControls(w: w)
                }
                .frame(width: w)
                .frame(maxWidth: .infinity)
            }
            .alert(isPresented: $showQuit) {
                Alert(title: Text("Abandon Battle?"),
                      message: Text("You will forfeit this mission's progress."),
                      primaryButton: .destructive(Text("Abandon")) {
                        engine.forfeit()
                      },
                      secondaryButton: .cancel())
            }
        }
    }

    // MARK: Top bar (party HUD)

    private func topBar(w: CGFloat) -> some View {
        HStack(spacing: 8) {
            Button { showQuit = true } label: {
                ChevronGlyph(size: 16).rotationEffect(.degrees(180))
                    .padding(8)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(engine.units.enumerated()), id: \.element.id) { idx, u in
                        if u.side == .mage {
                            mageHUD(u, index: idx)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }

    private func mageHUD(_ u: BattleUnit, index: Int) -> some View {
        let isSel = engine.selectedMageIndex == index && u.alive
        let cls = u.mageClassId.flatMap { MageRoster.byId($0) }
        return Button {
            if u.alive { engine.selectedMageIndex = index; engine.selectedSpellId = nil }
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle().fill((cls?.element.color ?? Theme.gold).opacity(u.alive ? 0.25 : 0.1))
                        .frame(width: 34, height: 34)
                    if let cls = cls { ElementGlyph(kind: cls.element, size: 18) }
                    if !u.alive {
                        CrossGlyph(size: 16, color: Theme.danger)
                    }
                }
                HStack(spacing: 2) {
                    HeartGlyph(size: 9)
                    Text("\(max(0,u.hp))").font(.system(size: 10, weight: .bold)).foregroundColor(Theme.text)
                }
                HStack(spacing: 2) {
                    Circle().fill(Theme.aqua).frame(width: 7, height: 7)
                    Text("\(u.mana)").font(.system(size: 10, weight: .bold)).foregroundColor(Theme.aqua)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSel ? Theme.gold : Color.clear, lineWidth: 2)
            )
            .opacity(u.alive ? 1 : 0.5)
        }
        .buttonStyle(.plain)
    }

    // MARK: Objective bar

    private func objectiveBar(w: CGFloat) -> some View {
        VStack(spacing: 2) {
            HStack {
                Text("Round \(engine.roundNumber)")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(Theme.gold)
                Spacer()
                Text(objectiveText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.text)
                    .lineLimit(1)
            }
            if !engine.statusMessage.isEmpty {
                Text(engine.statusMessage)
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(Theme.textDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Theme.panel.opacity(0.6))
    }

    private var objectiveText: String {
        switch engine.mission.objective {
        case .survive(let t): return "Survive: \(engine.objectiveProgress)/\(t)"
        case .protectLeyNode(_, let t): return "Protect: \(engine.objectiveProgress)/\(t)"
        case .annihilate, .defeatBoss: return "Enemies: \(engine.enemies.count)"
        case .igniteTiles(let ts): return "Ignite \(ts.count) tiles"
        case .extinguishTiles(let ts): return "Extinguish \(ts.count) tiles"
        case .escort: return "Reach the exit"
        }
    }

    // MARK: Bottom controls (spell bar + end turn)

    private func bottomControls(w: CGFloat) -> some View {
        VStack(spacing: 6) {
            if let mage = engine.selectedMage {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(engine.spellbook(for: mage), id: \.def.id) { spell in
                            spellButton(spell, mage: mage)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            } else {
                Text("All mages have acted. End your turn.")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(Theme.textDim)
                    .padding(.vertical, 8)
            }
            HStack(spacing: 10) {
                Button {
                    engine.selectedSpellId = nil
                } label: {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundColor(Theme.textDim)
                        .padding(.vertical, 10).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.panel))
                }
                Button {
                    engine.endPlayerTurn()
                } label: {
                    Text("End Turn")
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(Theme.obsidian)
                        .padding(.vertical, 10).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.gold))
                }
                .disabled(engine.phase != .playerTurn)
                .opacity(engine.phase == .playerTurn ? 1 : 0.5)
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 8).padding(.top, 4)
        .background(Theme.panel.opacity(0.85).edgesIgnoringSafeArea(.bottom))
    }

    private func spellButton(_ spell: ResolvedSpell, mage: BattleUnit) -> some View {
        let selected = engine.selectedSpellId == spell.def.id
        let affordable = mage.mana >= spell.manaCost && !mage.hasActed && !mage.stunned
        return Button {
            if affordable {
                engine.selectedSpellId = selected ? nil : spell.def.id
            }
        } label: {
            VStack(spacing: 3) {
                ElementGlyph(kind: spell.element, size: 22)
                Text(spell.name)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Theme.text)
                    .lineLimit(1)
                HStack(spacing: 2) {
                    Circle().fill(Theme.aqua).frame(width: 6, height: 6)
                    Text("\(spell.manaCost)").font(.system(size: 9, weight: .bold)).foregroundColor(Theme.aqua)
                }
            }
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selected ? spell.element.color.opacity(0.3) : Theme.panelHi)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? spell.element.color : Theme.goldDim.opacity(0.4), lineWidth: selected ? 2 : 1)
            )
            .opacity(affordable ? 1 : 0.4)
        }
        .buttonStyle(.plain)
    }
}

extension BattleEngine {
    func forfeit() {
        lost = true
        phase = .lost
    }
}
