import SwiftUI
import WebKit

/// 使用 ECharts (HTML+JS) 展示消费统计的饼图与柱状图，数据由 Swift 注入
struct EChartsWebView: View {
    let stats: DetailedStatisticsResponse?

    var body: some View {
        EChartsWebViewRepresentable(stats: stats)
            .frame(minHeight: 560)
    }
}

#if os(macOS)
private struct EChartsWebViewRepresentable: NSViewRepresentable {
    let stats: DetailedStatisticsResponse?

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        loadHTML(webView: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastInjected == stats?.categoryStats.map(\.total) {
            return
        }
        context.coordinator.lastInjected = stats?.categoryStats.map(\.total)
        injectAndRender(webView: webView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadHTML(webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "StatisticsCharts", withExtension: "html", subdirectory: "Resources")
            ?? Bundle.main.url(forResource: "StatisticsCharts", withExtension: "html") else {
            return
        }
        let dir = url.deletingLastPathComponent()
        webView.loadFileURL(url, allowingReadAccessTo: dir)
    }

    private func injectAndRender(webView: WKWebView) {
        let payload: [String: Any]
        if let s = stats {
            payload = [
                "totalAmount": s.totalAmount,
                "totalCount": s.totalCount,
                "categoryStats": s.categoryStats.map { ["category": $0.category, "total": $0.total, "count": $0.count] }
            ]
        } else {
            payload = ["categoryStats": [] as [[String: Any]]]
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        let script = "if (typeof renderCharts === 'function') { renderCharts(\(jsonString)); } else { window.__statsData__ = \(jsonString); }"
        webView.evaluateJavaScript(script) { _, _ in }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: EChartsWebViewRepresentable
        var lastInjected: [Double]?

        init(_ parent: EChartsWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.injectAndRender(webView: webView)
        }
    }
}
#else
private struct EChartsWebViewRepresentable: UIViewRepresentable {
    let stats: DetailedStatisticsResponse?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        loadHTML(webView: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastInjected == stats?.categoryStats.map(\.total) {
            return
        }
        context.coordinator.lastInjected = stats?.categoryStats.map(\.total)
        injectAndRender(webView: webView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadHTML(webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "StatisticsCharts", withExtension: "html", subdirectory: "Resources")
            ?? Bundle.main.url(forResource: "StatisticsCharts", withExtension: "html") else {
            return
        }
        let dir = url.deletingLastPathComponent()
        webView.loadFileURL(url, allowingReadAccessTo: dir)
    }

    private func injectAndRender(webView: WKWebView) {
        let payload: [String: Any]
        if let s = stats {
            payload = [
                "totalAmount": s.totalAmount,
                "totalCount": s.totalCount,
                "categoryStats": s.categoryStats.map { ["category": $0.category, "total": $0.total, "count": $0.count] }
            ]
        } else {
            payload = ["categoryStats": [] as [[String: Any]]]
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        let script = "if (typeof renderCharts === 'function') { renderCharts(\(jsonString)); } else { window.__statsData__ = \(jsonString); }"
        webView.evaluateJavaScript(script) { _, _ in }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: EChartsWebViewRepresentable
        var lastInjected: [Double]?

        init(_ parent: EChartsWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.injectAndRender(webView: webView)
        }
    }
}
#endif
