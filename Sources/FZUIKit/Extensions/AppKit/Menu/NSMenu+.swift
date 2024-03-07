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
        if handlers.needsDelegate || items.contains(where: {$0.view is MenuItemView}) {
            if delegateProxy == nil {
                delegateProxy = DelegateProxy(self)
            }
        } else if delegateProxy != nil {
            let _delegate = delegateProxy?.delegate
            delegateProxy = nil
            delegate = _delegate
        }
    }
    
    class DelegateProxy: NSObject, NSMenuDelegate {
        var delegate: NSMenuDelegate?
        var delegateObservation: NSKeyValueObservation? = nil
        init(_ menu: NSMenu) {
            self.delegate = menu.delegate
            
            super.init()
            menu.delegate = self
            delegateObservation = menu.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self else { return }
                self.delegate = new
                if new == nil || (new != nil && (new as? NSObject) != self) {
                    self.delegate = new
                    menu.delegate = self
                }
            }
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
        
        func numberOfItems(in menu: NSMenu) -> Int {
            return delegate?.numberOfItems?(in: menu) ?? menu.items.count
        }
        
        func menuNeedsUpdate(_ menu: NSMenu) {
            delegate?.menuNeedsUpdate?(menu)
        }
        
        func menuHasKeyEquivalent(_ menu: NSMenu, for event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>, action: UnsafeMutablePointer<Selector?>) -> Bool {
            if let menuHasKeyEquivalent = delegate?.menuHasKeyEquivalent?(menu, for: event, target: target, action: action) {
                return menuHasKeyEquivalent
            }
            let keyEquivalent = event.readableKeyCode.lowercased()
            return menu.items.contains(where: {$0.keyEquivalent == keyEquivalent && $0.isEnabled})
        }
        
        func confinementRect(for menu: NSMenu, on screen: NSScreen?) -> NSRect {
            delegate?.confinementRect?(for: menu, on: screen) ?? .zero
        }
        
        func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
            delegate?.menu?(menu, update: item, at: index, shouldCancel: shouldCancel) ?? true
        }
        
        func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
            if menu.delegate === self {
                menu.handlers.willHighlight?(item)
            }
            menu.items.compactMap({$0.view as? MenuItemView}).forEach({$0.isHighlighted = false})
            (item?.view as? MenuItemView)?.isHighlighted = true
            delegate?.menu?(menu, willHighlight: item)
        }
    }
}

#endif
