//
//  WKWebView+.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS) || os(iOS)
import WebKit

public extension WKWebView {
    /**
     Loads the web content that the specified URL references and navigates to that content.

     Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
     Provide the source of this load request for app activity data by setting the attribution parameter on your request.

     - Parameter url: The URL to the website.
     - Returns:A new navigation object that you use to track the loading progress of the request.
     */
    @discardableResult
    func load(_ url: URL) -> WKNavigation? {
        load(URLRequest(url: url))
    }

    /**
     Loads the web content that the specified URL references and navigates to that content.

     Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
     Provide the source of this load request for app activity data by setting the attribution parameter on your request.

     - Parameter url: The URL to the website.
     - Returns:A new navigation object that you use to track the loading progress of the request.
     */
    @discardableResult
    func load(_ url: String) -> WKNavigation? {
        guard let url = URL(string: url) else { return nil }
        return load(url)
    }

    /// Fetches all stored cookies asynchronously and returns them to the specified completion handler.
    func cookies(completion: @escaping ([HTTPCookie])->()) {
        configuration.websiteDataStore.httpCookieStore.getAllCookies {
            completion($0)
        }
    }

    /// Returns all stored cookies asynchronously.
    func cookies() async -> [HTTPCookie] {
        await configuration.websiteDataStore.httpCookieStore.allCookies()
    }
    
    /// Fetches all cookies for the current webpage asynchronously and returns them to the specified completion handler.
    func cookiesForCurrentPage(completion: @escaping ([HTTPCookie]) -> ()) {
        guard let host = url?.host else {
            completion([])
            return
        }
        cookies { completion($0.filter { $0.domain.contains(host) }) }
    }
    
    /// Returns all cookies for the current webpage asynchronously.
    func cookiesForCurrentPage() async -> [HTTPCookie] {
        guard let host = url?.host else { return [] }
        return await cookies().filter({ $0.domain.contains(host) })
    }

    /**
     Creates and returns an observation object that monitors changes to the web view's cookie store.

     The returned observation begins observing immediately and invokes the handler whenever the cookie store changes.
     
     Retain the returned observation object for as long as observation is required. Observation automatically stops when the observation object is deallocated.

     - Parameters:
        - sendInitial: A Boolean value indicating whether to send the initial cookies to the handler.
        - handler: A closure invoked whenever the cookie store changes. The closure receives the previous cookies and the updated cookies.
     - Returns: An active cookie observation object.
     */
    func observeCookies(sendInitial: Bool = false, handler: @escaping (_ old: [HTTPCookie], _ new: [HTTPCookie]) -> Void) -> WKWebViewCookiesObservation {
        WKWebViewCookiesObservation(storage: configuration.websiteDataStore.httpCookieStore, sendInitial: sendInitial, handler: handler)
    }
}

/**
 An object that observes changes to the cookies of a `WKHTTPCookieStore`.

 Instances begin observing immediately when created and continue observing until invalidated or deallocated.
 
 Retain the observation for as long as observation is required.
 */
public final class WKWebViewCookiesObservation: NSObject {
    private weak var storage: WKHTTPCookieStore?
    private let observer: Observer
    private var didAddObserver = false

    init(storage: WKHTTPCookieStore, sendInitial: Bool, handler: @escaping (_ old: [HTTPCookie], _ new: [HTTPCookie]) -> Void) {
        self.storage = storage
        self.observer = Observer(handler: handler)
        super.init()
        storage.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            self.observer.cookies = cookies
            storage.add(self.observer)
            self.didAddObserver = true
            guard sendInitial else { return }
            handler(cookies, cookies)
        }
    }
    
    /**
     Invalidates the observation.
     
     The method is automatically called when the observation is deinited.
     */
    public func invalidate() {
        guard didAddObserver else { return }
        didAddObserver = false
        storage?.remove(observer)
    }

    deinit {
        invalidate()
    }

    private final class Observer: NSObject, WKHTTPCookieStoreObserver {
        var cookies: [HTTPCookie] = []
        let handler: ([HTTPCookie], [HTTPCookie]) -> Void

        init(handler: @escaping ([HTTPCookie], [HTTPCookie]) -> Void) {
            self.handler = handler
        }

        func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
            cookieStore.getAllCookies { [weak self] newCookies in
                guard let self = self else { return }
                let oldCookies = self.cookies
                guard Set(oldCookies) != Set(newCookies) else { return }
                self.cookies = newCookies
                self.handler(oldCookies, newCookies)
            }
        }
    }
}

#endif
