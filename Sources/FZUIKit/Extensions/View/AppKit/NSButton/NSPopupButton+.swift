//
//  NSPopupButton+.swift
//
//
//  Created by Florian Zand on 29.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation
    import FZSwiftUtils

    public extension NSPopUpButton {
        /**
         Creates a popup button with the specified menu items.

         - Parameters:
            - items: An array of menu items.
            - pullsDown: `true` if you want the receiver to display a pull-down menu; otherwise, `false` if you want it to display a pop-up menu.
            - action: The action block of the button.

         - Returns: An initialized `NSPopUpButton` object.
         */
        convenience init(items: [NSMenuItem], pullsDown _: Bool = false, action: ActionBlock? = nil) {
            self.init()
            self.items = items
            actionBlock = action
        }

        /**
         Creates a popup button with the titles.

         - Parameters:
            - titles: An array of titles.
            - pullsDown: `true` if you want the receiver to display a pull-down menu; otherwise, `false` if you want it to display a pop-up menu.
            - action: The action block of the button.

         - Returns: An initialized `NSPopUpButton` object.
         */
        convenience init(titles: [String], pullsDown _: Bool = false, action: ActionBlock? = nil) {
            self.init()
            items = titles.compactMap { NSMenuItem($0) }
            actionBlock = action
        }

        /**
         Creates a popup button with the titles.

         - Parameters:
            - pullsDown: `true` if you want the receiver to display a pull-down menu; otherwise, `false` if you want it to display a pop-up menu.
            - items: The menu items of the popup button.

         - Returns: An initialized `NSPopUpButton` object.
         */
        convenience init(pullsDown _: Bool = false, @MenuBuilder items: () -> [NSMenuItem]) {
            self.init()
            self.items = items()
        }

        /**
         The menu items.
         */
        var items: [NSMenuItem] {
            get {
                menu?.items ?? []
            }
            set {
                if let menu = menu {
                    let selectedItemTitle = titleOfSelectedItem
                    menu.items = newValue
                    if let selectedItemTitle = selectedItemTitle, let item = newValue.first(where: { $0.title == selectedItemTitle }) {
                        select(item)
                    }
                } else {
                    menu = NSMenu(items: newValue)
                }
            }
        }
        
        /// A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        @discardableResult
        func pullsDown(_ pullsDown: Bool) -> Self {
            self.pullsDown = pullsDown
            return self
        }
        
        /// A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        @discardableResult
        func autoenablesItems(_ autoenables: Bool) -> Self {
            autoenablesItems = autoenables
            return self
        }
        
        /// The menu associated with the pop-up button.
        @discardableResult
        func menu(_ menu: NSMenu?) -> Self {
            self.menu = menu
            return self
        }
        
        /// The menu associated with the pop-up button.
        func menu(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            menu = NSMenu(items: items())
            return self
        }
        
        /// The edge of the button on which to display the menu when screen space is constrained.
        @discardableResult
        func preferredEdge(_ preferredEdge: NSRectEdge) -> Self {
            self.preferredEdge = preferredEdge
            return self
        }
        
        /**
         Returns the menu item with the specified tag.
         
         - Parameter tag: A numeric tag associated with a menu item.
         - Returns: The menu item, or `nil` if no item with the specified tag exists in the menu.
         */
        func item(withTag tag: Int) -> NSMenuItem? {
            menu?.item(withTag: tag)
        }
    }
#endif
