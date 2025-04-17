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
            let request = URLRequest(url: url)
            return load(request)
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
        
        /// Fetches all stored cookies asynchronously and delivers them to the specified completion handler.
        func cookies(completion: @escaping ([HTTPCookie])->()) {
            configuration.websiteDataStore.httpCookieStore.getAllCookies {
                completion($0)
            }
        }
        
        /// Fetches all stored cookies asynchronously.
        func cookies() async -> [HTTPCookie] {
            await configuration.websiteDataStore.httpCookieStore.allCookies()
        }
    }
#endif
