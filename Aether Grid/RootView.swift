import SwiftUI

// Top-level navigation host. Uses a custom screen-stack via enum + NavigationView for battle.
enum AppScreen: Hashable {
    case menu
}

struct RootView: View {
    @EnvironmentObject var store: GameStore
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.indigoDeep, Theme.obsidian],
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            MainMenuView()
        }
        .onAppear {
            if !store.save.onboardingDone {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                store.save.onboardingDone = true
                store.persist()
                showOnboarding = false
            }
        }
    }
}
