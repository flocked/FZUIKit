//
//  WKWebView+Handlers.swift
//  
//
//  Created by Florian Zand on 17.04.25.
//

#if os(macOS) || os(iOS)
import FZSwiftUtils
import WebKit

extension WKWebView {
    /// The handlers of a webview.
    public struct Handlers {
        /// The handler that returns the current url request when the web view finishes loading a website.
        public var request: ((_ request: URLRequest?) -> Void)?
        /// The handler that returns the current url response when the web view finishes loading a website.
        public var response: ((_ response: URLResponse?) -> Void)?
        /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
        public var cookies: ((_ cookies: [HTTPCookie]) -> Void)?
        
        /// The handler that is called when content starts arriving for the main frame.
        public var didCommit: ((_ navigation: WKNavigation) -> Void)?
        /// The handler that is called when navigation finishes successfully.
        public var didFinish: ((_ navigation: WKNavigation) -> Void)?
        /// The handler that is called when navigation fails after it has started.
        public var didFail: ((_ navigation: WKNavigation, _ error: Error) -> Void)?
        
        /// The handler that is called when navigation starts loading.
        public var didStartProvisional: ((_ navigation: WKNavigation) -> Void)?
        /// The handler that is called when provisional navigation fails before committing.
        public var didFailProvisional: ((_ navigation: WKNavigation, _ error: Error) -> Void)?
        
        /// The handler that is called when a server redirect is received during provisional navigation.
        public var didReceiveServerRedirect: ((_ navigation: WKNavigation) -> Void)?
        /// The handler that is called when the web content process is terminated.
        public var webContentProcessDidTerminate: (() -> Void)?
        
        /// The handler that determines the navigation policy for a navigation response.
        public var responseDecidePolicy: ((_ response: WKNavigationResponse) -> WKNavigationResponsePolicy)?
        /// The handler that determines the navigation policy for a navigation action.
        public var actionDecidePolicy: ((_ action: WKNavigationAction, _ preferences: WKWebpagePreferences) -> WKNavigationActionPolicy)?
        
        /// The handler that is called when an authentication challenge is received.
        public var authenticationChallenge: ((_ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
        /// The handler that determines whether to allow a deprecated TLS connection.
        @available(macOS 11.0, iOS 14.0, *)
        public var shouldAllowDeprecatedTLS: ((_ challenge: URLAuthenticationChallenge) -> Bool)? {
            get { _shouldAllowDeprecatedTLS as? ((URLAuthenticationChallenge) -> Bool) }
            set { _shouldAllowDeprecatedTLS = newValue }
        }
        var _shouldAllowDeprecatedTLS: Any?
        
        /// The handler that is called when a navigation action becomes a download.
        @available(macOS 11.3, iOS 14.5, *)
        public var actionDidBecomeDownload: ((_ action: WKNavigationAction, _ download: WKDownload) -> Void)? {
            get { _actionDidBecomeDownload as? ((_ navigation: WKNavigationAction, _ download: WKDownload) -> Void) }
            set { _actionDidBecomeDownload = newValue }
        }
        var _actionDidBecomeDownload: Any?
        
        /// The handler that is called when a navigation response becomes a download.
        @available(macOS 11.3, iOS 14.5, *)
        public var responseDidBecomeDownload: ((_ response: WKNavigationResponse, _ download: WKDownload) -> Void)? {
            get { _responseDidBecomeDownload as? ((WKNavigationResponse, WKDownload) -> Void) }
            set { _responseDidBecomeDownload = newValue }
        }
        var _responseDidBecomeDownload: Any?
        
        /// The handler that decides whether to go to a back-forward list item, based on instant back usage.
        @available(macOS 15.4, iOS 18.4, *)
        public var shouldGoToBackForwardListItem: ((_ item: WKBackForwardListItem, _ willUseInstantBack: Bool) -> Bool)? {
            get { _shouldGoToBackForwardListItem as? ((WKBackForwardListItem, Bool) -> Bool) }
            set { _shouldGoToBackForwardListItem = newValue }
        }
        var _shouldGoToBackForwardListItem: Any?
        
        var needsDelegate: Bool {
            [request, response, cookies, didCommit, didFinish, didFail, didReceiveServerRedirect,  didStartProvisional, didFailProvisional, webContentProcessDidTerminate, responseDecidePolicy, actionDecidePolicy, authenticationChallenge, _shouldAllowDeprecatedTLS, _actionDidBecomeDownload, _responseDidBecomeDownload, _shouldGoToBackForwardListItem].contains { $0 != nil }
        }
    }
    
    /// The download handlers of a webview.
    @available(macOS 11.3, iOS 14.5, *)
    public struct DownloadHandlers {
        /// The handler that determines the final destination URL for the downloaded file.
        public var destination: ((_ download: WKDownload, _ response: URLResponse, _ suggestedFilename: String) -> (URL?))?
        
        public var maxRetries: ((_ download: WKDownload) -> (Int))?
        
        /// The handler that is called when a download has finished successfully.
        public var didFinish: ((_ download: WKDownload) -> ())?
        
        /// The handler that is called when a download fails with an optional resume data.
        public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?) -> ())?
        
        /// The handler that is called when a download receives an authentication challenge.
        public var challenge: ((_ download: WKDownload, _ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
        
        /// The handler that determines how to handle an HTTP redirection during download.
        public var willPerformHTTPRedirection: ((_ download: WKDownload, _ response: HTTPURLResponse, _ rewRequest: URLRequest) -> (WKDownload.RedirectPolicy))?
        
        /// The handler that determines whether a placeholder file should be created before downloading begins.
        @available(macOS 11.3, iOS 18.2, *)
        public var decidePlaceholderPolicy: ((_ download: WKDownload) -> (WKDownload.PlaceholderPolicy, URL?))? {
            get { _decidePlaceholderPolicy as? ((_ download: WKDownload) -> (WKDownload.PlaceholderPolicy, URL?)) }
            set { _decidePlaceholderPolicy = newValue }
        }
        var _decidePlaceholderPolicy: Any?
        
        /// The handler that is called when the final URL of  a download is received.
        @available(macOS 11.3, iOS 18.2, *)
        public var didReceiveFinalURL: ((_ download: WKDownload, _ finalURL: URL) -> ())? {
            get { _didReceiveFinalURL as? ((_ download: WKDownload, _ finalURL: URL) -> ()) }
            set { _didReceiveFinalURL = newValue }
        }
        var _didReceiveFinalURL: Any?

        
        /// The handler that is called when a placeholder file URL is received before the actual download starts.
        @available(macOS 11.3, iOS 18.2, *)
        public var didReceivePlaceholderURL: ((_ download: WKDownload, _ placeholderURL: URL, _ completionHandler: @escaping () -> Void) -> ())? {
            get { _didReceivePlaceholderURL as? ((_ download: WKDownload, _ placeholderURL: URL, _ completionHandler: @escaping () -> Void) -> ()) }
            set { _didReceivePlaceholderURL = newValue }
        }
        var _didReceivePlaceholderURL: Any?
        
        
        /// The handler that is called when the current downloads change.
        public var downloads: ((_ downloads: [WKDownload]) -> ())?
        
        var needsDelegate: Bool {
            destination != nil || didFinish != nil || didFail != nil || challenge != nil || willPerformHTTPRedirection != nil || _decidePlaceholderPolicy != nil || _didReceiveFinalURL != nil || _didReceivePlaceholderURL != nil
        }
    }
    
    /// The handlers of the webview.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            setupDelegate()
        }
    }
    
    /// The download handlers of the webview.
    @available(macOS 11.3, iOS 14.5, *)
    public var downloadHanders: DownloadHandlers {
        get { getAssociatedValue("handlers") ?? DownloadHandlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            setupDelegate()
        }
    }
    
    private func setupDelegate() {
        if #available(macOS 11.3, iOS 14.5, *) {
            if !(handlers.needsDelegate && downloadHanders.needsDelegate) {
                _delegate = nil
            } else if _delegate == nil {
                _delegate = Delegate(for: self)
            }
        } else if !handlers.needsDelegate {
            _delegate = nil
        } else if _delegate == nil {
            _delegate = Delegate(for: self)
        }
    }
    
    @available(macOS 11.3, iOS 14.5, *)
    private var downloads: [WKDownload] {
        get { downloadsQueue.sync { getAssociatedValue("downloads") ?? [] } }
        set {
            downloadsQueue.async(flags: .barrier) {
                guard Set(self.downloads) != Set(newValue) else { return }
                self.setAssociatedValue(newValue, key: "downloads")
                self.downloadHanders.downloads?(newValue)
            }
        }
    }
    
    private var downloadsQueue: DispatchQueue {
        getAssociatedValue("downloadsQueue", initialValue: DispatchQueue(label: "com.WKWebView.downloadsQueue", attributes: .concurrent))
    }
    
    /// The default location for downloads.
    @available(macOS 11.3, iOS 14.5, *)
    public var defaultDownloadLocation: URL {
        get {
            if #available(macOS 13.0, iOS 16.0, *) {
                return getAssociatedValue("downloadLocation") ?? .downloadsDirectory
            }
            return getAssociatedValue("downloadLocation") ?? FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        }
        set { setAssociatedValue(newValue, key: "downloadLocation") }
    }
    
    private var currentCookies: [HTTPCookie] {
        get { cookiesQueue.sync { getAssociatedValue("currentCookies") ?? [] } }
        set {
            cookiesQueue.async(flags: .barrier) {
                guard self.currentCookies.count != newValue.count || self.currentCookies.map({ $0.wrapper }) != newValue.map({ $0.wrapper }) else { return }
                self.setAssociatedValue(newValue, key: "currentCookies")
                self.handlers.cookies?(newValue)
            }
        }
    }
    
    private var cookiesQueue: DispatchQueue {
        getAssociatedValue("cookiesQueue", initialValue: DispatchQueue(label: "com.WKWebView.cookiesQueue", attributes: .concurrent))
    }
    
    var _delegate: Delegate? {
        get { getAssociatedValue("_delegate")}
        set { setAssociatedValue(newValue, key: "_delegate") }
    }
    
    class Delegate: NSObject, WKNavigationDelegate {
        let webview: WKWebView
        weak var delegate: (any WKNavigationDelegate)?
        var observation: KeyValueObservation?

        init(for webview: WKWebView) {
            self.webview = webview
            super.init()
            delegate = webview.navigationDelegate
            webview.navigationDelegate = self
            observation = webview.observeChanges(for: \.navigationDelegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.webview.navigationDelegate = self
            }
        }
        
        deinit {
            observation = nil
            webview.navigationDelegate = delegate
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webView.handlers.didStartProvisional?(navigation)
            delegate?.webView?(webView, didStartProvisionalNavigation: navigation)
        }

        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            webView.handlers.didReceiveServerRedirect?(navigation)
            delegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            webView.handlers.didCommit?(navigation)
            delegate?.webView?(webView, didCommit: navigation)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.handlers.didFinish?(navigation)
            delegate?.webView?(webView, didFinish: navigation)
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                webView.currentCookies = $0
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.handlers.didFail?(navigation, error)
            delegate?.webView?(webView, didFail: navigation, withError: error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.handlers.didFailProvisional?(navigation, error)
            delegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.handlers.webContentProcessDidTerminate?()
            delegate?.webViewWebContentProcessDidTerminate?(webView)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            if let delegate = webView.navigationDelegate,
               delegate.responds(to: NSSelectorFromString("webView:decidePolicyForNavigationAction:preferences:decisionHandler:")) {
                delegate.webView?(webView, decidePolicyFor: navigationAction, preferences: preferences, decisionHandler: decisionHandler)
                webView.handlers.request?(navigationAction.request)
            } else if let delegate = webView.navigationDelegate,
                      delegate.responds(to: NSSelectorFromString("webView:decidePolicyForNavigationAction:decisionHandler:")) {
                delegate.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: { decisionHandler($0, preferences) })
                webView.handlers.request?(navigationAction.request)
            } else {
                let policy = webView.handlers.actionDecidePolicy?(navigationAction, preferences) ?? .allow
                guard policy != .cancel else { return }
                webView.handlers.request?(navigationAction.request)
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
            if let delegate = webView.navigationDelegate,
               delegate.responds(to: NSSelectorFromString("webView:decidePolicyForNavigationResponse:decisionHandler:")) {
                delegate.webView?(webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler)
                webview.handlers.response?(navigationResponse.response)
            } else {
                let policy = webView.handlers.responseDecidePolicy?(navigationResponse) ?? .allow
                decisionHandler(policy)
                guard policy != .cancel else { return }
                webview.handlers.response?(navigationResponse.response)
            }
        }

        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if let delegate = delegate, delegate.responds(to: #selector(WKNavigationDelegate.webView(_:didReceive:completionHandler:))) {
                delegate.webView?(webView, didReceive: challenge, completionHandler: completionHandler)
            } else if let handler = webView.handlers.authenticationChallenge {
                let result = handler(challenge)
                completionHandler(result.0, result.1)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }

        @available(macOS 11.0, iOS 14.0, *)
        func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
            if let delegate = delegate, delegate.responds(to: #selector(WKNavigationDelegate.webView(_:authenticationChallenge:shouldAllowDeprecatedTLS:))) {
                delegate.webView?(webView, authenticationChallenge: challenge, shouldAllowDeprecatedTLS: decisionHandler)
            } else {
                decisionHandler(webView.handlers.shouldAllowDeprecatedTLS?(challenge) ?? false)
            }
        }
        
        @available(macOS 11.3, iOS 14.5, *)
        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            webView.handlers.actionDidBecomeDownload?(navigationAction, download)
            delegate?.webView?(webView, navigationAction: navigationAction, didBecome: download)
        }

        @available(macOS 11.3, iOS 14.5, *)
        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            webView.handlers.responseDidBecomeDownload?(navigationResponse, download)
            delegate?.webView?(webView, navigationResponse: navigationResponse, didBecome: download)
        }
        
        @available(macOS 15.4, iOS 18.4, *)
        func webView(_ webView: WKWebView, shouldGoTo backForwardListItem: WKBackForwardListItem, willUseInstantBack: Bool, completionHandler: @escaping (Bool) -> Void) {
            if let delegate = delegate, delegate.responds(to: #selector(WKNavigationDelegate.webView(_:shouldGoTo:willUseInstantBack:completionHandler:))) {
                delegate.webView?(webView, shouldGoTo: backForwardListItem, willUseInstantBack: willUseInstantBack, completionHandler: completionHandler)
            } else {
                completionHandler(webview.handlers.shouldGoToBackForwardListItem?(backForwardListItem, willUseInstantBack) ?? true)
            }
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension WKWebView.Delegate: WKDownloadDelegate {
    var downloadDelegate: WKDownloadDelegate? { delegate as? WKDownloadDelegate }
    
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping @MainActor @Sendable (URL?) -> Void) {
        download.retryAmount = webview.downloadHanders.maxRetries?(download) ?? download.retryAmount
        if let downloadDelegate = downloadDelegate, downloadDelegate.responds(to: #selector(WKDownloadDelegate.download(_:decideDestinationUsing:suggestedFilename:completionHandler:))) {
            downloadDelegate.download(download, decideDestinationUsing: response, suggestedFilename: suggestedFilename, completionHandler: completionHandler)
        } else if let destionation = webview.downloadHanders.destination?(download, response, suggestedFilename) {
                completionHandler(destionation)
            } else {
                completionHandler(suggestedFilename != "" ? webview.defaultDownloadLocation.appendingPathComponent(suggestedFilename) : nil)
        }
    }
    
    @available(macOS 11.3, iOS 18.2, *)
    func download(_ download: WKDownload, decidePlaceholderPolicy completionHandler: @escaping @MainActor (WKDownload.PlaceholderPolicy, URL?) -> Void) {
        if let downloadDelegate = downloadDelegate, downloadDelegate.responds(to: #selector(WKDownloadDelegate.download(_:decidePlaceholderPolicy:))) {
            downloadDelegate.download?(download, decidePlaceholderPolicy: completionHandler)
        } else if let policy = webview.downloadHanders.decidePlaceholderPolicy?(download) {
            completionHandler(policy.0, policy.1)
        } else {
            completionHandler(.enable, nil)
        }
    }
    
    func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let downloadDelegate = downloadDelegate, downloadDelegate.responds(to: #selector(WKDownloadDelegate.download(_:didReceive:completionHandler:))) {
            downloadDelegate.download?(download, didReceive: challenge, completionHandler: completionHandler)
        } else if let challenge = webview.downloadHanders.challenge?(download, challenge) {
            completionHandler(challenge.0, challenge.1)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    @available(macOS 11.3, iOS 18.2, *)
    func download(_ download: WKDownload, didReceivePlaceholderURL url: URL, completionHandler: @escaping @MainActor () -> Void) {
        webview.downloadHanders.didReceivePlaceholderURL?(download, url, completionHandler)
        downloadDelegate?.download?(download, didReceivePlaceholderURL: url, completionHandler: completionHandler)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        webview.downloadHanders.didFinish?(download)
        webview.downloads.remove(download)
        downloadDelegate?.downloadDidFinish?(download)
    }
        
    @available(macOS 11.3, iOS 18.2, *)
    func download(_ download: WKDownload, didReceiveFinalURL url: URL) {
        webview.downloadHanders.didReceiveFinalURL?(download, url)
        downloadDelegate?.download?(download, didReceiveFinalURL: url)
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        webview.downloadHanders.didFail?(download, error, resumeData)
        webview.downloads.remove(download)
        downloadDelegate?.download?(download, didFailWithError: error, resumeData: resumeData)
        if let resumeData = resumeData, download.retries < download.retryAmount, let request = download.originalRequest, let fileDestinationURL = download.fileDestinationURL {
            webview.resumeDownload(fromResumeData: resumeData, completionHandler: {
                newDownload in
                newDownload.retries = download.retries + 1
            })
        }
    }
    
    func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping @MainActor (WKDownload.RedirectPolicy) -> Void) {
        if let downloadDelegate = downloadDelegate, downloadDelegate.responds(to: #selector(WKDownloadDelegate.download(_:willPerformHTTPRedirection:newRequest:decisionHandler:))) {
            downloadDelegate.download?(download, willPerformHTTPRedirection: response, newRequest: request, decisionHandler: decisionHandler)
        } else {
            decisionHandler(webview.downloadHanders.willPerformHTTPRedirection?(download, response, request) ?? .allow)
        }
    }
}

fileprivate extension HTTPCookie {
    var wrapper: Wrapper { Wrapper(cookie: self) }
    
    struct Wrapper: Hashable, Comparable {
        let cookie: HTTPCookie

        func hash(into hasher: inout Hasher) {
            hasher.combine(cookie.name)
            hasher.combine(cookie.value)
            hasher.combine(cookie.domain)
            hasher.combine(cookie.path)
            hasher.combine(cookie.expiresDate)
            hasher.combine(cookie.isSecure)
            hasher.combine(cookie.isHTTPOnly)
            hasher.combine(cookie.comment)
            hasher.combine(cookie.commentURL)
            hasher.combine(cookie.version)
            hasher.combine(cookie.portList)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.cookie.name == rhs.cookie.name &&
                   lhs.cookie.value == rhs.cookie.value &&
                   lhs.cookie.domain == rhs.cookie.domain &&
                   lhs.cookie.path == rhs.cookie.path &&
                   lhs.cookie.expiresDate == rhs.cookie.expiresDate &&
                   lhs.cookie.isSecure == rhs.cookie.isSecure &&
                   lhs.cookie.isHTTPOnly == rhs.cookie.isHTTPOnly &&
                   lhs.cookie.comment == rhs.cookie.comment &&
                   lhs.cookie.commentURL == rhs.cookie.commentURL &&
                   lhs.cookie.version == rhs.cookie.version &&
                   lhs.cookie.portList == rhs.cookie.portList
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.cookie.name != rhs.cookie.name { return lhs.cookie.name < rhs.cookie.name }
            if lhs.cookie.domain != rhs.cookie.domain { return lhs.cookie.domain < rhs.cookie.domain }
            return lhs.cookie.path < rhs.cookie.path
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension WKDownload {
    /// The amount of retries when downloading via ``FZWebView`` fails.
    public var retryAmount: Int {
        get { getAssociatedValue("retryAmount") ?? 0 }
        set { setAssociatedValue(newValue, key: "retryAmount") }
    }
    
    var retries: Int {
        get { getAssociatedValue("retries") ?? 0 }
        set { setAssociatedValue(newValue, key: "retries") }
    }

    var fileDestinationURL: URL? {
        get { getAssociatedValue("fileDestinationURL") }
        set { setAssociatedValue(newValue, key: "fileDestinationURL") }
    }
}
#endif
