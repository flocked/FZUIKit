//
//  NSToolbar+.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSToolbar {
    public convenience init(
        identifier: NSToolbar.Identifier,
        items: [NSToolbarItem]
    ) {
        self.init(identifier: identifier)
        setupDelegateProxy(items: items)
    }

    public convenience init(
        identifier: NSToolbar.Identifier,
        @Builder builder: () -> [NSToolbarItem]
    ) {
        self.init(identifier: identifier, items: builder())
    }

    public convenience init(
        _ identifier: NSToolbar.Identifier,
        @Builder builder: () -> [NSToolbarItem]
    ) {
        self.init(identifier: identifier, items: builder())
    }

    public var itemSelectionHandler: ((NSToolbarItem.Identifier?) -> Void)? {
        get { getAssociatedValue(key: "_toolbarItemSelectionHandler", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_toolbarItemSelectionHandler", object: self)
            setupToolbarItemSelectionObserver()
        }
    }

    internal var toolbarItemSelectionObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_toolbarItemSelectionObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_toolbarItemSelectionObserver", object: self)
        }
    }

    internal func setupToolbarItemSelectionObserver() {
        if itemSelectionHandler != nil {
            if toolbarItemSelectionObserver == nil {
                toolbarItemSelectionObserver = observeChange(\.selectedItemIdentifier) { [weak self] _,_, itemIdentifier in
                    guard let self = self else { return }
                    self.itemSelectionHandler?(itemIdentifier)
                }
            }
        } else {
            toolbarItemSelectionObserver = nil
        }
    }

    internal var delegateProxy: DelegateProxy? {
        get { getAssociatedValue(key: "_toolbarDelegateProxy", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_toolbarDelegateProxy", object: self)
        }
    }

    internal func setupDelegateProxy(items: [NSToolbarItem]) {
        if delegateProxy == nil {
            delegateProxy = DelegateProxy(self, items: items)
        }
    }
}

internal extension NSToolbar {
    class DelegateProxy: NSObject, NSToolbarDelegate {
        internal weak var toolbar: NSToolbar!
        internal weak var delegate: NSToolbarDelegate? = nil
        internal var items: [NSToolbarItem]

        func toolbarWillAddItem(_ notification: Notification) {
            delegate?.toolbarWillAddItem?(notification)
        }

        func toolbarDidRemoveItem(_ notification: Notification) {
            delegate?.toolbarDidRemoveItem?(notification)
        }

        @available(macOS 13.0, *)
        func toolbar(_ toolbar: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
            return delegate?.toolbar?(toolbar, itemIdentifier: itemIdentifier, canBeInsertedAt: index) ?? true
        }

        public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            return items.filter { $0.isDefaultItem }
                .map { $0.itemIdentifier }
        }

        public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
            return Set(items.filter { $0.isImmovableItem }
                .map { $0.itemIdentifier })
        }

        public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            var items = items.map { $0.itemIdentifier }
            items.append(contentsOf: [.flexibleSpace, .space])
            return items.uniqued()
        }

        /*
         public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
             return items.filter { $0.isSelectable }.map { $0.itemIdentifier }
         }
          */

        public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
            let toolbarItem = items.first { item -> Bool in
                item.itemIdentifier == itemIdentifier
            }
            return toolbarItem
        }

        public init(_ toolbar: NSToolbar, items: [NSToolbarItem]?) {
            self.toolbar = toolbar
            self.items = items ?? toolbar.items
            super.init()
            delegate = self.toolbar.delegate
            self.toolbar.delegate = self
        }

        public convenience init(
            toolbar: NSToolbar,
            @Builder builder: () -> [NSToolbarItem]
        ) {
            self.init(toolbar, items: builder())
        }

        public convenience init(
            _ toolbar: NSToolbar,
            @Builder builder: () -> [NSToolbarItem]
        ) {
            self.init(toolbar, items: builder())
        }
    }
}
#endif
