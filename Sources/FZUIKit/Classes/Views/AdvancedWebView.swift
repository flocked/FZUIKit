//
//  AdvancedWebView.swift
//  
//
//  Created by Florian Zand on 23.02.23.
//

import WebKit
import FZSwiftUtils

/**
 A WKWebView with properties for current url request & current cookies and handlers for didFinishLoading & cookies.

 */
public class AdvanceWebView: WKWebView {
    /// The handler that returns the current url request when the web view finishes loading a website.
    public var didFinishLoadingHandler: ((URLRequest?)->())? = nil
    
    /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
    public var cookiesHandler: (([HTTPCookie]) -> ())? = nil
    
    /// The current url request.
    public var currentRequest: URLRequest? = nil
    
    /// All HTTP cookies of the current url request.
    public var currentHTTPCookies: [HTTPCookie] = []
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
        self.uiDelegate = self
    }
    
    internal var isIntialLoadingRequest = false
    public override func load(_ request: URLRequest) -> WKNavigation? {
        self.isIntialLoadingRequest = true
        self.currentRequest = nil
        self.currentHTTPCookies.removeAll()
        self.isIntialLoadingRequest = false
        return super.load(request)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.navigationDelegate = nil
        self.uiDelegate = nil
    }
}

extension AdvanceWebView: WKUIDelegate  {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.currentRequest = navigationAction.request
        debugPrint("webView currentRequest", self, self.currentRequest ?? "")
        self.didFinishLoadingHandler?(navigationAction.request)

        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies({cookies in
            
            guard var domain = self.currentRequest?.url?.host else { return }
            var components = domain.components(separatedBy: ".")
            if components.count > 2 {
                domain = [components.removeLast(), components.removeLast()].reversed().joined(separator: ".")
            }
            let cookies = cookies.filter({$0.domain == domain})
            self.currentHTTPCookies = cookies

            if !cookies.isEmpty {
                debugPrint("webView currentHTTPCookies", self, self.currentHTTPCookies)
                self.cookiesHandler?(cookies)
            }
        })
        decisionHandler(.allow)
    }
}

extension AdvanceWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Swift.debugPrint("webView.didFinishNavigation", self, navigation)
    }
}
