//
//  NSStatusItem+.swift
//
//
//  Created by Florian Zand on 10.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    extension NSStatusItem {
        /**
         The handler to be called when the status item gets clicked.
         
         To detect right clicks, use ``onRightClick``.
         
         When using this handler, the `action` and `target` of the item's button is set to `nil` and this handler is used  instead.
         */
        public var onClick: (()->())? {
            get { getAssociatedValue(key: "onClick", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "onClick", object: self)
                updateAction()
            }
        }

        /**
         The handler to be called when the status item gets right clicked.
         
         To detect left clicks, use ``onClick``.
         
         When using this handler, the `action` and `target` of the item's button is set to `nil` and this handler is used  instead.
         */
        public var onRightClick: (()->())? {
            get { getAssociatedValue(key: "onRightClick", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "onRightClick", object: self)
                updateAction()
            }
        }
        
        /// The menu that is displayed when the item is right clicked.
        public var rightClickMenu: NSMenu? {
            get { getAssociatedValue(key: "rightClickMenu", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "rightClickMenu", object: self)
                updateAction()
            }
        }
        
        
        
        /// The mouse holding state.
        public enum MouseClickState: Int, Hashable {
            /// The mouse started clicking the item.
            case started
            /// The mouse ended clicking the item.
            case ended
        }
        
        /**
         The handler that gets called when the mouse is clicking and holding the item.
         
         - Parameter state: The mouse holding state.
         */
        public var onMouseHold: ((_ state: MouseClickState)->())? {
            get { getAssociatedValue(key: "onMouseHold", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "onMouseHold", object: self)
                updateAction()
            }
        }
        
        /**
         The handler that gets called when the mouse is right clicking and holding the item.
         
         - Parameter state: The mouse holding state.
         */
        public var onRightMouseHold: ((MouseClickState)->())? {
            get { getAssociatedValue(key: "onRightMouseHold", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "onRightMouseHold", object: self)
                updateAction()
            }
        }

        func updateAction() {
            var mask: NSEvent.EventTypeMask = []
            if onClick != nil {
                mask.insert(.leftMouseUp)
            }

            if onRightClick != nil || rightClickMenu != nil {
                mask.insert(.rightMouseUp)
            }
            
            if onMouseHold != nil {
                mask.insert([.leftMouseDown, .leftMouseUp])
            }
            
            if onRightMouseHold != nil {
                mask.insert([.rightMouseDown, .rightMouseUp])
            }

            button?.sendAction(on: mask)
            if onClick != nil || onRightClick != nil || onMouseHold != nil || onRightMouseHold != nil || rightClickMenu != nil {
                button?.actionBlock = { [weak self] button in
                    guard let self = self, let event = NSApp.currentEvent else { return }
                    switch event.type {
                    case .leftMouseDown:
                        self.onMouseHold?(.started)
                    case .leftMouseUp:
                        self.onMouseHold?(.ended)
                        self.onClick?()
                    case .rightMouseDown:
                        self.onRightMouseHold?(.started)
                    case .rightMouseUp:
                        self.onRightMouseHold?(.ended)
                        self.onRightClick?()
                        if let rightClickMenu = self.rightClickMenu {
                            self.perform(NSSelectorFromString("popUpStatusItemMenu:"), with: rightClickMenu)
                        }
                    default: break
                    }
                }
            } else {
                button?.actionBlock = nil
            }
        }
        
        /// The title of the item's button.
        public var title: String? {
            get { button?.title }
            set { button?.title = newValue ?? "" }
        }
        
        /// The image of the item's button.
        public var image: NSImage? {
            get { button?.image }
            set { button?.image = newValue }
        }

        /**
         Creates a status item with the specified title and menu.

         - Parameters:
            - title: The title to be displayed.
            - menu: The menu of the items.

         - Returns: Returns  the status item.
         */
        public convenience init(title: String, menu: NSMenu) {
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
        public convenience init(title: String, @MenuBuilder items: () -> [NSMenuItem]) {
            self.init(title: title, menu: NSMenu(items: items()))
        }

        /**
         Creates a status item with the specified title and action.

         - Parameters:
            - title: The title to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        public convenience init(title: String, action: @escaping ()->()) {
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
        public convenience init(image: NSImage, menu: NSMenu) {
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
        public convenience init(image: NSImage, @MenuBuilder items: () -> [NSMenuItem]) {
            self.init(image: image, menu: NSMenu(items: items()))
        }

        /**
         Creates a status item with the specified image and action.

         - Parameters:
            - image: The image to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        public convenience init(image: NSImage, action: @escaping ()->()) {
            self.init()
            button?.image = image
            onClick = action
        }

        /**
         Creates a status item with the specified symbol image and menu items.

         - Parameters:
            - symbolName: The symbol name of the image to be displayed.
            - items: The menu items for the status item.

         - Returns: Returns  the status item.
         */
        @available(macOS 11.0, *)
        public convenience init?(symbolName: String, @MenuBuilder items: () -> [NSMenuItem]) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            self.init()
            button?.image = image
            menu = NSMenu(items: items())
        }

        /**
         Creates a status item with the specified symbol image and action.

         - Parameters:
            - symbolName: The symbol name of the image to be displayed.
            - action: The handler to be called when the status item gets clicked.

         - Returns: Returns  the status item.
         */
        @available(macOS 11.0, *)
        public convenience init?(symbolName: String, action: @escaping ()->()) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            self.init()
            button?.image = image
            onClick = action
        }
    }
#endif
