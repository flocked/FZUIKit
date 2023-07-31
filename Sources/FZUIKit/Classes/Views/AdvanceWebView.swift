//
//  AdvanceWebView.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import WebKit
import FZSwiftUtils

/**
 A WKWebView with properties for current url request & current cookies and handlers for didFinishLoading & cookies.

 */
@available(macOS 11.3, iOS 14.5, *)
public class AdvanceWebView: WKWebView {
    @available(macOS 11.3, iOS 14.5, *)
    /// The handlers for downloading files.
    public struct DownloadHandlers {
        /// The handler that determines whether a url request should be downloaded.
        public var shouldDownload: ((URLRequest)->(Bool))? = nil
        /// The handler that determines the file location of a finished download.
        public var downloadLocation: ((_ response: URLResponse, _ suggestedFilename: String)->(URL?))? = nil
        /// The handler that gets called whenever a download starts.
        public var didStart: ((WKDownload)->())? = nil
        /// The handler that gets called whenever a download finishes.
        public var didFinish: ((WKDownload)->())? = nil
        /// The handler that gets called whenever a download failed and determines whether a failed download should be tried downloading again.
        public var didFail: ((_ download: WKDownload, _ error: Error, _ resumeData: Data?)->(Bool))? = nil
    }
    
    @available(macOS 11.3, iOS 14.5, *)
    /// The handlers for downloading files.
    public var downloadHandlers: DownloadHandlers {
        get {  return getAssociatedValue(key: "AdvanceWebView_downloadHandlers", object: self, initialValue: DownloadHandlers()) }
        set { set(associatedValue: newValue, key: "AdvanceWebView_downloadHandlers", object: self) }
    }
    
    /// The current downloads.
    public let downloads = SynchronizedArray<WKDownload>()
    
    /// The handler that returns the current url request when the web view finishes loading a website.
    public var requestHandler: ((URLRequest?)->())? = nil
    
    /// The handler that returns the current HTTP cookies when the web view finishes loading a website.
    public var cookiesHandler: (([HTTPCookie]) -> ())? = nil

    /// The current url request.
    public var currentRequest: URLRequest? = nil
    
    /// All HTTP cookies of the current url request.
    public var currentHTTPCookies: [HTTPCookie] = []
    
    internal var delegate: Delegate!
    
    internal let awaitingRequests = SynchronizedArray<URLRequest>()
    internal let awaitingDownloadRequests = SynchronizedArray<URLRequest>()
    internal let sequentialOperationQueue = OperationQueue(maxConcurrentOperationCount: 1)
        
    public init(frame: CGRect) {
        super.init(frame: frame, configuration: .init())
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
    
    internal var isIntialLoadingRequest = false
    public override func load(_ request: URLRequest) -> WKNavigation? {
        self.isIntialLoadingRequest = true
        self.currentRequest = nil
        self.currentHTTPCookies.removeAll()
        self.isIntialLoadingRequest = false

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
            sequentialOperationQueue.maxConcurrentOperationCount = 0
            return super.load(request)
        }
    }
    
    /**
     Starts to download the resource at the URL.

     - Parameters request: An object that encapsulates a URL and other parameters that you need to download a resource from a webpage.
     */
    public func startDownload(_ url: String) {
        guard let url = URL(string: url) else { return }
        self.startDownload(URLRequest(url: url))
    }
    
    /**
     Starts to download the resource at the URL.

     - Parameters request: An object that encapsulates a URL and other parameters that you need to download a resource from a webpage.
     */
    public func startDownload(_ url: URL) {
        self.startDownload(URLRequest(url: url))
    }
    
    /**
     Starts to download the resource at the URL in the request.

     - Parameters request: An object that encapsulates a URL and other parameters that you need to download a resource from a webpage.
     */
    public func startDownload(_ request: URLRequest) {
        self.startDownload(using: request, completionHandler: { _ in  })
    }
    
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
        
        @available(macOS 11.3, iOS 14.5, *)
        func setupDownload(_ download: WKDownload) {
            download.delegate = self
            self.webview.downloads.append(download)
            download.downloadObservation = download.observeChanges(for: \.progress.fractionCompleted, handler: {
                old, new in
                download.progress.updateEstimatedTimeRemaining()
            })
            self.webview.downloadHandlers.didStart?(download)
            self.webview.sequentialOperationQueue.maxConcurrentOperationCount = 1
        }
    }
}

@available(macOS 11.3, iOS 14.5, *)
extension AdvanceWebView.Delegate: WKNavigationDelegate {
    @available(macOS 11.3, iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
        self.setupDownload(download)
    }
        
    @available(macOS 11.3, iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        Swift.debugPrint("navigationResponse didBecome", download.originalRequest?.url ?? "")
        self.setupDownload(download)
    }
        
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if webview.currentRequest != navigationAction.request {
            webview.requestHandler?(navigationAction.request)
        }
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
            self.webview.currentHTTPCookies = cookies
        })
        let shouldDownload = self.webview.downloadHandlers.shouldDownload?(navigationAction.request) ?? false
        if shouldDownload {
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
        Swift.debugPrint("[AdvanceWebView] download downloadLocation", suggestedFilename, response.expectedContentLength)
        let downloadLocation = webview.downloadHandlers.downloadLocation?(response, suggestedFilename)
        completionHandler(downloadLocation)
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
        if let index = webview.downloads.firstIndex(of: download) {
            webview.downloads.remove(at: index)
        }
        if webview.downloadHandlers.didFail?(download, error, resumeData) ?? false {
            guard let resumeData = resumeData else { return }
            self.webview.resumeDownload(fromResumeData: resumeData, completionHandler: { download in
                Swift.debugPrint("[AdvanceWebView] download retry", download.originalRequest?.url ?? "")
                self.webview.downloads.append(download)
            })
        }
    }
    
    public func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        Swift.debugPrint("[AdvanceWebView] download willPerformHTTPRedirection", response, response.url ?? "")
        decisionHandler(.allow)
    }
}

@available(macOS 11.3, iOS 14.5, *)
internal extension WKDownload {
    var downloadObservation: NSKeyValueObservation? {
        get { getAssociatedValue(key: "downloadObservation", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "downloadObservation", object: self) }
    }
}
