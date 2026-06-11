import SwiftUI

struct MissionResultView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.presentationMode) var presentation
    let mission: MissionDef
    let won: Bool
    let stars: Int
    let essence: Int
    let bonusMet: Bool
    let onRetry: () -> Void

    @State private var appear = false

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [won ? Theme.indigo : Theme.obsidian, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 18) {
                    Spacer()
                    Text(won ? "Victory" : "Defeat")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(won ? Theme.gold : Theme.danger)
                    Text(mission.name)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(Theme.textDim)

                    if won {
                        HStack(spacing: 14) {
                            ForEach(0..<3) { i in
                                StarGlyph(size: 44, filled: i < stars)
                                    .scaleEffect(appear ? 1 : 0.5)
                                    .animation(.spring().delay(Double(i)*0.15), value: appear)
                            }
                        }
                        VStack(spacing: 8) {
                            resultLine("Clear", true)
                            resultLine(mission.bonus.label.replacingOccurrences(of: "Bonus: ", with: ""), bonusMet)
                            resultLine("No mage lost", stars >= 3)
                        }
                        .padding(16).runePanel().frame(maxWidth: 360)

                        HStack(spacing: 6) {
                            FlaskGlyph(size: 18, color: Theme.aqua)
                            Text("+\(essence) Essence")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(Theme.aqua)
                        }
                    } else {
                        Text("The ley-lines fade. Regroup and try again.")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Theme.textDim)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    Spacer()
                    VStack(spacing: 10) {
                        Button {
                            onRetry()
                        } label: {
                            Text(won ? "Continue" : "Retry").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GoldButtonStyle())
                    }
                    .frame(maxWidth: 360)
                    .padding(.horizontal, 24)
                    Spacer(minLength: 20)
                }
                .frame(width: w)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear { appear = true }
    }

    private func resultLine(_ text: String, _ done: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(done ? Theme.success : Theme.textDim, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                if done { StarShape().fill(Theme.success).frame(width: 12, height: 12) }
            }
            Text(text)
                .font(.system(size: 13, design: .serif))
                .foregroundColor(done ? Theme.text : Theme.textDim)
            Spacer()
        }
    }
}
