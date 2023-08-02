//
//  WKWebView+.swift
//  
//
//  Created by Florian Zand on 06.07.23.
//

import WebKit

public extension WKWebView {
    /**
     Returns the html string of the current website to the specified completion block.
     - Parameters completion: The handler that returns the htmlString, or `nil` if no htmlString is available.
     */
    func htmlString(completion: @escaping ((String?)->()))  {
        DispatchQueue.main.async {
            self.evaluateJavaScript("document.body.innerHTML") { result, error in
                let htmlString = result as? String
                completion(htmlString)
            }
        }
    }
    
    /// Returns the html string of the current website.
    func htmlString() -> String? {
        var htmlString: String? = nil
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .default).async {
            self.htmlString(completion: { string in
                htmlString = string
                group.leave()
            })
           }
           group.wait()
           return htmlString
    }
    
    /**
     Loads the web content that the specified URL references and navigates to that content.
     
     Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
     Provide the source of this load request for app activity data by setting the attribution parameter on your request.
     
     - Parameters url: The URL to the website.
     - Returns:A new navigation object that you use to track the loading progress of the request.
     */
    @discardableResult func load(_ url: URL) -> WKNavigation? {
        let request = URLRequest(url: url)
        return self.load(request)
    }
    
    /**
     Loads the web content that the specified URL references and navigates to that content.
     
     Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
     Provide the source of this load request for app activity data by setting the attribution parameter on your request.
     
     - Parameters url: The URL to the website.
     - Returns:A new navigation object that you use to track the loading progress of the request.
     */
    @discardableResult func load(_ url: String) -> WKNavigation? {
        guard let url = URL(string: url) else { return nil }
        return self.load(url)
    }
}
