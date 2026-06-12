import SwiftUI

struct MissionSelectView: View {
    @EnvironmentObject var store: GameStore
    let region: Region

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 12) {
                        Text(region.subtitle)
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(region.accent)
                            .padding(.top, 8)
                        ForEach(MissionCatalog.missions(region: region.id)) { m in
                            missionRow(m)
                        }
                        Spacer(minLength: 20)
                    }
                    .frame(width: w)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle(region.name, displayMode: .inline)
    }

    @ViewBuilder
    private func missionRow(_ m: MissionDef) -> some View {
        let unlocked = store.isMissionUnlocked(m)
        let stars = store.stars(for: m.id)
        let isBoss = m.indexInRegion == 8

        Group {
            if unlocked {
                NavigationLink(destination: LoadoutView(mission: m)) {
                    missionRowBody(m, unlocked: true, stars: stars, isBoss: isBoss)
                }
            } else {
                missionRowBody(m, unlocked: false, stars: stars, isBoss: isBoss)
            }
        }
        .padding(.horizontal, 16)
    }

    private func missionRowBody(_ m: MissionDef, unlocked: Bool, stars: Int, isBoss: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isBoss ? Theme.danger.opacity(0.25) : Theme.panelHi)
                    .frame(width: 38, height: 38)
                Text("\(m.displayNumber)")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(unlocked ? (isBoss ? Theme.danger : Theme.gold) : Theme.textDim)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(m.name)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(unlocked ? Theme.text : Theme.textDim)
                    .lineLimit(1)
                Text(m.objective.label)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textDim)
            }
            Spacer()
            if unlocked {
                HStack(spacing: 2) {
                    ForEach(0..<3) { i in
                        StarGlyph(size: 14, filled: i < stars)
                    }
                }
            } else {
                LockGlyph(size: 16)
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
        .runePanel(stroke: unlocked ? (isBoss ? 0.6 : 0.4) : 0.2)
        .opacity(unlocked ? 1 : 0.7)
    }
}
