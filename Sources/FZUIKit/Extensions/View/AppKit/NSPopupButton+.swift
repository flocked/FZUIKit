//
//  NSPopupButton+.swift
//
//
//  Created by Florian Zand on 29.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation

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
    }
#endif
