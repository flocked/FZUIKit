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
        /// The handlers that is called when the menu will open.
        public var willOpen: (()->())?
        /// The handlers that is called when the menu did close.
        public var didClose: (()->())?
        /// The handlers that is called when the menu is about to highlight a given item.
        public var willHighlight: ((NSMenuItem?)->())?
        /// The handler that is called when the appearance changed.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that is called before the menu is displayed allowing you to update it.
        public var update: ((_ menu: NSMenu)->())?

        var needsDelegate: Bool {
            willOpen != nil || didClose != nil || willHighlight != nil || effectiveAppearance != nil || update != nil
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
    
    /// Sets the handler that is called before the menu is displayed allowing you to update it.
    @discardableResult
    public func updateHandler(_ handler: ((_ menu: NSMenu)->())?) -> Self {
        handlers.update = handler
        return self
    }
    
    fileprivate var effectiveAppearanceObservation: KeyValueObservation? {
        get { getAssociatedValue("effectiveAppearanceObservation") }
        set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
    }
    
    fileprivate var delegateProxy: Delegate? {
        get { getAssociatedValue("delegateProxy") }
        set { setAssociatedValue(newValue, key: "delegateProxy") }
    }
    
    func setupDelegateProxy() {
        if handlers.needsDelegate || items.contains(where: { $0.needsDelegateProxy }) {
            guard delegateProxy == nil else { return }
            delegateProxy = .init(self)
        } else if delegateProxy != nil {
            let _delegate = delegateProxy?.delegate
            delegateProxy = nil
            delegate = _delegate
        }
    }
    
    fileprivate class Delegate: NSObject, NSMenuDelegate {
        weak var delegate: NSMenuDelegate?
        var eventObserver: CFRunLoopObserver?
        var delegateObservation: KeyValueObservation?
        var menuMinimumWidth: CGFloat?
        static let supportedSelectors = [#selector(NSMenuDelegate.menuWillOpen(_:)), #selector(NSMenuDelegate.menuDidClose(_:)), #selector(NSMenuDelegate.menuNeedsUpdate(_:)), #selector(NSMenuDelegate.menu(_:willHighlight:))]

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
        
        override func responds(to selector: Selector!) -> Bool {
            if Self.supportedSelectors.contains(selector) {
                return true
            }
            return delegate?.responds(to: selector) ?? false
        }
        
        override func forwardingTarget(for selector: Selector!) -> Any? {
            if delegate?.responds(to: selector) == true {
                return delegate
            }
            return super.forwardingTarget(for: selector)
        }
        
        func menuWillOpen(_ menu: NSMenu) {
            menu.handlers.willOpen?()
            delegate?.menuWillOpen?(menu)
        }
        
        func menuDidClose(_ menu: NSMenu) {
            menu.items = menu.items.withoutAlternates()
            menu.handlers.didClose?()
            delegate?.menuDidClose?(menu)
            if eventObserver != nil {
                CFRunLoopObserverInvalidate(eventObserver)
                eventObserver = nil
            }
            if let minimumWidth = menuMinimumWidth {
                menu.minimumWidth = minimumWidth
                menuMinimumWidth = nil
            }
        }
        
        func menuNeedsUpdate(_ menu: NSMenu) {
            menu.handlers.update?(menu)
            delegate?.menuNeedsUpdate?(menu)
            let optionPressed = NSEvent.modifierFlags.contains([.option])
            menu.items.filter({ $0.visibility != .always }).forEach({ $0.isHidden = !optionPressed })
            if eventObserver == nil, menu.items.contains(where: { $0.visibility == .whileHoldingOption }) {
                eventObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { (observer, activity) in
                    let optionKeyIsPressed = NSEvent.modifierFlags.contains(.option)
                    menu.items.filter({ $0.visibility == .whileHoldingOption }).forEach({$0.isHidden = !optionKeyIsPressed})
                })
                CFRunLoopAddObserver(CFRunLoopGetCurrent(), eventObserver, CFRunLoopMode.commonModes)
            }
            let itemsCount = menu.items.count
            menu.items = menu.items.withAlternates()
            menu.items.forEach({ $0.updateHandler?($0) })
            if menu.autoUpdatesWidth, itemsCount != menu.items.count {
                menuMinimumWidth = menu.minimumWidth
                menu.minimumWidth = max(menu.minimumWidth, menu.size.width)
            } else if let minimumWidth = menuMinimumWidth {
                menu.minimumWidth = minimumWidth
            }
        }
        
        func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
            menu.items.forEach({($0.view as? NSMenuItemView)?.isHighlighted = $0 === item })
            menu.handlers.willHighlight?(item)
            delegate?.menu?(menu, willHighlight: item)
        }
    }
}

fileprivate extension [NSMenuItem] {
    func withAlternates() -> [NSMenuItem] {
        flatMap { if let alternate = $0.alternateItem, !alternate.keyEquivalentModifierMask.isEmpty { return [$0, alternate] } else { return [$0] } }.uniqued()
    }
    
    func withoutAlternates() -> [Element] {
        let alternateSet = Set(compactMap { $0.alternateItem?.objectID })
        return compactMap { alternateSet.contains($0.objectID) ? nil : $0 }
    }
}

#endif
