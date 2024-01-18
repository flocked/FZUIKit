//
//  NSStatusItem+.swift
//
//
//  Created by Florian Zand on 10.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSStatusItem {
        /// The handler to be called when the status item gets clicked.
        var onClick: NSButton.ActionBlock? {
            get { getAssociatedValue(key: "statusItemActionBlock", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "statusItemActionBlock", object: self)
                updateAction()
            }
        }

        /// The handler to be called when the status item gets right clicked.
        var onRightClick: NSButton.ActionBlock? {
            get { getAssociatedValue(key: "statusItemRightActionBlock", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "statusItemRightActionBlock", object: self)
                updateAction()
            }
        }

        func updateAction() {
            var mask: NSEvent.EventTypeMask = []
            if onClick != nil {
                mask.insert(.leftMouseUp)
            }

            if onRightClick != nil {
                mask.insert(.rightMouseUp)
            }

            button?.sendAction(on: mask)
            button?.actionBlock = { [weak self] button in
                guard let self = self else { return }
                let event = NSApp.currentEvent!
                if let onRightClick = self.onRightClick, event.type == .rightMouseUp {
                    onRightClick(button)
                } else if event.type == .leftMouseUp, let onClick = self.onClick {
                    onClick(button)
                }
            }
        }

        /**
         Creates a status item with the specified title and menu.

         - Parameters:
            - title: The title to be displayed.
            - menu: The menu of the items.

         - Returns: Returns  the status item.
         */
        convenience init(title: String, menu: NSMenu) {
            self.init()
            button?.title = title
            self.menu = menu
        }

        /**
         Creates a status item with the specified title and menu items.

         - Parameters:
            - title: The title to be displayed.
            - items: The menu items for the status item.

         - Returns: Returns  the status item.
         */
        convenience init(title: String, @MenuBuilder items: () -> [NSMenuItem]) {
            self.init(title: title, menu: NSMenu(items: items()))
        }

        /**
         Creates a status item with the specified title and action.

         - Parameters:
            - title: The title to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        convenience init(title: String, action: @escaping NSButton.ActionBlock) {
            self.init()
            button?.title = title
            onClick = action
        }

        /**
         Creates a status item with the specified image and menu.

         - Parameters:
            - image: The image to be displayed.
            - menu: The menu of the items.

         - Returns: Returns  the status item.
         */
        convenience init(image: NSImage, menu: NSMenu) {
            self.init()
            button?.image = image
            self.menu = menu
        }

        /**
         Creates a status item with the specified image and menu.

         - Parameters:
            - image: The image to be displayed.
            - items: The menu items for the status item.

         - Returns: Returns  the status item.
         */
        convenience init(image: NSImage, @MenuBuilder items: () -> [NSMenuItem]) {
            self.init(image: image, menu: NSMenu(items: items()))
        }

        /**
         Creates a status item with the specified image and action.

         - Parameters:
            - image: The image to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        convenience init(image: NSImage, action: @escaping NSButton.ActionBlock) {
            self.init()
            button?.image = image
            onClick = action
        }

        @available(macOS 11.0, *)
        /**
         Creates a status item with the specified symbol image and menu items.

         - Parameters:
            - symbolName: The symbol name of the image to be displayed.
            - items: The menu items for the status item.

         - Returns: Returns  the status item.
         */
        convenience init?(symbolName: String, @MenuBuilder items: () -> [NSMenuItem]) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            self.init()
            button?.image = image
            menu = NSMenu(items: items())
        }

        @available(macOS 11.0, *)
        /**
         Creates a status item with the specified symbol image and action.

         - Parameters:
            - symbolName: The symbol name of the image to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        convenience init?(symbolName: String, action: @escaping NSButton.ActionBlock) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            self.init()
            button?.image = image
            onClick = action
        }
    }
#endif
