import SwiftUI

// 5-step skippable onboarding shown on first launch (fullScreenCover from RootView).
struct OnboardingView: View {
    let onDone: () -> Void
    @State private var step = 0

    private let lastStep = 4

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button { onDone() } label: {
                            Text("Skip")
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundColor(Theme.textDim)
                                .padding(.vertical, 8).padding(.horizontal, 14)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8).padding(.trailing, 10)

                    Spacer()

                    stepIllustration
                        .frame(height: 150)

                    VStack(spacing: 12) {
                        Text(stepTitle)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(Theme.gold)
                            .multilineTextAlignment(.center)
                        Text(stepBody)
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 26)

                    Spacer()

                    HStack(spacing: 8) {
                        ForEach(0...lastStep, id: \.self) { i in
                            Capsule()
                                .fill(i == step ? Theme.gold : Theme.goldDim.opacity(0.35))
                                .frame(width: i == step ? 22 : 8, height: 8)
                        }
                    }
                    .padding(.bottom, 18)

                    HStack(spacing: 12) {
                        if step > 0 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { step -= 1 }
                            } label: {
                                Text("Back").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GoldButtonStyle(filled: false))
                        }
                        Button {
                            if step >= lastStep {
                                onDone()
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) { step += 1 }
                            }
                        } label: {
                            Text(step >= lastStep ? "Begin" : "Next").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GoldButtonStyle())
                    }
                    .frame(maxWidth: 380)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .frame(width: w)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step content

    private var stepTitle: String {
        switch step {
        case 0: return "Welcome, Spellforger"
        case 1: return "Move and Cast"
        case 2: return "Elements React"
        case 3: return "Read the Field"
        default: return "Grow Your Coven"
        }
    }

    private var stepBody: String {
        switch step {
        case 0:
            return "Command a party of battle-mages across six war-torn regions. Victory belongs not to raw power, but to those who master the chemistry of the battlefield."
        case 1:
            return "Each round, every mage may move once and cast one spell. Tap a mage, tap a highlighted tile to move, then pick a spell and tap a gold tile to cast. End your turn when the party has acted."
        case 2:
            return "Spells place elements on tiles - and elements react. Fire races across oil. Lightning chains through water and stuns. Ice freezes pools into walls. Flame detonates poison clouds. Chain reactions win battles."
        case 3:
            return "Terrain matters: oil pools and vine beds are fuel, water conducts, lava reignites, chasms block, and ley-nodes restore mana. Bonus objectives earn extra stars - keep every mage alive for a third."
        default:
            return "Stars unlock new regions and seven more mage classes. Spend Essence in the Spell Lab to upgrade spells through three tiers, and fill your Grimoire by discovering every reaction."
        }
    }

    @ViewBuilder
    private var stepIllustration: some View {
        switch step {
        case 0:
            ZStack {
                Circle().stroke(Theme.gold.opacity(0.4), lineWidth: 2).frame(width: 140, height: 140)
                ElementDiamondIcon(size: 96)
            }
        case 1:
            HStack(spacing: 18) {
                demoTile(Theme.aqua.opacity(0.6), inner: AnyView(ChevronGlyph(size: 18)))
                demoTile(Theme.gold.opacity(0.8), inner: AnyView(ElementGlyph(kind: .fire, size: 30)))
                demoTile(Theme.ember.opacity(0.6), inner: AnyView(FlameShape().fill(Theme.ember).frame(width: 28, height: 28)))
            }
        case 2:
            HStack(spacing: 12) {
                ElementGlyph(kind: .fire, size: 40)
                Text("+")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(Theme.textDim)
                ElementGlyph(kind: .oil, size: 40)
                ChevronGlyph(size: 20)
                ZStack {
                    Circle().fill(Theme.ember.opacity(0.25)).frame(width: 70, height: 70)
                    FlameShape().fill(Theme.ember).frame(width: 40, height: 40)
                }
            }
        case 3:
            HStack(spacing: 14) {
                demoTile(Color(red: 0.12, green: 0.10, blue: 0.09), inner: AnyView(ElementGlyph(kind: .oil, size: 26)))
                demoTile(Color(red: 0.10, green: 0.26, blue: 0.36), inner: AnyView(ElementGlyph(kind: .water, size: 26)))
                demoTile(Color(red: 0.28, green: 0.16, blue: 0.40), inner: AnyView(RuneCircleGlyph(size: 32, color: Theme.gold)))
            }
        default:
            HStack(spacing: 18) {
                VStack(spacing: 6) {
                    StarGlyph(size: 38)
                    Text("Stars").font(.system(size: 11, design: .serif)).foregroundColor(Theme.textDim)
                }
                VStack(spacing: 6) {
                    FlaskGlyph(size: 38, color: Theme.aqua)
                    Text("Essence").font(.system(size: 11, design: .serif)).foregroundColor(Theme.textDim)
                }
                VStack(spacing: 6) {
                    BookGlyph(size: 38)
                    Text("Grimoire").font(.system(size: 11, design: .serif)).foregroundColor(Theme.textDim)
                }
            }
        }
    }

    private func demoTile(_ fill: Color, inner: AnyView) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(fill)
                .frame(width: 64, height: 64)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.gold.opacity(0.35), lineWidth: 1))
            inner
        }
    }
}
