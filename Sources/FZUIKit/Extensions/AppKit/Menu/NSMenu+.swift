//
//  NSMenu+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

    import AppKit
    import Foundation
    import FZSwiftUtils

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
        
        /// The menu items in the menu.
        @discardableResult
        func items(_ items: [NSMenuItem]) -> Self {
            self.items = items
            return self
        }
        
        /// The menu items in the menu.
        @discardableResult
        func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            self.items = items()
            return self
        }
        
        /// A Boolean value that indicates whether the menu automatically enables and disables its menu items.
        @discardableResult
        func autoenablesItems(_ autoenables: Bool) -> Self {
            autoenablesItems = autoenables
            return self
        }
        
        /// The font of the menu and its submenus.
        @discardableResult
        func font(_ font: NSFont!) -> Self {
            self.font = font
            return self
        }
        
        /// The title of the menu.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// The menu items that are currently selected.
        @available(macOS 14.0, *)
        @discardableResult
        func selectedItems(_ items: [NSMenuItem]) -> Self {
            self.selectedItems = items
            return self
        }
        
        /// The menu items that are currently selected.
        @available(macOS 14.0, *)
        @discardableResult
        func selectedItems(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            self.selectedItems = items()
            return self
        }
        
        /// The selection mode of the menu.
        @available(macOS 14.0, *)
        @discardableResult
        func selectionMode(_ selectionMode: NSMenu.SelectionMode) -> Self {
            self.selectionMode = selectionMode
            return self
        }
        
        /// The minimum width of the menu in screen coordinates.
        @discardableResult
        func minimumWidth(_ minimumWidth: CGFloat) -> Self {
            self.minimumWidth = minimumWidth
            return self
        }
        
        /// The presentation style of the menu.
        @available(macOS 14.0, *)
        @discardableResult
        func presentationStyle(_ presentationStyle: NSMenu.PresentationStyle) -> Self {
            self.presentationStyle = presentationStyle
            return self
        }
        
        /// A Boolean value that indicates whether the pop-up menu allows appending of contextual menu plug-in items.
        @discardableResult
        func allowsContextMenuPlugIns(_ allows: Bool) -> Self {
            allowsContextMenuPlugIns = allows
            return self
        }
        
        /// A Boolean value that indicates whether the menu displays the state column.
        @discardableResult
        func showsStateColumn(_ shows: Bool) -> Self {
            showsStateColumn = shows
            return self
        }
        
        /// Configures the layout direction of menu items in the menu.
        @discardableResult
        func userInterfaceLayoutDirection(_ direction: NSUserInterfaceLayoutDirection) -> Self {
            userInterfaceLayoutDirection = direction
            return self
        }
        
        /// The delegate of the menu.
        @discardableResult
        func delegate(_ delegate: NSMenuDelegate?) -> Self {
            self.delegate = delegate
            return self
        }
        
        /// Adds the specified menu item to the end of the menu.
        @discardableResult
        static func += (_ menu: NSMenu, _ item: NSMenuItem) -> NSMenu {
            menu.addItem(item)
            return menu
        }
    }

extension NSMenu {
    /// The handlers for the menu.
    public struct Handlers {
        /// The handlers that gets called when the menu did close.
        public var didClose: (()->())?
        /// The handlers that gets called when the menu will open.
        public var willOpen: (()->())?
        /// The handlers that gets called when the menu will open.
        public var willHighlight: ((NSMenuItem?)->())?
        
        var needsDelegate: Bool {
            didClose != nil ||
            willOpen != nil ||
            willHighlight != nil
        }
    }
    
    /// Handlers for the menu.
    public var handlers: Handlers {
        get { getAssociatedValue(key: "menuHandlers", object: self, initialValue: Handlers()) }
        set { 
            set(associatedValue: newValue, key: "menuHandlers", object: self)
            setupDelegateProxy()
        }
    }
    
    var delegateProxy: DelegateProxy? {
        get { getAssociatedValue(key: "menuProxy", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "menuProxy", object: self) }
    }
    
    func setupDelegateProxy() {
        if handlers.needsDelegate {
            if delegateProxy == nil {
                delegateProxy = DelegateProxy(self)
            }
        } else if delegateProxy != nil {
            if delegate === delegateProxy {
                delegate = delegateProxy?.delegate
            }
            delegateProxy = nil
        }
    }
    
    class DelegateProxy: NSObject, NSMenuDelegate {
        var delegate: NSMenuDelegate?
        init(_ menu: NSMenu) {
            self.delegate = menu.delegate
            super.init()
            menu.delegate = self
        }
        
        func menuDidClose(_ menu: NSMenu) {
            if menu.delegate === self {
                menu.handlers.didClose?()
            }
            delegate?.menuDidClose?(menu)
        }
        
        func menuWillOpen(_ menu: NSMenu) {
            if menu.delegate === self {
                menu.handlers.willOpen?()
            }
            delegate?.menuWillOpen?(menu)
        }
        
        func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
            if menu.delegate === self {
                menu.handlers.willHighlight?(item)
            }
            delegate?.menu?(menu, willHighlight: item)
        }
    }
}

#endif
