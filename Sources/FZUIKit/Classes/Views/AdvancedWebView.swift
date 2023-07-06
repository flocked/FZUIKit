//
//  AdvancedWebView.swift
//  
//
//  Created by Florian Zand on 23.02.23.
//

import WebKit
import FZSwiftUtils

/**
 An advanced WKWebView with properties for current url request & current cookies and handlers for didFinishLoading & cookies.

 */
public class AdvancedWebView: WKWebView {
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
    
    internal var _navigationDelegate: WKNavigationDelegate? = nil
    internal var _uiDelegate: WKUIDelegate? = nil
    
    public override var uiDelegate: WKUIDelegate? {
        get { self._uiDelegate }
        set { self._uiDelegate = newValue
            super.uiDelegate = self
        }
    }
    
    public override var navigationDelegate: WKNavigationDelegate? {
        get { self._navigationDelegate }
        set { self._navigationDelegate = newValue
            super.navigationDelegate = self
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.navigationDelegate = nil
        self.uiDelegate = nil
    }
}

extension AdvancedWebView: WKUIDelegate  {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.currentRequest = navigationAction.request
        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies({cookies in
            let cookies = cookies.filter({$0.domain == self.url?.host})
            self.currentHTTPCookies = cookies
            if !cookies.isEmpty {
                self.cookiesHandler?(cookies)
            }
        })
        decisionHandler(.allow)
    }
}

extension AdvancedWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishLoadingHandler?(self.currentRequest)
        self._navigationDelegate?.webView?(webView, didFinish: navigation)
    }
}
