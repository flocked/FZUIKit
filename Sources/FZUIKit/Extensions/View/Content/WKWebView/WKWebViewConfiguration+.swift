//
//  WKWebViewConfiguration+.swift
//  
//
//  Created by Florian Zand on 08.01.26.
//

#if os(macOS) || os(iOS) || os(visionOS)
import WebKit

extension WKWebViewConfiguration {
    /// A configuration that stores website data in memory, and doesn’t write that data to disk.
    public static func nonPersistent() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        return configuration
    }
}
#endif
