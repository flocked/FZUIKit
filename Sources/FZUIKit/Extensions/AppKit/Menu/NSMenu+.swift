//
//  NSMenu+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSMenu {
        /**
         Initializes and returns a menu having the specified menu items.
         - Parameter items: The menu items for the menu.
         - Returns: The initialized `NSMenu` object.
         */
        convenience init(items: [NSMenuItem]) {
            self.init(title: "", items: items)
        }

        /**
         Initializes and returns a menu having the specified title and menu items.

         - Parameters:
            - items: The menu items for the menu.
            - title: The title to assign to the menu.

         - Returns: The initialized `NSMenu` object.
         */
        convenience init(title: String, items: [NSMenuItem]) {
            self.init(title: title)
            self.items = items
        }
    }

#endif
