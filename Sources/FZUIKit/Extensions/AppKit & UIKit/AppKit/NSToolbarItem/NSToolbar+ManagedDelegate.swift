//
//  File.swift
//  
//
//  Created by Florian Zand on 18.06.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/**
 A toolbar delegate that manages it's items automatically.
 
 Use the items isDefaultItem, isSelectable and isImmovableItem properties.
 */
    public class ManagedToolbarDelegate: NSObject, NSToolbarDelegate {
        public private(set) var items: [NSToolbarItem]
        
        /// The handler gets called whenever an item will be added to the toolbar.
        public var willAddItemHandler: ((NSToolbarItem)->())? = nil
        /// The handler gets called whenever an item gets removed from the toolbar.
        public var didRemoveItemHandler: ((NSToolbarItem)->())? = nil
        /// Handler that determines whether an item can be inserted to the toolbar.
        public var itemCanBeInsertedHandler: ((NSToolbarItem)->(Bool))? = nil

        public func toolbarWillAddItem(_ notification: Notification) {
            if let item = notification.userInfo?["itemKey"] as? NSToolbarItem {
                self.willAddItemHandler?(item)
            }
        }

        public func toolbarDidRemoveItem(_ notification: Notification) {
            if let item = notification.userInfo?["itemKey"] as? NSToolbarItem {
                self.didRemoveItemHandler?(item)
            }
        }

        @available(macOS 13.0, *)
        public func toolbar(_ toolbar: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
            if let item = self.items.first(where: {$0.itemIdentifier == itemIdentifier}) {
                return self.itemCanBeInsertedHandler?(item) ?? true
            }
            return true
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

        
         public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
             return items.filter { $0.isSelectable }.map { $0.itemIdentifier }
         }
          

        public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
            let toolbarItem = items.first { item -> Bool in
                item.itemIdentifier == itemIdentifier
            }
            return toolbarItem
        }

        /**
         Creates a toolbar delegate that manages the specified items automatically.

         Use the items isDefaultItem, isSelectable and isImmovableItem properties.
         
         - Parameters items: An array of toolbar items to be managed by the delegate.
         - Returns: Returns a managed toolbar delegate.
         */
        public init(items: [NSToolbarItem]) {
            self.items = items
            super.init()
        }

        /**
         Creates a toolbar delegate that manages the specified items automatically.
         
         Use NSToolbarItem isDefaultItem, isSelectable and isImmovableItem properties.
         
         - Parameters items: The builder for the toolbar items to be managed by the delegate.
         - Returns: Returns a managed toolbar delegate.
         */
        public convenience init(@NSToolbar.Builder builder: () -> [NSToolbarItem]) {
            self.init(items: builder())
        }
}

#endif
