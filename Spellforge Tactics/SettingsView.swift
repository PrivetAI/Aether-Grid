import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: GameStore
    @State private var showResetAlert = false
    @State private var showPrivacy = false

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            ZStack {
                LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 14) {
                        toggleRow("Sound", isOn: Binding(
                            get: { store.save.soundEnabled },
                            set: { store.save.soundEnabled = $0; store.persist() }))
                        toggleRow("Haptics", isOn: Binding(
                            get: { store.save.hapticsEnabled },
                            set: { store.save.hapticsEnabled = $0; store.persist() }))

                        Button { showPrivacy = true } label: {
                            HStack {
                                BookGlyph(size: 18)
                                Text("Privacy Policy")
                                    .font(.system(size: 15, weight: .semibold, design: .serif))
                                    .foregroundColor(Theme.text)
                                Spacer()
                                ChevronGlyph(size: 14)
                            }
                            .padding(14).runePanel()
                        }
                        .buttonStyle(.plain)

                        Button { showResetAlert = true } label: {
                            HStack {
                                CrossGlyph(size: 18, color: Theme.danger)
                                Text("Reset Progress")
                                    .font(.system(size: 15, weight: .semibold, design: .serif))
                                    .foregroundColor(Theme.danger)
                                Spacer()
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.panel))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.danger.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 4) {
                            ElementDiamondIcon(size: 48)
                            Text("Spellforge Tactics")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(Theme.gold)
                            Text("Version 1.0")
                                .font(.system(size: 11)).foregroundColor(Theme.textDim)
                        }
                        .padding(.top, 20)
                        Spacer(minLength: 20)
                    }
                    .frame(width: w)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .alert(isPresented: $showResetAlert) {
            Alert(title: Text("Reset Progress?"),
                  message: Text("This permanently erases all stars, essence, unlocks, and statistics. This cannot be undone."),
                  primaryButton: .destructive(Text("Reset")) {
                    store.resetProgress()
                  },
                  secondaryButton: .cancel())
        }
        .sheet(isPresented: $showPrivacy) {
            SpellforgeWebPanel(urlString: "https://example.com")
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.black.ignoresSafeArea())
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(Theme.text)
            Spacer()
            // Custom toggle (no system styling reliance for theme independence)
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
                    Capsule().fill(isOn.wrappedValue ? Theme.gold : Theme.panelHi)
                        .frame(width: 48, height: 28)
                    Circle().fill(Theme.obsidian).frame(width: 22, height: 22).padding(3)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(14).runePanel()
    }
}
