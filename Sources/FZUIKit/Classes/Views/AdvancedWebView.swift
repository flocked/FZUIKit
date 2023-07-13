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
        self.didFinishLoadingHandler?(self.currentRequest)

        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies({cookies in
            self.currentHTTPCookies = cookies
            if !cookies.isEmpty {
                self.cookiesHandler?(cookies)
            }
        })
        decisionHandler(.allow)
    }
}

extension AdvanceWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
}
