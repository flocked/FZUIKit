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
    
    @available(macOS 11.3, *)
    /// The handlers for downloading files.
    public struct DownloadHandlers {
        /// The handler that determines whether a url request should be downloaded.
        public var shouldDownload: ((URLRequest)->(Bool))? = nil
        /// The handler that determines the file location of a finished download.
        public var downloadLocation: ((_ suggestedFilename: String)->(URL?))? = nil
        /// The handler that gets called whenever a download finishes.
        public var didFinish: (()->())? = nil
        /// The handler that gets called whenever a download failed.
        public var didFail: ((_ error: Error, _ resumeData: Data?)->())? = nil
    }
    
    @available(macOS 11.3, *)
    /// The handlers for downloading files.
    public var downloadHandlers: DownloadHandlers {
        get {
            if _downloadHandlers == nil {
                _downloadHandlers = DownloadHandlers()
            }
            return _downloadHandlers as! DownloadHandlers
        }
        set {  _downloadHandlers = newValue }
    }
    private var _downloadHandlers: Any? = nil

    /// The current url request.
    public var currentRequest: URLRequest? = nil
    
    /// All HTTP cookies of the current url request.
    public var currentHTTPCookies: [HTTPCookie] = []
    
    public init(frame: CGRect) {
        super.init(frame: frame, configuration: .init())
        self.navigationDelegate = self
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.navigationDelegate = self
    }
    
    internal var isIntialLoadingRequest = false
    public override func load(_ request: URLRequest) -> WKNavigation? {
        self.isIntialLoadingRequest = true
        self.currentRequest = nil
        self.currentHTTPCookies.removeAll()
        self.isIntialLoadingRequest = false
        return super.load(request)
    }
}


extension AdvanceWebView: WKNavigationDelegate  {
    @available(macOS 11.3, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    @available(macOS 11.3, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if self.currentRequest != navigationAction.request {
            self.didFinishLoadingHandler?(navigationAction.request)
        }
        self.currentRequest = navigationAction.request

        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies({cookies in
            guard var domain = self.currentRequest?.url?.host else { return }
            var components = domain.components(separatedBy: ".")
            if components.count > 2 {
                domain = [components.removeLast(), components.removeLast()].reversed().joined(separator: ".")
            }
            let cookies = cookies.filter({$0.domain.contains(domain)})
            if !cookies.isEmpty, cookies != self.currentHTTPCookies {
                self.cookiesHandler?(cookies)
            }
            self.currentHTTPCookies = cookies
        })
       
        if #available(macOS 11.3, *) {
            let shouldDownload = downloadHandlers.shouldDownload?(navigationAction.request) ?? false
            decisionHandler(shouldDownload ? .download : .allow)
        } else {
            decisionHandler(.allow)
        }
    }
}

@available(macOS 11.3, *)
extension AdvanceWebView: WKDownloadDelegate {
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        Swift.print("[AdvanceWebView] download suggestedFilename", suggestedFilename)
        let url = self.downloadHandlers.downloadLocation?(suggestedFilename) ?? nil
        completionHandler(url)
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        Swift.print("[AdvanceWebView] download didFinish")
        self.downloadHandlers.didFinish?()
    }
    
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        Swift.print("[AdvanceWebView] download failed", error)
        self.downloadHandlers.didFail?(error, resumeData)
    }
    
    public func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        Swift.print("[AdvanceWebView] download willPerformHTTPRedirection", response, response.url ?? "")
        decisionHandler(.allow)
    }
    
}
