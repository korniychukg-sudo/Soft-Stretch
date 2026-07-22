import SwiftUI
import WebKit

// Fullscreen web panel — also reused as the Privacy sheet from More.
struct StretchWebPanel: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .black
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // Must stay empty — reloading here would loop on SwiftUI re-renders.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
