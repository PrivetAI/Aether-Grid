import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let w = min(geo.size.width, UIScreen.main.bounds.width)
                ZStack {
                    LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                                   startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack(spacing: 18) {
                            Spacer(minLength: 20)
                            ElementDiamondIcon(size: 88)
                            Text("Aether Grid")
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundColor(Theme.gold)
                                .multilineTextAlignment(.center)
                            Text("Command battle-mages. Master the chemistry of war.")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(Theme.textDim)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            statBar

                            VStack(spacing: 12) {
                                NavigationLink(destination: RegionMapView()) {
                                    menuRow("Campaign", SwordGlyph(size: 22))
                                }
                                NavigationLink(destination: SpellLabView()) {
                                    menuRow("Spell Lab", FlaskGlyph(size: 22))
                                }
                                NavigationLink(destination: GrimoireView()) {
                                    menuRow("Grimoire", BookGlyph(size: 22))
                                }
                                NavigationLink(destination: AchievementsView()) {
                                    menuRow("Achievements", TrophyGlyph(size: 22))
                                }
                                NavigationLink(destination: StatisticsView()) {
                                    menuRow("Statistics", ChartGlyph(size: 22))
                                }
                                NavigationLink(destination: SettingsView()) {
                                    menuRow("Settings", GearGlyph(size: 22))
                                }
                            }
                            .frame(maxWidth: 420)
                            .padding(.horizontal, 20)
                            Spacer(minLength: 30)
                        }
                        .frame(width: w)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var statBar: some View {
        HStack(spacing: 22) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    StarGlyph(size: 16)
                    Text("\(store.save.totalStars)")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Theme.text)
                }
                Text("Stars").font(.system(size: 11)).foregroundColor(Theme.textDim)
            }
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    FlaskGlyph(size: 16, color: Theme.aqua)
                    Text("\(store.save.essence)")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Theme.text)
                }
                Text("Essence").font(.system(size: 11)).foregroundColor(Theme.textDim)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 24)
        .runePanel()
    }

    private func menuRow(_ title: String, _ icon: some View) -> some View {
        HStack(spacing: 14) {
            icon.frame(width: 30)
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Theme.text)
            Spacer()
            ChevronGlyph(size: 14)
        }
        .padding(.vertical, 16).padding(.horizontal, 18)
        .runePanel()
    }
}
