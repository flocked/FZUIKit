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
        
        /**
         Adds a menu item and it's alternative to the end of the menu.
         
         The anternate item is displayed, when the specified modifier mask is pressed by the user.
         
         - Parameters:
            - item: The menu item to add to the menu.
            - alternative: The alternative menu item to add to the menu.
            - modifierMask: The modifier mask for displaying the alternate menu item. The default value is `option.`
         */
        func addItem(_ item: NSMenuItem, alternate: NSMenuItem, modifierMask: NSEvent.ModifierFlags = [.option]) {
            addItem(item)
            addItem(alternate.isAlternate(true).keyEquivalentModifierMask(modifierMask))
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
        
        /**
         Inserts menu items into the menu at a specific location.
         
         - Parameters:
            - items: The menu items to insert.
            - index: An integer index identifying the location of the menu item in the menu.
         */
        func insertItems(_ items: [NSMenuItem], at index: Int) {
            items.reversed().forEach({ insertItem($0, at: index) })
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
        /// The handler that gets called when the appearance changes.
        public var effectiveAppearance: ((NSAppearance)->())?

        var needsDelegate: Bool {
            willOpen != nil ||
            didClose != nil ||
            willHighlight != nil ||
            effectiveAppearance != nil
        }
    }
    
    /// Handlers for the menu.
    public var handlers: Handlers {
        get { getAssociatedValue("menuHandlers", initialValue: Handlers()) }
        set { 
            setAssociatedValue(newValue, key: "menuHandlers")
            setupDelegateProxy()
            if newValue.effectiveAppearance != nil {
                effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.handlers.effectiveAppearance?(new)
                }
            } else {
                effectiveAppearanceObservation = nil
            }
        }
    }
    
    var effectiveAppearanceObservation: KeyValueObservation? {
        get { getAssociatedValue("effectiveAppearanceObservation") }
        set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
    }
    
    var delegateProxy: Delegate? {
        get { getAssociatedValue("delegateProxy") }
        set { setAssociatedValue(newValue, key: "delegateProxy") }
    }
    
    func setupDelegateProxy(itemProviderView: NSView? = nil) {
        if itemProviderView != nil ||  items.contains(where: { $0.visiblity != .normal }) || handlers.needsDelegate {
            if delegateProxy == nil {
                delegateProxy = Delegate(self)
            }
            delegateProxy?.itemProviderView = itemProviderView
        } else if delegateProxy != nil {
            let _delegate = delegateProxy?.delegate
            delegateProxy = nil
            delegate = _delegate
        }
    }
    
    class Delegate: NSObject, NSMenuDelegate {
        weak var delegate: NSMenuDelegate?
        weak var itemProviderView: NSView?
        var eventObserver: CFRunLoopObserver?
        var delegateObservation: KeyValueObservation?
        
        init(_ menu: NSMenu) {
            self.delegate = menu.delegate
            super.init()
            menu.delegate = self
            delegateObservation = menu.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new as? NSObject != self else { return }
                self.delegate = new
                menu.delegate = self
            }
        }
        
        func menuWillOpen(_ menu: NSMenu) {
            guard menu.delegate === self else { return }
            menu.handlers.willOpen?()
            let optionPressed = NSEvent.current?.modifierFlags.contains([.option]) == true
            menu.items.filter({ $0.visiblity != .normal }).forEach({ $0.isHidden = !optionPressed })
            delegate?.menuWillOpen?(menu)
            let hiddenOptionItems = menu.items.filter({ $0.visiblity == .optionHold })
            if !hiddenOptionItems.isEmpty, eventObserver == nil {
                eventObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { (observer, activity) in
                    self.menuRecievedEvents(menu: menu)
                })
                CFRunLoopAddObserver(CFRunLoopGetCurrent(), eventObserver, CFRunLoopMode.commonModes)
            }
        }
        
        func menuDidClose(_ menu: NSMenu) {
            guard menu.delegate === self else { return }
            menu.handlers.didClose?()
            delegate?.menuDidClose?(menu)
            if eventObserver != nil {
                CFRunLoopObserverInvalidate(eventObserver)
                eventObserver = nil
            }
            if itemProviderView?.menu == menu {
                itemProviderView?.menu = nil
            }
            itemProviderView = nil
        }
        
        func menuRecievedEvents(menu: NSMenu) {
            let optionKeyIsPressed = CGEvent(source: nil)?.flags.contains(.maskAlternate) == true
            menu.items.filter({ $0.visiblity == .optionHold }).forEach({$0.isHidden = !optionKeyIsPressed})
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
            delegate?.menu?(menu, willHighlight: item)
        }
    }
}

#endif
