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
        /// The handler that gets called whenever the download progresses.
        public var progress: ((_ current: Int64, _ total: Int64)->())? = nil
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
    private var downloadLocation: URL? = nil
    private var downloadStartDate = Date()
    private var finderFileDownloadProgress: Progress?

    
    @available(macOS 11.3, *)
    /// The current download.
    @objc dynamic public var download: WKDownload? {
        get {
            return _download as? WKDownload
        }
        set {  _download = newValue }
    }
    private var _download: Any? = nil
    
    internal var downloadProgressTotalObservation: NSKeyValueObservation? = nil
    internal var downloadProgressCompletedObservation: NSKeyValueObservation? = nil


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
        self.setupDownload(download)
    }
        
    @available(macOS 11.3, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        self.setupDownload(download)
    }
    
    @available(macOS 11.3, *)
    internal func setupDownload(_ download: WKDownload) {
        download.delegate = self
        self.download = download
        Swift.print("navigationResponse didBecome", download, download.progress)

        self.downloadProgressTotalObservation = download.observeChanges(for: \.progress.totalUnitCount, handler: {
            old, new in
            if let progress = self.download?.progress {
                self.updateDownloadProgress()
                self.downloadHandlers.progress?(progress.completedUnitCount, progress.totalUnitCount)
            }
        })
        self.downloadProgressCompletedObservation = download.observeChanges(for: \.progress.completedUnitCount, handler: {  old, new in
            if let progress = self.download?.progress {
                self.updateDownloadProgress()
                self.downloadHandlers.progress?(progress.completedUnitCount, progress.totalUnitCount)
            }
        })
        self.updateDownloadProgress()
    }
    
    @available(macOS 11.3, *)
    internal func updateDownloadProgress() {
        self.download?.progress.updateEstimatedTimeRemaining(dateStarted: self.downloadStartDate)
        guard self.download != nil else {
            finderFileDownloadProgress?.cancel()
            finderFileDownloadProgress = nil
            return
        }
        
        if finderFileDownloadProgress == nil, let downloadLocation = self.downloadLocation, let totalBytes = self.download?.progress.totalUnitCount {
            finderFileDownloadProgress = Progress(parent: nil, userInfo: [
                .fileOperationKindKey: Progress.FileOperationKind.downloading,
                .fileURLKey: downloadLocation])
            finderFileDownloadProgress?.isCancellable = true
            finderFileDownloadProgress?.isPausable = false
            finderFileDownloadProgress?.kind = .file
            finderFileDownloadProgress?.totalUnitCount = totalBytes
            finderFileDownloadProgress?.publish()
        }
        
        guard let downloadProgress = self.download?.progress else { return }
        finderFileDownloadProgress?.totalUnitCount = downloadProgress.totalUnitCount
        finderFileDownloadProgress?.estimatedTimeRemaining = downloadProgress.estimatedTimeRemaining
        finderFileDownloadProgress?.throughput = downloadProgress.throughput
        finderFileDownloadProgress?.completedUnitCount = downloadProgress.completedUnitCount
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
            if shouldDownload == false {
                downloadLocation = nil
            }
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
        self.downloadLocation = self.downloadHandlers.downloadLocation?(suggestedFilename) ?? nil
        if downloadLocation != nil {
            self.downloadStartDate = Date()
        }
        completionHandler(self.downloadLocation)
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        Swift.print("[AdvanceWebView] download didFinish")
        self.download = nil
        self.downloadProgressCompletedObservation = nil
        self.downloadProgressTotalObservation = nil
        self.updateDownloadProgress()
        self.downloadHandlers.didFinish?()
    }
    
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        Swift.print("[AdvanceWebView] download failed", error)
        if let downloadLocation = self.downloadLocation, FileManager.default.fileExists(at: downloadLocation) {
            do {
                try FileManager.default.removeItem(at: downloadLocation)
            } catch {
                Swift.print(error)
            }
        }
        self.download = nil
        self.updateDownloadProgress()
        self.downloadProgressCompletedObservation = nil
        self.downloadProgressTotalObservation = nil
        self.downloadHandlers.didFail?(error, resumeData)
    }
    
    public func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        Swift.print("[AdvanceWebView] download willPerformHTTPRedirection", response, response.url ?? "")
        decisionHandler(.allow)
    }
}
