import SwiftUI

struct SpellforgeLoadingScreen: View {
    @State private var pulse = false
    @State private var spin = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.indigoDeep, Theme.obsidian],
                startPoint: .top, endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(Theme.gold.opacity(0.5), lineWidth: 3)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: spin)
                    ElementDiamondIcon(size: 96)
                        .scaleEffect(pulse ? 1.08 : 0.92)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                }
                Text("Spellforge Tactics")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(Theme.gold)
                Text("Weaving the ley-lines...")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Theme.textDim)
            }
        }
        .onAppear { pulse = true; spin = true }
    }
}
