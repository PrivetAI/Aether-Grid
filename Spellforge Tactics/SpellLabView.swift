import SwiftUI

struct SpellLabView: View {
    @EnvironmentObject var store: GameStore
    @State private var selectedClass: String = MageRoster.all.first!.id

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    essenceHeader
                    classPicker
                    ScrollView {
                        VStack(spacing: 12) {
                            if let cls = MageRoster.byId(selectedClass) {
                                ForEach(cls.spellIDs, id: \.self) { sid in
                                    if let base = SpellCatalog.spell(sid) {
                                        spellCard(base)
                                    }
                                }
                            }
                            Spacer(minLength: 20)
                        }
                        .frame(width: w)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarTitle("Spell Lab", displayMode: .inline)
    }

    private var essenceHeader: some View {
        HStack(spacing: 6) {
            FlaskGlyph(size: 18, color: Theme.aqua)
            Text("\(store.save.essence) Essence")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Theme.aqua)
            Spacer()
            Text("Spend Essence to upgrade spells")
                .font(.system(size: 11))
                .foregroundColor(Theme.textDim)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Theme.panel.opacity(0.6))
    }

    private var classPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MageRoster.all) { cls in
                    let unlocked = store.isClassUnlocked(cls)
                    Button {
                        if unlocked { selectedClass = cls.id }
                    } label: {
                        VStack(spacing: 3) {
                            ElementGlyph(kind: cls.element, size: 20)
                            Text(cls.title)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(selectedClass == cls.id ? Theme.gold : Theme.textDim)
                        }
                        .padding(.vertical, 8).padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedClass == cls.id ? cls.element.color.opacity(0.2) : Theme.panel)
                        )
                        .opacity(unlocked ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
    }

    private func spellCard(_ base: SpellDef) -> some View {
        let tier = store.spellTier(base.id)
        let resolved = store.upgradedSpell(base)
        let cost = store.upgradeCost(base.id)
        let canUp = store.canUpgrade(base.id)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ElementGlyph(kind: base.element, size: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(base.name)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Theme.text)
                    Text("Range \(resolved.range) · AoE \(aoeLabel(resolved.aoe)) · Dmg \(resolved.damage) · Mana \(base.manaCost)")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textDim)
                }
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<3) { i in
                        Circle().fill(i < tier ? Theme.gold : Theme.goldDim.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            Text(base.lore)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(Theme.textDim)
                .fixedSize(horizontal: false, vertical: true)

            if tier < 3 {
                let next = [base.tier1, base.tier2, base.tier3][tier]
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Next: \(next.title)")
                            .font(.system(size: 11, weight: .semibold)).foregroundColor(Theme.gold)
                        Text(next.desc).font(.system(size: 10)).foregroundColor(Theme.textDim)
                    }
                    Spacer()
                    Button {
                        store.upgrade(base.id)
                    } label: {
                        HStack(spacing: 3) {
                            FlaskGlyph(size: 12, color: Theme.obsidian)
                            Text("\(cost)").font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Theme.obsidian)
                        .padding(.vertical, 7).padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(canUp ? Theme.gold : Theme.goldDim.opacity(0.4)))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canUp)
                }
            } else {
                Text("Fully mastered")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.success)
            }
        }
        .padding(14)
        .runePanel()
        .padding(.horizontal, 16)
    }

    private func aoeLabel(_ a: Int) -> String {
        switch a { case 0: return "Single"; case 1: return "Plus"; default: return "3x3" }
    }
}
