//
//  NSMenu+Handler.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation
import FZSwiftUtils

extension NSMenu {
    /// The handlers for the menu.
    public struct Handlers {
        /// The handlers that gets called when the menu will open.
        public var willOpen: (()->())?
        /// The handlers that gets called when the menu did close.
        public var didClose: (()->())?
        /// The handlers that gets called when the menu will open.
        public var willHighlight: ((NSMenuItem?)->())?
        /// The handler that gets called when the appearance changes.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that gets called before the menu is displayed to be able to update it.
        public var update: ((NSMenu)->())?

        var needsDelegate: Bool {
            willOpen != nil ||
            didClose != nil ||
            willHighlight != nil ||
            effectiveAppearance != nil ||
            update != nil
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
    
    func setupDelegateProxy() {
        if self is NSView.ViewMenuProviderMenu || handlers.needsDelegate || items.contains(where: { $0.needsDelegateProxy }) {
            if delegateProxy == nil {
                delegateProxy = Delegate(self)
            }
        } else if delegateProxy != nil {
            let _delegate = delegateProxy?.delegate
            delegateProxy = nil
            delegate = _delegate
        }
    }
    
    class Delegate: NSObject, NSMenuDelegate {
        weak var delegate: NSMenuDelegate?
        var eventObserver: CFRunLoopObserver?
        var delegateObservation: KeyValueObservation?
        var viewMenuProviderMenu: NSMenu?

        init(_ menu: NSMenu) {
            self.delegate = menu.delegate
            super.init()
            menu.delegate = self
            delegateObservation = menu.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                menu.delegate = self
            }
        }
        
        func menuWillOpen(_ menu: NSMenu) {
            guard menu.delegate === self else { return }
            menu.handlers.willOpen?()
            delegate?.menuWillOpen?(menu)
            viewMenuProviderMenu?.handlers.willOpen?()
        }
        
        func menuDidClose(_ menu: NSMenu) {
            menu.items = menu.items.removeAlternates()
            guard menu.delegate === self else { return }
            menu.handlers.didClose?()
            delegate?.menuDidClose?(menu)
            if eventObserver != nil {
                CFRunLoopObserverInvalidate(eventObserver)
                eventObserver = nil
            }
            if let viewMenu = viewMenuProviderMenu {
                let items = menu.items
                menu.items = []
                viewMenu.items = items
                viewMenuProviderMenu = nil
                viewMenu.handlers.didClose?()
            }
        }
        
        func numberOfItems(in menu: NSMenu) -> Int {
            return delegate?.numberOfItems?(in: menu) ?? menu.items.count
        }
        
        func menuNeedsUpdate(_ menu: NSMenu) {
            guard menu.delegate === self else { return }
            menu.handlers.update?(menu)
            delegate?.menuNeedsUpdate?(menu)
            viewMenuProviderMenu = (menu as? NSView.ViewMenuProviderMenu)?.getMenu()
            if let viewMenu = viewMenuProviderMenu {
                let items = viewMenu.items
                viewMenu.items = []
                menu.items = items
            }
            let optionPressed = NSEvent.modifierFlags.contains([.option])
            menu.items.filter({ $0.visibility != .always }).forEach({ $0.isHidden = !optionPressed })
            if eventObserver == nil, menu.items.contains(where: { $0.visibility == .whileHoldingOption }) {
                eventObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { (observer, activity) in
                    let optionKeyIsPressed = NSEvent.modifierFlags.contains(.option)
                    menu.items.filter({ $0.visibility == .whileHoldingOption }).forEach({$0.isHidden = !optionKeyIsPressed})
                })
                CFRunLoopAddObserver(CFRunLoopGetCurrent(), eventObserver, CFRunLoopMode.commonModes)
            }
            menu.items = menu.items.addAlternates()
            menu.items.forEach({ $0.updateHandler?($0) })
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
            menu.items.forEach({($0.view as? NSMenuItemView)?.isHighlighted = $0 === item })
            viewMenuProviderMenu?.handlers.willHighlight?(item)
            if menu.delegate === self {
                menu.handlers.willHighlight?(item)
            }
            delegate?.menu?(menu, willHighlight: item)
        }
    }
}

fileprivate extension Array where Element: NSMenuItem {
    func addAlternates() -> [NSMenuItem] {
        flatMap { if let alternate = $0.alternateItem { return [$0, alternate] } else { return [$0] } }.uniqued()
    }
    
    func removeAlternates() -> [Element] {
        let alternateSet = Set(compactMap { $0.alternateItem?.objectID })
        return compactMap { alternateSet.contains($0.objectID) ? nil : $0 }
    }
}

fileprivate extension NSMenuItem {
    var objectID: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

#endif
