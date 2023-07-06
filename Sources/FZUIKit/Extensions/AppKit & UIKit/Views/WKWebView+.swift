//
//  WKWebView+.swift
//  
//
//  Created by Florian Zand on 06.07.23.
//

import WebKit

public extension WKWebView {
    /**
     Returns html string of the current website to the specified completion block.
     - Parameters completion: The handler that returns the htmlString, or `nil` if no htmlString is available.
     */
    func htmlString(completion: @escaping ((String?)->()))  {
        self.evaluateJavaScript("document.body.innerHTML") { result, error in
            let htmlString = result as? String
            completion(htmlString)
        }
    }
}
