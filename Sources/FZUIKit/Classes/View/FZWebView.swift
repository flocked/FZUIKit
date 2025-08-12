//
//  FZWebView.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if compiler(>=5.5)
#if os(macOS) || os(iOS)
import FZSwiftUtils
import WebKit

@available(macOS 11.3, iOS 14.5, *)
extension WKWebView {
    
    /// The handlers of a web view.
    public struct Handlers {
        
        /// The handler that decides the policy for a navigation action.
        public var navigationActionPolicy: ((_ action: WKNavigationAction) -> WKNavigationActionPolicy)?
        
        /// The handler that decides the policy for a navigation response.
        public var navigationResponsePolicy: ((_ response: WKNavigationResponse) -> WKNavigationResponsePolicy)?
        
        /// The handler called when provisional navigation starts.
        public var didStartProvisionalNavigation: ((_ navigation: WKNavigation) -> Void)?
        
        /// The handler called when the web view receives a server redirect during provisional navigation.
        public var didReceiveServerRedirectForProvisionalNavigation: ((_ navigation: WKNavigation) -> Void)?
        
        /// The handler called when navigation finishes successfully.
        public var didFinishNavigation: ((_ navigation: WKNavigation) -> Void)?
        
        /// The handler called when navigation commits content.
        public var didCommitNavigation: ((_ navigation: WKNavigation) -> Void)?
        
        /// The handler that handles authentication challenges.
        public var authenticate: ((_ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
        
        /// The handler that decides whether to allow deprecated TLS for an authentication challenge.
        public var shouldAllowDeprecatedTLS: ((_ challenge: URLAuthenticationChallenge) -> Bool)?
        
        /// The handler called when navigation fails with an error.
        public var didFailNavigation: ((_ navigation: WKNavigation, _ error: Error) -> Void)?
        
        /// The handler called when provisional navigation fails with an error.
        public var didFailProvisionalNavigation: ((_ navigation: WKNavigation, _ error: Error) -> Void)?
        
        /// The handler called when the web content process terminates.
        public var webContentProcessDidTerminate: (() -> Void)?
        
        /// The handler called when a navigation response becomes a download.
        public var navigationResponseDidBecomeDownload: ((_ response: WKNavigationResponse, _ download: WKDownload) -> Void)?
        
        /// The handler called when a navigation action becomes a download.
        public var navigationActionDidBecomeDownload: ((_ action: WKNavigationAction, _ download: WKDownload) -> Void)?
        
        /// The handler deciding whether to navigate to a back-forward list item.
        public var shouldGoTo: ((_ item: WKBackForwardListItem, _ willUseInstantBack: Bool) -> Bool)?
        
        var needsDelegate: Bool {
            navigationActionPolicy != nil || navigationResponsePolicy != nil || didStartProvisionalNavigation != nil || didReceiveServerRedirectForProvisionalNavigation != nil || didFinishNavigation != nil || didCommitNavigation != nil || authenticate != nil || shouldAllowDeprecatedTLS != nil || didFailNavigation != nil || didFailProvisionalNavigation != nil || webContentProcessDidTerminate != nil || navigationResponseDidBecomeDownload != nil || navigationActionDidBecomeDownload != nil || shouldGoTo != nil
        }
    }

    /// The handlers for managing downloads.
    public struct DownloadHandlers {
        
        /// The handler that decides whether a URL request should be downloaded.
        public var shouldDownload: ((_ response: URLResponse) -> Bool)?
        
        /// The handler that provides the destination URL for a finished download.
        public var downloadLocation: ((_ download: WKDownload, _ response: URLResponse, _ suggestedFilename: String) -> URL?)?
        
        /// The handler that handles authentication challenges during a download.
        public var authenticate: ((_ download: WKDownload, _ challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?))?
        
        /// The handler called when a download starts.
        public var didStart: ((_ download: WKDownload) -> Void)?
        
        /// The handler called when a download finishes.
        public var didFinish: ((_ download: WKDownload) -> Void)?
        
        /// The handler called when a download fails and determines whether to retry.
        public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?) -> ())?
        
        /// The handler that provides the placeholder policy for a download.
        @available(macOS 11.3, iOS 18.2, *)
        public var placeholderPolicy: ((_ download: WKDownload) -> (policy: WKDownload.PlaceholderPolicy, destination: URL?))? {
            get { _placeholderPolicy as? ((WKDownload) -> (WKDownload.PlaceholderPolicy, URL?)) }
            set { _placeholderPolicy = newValue }
        }
        
        var _placeholderPolicy: Any?
        
        /// The handler called when a placeholder URL is received during download.
        @available(macOS 11.3, iOS 18.2, *)
        public var didReceivePlaceholderURL: ((_ download: WKDownload, _ url: URL) -> Void)? {
            get { _didReceivePlaceholderURL as? ((WKDownload, URL) -> ()) }
            set { _didReceivePlaceholderURL = newValue }
        }
        
        var _didReceivePlaceholderURL: Any?
        
        /// The handler called when the final URL is received during download.
        @available(macOS 11.3, iOS 18.2, *)
        public var didReceiveFinalURL: ((_ download: WKDownload, _ url: URL) -> Void)? {
            get { _didReceiveFinalURL as? ((WKDownload, URL) -> ()) }
            set { _didReceiveFinalURL = newValue }
        }
        
        var _didReceiveFinalURL: Any?

        
        /// The handler deciding whether to follow an HTTP redirection during download.
        public var shouldPerformHTTPRedirection: ((_ download: WKDownload, _ response: HTTPURLResponse, _ newRequest: URLRequest) -> WKDownload.RedirectPolicy)?
        
        var needsDelegate: Bool {
            shouldDownload != nil || downloadLocation != nil || authenticate != nil || didStart != nil || didFail != nil || didFinish != nil || shouldPerformHTTPRedirection != nil || _placeholderPolicy != nil || _didReceiveFinalURL != nil || _didReceivePlaceholderURL != nil
        }
    }

    /// The download strategy.
    public enum DownloadStrategy: Int, Hashable {
        /// Deletes an existing file at the suggested download location.
        case delete
        /// Doesn't download a file if it exists at the suggested download location.
        case ignore
        /// Resume downloading a file if it exists at the suggested download location.
        case resume
    }
    
    /**
     The default download strategy.
     
     Defaults to `resume`.
     */
    public var defaultDownloadStrategy: DownloadStrategy {
        get { getAssociatedValue("defaultDownloadStrategy") ?? .resume }
        set { setAssociatedValue(newValue, key: "defaultDownloadStrategy") }
    }
    
    /**
     The default retry amount of downloads that fail.
     
     Defaults to `0`.
     */
    public var defaultDownloadRetryAmount: Int {
        get { getAssociatedValue("defaultDownloadRetryAmount") ?? 0 }
        set { setAssociatedValue(newValue.clamped(min: 0), key: "defaultDownloadRetryAmount") }
    }
    
    /// The handlers of the web view.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            setupHandlerDelegate()
        }
    }

    /// The handlers for downloading files.
    public var downloadHandlers: DownloadHandlers {
        get { getAssociatedValue("downloadHandlers") ?? DownloadHandlers() }
        set {
            setAssociatedValue(newValue, key: "downloadHandlers")
            setupHandlerDelegate()
        }
    }
    
    /*
     public var downloads: [WKDownload] {
         _downloads.synchronized
     }
    
     public func removeFinishedDownloads(includingCancelled: Bool = false) {
         if includingCancelled {
             _downloads.removeAll(where: { $0.progress.isFinished || $0.progress.isCancelled})
         } else {
             _downloads.removeAll(where: { $0.progress.isFinished && !$0.progress.isCancelled})
         }
     }
    
     var _downloads: SynchronizedArray<WKDownload> {
         get { getAssociatedValue("downloads", initialValue: []) }
         set { setAssociatedValue(newValue, key: "downloads") }
     }
      */
    
    /**
     The default download directory for downloads where no download location is provided to downloadHandler's ``WebKit/WKWebView/DownloadHandlers-swift.struct/downloadLocation``.
     
     Defaults to the user's download directory.
     */
    public var defaultDownloadDirectory: URL? {
        get { getAssociatedValue("defaultDownloadDirectory", initialValue: {
            if #available(macOS 13.0, iOS 16.0, *) {
                return .downloadsDirectory
            } else {
                return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            }
        })
        }
        set { setAssociatedValue(newValue, key: "defaultDownloadDirectory") }
    }
    
    private func setupHandlerDelegate() {
        if !handlers.needsDelegate && !downloadHandlers.needsDelegate {
            handlerDelegate?.delegateObservation = nil
            navigationDelegate = handlerDelegate?.delegate
            handlerDelegate = nil
        } else if handlerDelegate == nil {
            handlerDelegate = .init(for: self)
        }
    }
    
    private var handlerDelegate: HandlerDelegate? {
        get { getAssociatedValue("handlerDelegate") }
        set { setAssociatedValue(newValue, key: "handlerDelegate") }
    }
    
    private class HandlerDelegate: NSObject, WKNavigationDelegate, WKDownloadDelegate {
        weak var webView: WKWebView?
        weak var delegate: WKNavigationDelegate?
        var delegateObservation: KeyValueObservation?
        
        init(for webView: WKWebView) {
            self.webView = webView
            super.init()
            delegate = webView.navigationDelegate
            webView.navigationDelegate = self
            delegateObservation = webView.observeChanges(for: \.navigationDelegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.webView?.navigationDelegate = self
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
            decisionHandler(webView.handlers.navigationActionPolicy?(navigationAction) ?? .allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
            if webView.downloadHandlers.shouldDownload?(navigationResponse.response) == true {
                decisionHandler(.download)
            } else {
                decisionHandler(webView.handlers.navigationResponsePolicy?(navigationResponse) ?? .allow)
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webView.handlers.didStartProvisionalNavigation?(navigation)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            webView.handlers.didReceiveServerRedirectForProvisionalNavigation?(navigation)
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if let auth = webView.handlers.authenticate?(challenge) {
                completionHandler(auth.0, auth.1)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.handlers.didFinishNavigation?(navigation)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            webView.handlers.didCommitNavigation?(navigation)
        }
        
        func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping @MainActor (Bool) -> Void) {
            decisionHandler(webView.handlers.shouldAllowDeprecatedTLS?(challenge) ?? false)
        }
        
        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            webView.handlers.navigationActionDidBecomeDownload?(navigationAction, download)
            webView.downloadHandlers.didStart?(download)
            download.delegate = self
            guard download.retryAmount == -1 else { return }
            download.retryAmount = webView.defaultDownloadRetryAmount
        }
        
        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            webView.handlers.navigationResponseDidBecomeDownload?(navigationResponse, download)
            webView.downloadHandlers.didStart?(download)
            download.delegate = self
            guard download.retryAmount == -1 else { return }
            download.retryAmount = webView.defaultDownloadRetryAmount
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.handlers.webContentProcessDidTerminate?()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            webView.handlers.didFailNavigation?(navigation, error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            webView.handlers.didFailProvisionalNavigation?(navigation, error)
        }
        
        func webView(_ webView: WKWebView, shouldGoTo backForwardListItem: WKBackForwardListItem, willUseInstantBack: Bool, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(webView.handlers.shouldGoTo?(backForwardListItem, willUseInstantBack) ?? true)
        }
        
        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping @MainActor (URL?) -> Void) {
            let downloadLocation = webView?.downloadHandlers.downloadLocation?(download, response, suggestedFilename) ?? webView?.defaultDownloadDirectory?.appendingPathComponent(suggestedFilename)
            if let downloadDirectory = downloadLocation?.deletingLastPathComponent(), !FileManager.default.directoryExists(at: downloadDirectory) {
                try? FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true)
            }
            if let downloadLocation = downloadLocation, FileManager.default.fileExists(at: downloadLocation) {
                switch webView?.defaultDownloadStrategy ?? .resume {
                case .delete:
                    do {
                        try FileManager.default.removeItem(at: downloadLocation)
                        completionHandler(downloadLocation)
                    } catch {
                        Swift.debugPrint(error)
                        completionHandler(nil)
                    }
                case .ignore:
                    completionHandler(nil)
                case .resume:
                    guard download.originalRequest?.allHTTPHeaderFields?["Range"] == nil, let fileSize = downloadLocation.resources.fileSize?.bytes, fileSize < response.expectedContentLength else {
                        completionHandler(downloadLocation)
                        return
                    }
                    var request: URLRequest?
                    if let _request = download.originalRequest {
                        request = _request
                    } else if let url = response.url {
                        request = URLRequest(url: url)
                    }
                    if var request = request {
                        completionHandler(nil)
                        request.addRangeHeader(for: downloadLocation)
                        webView?.startDownload(using: request, completionHandler: { _ in })
                    } else {
                        completionHandler(nil)
                    }
                }
            } else {
                completionHandler(downloadLocation ?? webView?.defaultDownloadDirectory?.appendingPathComponent(suggestedFilename))
            }
        }
        
        func downloadDidFinish(_ download: WKDownload) {
            webView?.downloadHandlers.didFinish?(download)
        }
        
        func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
            guard let webView = webView else { return }
            webView.downloadHandlers.didFail?(download, error, resumeData)
            guard download.retryAmount > 1, let resumeData = resumeData else { return }
            webView.resumeDownload(fromResumeData: resumeData) { newDownload in
                newDownload.retryAmount = download.retryAmount - 1
            }
        }
        
        @available(macOS 11.3, iOS 18.2, *)
        func download(_ download: WKDownload, didReceivePlaceholderURL url: URL, completionHandler: @escaping @MainActor () -> Void) {
            webView?.downloadHandlers.didReceivePlaceholderURL?(download, url)
        }
        
        @available(macOS 11.3, iOS 18.2, *)
        func download(_ download: WKDownload, decidePlaceholderPolicy completionHandler: @escaping @MainActor (WKDownload.PlaceholderPolicy, URL?) -> Void) {
            if let policy = webView?.downloadHandlers.placeholderPolicy?(download) {
                completionHandler(policy.policy, policy.destination)
            } else {
                completionHandler(.disable, nil)
            }
        }
        
        @available(macOS 11.3, iOS 18.2, *)
        func download(_ download: WKDownload, didReceiveFinalURL url: URL) {
            webView?.downloadHandlers.didReceiveFinalURL?(download, url)
        }
        
        func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping @MainActor (WKDownload.RedirectPolicy) -> Void) {
            decisionHandler(webView?.downloadHandlers.shouldPerformHTTPRedirection?(download, response, request) ?? .allow)
        }
        
        func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if let auth = webView?.downloadHandlers.authenticate?(download, challenge) {
                completionHandler(auth.disposition, auth.credential)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension WKDownload {
    /// The amount of retries when the download fails.
    public var retryAmount: Int {
        get { getAssociatedValue("retryAmount", initialValue: -1) }
        set { setAssociatedValue(newValue, key: "retryAmount") }
    }

    var fileDestinationURL: URL? {
        get { getAssociatedValue("fileDestinationURL") }
        set { setAssociatedValue(newValue, key: "fileDestinationURL") }
    }
}

#endif
#endif

/*
 #if os(macOS) || os(iOS)
     import FZSwiftUtils
     import WebKit

     /**
      An extended `WKWebView`.
     
      A `WKWebView` with handlers for request, response, cookies, etc.
      */
     @available(macOS 11.3, iOS 14.5, *)
     open class FZWebView: WKWebView {
        
         /// The handlers of a web view.
         public struct Handlers {
             /// The handler that returns the current url request when the web view finishes loading a website.
             public var request: ((_ request: URLRequest?) -> Void)?
            
             /// The handler that returns the current url response when the web view finishes loading a website.
             public var response: ((_ response: URLResponse?) -> Void)?
            
             /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
             public var cookies: ((_ cookies: [HTTPCookie]) -> Void)?
            
             /// The handler that gets called when the webview did finish loading a url.
             public var didFinish: ((_ url: URL?)->())?
         }
        
         /// The handlers for downloading files.
         public struct DownloadHandlers {
             /// The handler that determines whether a url request should be downloaded.
             public var shouldDownload: ((URLRequest) -> (Bool))?
             /// The handler that determines the file location of a finished download.
             public var downloadLocation: ((_ response: URLResponse, _ suggestedFilename: String) -> (URL?))?
             /// The handler that handles the authenticate challenge for a download.
             public var authenticate: ((_ download: WKDownload, _ challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?))?
             /// The handler that gets called whenever a download starts.
             public var didStart: ((WKDownload) -> Void)?
             /// The handler that gets called whenever a download finishes.
             public var didFinish: ((WKDownload) -> Void)?
             /// The handler that gets called whenever a download failed and determines whether a failed download should be tried downloading again.
             public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?) -> (Bool))?
         }

         /// The download strategy.
         public enum DownloadStrategy: Int, Hashable {
             /// Deletes an existing file at the suggested download location.
             case delete
             /// Doesn't download a file if it exists at the suggested download location.
             case ignore
             /// Resume downloading a file if it exists at the suggested download location.
             case resume
         }
        
         /// The handlers of the web view.
         open var handlers = Handlers()

         /// The handlers for downloading files.
         open var downloadHandlers = DownloadHandlers()

         /// The download strategy.
         open var defaultDownloadStrategy: DownloadStrategy = .resume

         /// The progress of all downloads.
         public let downloadProgress = DownloadProgress()

         /// The current downloads.
         public let downloads = SynchronizedArray<WKDownload>()

         /// The current url request.
         @objc dynamic open var currentRequest: URLRequest? {
             didSet {
                 guard oldValue != currentRequest else { return }
                 handlers.request?(currentRequest)
             }
         }
        
         /// The current url response.
         @objc dynamic open var currentResponse: URLResponse? {
             didSet {
                 guard oldValue != currentResponse else { return }
                 handlers.response?(currentResponse)
             }
         }

         /// The current HTTP cookies.
         @objc dynamic open fileprivate(set) var currentHTTPCookies: [HTTPCookie] {
             get { _currentHTTPCookies.synchronized }
             set {
                 guard Set(currentHTTPCookies.map({ CookieWrapper($0) })) != Set(newValue.map({ CookieWrapper($0) })) else { return }
                 _currentHTTPCookies.synchronized = newValue
                 handlers.cookies?(newValue)
             }
         }

         var _currentHTTPCookies = SynchronizedArray<HTTPCookie>()
         var delegate: Delegate!
         let awaitingRequests = SynchronizedArray<URLRequest>()
         let awaitingDownloadRequests = SynchronizedArray<URLRequest>()
         let awaitingResumeDatas = SynchronizedArray<Data>()
         let sequentialOperationQueue = OperationQueue(maxConcurrentOperationCount: 1)
         let downloadFileURLHandlers = SynchronizedDictionary<URLRequest, (URLResponse, String) -> (URL)>()
         let downloadFileStrategies = SynchronizedDictionary<URLRequest, DownloadStrategy>()
        
         public init(frame: CGRect) {
             super.init(frame: frame, configuration: .init())
             sharedInit()
         }

         public init() {
             super.init(frame: .zero, configuration: .init())
             sharedInit()
         }

         override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
             super.init(frame: frame, configuration: configuration)
             sharedInit()
         }

         public required init?(coder: NSCoder) {
             super.init(coder: coder)
             sharedInit()
         }
        
         private func sharedInit() {
             delegate = Delegate(webview: self)
             configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                 self.currentHTTPCookies = cookies
             }
             swizzle()
         }

         override open func load(_ request: URLRequest) -> WKNavigation? {
             if sequentialOperationQueue.maxConcurrentOperationCount == 0 {
                 awaitingRequests.append(request)
                 sequentialOperationQueue.addOperation {
                     if let first = self.awaitingRequests.first {
                         self.awaitingRequests.remove(at: 0)
                         DispatchQueue.main.async {
                             _ = self.load(first)
                         }
                     }
                 }
                 return nil
             } else {
                 currentRequest = nil
                 currentResponse = nil
                 currentHTTPCookies = []
                 sequentialOperationQueue.maxConcurrentOperationCount = 0
                 return super.load(request)
             }
         }

         /**
          Starts to download the resource at the URL.

          - Parameter url: The URL to download a resource from a webpage.
          */
         open func startDownload(_ url: URL, strategy: DownloadStrategy? = nil, fileURLHandler: @escaping (_ response: URLResponse, _ suggestedFilename: String) -> (URL), completionHandler: @escaping (WKDownload) -> Void) {
             startDownload(URLRequest(url: url), strategy: strategy, fileURLHandler: fileURLHandler, completionHandler: completionHandler)
         }

         /**
          Starts to download the resource at the URL in the request.

          - Parameter request: An object that encapsulates a URL and other parameters that you need to download a resource from a webpage.
          */
         open func startDownload(_ request: URLRequest, strategy: DownloadStrategy? = nil, fileURLHandler: @escaping (_ response: URLResponse, _ suggestedFilename: String) -> (URL), completionHandler: @escaping (WKDownload) -> Void) {
             downloadFileURLHandlers[request] = fileURLHandler
             downloadFileStrategies[request] = strategy ?? defaultDownloadStrategy
             startDownload(using: request, completionHandler: { download in
                 self.downloadFileURLHandlers[request] = nil
                 self.downloadFileStrategies[request] = nil
                 completionHandler(download)
             })
         }
     }

     @available(macOS 11.3, iOS 14.5, *)
     extension FZWebView {
         class Delegate: NSObject {
             let webview: FZWebView

             init(webview: FZWebView) {
                 self.webview = webview
                 super.init()
                 self.webview.navigationDelegate = self
             }

             func setupDownload(_ download: WKDownload) {
                 download.delegate = self
                 webview.downloads.append(download)
                 download.progress.autoUpdateEstimatedTimeRemaining = true
                 webview.downloadProgress.addChild(download.progress)
                 webview.downloadHandlers.didStart?(download)
                 webview.sequentialOperationQueue.maxConcurrentOperationCount = 1
             }
            
             func updateCookies() {
                 webview.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                     /*
                     guard var domain = self.webview.currentRequest?.url?.host else { return }
                     var components = domain.components(separatedBy: ".")
                     if components.count > 2 {
                         domain = [components.removeLast(), components.removeLast()].reversed().joined(separator: ".")
                     }
                     let cookies = cookies.filter { $0.domain.contains(domain) }
                      */
                     self.webview.currentHTTPCookies = cookies
                 }
             }
         }
     }

     @available(macOS 11.3, iOS 14.5, *)
     extension FZWebView.Delegate: WKNavigationDelegate {
         func webView(_: WKWebView, navigationAction _: WKNavigationAction, didBecome download: WKDownload) {
             // Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
             setupDownload(download)
         }
        
         func webView(_: WKWebView, didFinish navigation: WKNavigation!) {
             webview.handlers.didFinish?(webview.url)
             updateCookies()
         }

         func webView(_: WKWebView, navigationResponse _: WKNavigationResponse, didBecome download: WKDownload) {
             // Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
             setupDownload(download)
         }
        
         func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
             webview.currentResponse = navigationResponse.response
             decisionHandler(.allow)
         }

         func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
             webview.currentRequest = navigationAction.request
             updateCookies()
             if webview.downloadHandlers.shouldDownload?(navigationAction.request) ?? false {
                 decisionHandler(.download)
             } else {
                 decisionHandler(.allow)
                 webview.sequentialOperationQueue.maxConcurrentOperationCount = 1
             }
         }
     }

     @available(macOS 11.3, iOS 14.5, *)
     extension FZWebView.Delegate: WKDownloadDelegate {
         func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
             // Swift.debugPrint("[FZWebView] download suggestedFilename", suggestedFilename, response.expectedContentLength)
             var downloadLocation: URL?
             if let request = download.originalRequest, let handler = webview.downloadFileURLHandlers[request] {
                 downloadLocation = handler(response, suggestedFilename)
             } else {
                 downloadLocation = webview.downloadHandlers.downloadLocation?(response, suggestedFilename)
             }
             var downloadStrategy = webview.defaultDownloadStrategy
             if let request = download.originalRequest, let strategy = webview.downloadFileStrategies[request] {
                 downloadStrategy = strategy
             }
             if let downloadLocation = downloadLocation, FileManager.default.fileExists(at: downloadLocation) {
                 switch downloadStrategy {
                 case .delete:
                     do {
                         // Swift.debugPrint("[FZWebView] download delete", suggestedFilename, response.expectedContentLength)
                         try FileManager.default.removeItem(at: downloadLocation)
                         download.fileDestinationURL = downloadLocation
                         completionHandler(downloadLocation)
                     } catch {
                         Swift.debugPrint(error)
                         completionHandler(nil)
                     }
                 case .ignore:
                     // Swift.debugPrint("[FZWebView] download ignore", suggestedFilename, response.expectedContentLength)
                     completionHandler(nil)
                 case .resume:
                     guard download.originalRequest?.allHTTPHeaderFields?["Range"] == nil, let fileSize = downloadLocation.resources.fileSize?.bytes, fileSize < response.expectedContentLength else {
                         download.fileDestinationURL = downloadLocation
                         completionHandler(downloadLocation)
                         return
                     }
                     var request: URLRequest?
                     if let _request = download.originalRequest {
                         request = _request
                     } else if let url = response.url {
                         request = URLRequest(url: url)
                     }
                     if var request = request {
                         // Swift.debugPrint("[FZWebView] download resume", suggestedFilename, response.expectedContentLength)
                         completionHandler(nil)
                         request.addRangeHeader(for: downloadLocation)
                         webview.startDownload(using: request, completionHandler: { _ in })
                     } else {
                         completionHandler(nil)
                     }
                 }
             } else {
                 // Swift.debugPrint("[FZWebView] download", suggestedFilename, response.expectedContentLength)
                 download.fileDestinationURL = downloadLocation
                 completionHandler(downloadLocation)
             }
         }

         func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
             if let authenticate = webview.downloadHandlers.authenticate?(download, challenge) {
                 completionHandler(authenticate.disposition, authenticate.credential)
             } else {
                 completionHandler(.performDefaultHandling, nil)
             }
         }

         func downloadDidFinish(_ download: WKDownload) {
             // Swift.debugPrint("[FZWebView] download didFinish", download.originalRequest?.url ?? "")
             if let index = webview.downloads.firstIndex(of: download) {
                 webview.downloads.remove(at: index)
             }
             webview.downloadHandlers.didFinish?(download)
         }

         func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
             // Swift.debugPrint("[FZWebView] download failed", error, download.originalRequest?.url ?? "")
             if let resumeData = resumeData, download.retryAmount > 0, let request = download.originalRequest, let fileDestinationURL = download.fileDestinationURL {
                 webview.downloadFileURLHandlers[request] = { _, _ in fileDestinationURL }
                 webview.resumeDownload(fromResumeData: resumeData, completionHandler: {
                     newDownload in
                     newDownload.retryAmount = download.retryAmount - 1
                     self.webview.downloadFileURLHandlers[request] = nil
                 })
             }
             if let index = webview.downloads.firstIndex(of: download) {
                 webview.downloadProgress.removeChild(download.progress)
                 webview.downloads.remove(at: index)
             }
             if webview.downloadHandlers.didFail?(download, error, resumeData) ?? false {
                 guard let resumeData = resumeData else { return }
                 webview.resumeDownload(fromResumeData: resumeData, completionHandler: { download in
                     // Swift.debugPrint("[FZWebView] download retry", download.originalRequest?.url ?? "")

                 })
             }
         }

         func download(_: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest _: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
             // Swift.debugPrint("[FZWebView] download willPerformHTTPRedirection", response, response.url ?? "")
             decisionHandler(.allow)
         }
     }

     @available(macOS 11.3, iOS 14.5, *)
     public extension FZWebView {
         class DownloadProgress: MutableProgress, @unchecked Sendable {
             /// The downloading progresses.
             public var downloading: [Progress] {
                 children.filter { $0.isFinished == false }
             }

             /// The throughput of the downloads.
             public var downloadThroughput: DataSize {
                 DataSize(downloading.compactMap(\.throughput).sum())
             }

             /// The estimated time remaining for the downloads.
             public var downloadEstimatedTimeRemaining: TimeDuration {
                 TimeDuration(downloading.compactMap(\.estimatedTimeRemaining).sum())
             }
         }
     }

     @available(macOS 11.3, iOS 14.5, *)
     extension WKDownload {
         /// The amount of retries when downloading via ``FZWebView`` fails.
         public var retryAmount: Int {
             get { getAssociatedValue("retryAmount", initialValue: 0) }
             set { setAssociatedValue(newValue, key: "retryAmount") }
         }

         var fileDestinationURL: URL? {
             get { getAssociatedValue("fileDestinationURL") }
             set { setAssociatedValue(newValue, key: "fileDestinationURL") }
         }
     }

 struct CookieWrapper: Hashable {
     let cookie: HTTPCookie
    
     init(_ cookie: HTTPCookie) {
         self.cookie = cookie
     }

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
 }

 @available(macOS 11.3, iOS 14.5, *)
 extension FZWebView {
     // workaround because overwriting `startDownload(:)` and `resumeDownload(:)` directly causes errors for Swift `6.0`.
     func swizzle() {
         do {
            try replaceMethod(
             #selector(WKWebView.startDownload(using:completionHandler:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, URLRequest, ((WKDownload) -> Void)) -> ()).self,
             hookSignature: (@convention(block)  (AnyObject, URLRequest, @escaping ((WKDownload) -> Void)) -> ()).self) { store in {
                 object, request, completionHandler in
                 if let view = object as? FZWebView {
                     if view.sequentialOperationQueue.maxConcurrentOperationCount == 0 {
                         view.awaitingDownloadRequests.append(request)
                         view.sequentialOperationQueue.addOperation {
                             if let first = view.awaitingDownloadRequests.first {
                                 view.awaitingDownloadRequests.remove(at: 0)
                                 DispatchQueue.main.async {
                                     view.startDownload(using: first, completionHandler: { download in
                                         view.delegate.setupDownload(download)
                                         completionHandler(download)
                                     })
                                 }
                             }
                         }
                     } else {
                         view.sequentialOperationQueue.maxConcurrentOperationCount = 0
                         let handler: ((WKDownload) -> Void) = { download in
                             view.delegate.setupDownload(download)
                             completionHandler(download)
                         }
                         store.original(object, #selector(WKWebView.startDownload(using:completionHandler:)), request, handler)
                     }
                 } else {
                     store.original(object, #selector(WKWebView.startDownload(using:completionHandler:)), request, completionHandler)
                 }
             }
            }
             try replaceMethod(
              #selector(WKWebView.resumeDownload(fromResumeData:completionHandler:)),
             methodSignature: (@convention(c)  (AnyObject, Selector, Data, ((WKDownload) -> Void)) -> ()).self,
              hookSignature: (@convention(block)  (AnyObject, Data, @escaping ((WKDownload) -> Void)) -> ()).self) { store in {
                  object, resumeData, completionHandler in
                  if let view = object as? FZWebView {
                      if view.sequentialOperationQueue.maxConcurrentOperationCount == 0 {
                          view.awaitingResumeDatas.append(resumeData)
                          view.sequentialOperationQueue.addOperation {
                              if let first = view.awaitingResumeDatas.first {
                                  view.awaitingResumeDatas.remove(at: 0)
                                  DispatchQueue.main.async {
                                      self.resumeDownload(fromResumeData: first) { download in
                                          view.delegate.setupDownload(download)
                                          completionHandler(download)
                                      }
                                  }
                              }
                          }
                      } else {
                          view.sequentialOperationQueue.maxConcurrentOperationCount = 0
                          let handler: ((WKDownload) -> Void) = { download in
                              view.delegate.setupDownload(download)
                              completionHandler(download)
                          }
                          store.original(object, #selector(WKWebView.resumeDownload(fromResumeData:completionHandler:)), resumeData, handler)
                      }
                  } else {
                      store.original(object, #selector(WKWebView.resumeDownload(fromResumeData:completionHandler:)), resumeData, completionHandler)
                  }
              }
             }
         } catch {
            debugPrint(error)
         }
     }
 }

 #endif

 */
