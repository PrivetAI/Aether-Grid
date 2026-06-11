import SwiftUI

struct GrimoireView: View {
    @EnvironmentObject var store: GameStore
    @State private var section: GrimoireSection = .elements

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    sectionPicker
                    ScrollView {
                        VStack(spacing: 10) {
                            content
                            Spacer(minLength: 20)
                        }
                        .frame(width: w)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarTitle("Grimoire", displayMode: .inline)
    }

    private var sectionPicker: some View {
        HStack(spacing: 6) {
            ForEach(GrimoireSection.allCases) { s in
                Button {
                    section = s
                } label: {
                    Text(s.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(section == s ? Theme.obsidian : Theme.textDim)
                        .padding(.vertical, 7).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(section == s ? Theme.gold : Theme.panel))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Theme.panel.opacity(0.5))
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .elements:
            ForEach(GrimoireBuilder.elements(store.save)) { e in
                codexCard(seen: e.seen, title: e.kind.displayName, lore: e.kind.lore) {
                    ElementGlyph(kind: e.kind, size: 28)
                }
            }
        case .reactions:
            ForEach(GrimoireBuilder.reactions(store.save)) { r in
                codexCard(seen: r.seen,
                          title: "\(r.applied.displayName) + \(r.existing.displayName)",
                          lore: r.lore) {
                    HStack(spacing: 2) {
                        ElementGlyph(kind: r.applied, size: 20)
                        Text("+").foregroundColor(Theme.textDim)
                        ElementGlyph(kind: r.existing, size: 20)
                    }
                }
            }
        case .enemies:
            ForEach(GrimoireBuilder.enemies(store.save)) { e in
                codexCard(seen: e.seen, title: e.def.name, lore: enemyLore(e.def)) {
                    EnemyGlyph(behavior: e.def.behavior, size: 26)
                }
            }
        case .spells:
            ForEach(GrimoireBuilder.spells(store.save)) { s in
                codexCard(seen: s.seen, title: s.def.name, lore: s.def.lore) {
                    ElementGlyph(kind: s.def.element, size: 26)
                }
            }
        }
    }

    private func enemyLore(_ d: EnemyDef) -> String {
        var s = d.lore
        if !d.weaknesses.isEmpty {
            s += " Weak to: " + d.weaknesses.map { $0.displayName }.joined(separator: ", ") + "."
        }
        if !d.immunities.isEmpty {
            s += " Immune to: " + d.immunities.map { $0.displayName }.joined(separator: ", ") + "."
        }
        return s
    }

    private func codexCard<Icon: View>(seen: Bool, title: String, lore: String, @ViewBuilder icon: () -> Icon) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Theme.panelHi).frame(width: 46, height: 46)
                if seen { icon() } else { Text("?").font(.system(size: 22, weight: .bold)).foregroundColor(Theme.textDim) }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(seen ? title : "Undiscovered")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(seen ? Theme.text : Theme.textDim)
                Text(seen ? lore : "Encounter this in battle to reveal its entry.")
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(Theme.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .runePanel(stroke: seen ? 0.4 : 0.15)
        .padding(.horizontal, 16)
        .opacity(seen ? 1 : 0.7)
    }
}
