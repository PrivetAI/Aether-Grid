import SwiftUI

@main
struct SpellforgeTacticsApp: App {
    @State private var spellforgeLinkReady: Bool? = nil
    @StateObject private var store = GameStore()

    private let spellforgeSourceLink = "https://example.com"
    private let spellforgeCheckDomain = "example"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = spellforgeLinkReady {
                    if ready {
                        SpellforgeWebPanel(urlString: spellforgeSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        RootView()
                            .environmentObject(store)
                    }
                } else {
                    SpellforgeLoadingScreen()
                        .onAppear { runSpellforgeCheck() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func runSpellforgeCheck() {
        guard let url = URL(string: spellforgeSourceLink) else {
            spellforgeLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = SpellforgeRedirectTracker(checkDomain: spellforgeCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.spellforgeFoundDomain {
                    spellforgeLinkReady = false; return
                }
                if let finalURL = tracker.spellforgeResolvedURL?.absoluteString,
                   finalURL.contains(self.spellforgeCheckDomain) {
                    spellforgeLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(self.spellforgeCheckDomain) {
                    spellforgeLinkReady = false; return
                }
                if error != nil {
                    spellforgeLinkReady = false; return
                }
                spellforgeLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if spellforgeLinkReady == nil { spellforgeLinkReady = false }
        }
    }
}

final class SpellforgeRedirectTracker: NSObject, URLSessionTaskDelegate {
    var spellforgeResolvedURL: URL?
    var spellforgeFoundDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            spellforgeFoundDomain = true
        }
        spellforgeResolvedURL = request.url
        completionHandler(request)
    }
}
