//
//  AdvanceWebView.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if os(macOS) || os(iOS)
import WebKit
import FZSwiftUtils

/**
 A WKWebView with properties for current url request & current cookies and handlers for didFinishLoading & cookies.

 */
@available(macOS 11.3, iOS 14.5, *)
public class AdvanceWebView: WKWebView {
    /// The handlers for downloading files.
    public struct DownloadHandlers {
        /// The handler that determines whether a url request should be downloaded.
        public var shouldDownload: ((URLRequest)->(Bool))? = nil
        /// The handler that determines the file location of a finished download.
        public var downloadLocation: ((_ response: URLResponse, _ suggestedFilename: String)->(URL?))? = nil
        /// The handler that handles the authentication challenge for a download.
        public var authentication: ((_ download: WKDownload, _ challenge: URLAuthenticationChallenge)->(disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?))? = nil
        /// The handler that gets called whenever a download starts.
        public var didStart: ((WKDownload)->())? = nil
        /// The handler that gets called whenever a download finishes.
        public var didFinish: ((WKDownload)->())? = nil
        /// The handler that gets called whenever a download failed and determines whether a failed download should be tried downloading again.
        public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?)->(Bool))? = nil
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
    public var downloadHandlers = DownloadHandlers()
    
    /// The download strategy.
    public var downloadStrategy: DownloadStrategy = .resume
    
    /// The progress of all downloads.
    public let downloadProgress = DownloadProgress()
    
    /// The current downloads.
    public let downloads = SynchronizedArray<WKDownload>()
    
    /// The handler that returns the current url request when the web view finishes loading a website.
    public var requestHandler: ((URLRequest?)->())? = nil
    
    /// The handlers that get called when the webview requests a specific url.
    public var urlHandlers = SynchronizedDictionary<URL, ()->()>()
    
    /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
    public var cookiesHandler: (([HTTPCookie]) -> ())? = nil

    /// The current url request.
    public var currentRequest: URLRequest? = nil
    
    /// All HTTP cookies of the current url request.
    @objc public dynamic fileprivate(set) var currentHTTPCookies: [HTTPCookie] {
        get { _currentHTTPCookies.synchronized }
        set { }
    }
    
    internal var _currentHTTPCookies = SynchronizedArray<HTTPCookie>()
    internal var delegate: Delegate!
    internal let awaitingRequests = SynchronizedArray<URLRequest>()
    internal let awaitingDownloadRequests = SynchronizedArray<URLRequest>()
    internal let awaitingResumeDatas = SynchronizedArray<Data>()
    internal let sequentialOperationQueue = OperationQueue(maxConcurrentOperationCount: 1)
        
    public init(frame: CGRect) {
        super.init(frame: frame, configuration: .init())
        self.delegate = Delegate(webview: self)
    }
    
    public init() {
        super.init(frame: .zero, configuration: .init())
        self.delegate = Delegate(webview: self)
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.delegate = Delegate(webview: self)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = Delegate(webview: self)
    }
    
    public override func load(_ request: URLRequest) -> WKNavigation? {
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
            self.currentRequest = nil
            self._currentHTTPCookies.removeAll()
            sequentialOperationQueue.maxConcurrentOperationCount = 0
            return super.load(request)
        }
    }
    
    /**
     Starts to download the resource at the URL.

     - Parameter url: The URL to download a resource from a webpage.
     */
    public func startDownload(_ url: URL, fileURLHandler: @escaping (_ response: URLResponse, _ suggestedFilename: String)->(URL), completionHandler: @escaping (WKDownload) -> Void) {
        self.startDownload(URLRequest(url: url), fileURLHandler: fileURLHandler, completionHandler: completionHandler)
    }
        
    /**
     Starts to download the resource at the URL in the request.

     - Parameter request: An object that encapsulates a URL and other parameters that you need to download a resource from a webpage.
     */
    public func startDownload(_ request: URLRequest, fileURLHandler: @escaping (_ response: URLResponse, _ suggestedFilename: String)->(URL), completionHandler: @escaping (WKDownload) -> Void) {
        downloadFileURLHandlers[request] = fileURLHandler
        self.startDownload(using: request, completionHandler: { download in
            self.downloadFileURLHandlers[request] = nil
            completionHandler(download)
        })
    }
        
    internal let downloadFileURLHandlers = SynchronizedDictionary<URLRequest, (URLResponse, String)->(URL)>()
    
    public override func startDownload(using request: URLRequest, completionHandler: @escaping (WKDownload) -> Void) {
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
    
    public override func resumeDownload(fromResumeData resumeData: Data, completionHandler: @escaping (WKDownload) -> Void) {
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
internal extension AdvanceWebView {
    class Delegate: NSObject {
        let webview: AdvanceWebView
        
        init(webview: AdvanceWebView) {
            self.webview = webview
            super.init()
            self.webview.navigationDelegate = self
        }
        
        func setupDownload(_ download: WKDownload) {
            download.delegate = self
            self.webview.downloads.append(download)
            download.downloadObservation = download.observeChanges(for: \.progress.fractionCompleted, handler: {
                old, new in
                download.progress.updateEstimatedTimeRemaining()
            })
            self.webview.downloadProgress.addChild(download.progress)
            self.webview.downloadHandlers.didStart?(download)
            self.webview.sequentialOperationQueue.maxConcurrentOperationCount = 1
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension AdvanceWebView.Delegate: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
        self.setupDownload(download)
    }
        
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
        self.setupDownload(download)
    }
        
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let oldCurrentRequest = webview.currentRequest
        webview.currentRequest = navigationAction.request
        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies({cookies in
            guard var domain = self.webview.currentRequest?.url?.host else { return }
            var components = domain.components(separatedBy: ".")
            if components.count > 2 {
                domain = [components.removeLast(), components.removeLast()].reversed().joined(separator: ".")
            }
            let cookies = cookies.filter({$0.domain.contains(domain)})
            if !cookies.isEmpty, cookies != self.webview.currentHTTPCookies {
                self.webview.cookiesHandler?(cookies)
            }
            
            self.webview._currentHTTPCookies.removeAll()
            self.webview._currentHTTPCookies.append(contentsOf: cookies)
            self.webview.currentHTTPCookies = cookies
        })
        
        if oldCurrentRequest != navigationAction.request {
            webview.requestHandler?(navigationAction.request)
        }
        
        if let url = navigationAction.request.url, let handler = self.webview.urlHandlers[url] {
            handler()
        }
        
        if self.webview.downloadHandlers.shouldDownload?(navigationAction.request) ?? false {
            decisionHandler(.download)
        } else {
            decisionHandler(.allow)
            self.webview.sequentialOperationQueue.maxConcurrentOperationCount = 1
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension AdvanceWebView.Delegate: WKDownloadDelegate {
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        Swift.debugPrint("[AdvanceWebView] download suggestedFilename", suggestedFilename, response.expectedContentLength)
        var downloadLocation: URL? = nil
        if let request = download.originalRequest, let handler = webview.downloadFileURLHandlers[request] {
            downloadLocation = handler(response, suggestedFilename)
        } else {
            downloadLocation = webview.downloadHandlers.downloadLocation?(response, suggestedFilename)
        }
        if let downloadLocation = downloadLocation, FileManager.default.fileExists(at: downloadLocation) {
            switch webview.downloadStrategy {
            case .delete:
                do {
                    Swift.debugPrint("[AdvanceWebView] download delete", suggestedFilename, response.expectedContentLength)
                    try FileManager.default.removeItem(at: downloadLocation)
                    download.fileDestinationURL = downloadLocation
                    completionHandler(downloadLocation)
                } catch {
                    Swift.debugPrint(error)
                    completionHandler(nil)
                }
            case .ignore:
                Swift.debugPrint("[AdvanceWebView] download ignore", suggestedFilename, response.expectedContentLength)
                completionHandler(nil)
            case .resume:
                guard download.originalRequest?.allHTTPHeaderFields?["Range"] == nil, let fileSize = downloadLocation.resources.fileSize?.bytes, fileSize < response.expectedContentLength else {
                    download.fileDestinationURL = downloadLocation
                    completionHandler(downloadLocation)
                    return
                }
                    var request: URLRequest? = nil
                    if let _request = download.originalRequest {
                        request = _request
                    } else if let url = response.url {
                        request = URLRequest(url: url)
                    }
                    if var request = request {
                        Swift.debugPrint("[AdvanceWebView] download resume", suggestedFilename, response.expectedContentLength)
                        completionHandler(nil)
                        request.addRangeHeader(for: downloadLocation)
                        self.webview.startDownload(using: request, completionHandler: { _ in  })
                    } else {
                        completionHandler(nil)
                    }
            }
        } else {
            Swift.debugPrint("[AdvanceWebView] download", suggestedFilename, response.expectedContentLength)
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
        Swift.debugPrint("[AdvanceWebView] download didFinish", download.originalRequest?.url ?? "")
        if let index = webview.downloads.firstIndex(of: download) {
            webview.downloads.remove(at: index)
        }
        webview.downloadHandlers.didFinish?(download)
    }
    
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        Swift.debugPrint("[AdvanceWebView] download failed", error, download.originalRequest?.url ?? "")
        if let resumeData = resumeData, download.retryAmount > 0, let request = download.originalRequest, let fileDestinationURL = download.fileDestinationURL {
            self.webview.downloadFileURLHandlers[request] = {_, _ in return fileDestinationURL }
            self.webview.resumeDownload(fromResumeData: resumeData, completionHandler: {
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
            self.webview.resumeDownload(fromResumeData: resumeData, completionHandler: { download in
                Swift.debugPrint("[AdvanceWebView] download retry", download.originalRequest?.url ?? "")

            })
        }
    }
    
    public func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        Swift.debugPrint("[AdvanceWebView] download willPerformHTTPRedirection", response, response.url ?? "")
        decisionHandler(.allow)
    }
}

@available(macOS 11.3, iOS 14.5, *)
public extension AdvanceWebView {
    class DownloadProgress: MutableProgress {
        /// The downloading progresses.
        public var downloading: [Progress] {
            self.children.filter({$0.isFinished == false})
        }
        
        /// The throughput of the downloads.
        public var downloadThroughput: DataSize {
            DataSize(self.downloading.compactMap({$0.throughput}).sum())
        }
        
        /// The estimated time remaining for the downloads.
        public var downloadEstimatedTimeRemaining: TimeDuration {
            TimeDuration(self.downloading.compactMap({$0.estimatedTimeRemaining}).sum())
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension WKDownload {
    internal var downloadObservation: NSKeyValueObservation? {
        get { getAssociatedValue(key: "downloadObservation", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "downloadObservation", object: self) }
    }
    
    public var retryAmount: Int {
        get { getAssociatedValue(key: "retryAmount", object: self, initialValue: 0) }
        set { set(associatedValue: newValue, key: "retryAmount", object: self) }
    }
    
    internal var fileDestinationURL: URL? {
        get { getAssociatedValue(key: "fileDestinationURL", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "fileDestinationURL", object: self) }
    }
}

#endif