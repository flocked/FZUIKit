//
//  FZWebView.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if os(macOS) || os(iOS)
    import FZSwiftUtils
    import WebKit

    /**
     An extended `WKWebView`.
     
     A WKWebView with properties for current url request & current cookies and handlers for didFinishLoading & cookies.

     */
    @available(macOS 11.3, iOS 14.5, *)
    open class FZWebView: WKWebView {
        
        /// The handlers for downloading files.
        public struct DownloadHandlers {
            /// The handler that determines whether a url request should be downloaded.
            public var shouldDownload: ((URLRequest) -> (Bool))?
            /// The handler that determines the file location of a finished download.
            public var downloadLocation: ((_ response: URLResponse, _ suggestedFilename: String) -> (URL?))?
            /// The handler that handles the authentication challenge for a download.
            public var authentication: ((_ download: WKDownload, _ challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?))?
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

        /// The handlers for downloading files.
        open var downloadHandlers = DownloadHandlers()

        /// The download strategy.
        open var defaultDownloadStrategy: DownloadStrategy = .resume

        /// The progress of all downloads.
        public let downloadProgress = DownloadProgress()

        /// The current downloads.
        public let downloads = SynchronizedArray<WKDownload>()

        /// The handler that returns the current url request when the web view finishes loading a website.
        open var requestHandler: ((URLRequest?) -> Void)?

        /// The handlers that get called when the webview requests a specific url.
        open var urlHandlers = SynchronizedDictionary<URL, () -> Void>()

        /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
        open var cookiesHandler: (([HTTPCookie]) -> Void)?

        /// The current url request.
        @objc dynamic open var currentRequest: URLRequest?

        /// All HTTP cookies of the current url request.
        @objc dynamic open fileprivate(set) var currentHTTPCookies: [HTTPCookie] {
            get { _currentHTTPCookies.synchronized }
            set { _currentHTTPCookies.synchronized = newValue }
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
            delegate = Delegate(webview: self)
        }

        public init() {
            super.init(frame: .zero, configuration: .init())
            delegate = Delegate(webview: self)
        }

        override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
            super.init(frame: frame, configuration: configuration)
            delegate = Delegate(webview: self)
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            delegate = Delegate(webview: self)
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
                currentHTTPCookies.removeAll()
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
        
        override open func startDownload(using request: URLRequest, completionHandler: @escaping (WKDownload) -> Void) {
            if sequentialOperationQueue.maxConcurrentOperationCount == 0 {
                awaitingDownloadRequests.append(request)
                sequentialOperationQueue.addOperation {
                    if let first = self.awaitingDownloadRequests.first {
                        self.awaitingDownloadRequests.remove(at: 0)
                        DispatchQueue.main.async {
                            self.startDownload(using: first, completionHandler: { download in
                                self.delegate.setupDownload(download)
                                completionHandler(download)
                            })
                        }
                    }
                }
            } else {
                sequentialOperationQueue.maxConcurrentOperationCount = 0
                super.startDownload(using: request, completionHandler: { download in
                    self.delegate.setupDownload(download)
                    completionHandler(download)
                })
            }
        }

        override open func resumeDownload(fromResumeData resumeData: Data, completionHandler: @escaping (WKDownload) -> Void) {
            if sequentialOperationQueue.maxConcurrentOperationCount == 0 {
                awaitingResumeDatas.append(resumeData)
                sequentialOperationQueue.addOperation {
                    if let first = self.awaitingResumeDatas.first {
                        self.awaitingResumeDatas.remove(at: 0)
                        DispatchQueue.main.async {
                            self.resumeDownload(fromResumeData: first) { download in
                                self.delegate.setupDownload(download)
                                completionHandler(download)
                            }
                        }
                    }
                }
            } else {
                sequentialOperationQueue.maxConcurrentOperationCount = 0
                super.resumeDownload(fromResumeData: resumeData) { download in
                    self.delegate.setupDownload(download)
                    completionHandler(download)
                }
            }
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
        }
    }

    @available(macOS 11.3, iOS 14.5, *)
    extension FZWebView.Delegate: WKNavigationDelegate {
        public func webView(_: WKWebView, navigationAction _: WKNavigationAction, didBecome download: WKDownload) {
            Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
            setupDownload(download)
        }

        public func webView(_: WKWebView, navigationResponse _: WKNavigationResponse, didBecome download: WKDownload) {
            Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
            setupDownload(download)
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let oldCurrentRequest = webview.currentRequest
            webview.currentRequest = navigationAction.request
            let store = webView.configuration.websiteDataStore
            store.httpCookieStore.getAllCookies { cookies in
                guard var domain = self.webview.currentRequest?.url?.host else { return }
                var components = domain.components(separatedBy: ".")
                if components.count > 2 {
                    domain = [components.removeLast(), components.removeLast()].reversed().joined(separator: ".")
                }
                let cookies = cookies.filter { $0.domain.contains(domain) }
                if !cookies.isEmpty, cookies != self.webview.currentHTTPCookies {
                    self.webview.cookiesHandler?(cookies)
                }

                self.webview.currentHTTPCookies = cookies
            }

            if oldCurrentRequest != navigationAction.request {
                webview.requestHandler?(navigationAction.request)
            }

            if let url = navigationAction.request.url, let handler = webview.urlHandlers[url] {
                handler()
            }

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
        
        public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            Swift.debugPrint("[FZWebView] download suggestedFilename", suggestedFilename, response.expectedContentLength)
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
                        Swift.debugPrint("[FZWebView] download delete", suggestedFilename, response.expectedContentLength)
                        try FileManager.default.removeItem(at: downloadLocation)
                        download.fileDestinationURL = downloadLocation
                        completionHandler(downloadLocation)
                    } catch {
                        Swift.debugPrint(error)
                        completionHandler(nil)
                    }
                case .ignore:
                    Swift.debugPrint("[FZWebView] download ignore", suggestedFilename, response.expectedContentLength)
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
                        Swift.debugPrint("[FZWebView] download resume", suggestedFilename, response.expectedContentLength)
                        completionHandler(nil)
                        request.addRangeHeader(for: downloadLocation)
                        webview.startDownload(using: request, completionHandler: { _ in })
                    } else {
                        completionHandler(nil)
                    }
                }
            } else {
                Swift.debugPrint("[FZWebView] download", suggestedFilename, response.expectedContentLength)
                download.fileDestinationURL = downloadLocation
                completionHandler(downloadLocation)
            }
        }

        func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if let authentication = webview.downloadHandlers.authentication?(download, challenge) {
                completionHandler(authentication.disposition, authentication.credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }

        public func downloadDidFinish(_ download: WKDownload) {
            Swift.debugPrint("[FZWebView] download didFinish", download.originalRequest?.url ?? "")
            if let index = webview.downloads.firstIndex(of: download) {
                webview.downloads.remove(at: index)
            }
            webview.downloadHandlers.didFinish?(download)
        }

        public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            Swift.debugPrint("[FZWebView] download failed", error, download.originalRequest?.url ?? "")
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
                    Swift.debugPrint("[FZWebView] download retry", download.originalRequest?.url ?? "")

                })
            }
        }

        public func download(_: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest _: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
            Swift.debugPrint("[FZWebView] download willPerformHTTPRedirection", response, response.url ?? "")
            decisionHandler(.allow)
        }
    }

    @available(macOS 11.3, iOS 14.5, *)
    public extension FZWebView {
        class DownloadProgress: MutableProgress {
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
            get { getAssociatedValue("fileDestinationURL", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "fileDestinationURL") }
        }
    }

#endif
