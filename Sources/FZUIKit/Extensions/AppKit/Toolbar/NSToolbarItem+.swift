//
//  NSToolbarItem+.swift
//
//
//  Created by Florian Zand on 15.09.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

public extension NSToolbarItem {
    /**
     Creates a toolbar item with the specified identifier.

     - Parameter itemIdentifier: The identifier for the toolbar item. You use this value to identify the item within your app, so you don’t need to localize it. For example, your toolbar delegate uses this value to identify the specific toolbar item.

     - Returns: A new toolbar item.
     */
    @objc convenience init(_ itemIdentifier: NSToolbarItem.Identifier) {
        self.init(itemIdentifier: itemIdentifier)
    }
}

extension NSToolbarItem.Identifier: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

#endif
