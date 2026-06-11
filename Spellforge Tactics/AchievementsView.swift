import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 10) {
                        header(w: w)
                        ForEach(AchievementCatalog.all) { a in
                            row(a)
                        }
                        Spacer(minLength: 20)
                    }
                    .frame(width: w)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarTitle("Achievements", displayMode: .inline)
    }

    private func header(w: CGFloat) -> some View {
        let total = AchievementCatalog.all.count
        let done = store.save.unlockedAchievements.count
        return HStack {
            TrophyGlyph(size: 26)
            Text("\(done) / \(total) unlocked")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Theme.gold)
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func row(_ a: AchievementDef) -> some View {
        let unlocked = store.isAchievementUnlocked(a.id)
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(unlocked ? Theme.gold.opacity(0.2) : Theme.panelHi).frame(width: 42, height: 42)
                if unlocked { TrophyGlyph(size: 22) } else { LockGlyph(size: 18) }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(a.name)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(unlocked ? Theme.text : Theme.textDim)
                Text(a.desc)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(Theme.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .runePanel(stroke: unlocked ? 0.5 : 0.15)
        .padding(.horizontal, 16)
        .opacity(unlocked ? 1 : 0.7)
    }
}
