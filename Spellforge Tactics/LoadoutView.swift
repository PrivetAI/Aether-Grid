import SwiftUI

struct LoadoutView: View {
    @EnvironmentObject var store: GameStore
    let mission: MissionDef

    @State private var selected: [String] = []
    @State private var goBattle = false

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            VStack(spacing: 6) {
                                Text(mission.name)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Theme.gold)
                                    .multilineTextAlignment(.center)
                                Text(mission.lore)
                                    .font(.system(size: 12, design: .serif))
                                    .foregroundColor(Theme.textDim)
                                    .multilineTextAlignment(.center)
                                Text(mission.bonus.label)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.success)
                            }
                            .padding(.horizontal, 18).padding(.top, 8)

                            Text("Choose your party (\(selected.count)/4)")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(Theme.text)

                            ForEach(MageRoster.all) { cls in
                                mageCard(cls)
                            }
                            Spacer(minLength: 100)
                        }
                        .frame(width: w)
                        .frame(maxWidth: .infinity)
                    }
                    bottomBar(w: w)
                }
            }
            .background(
                NavigationLink(isActive: $goBattle) {
                    BattleHostView(mission: mission, party: selectedClasses())
                } label: { EmptyView() }.hidden()
            )
        }
        .navigationBarTitle("Loadout", displayMode: .inline)
        .onAppear { preselect() }
    }

    private func preselect() {
        guard selected.isEmpty else { return }
        // Use last party if all still unlocked, else default to first available.
        let last = store.save.lastParty.filter { id in
            MageRoster.byId(id).map { store.isClassUnlocked($0) } ?? false
        }
        if !last.isEmpty {
            selected = Array(last.prefix(4))
        } else {
            selected = MageRoster.all.filter { store.isClassUnlocked($0) }.prefix(4).map { $0.id }
        }
    }

    private func selectedClasses() -> [MageClass] {
        selected.compactMap { MageRoster.byId($0) }
    }

    private func toggle(_ cls: MageClass) {
        guard store.isClassUnlocked(cls) else { return }
        if let i = selected.firstIndex(of: cls.id) {
            selected.remove(at: i)
        } else if selected.count < 4 {
            selected.append(cls.id)
        }
    }

    @ViewBuilder
    private func mageCard(_ cls: MageClass) -> some View {
        let unlocked = store.isClassUnlocked(cls)
        let chosen = selected.contains(cls.id)
        Button {
            toggle(cls)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(cls.element.color.opacity(0.25)).frame(width: 44, height: 44)
                    ElementGlyph(kind: cls.element, size: 24)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(cls.title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(unlocked ? Theme.text : Theme.textDim)
                    Text(unlocked ? "\(cls.name) · HP \(cls.maxHP) · Mana \(cls.maxMana)" : "Unlock at \(cls.unlockStars) stars")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textDim)
                }
                Spacer()
                if !unlocked {
                    LockGlyph(size: 18)
                } else if chosen {
                    ZStack {
                        Circle().fill(Theme.gold).frame(width: 24, height: 24)
                        CrossGlyph(size: 12, color: Theme.obsidian).rotationEffect(.degrees(45))
                    }
                } else {
                    Circle().stroke(Theme.goldDim, lineWidth: 1.5).frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 10).padding(.horizontal, 14)
            .runePanel(stroke: chosen ? 0.8 : (unlocked ? 0.4 : 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(chosen ? cls.element.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .opacity(unlocked ? 1 : 0.65)
    }

    private func bottomBar(w: CGFloat) -> some View {
        VStack(spacing: 0) {
            Button {
                if selected.count >= 1 {
                    store.save.lastParty = selected
                    store.persist()
                    goBattle = true
                }
            } label: {
                Text(selected.isEmpty ? "Select at least 1 mage" : "Begin Battle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GoldButtonStyle())
            .disabled(selected.isEmpty)
            .opacity(selected.isEmpty ? 0.5 : 1)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .frame(width: w)
        }
        .background(Theme.panel.edgesIgnoringSafeArea(.bottom))
    }
}
