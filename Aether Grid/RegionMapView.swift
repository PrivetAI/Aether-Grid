import SwiftUI

struct RegionMapView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(Regions.all) { region in
                            regionCard(region)
                        }
                        Spacer(minLength: 20)
                    }
                    .frame(width: w)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
            }
        }
        .navigationBarTitle("Campaign", displayMode: .inline)
    }

    private func regionStars(_ r: Int) -> Int {
        MissionCatalog.missions(region: r).reduce(0) { $0 + store.stars(for: $1.id) }
    }

    @ViewBuilder
    private func regionCard(_ region: Region) -> some View {
        let unlocked = store.isRegionUnlocked(region.id)
        let earned = regionStars(region.id)
        let maxStars = MissionCatalog.missions(region: region.id).count * 3

        Group {
            if unlocked {
                NavigationLink(destination: MissionSelectView(region: region)) {
                    regionCardBody(region, unlocked: true, earned: earned, maxStars: maxStars)
                }
            } else {
                regionCardBody(region, unlocked: false, earned: earned, maxStars: maxStars)
            }
        }
        .padding(.horizontal, 16)
    }

    private func regionCardBody(_ region: Region, unlocked: Bool, earned: Int, maxStars: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(region.accent.opacity(unlocked ? 0.9 : 0.3))
                    .frame(width: 10, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(region.name)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundColor(unlocked ? Theme.text : Theme.textDim)
                    Text(region.subtitle)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(region.accent.opacity(unlocked ? 1 : 0.5))
                }
                Spacer()
                if unlocked {
                    HStack(spacing: 3) {
                        StarGlyph(size: 14)
                        Text("\(earned)/\(maxStars)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.text)
                    }
                } else {
                    HStack(spacing: 4) {
                        LockGlyph(size: 16)
                        Text("\(region.starsToUnlock)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textDim)
                        StarGlyph(size: 12)
                    }
                }
            }
            Text(region.lore)
                .font(.system(size: 12, design: .serif))
                .foregroundColor(Theme.textDim)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .runePanel(stroke: unlocked ? 0.4 : 0.2)
        .opacity(unlocked ? 1 : 0.75)
    }
}
