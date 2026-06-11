import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 12) {
                        statGrid(w: w)
                        progressCard(w: w)
                        Spacer(minLength: 20)
                    }
                    .frame(width: w)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
            }
        }
        .navigationBarTitle("Statistics", displayMode: .inline)
    }

    private func statGrid(w: CGFloat) -> some View {
        let s = store.save
        let items: [(String, String)] = [
            ("Missions Won", "\(s.missionsWon)"),
            ("Total Stars", "\(s.totalStars)"),
            ("Essence", "\(s.essence)"),
            ("Reactions Triggered", "\(s.reactionsTriggered)"),
            ("Enemies Defeated", "\(s.enemiesDefeated)"),
            ("Spells Cast", "\(s.spellsCast)"),
            ("Bosses Defeated", "\(s.bossesDefeated)/\(BossCatalog.all.count)"),
            ("Turns Played", "\(s.totalTurnsPlayed)"),
        ]
        return VStack(spacing: 10) {
            ForEach(0..<((items.count+1)/2), id: \.self) { row in
                HStack(spacing: 10) {
                    statTile(items[row*2])
                    if row*2+1 < items.count { statTile(items[row*2+1]) } else { Spacer() }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func statTile(_ item: (String, String)) -> some View {
        VStack(spacing: 4) {
            Text(item.1)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(Theme.gold)
            Text(item.0)
                .font(.system(size: 11))
                .foregroundColor(Theme.textDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .runePanel()
    }

    private func progressCard(w: CGFloat) -> some View {
        let totalMissions = MissionCatalog.count
        let cleared = MissionCatalog.all.filter { store.stars(for: $0.id) >= 1 }.count
        let totalStars = totalMissions * 3
        let pct = totalStars > 0 ? Double(store.save.totalStars) / Double(totalStars) : 0
        return VStack(alignment: .leading, spacing: 10) {
            Text("Campaign Progress")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Theme.text)
            HStack {
                Text("Missions cleared")
                    .font(.system(size: 12)).foregroundColor(Theme.textDim)
                Spacer()
                Text("\(cleared)/\(totalMissions)")
                    .font(.system(size: 12, weight: .bold)).foregroundColor(Theme.text)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.panelHi)
                    Capsule().fill(Theme.gold).frame(width: g.size.width * CGFloat(pct))
                }
            }
            .frame(height: 12)
            Text("\(store.save.totalStars) of \(totalStars) stars earned")
                .font(.system(size: 11)).foregroundColor(Theme.textDim)
        }
        .padding(16)
        .runePanel()
        .padding(.horizontal, 16)
    }
}
