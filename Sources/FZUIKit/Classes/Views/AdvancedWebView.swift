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
    
    @available(macOS 11.3, iOS 14.5, *)
    /// The handlers for downloading files.
    public struct DownloadHandlers {
        /// The handler that determines whether a url request should be downloaded.
        public var shouldDownload: ((URLRequest)->(Bool))? = nil
        /// The handler that determines the file location of a finished download.
        public var downloadLocation: ((_ response: URLResponse, _ suggestedFilename: String)->(URL?))? = nil
        /// The handler that gets called whenever a download finishes.
        public var didStart: ((_ download: WKDownload)->())? = nil
        /// The handler that gets called whenever a download finishes.
        public var didFinish: ((_ download: WKDownload)->())? = nil
        /// The handler that gets called whenever a download failed.
        public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?)->())? = nil
        /// The handler that gets called whenever the download progresses.
        public var progress: ((_ download: WKDownload, _ progress: Progress)->())? = nil
    }
    
    @available(macOS 11.3, iOS 14.5, *)
    /// The handlers for downloading files.
    public var downloadHandlers: DownloadHandlers {
        get {  return getAssociatedValue(key: "AdvanceWebView_downloadHandlers", object: self, initialValue: DownloadHandlers()) }
        set { set(associatedValue: newValue, key: "AdvanceWebView_downloadHandlers", object: self) }
    }
    private var downloadLocation: URL? = nil
    private var downloadExpectedFileSize: Int64? = nil
    private var downloadStartDate = Date()
    private var finderFileDownloadProgress: Progress?

    @available(macOS 11.3, iOS 14.5, *)
    /// The current download.
    @objc dynamic public var download: WKDownload? {
        get {  return getAssociatedValue(key: "AdvanceWebView_download", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "AdvanceWebView_download", object: self) }
    }
    
    internal var downloadProgressObservation: NSKeyValueObservation? = nil


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
    @available(macOS 11.3, iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        self.setupDownload(download)
        self.downloadHandlers.didStart?(download)
    }
        
    @available(macOS 11.3, iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        self.setupDownload(download)
        self.downloadHandlers.didStart?(download)
    }
    
    @available(macOS 11.3, iOS 14.5, *)
    internal func setupDownload(_ download: WKDownload) {
        download.delegate = self
        self.download = download
        Swift.print("navigationResponse didBecome", download, download.progress)

        self.downloadProgressObservation = download.observeChanges(for: \.progress.fractionCompleted, handler: {
            old, new in
            if let progress = self.download?.progress {
            //    download.progress.updateEstimatedTimeRemaining(dateStarted: self.downloadStartDate)
                self.downloadHandlers.progress?(download, download.progress)
            }
        })
       // self.updateDownloadProgress()
    }
    /*
    @available(macOS 11.3, iOS 14.5, *)
    internal func updateDownloadProgress() {
        self.download?.progress.updateEstimatedTimeRemaining(dateStarted: self.downloadStartDate)
        guard self.download != nil else {
            finderFileDownloadProgress?.cancel()
            finderFileDownloadProgress = nil
            return
        }
     
        
#if os(macOS)
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
#endif
        
        guard let downloadProgress = self.download?.progress else { return }
        finderFileDownloadProgress?.totalUnitCount = downloadProgress.totalUnitCount
        finderFileDownloadProgress?.estimatedTimeRemaining = downloadProgress.estimatedTimeRemaining
        finderFileDownloadProgress?.throughput = downloadProgress.throughput
        finderFileDownloadProgress?.completedUnitCount = downloadProgress.completedUnitCount
    }
     */
        
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
        if #available(macOS 11.3, iOS 14.5, *) {
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

@available(macOS 11.3, iOS 14.5, *)
extension AdvanceWebView: WKDownloadDelegate {
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        Swift.print("[AdvanceWebView] download downloadLocation", suggestedFilename, response.expectedContentLength)
        self.downloadExpectedFileSize = response.expectedContentLength
        self.downloadLocation = self.downloadHandlers.downloadLocation?(response, suggestedFilename) ?? nil
        if downloadLocation != nil {
            self.downloadStartDate = Date()
        }
        completionHandler(self.downloadLocation)
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        if let downloadExpectedFileSize = downloadExpectedFileSize, let downloadLocation = downloadLocation, let data = try? Data(contentsOf: downloadLocation) {
            if Int64(data.count) != downloadExpectedFileSize {
                Swift.print("[AdvanceWebView] download didFinish", Int64(data.count), downloadExpectedFileSize)
            } else {
                Swift.print("[AdvanceWebView] download didFinish")
            }
        } else {
            Swift.print("[AdvanceWebView] download didFinish")
        }
        
        self.download = nil
        self.downloadProgressObservation = nil
        // self.updateDownloadProgress()
        self.downloadHandlers.didFinish?(download)
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
      //  self.updateDownloadProgress()
        self.downloadProgressObservation = nil
        self.downloadHandlers.didFail?(download, error, resumeData)
    }
    
    public func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        Swift.print("[AdvanceWebView] download willPerformHTTPRedirection", response, response.url ?? "")
        decisionHandler(.allow)
    }
}

/*
@available(macOS 11.3, *)
public extension WKDownload {
    /// The expected content size of the download.
    var expectedContentSize: Int64? {
        get {  return getAssociatedValue(key: "WKDownload_expectedContentSize", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "WKDownload_expectedContentSize", object: self) }
    }
}
*/
