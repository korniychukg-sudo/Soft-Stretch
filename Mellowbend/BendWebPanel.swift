import SwiftUI
import WebKit

final class MellowLinkResolver: NSObject, URLSessionTaskDelegate {
    private let referenceHost: String

    var landedURL: URL?
    var sawReferenceHost = false

    init(referenceHost: String) {
        self.referenceHost = referenceHost
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let hop = request.url?.absoluteString, hop.contains(referenceHost) {
            sawReferenceHost = true
        }
        landedURL = request.url

        completionHandler(request)
    }
}

struct BendWebPanel: UIViewRepresentable {
    let address: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }

        let panel = WKWebView(frame: .zero, configuration: config)
        panel.allowsBackForwardNavigationGestures = true
        panel.scrollView.bounces = true

        if let target = URL(string: address) {
            panel.load(URLRequest(url: target))
        }
        return panel
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
