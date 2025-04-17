//
//  HTMLStringLoadingTask.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

#if os(macOS) || os(iOS)
import WebKit
import FZSwiftUtils

/// Loads the html string of a website asynchronous.
class HTMLStringLoadingTask: NSObject {
    
    /// The state of the html string loading.
    @objc public enum State: Int, Codable, Hashable {
        case running
        case suspended
        case finished
        case cancelled
    }

    /// The state of the html string loading.
    @objc public dynamic private(set) var state: State = .running
    
    private let webview = WKWebView(frame: .zero, configuration: .init())
    private var loadingObservation: KeyValueObservation!
    private let request: URLRequest
    
    /// Resumes the task, if it is suspended.
    public func resume() {
        guard state == .suspended else { return }
        state = .running
        webview.load(request)
    }
    
    /// Temporarily suspends a task.
    public func suspend() {
        guard state == .running else { return }
        state = .suspended
        webview.stopLoading()
    }
    
    /// Cancels the task.
    public func cancel() {
        guard state != .finished else { return }
        state = .cancelled
        webview.stopLoading()
    }
    
    private init(request: URLRequest, handler: @escaping (String?)->()) {
        self.request = request
        super.init()
        loadingObservation = webview.observeChanges(for: \.isLoading) { [weak self] oldValue, newValue in
            guard let self = self, self.state == .running else { return }
            if !newValue {
                self.state = .finished
                self.webview.html.string(completion: handler)
            }
        }
        webview.load(request)
    }
    
    private convenience init(url: URL, handler: @escaping (String?)->()) {
        self.init(request: URLRequest(url: url), handler: handler)
    }
    
    private convenience init?(url: String, handler: @escaping (String?)->()) {
        guard let url = URL(string: url) else { return nil }
        self.init(request: URLRequest(url: url), handler: handler)
    }
}

extension HTMLStringLoadingTask {
    /// Returns a html string loading task for the specified url request.
    public static func loadString(for request: URLRequest, handler: @escaping (_ htmlString: String?)->()) -> HTMLStringLoadingTask {
        HTMLStringLoadingTask(request: request, handler: handler)
    }
    
    /// Returns a html string loading task for the specified url.
    public static func loadString(for url: URL, handler: @escaping (_ htmlString: String?)->()) -> HTMLStringLoadingTask {
        HTMLStringLoadingTask(request: URLRequest(url: url), handler: handler)
    }
    
    /// Returns a html string loading task for the specified url.
    public static func loadString(for url: String, handler: @escaping (_ htmlString: String?)->()) -> HTMLStringLoadingTask? {
        guard let url = URL(string: url) else { return nil }
        return HTMLStringLoadingTask(request: URLRequest(url: url), handler: handler)
    }
}
#endif
