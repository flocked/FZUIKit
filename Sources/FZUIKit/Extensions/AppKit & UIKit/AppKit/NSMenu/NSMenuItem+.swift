//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)

import AppKit
import Foundation
import SwiftUI

public extension NSMenuItem {
    /**
     Initializes and returns a menu item with the specified title.
     - Parameters title: The title of the menu item.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(_ title: String) {
        self.init(title: title)
    }

    /**
     Initializes and returns a menu item with the specified title.
     - Parameters title: The title of the menu item.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(title: String) {
        self.init(title: title, action: nil, keyEquivalent: "")
        isEnabled = true
    }

    /**
     Initializes and returns a menu item with the specified image.
     - Parameters image: The image of the menu item.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(image: NSImage) {
        self.init(title: "")
        self.image = image
    }

    /**
     Initializes and returns a menu item with the view.
     - Parameters view: The view of the menu item.
     - Parameters showsHighlight: A boolean value that indicates whether menu item should highlight on interaction.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(view: NSView, showsHighlight: Bool = true) {
        self.init(title: "")
        if showsHighlight {
            let highlightableView = NSMenuItemHighlightableView(frame: view.frame)
            highlightableView.addSubview(withConstraint: view)
            self.view = highlightableView
        } else {
            self.view = view
        }
    }

    /**
     Initializes and returns a menu item with the `SwiftUI` view.
     - Parameters view: The view of the menu item.
     - Parameters showsHighlight: A boolean value that indicates whether menu item should highlight on interaction.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init<V: View>(showsHighlight: Bool = true, view: V) {
        self.init(title: "")
        self.view = NSMenu.MenuItemHostingView(showsHighlight: showsHighlight, contentView: view)
    }

    /**
     Initializes and returns a menu item with the specified title and submenu containing the specified menu items.
     - Parameters title: The title for the menu item.
     - Parameters items: The items of the submenu.
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(title: String,
                     @MenuBuilder items: () -> [NSMenuItem])
    {
        self.init(title: title)
        submenu = NSMenu(title: "", items: items())
    }
}
#endif
