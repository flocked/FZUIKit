//
//  ToolbarItem+Custom.swift
//
//
//  Created by Florian Zand on 30.11.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension Toolbar {
    /**
     A custom toolbar item.
     
     Use ``toolbarItem`` to access the underlying `NSToolbarItem` that represents the item.
     */
    open class CustomItem: ToolbarItem {
        /// The `NSToolbarItem` that represents the item.
        public let toolbarItem: NSToolbarItem
        
        override var item: NSToolbarItem {
            toolbarItem.swizzleValidate(for: self)
        }
        
        /**
         Creates a toolbar item with the specified `NSToolbarItem`.
                  
         - Parameter item: The toolbar item.
         */
        public init(item: NSToolbarItem) {
            self.toolbarItem = item
            super.init(item.itemIdentifier)
        }
        
        /**
         Creates a toolbar item with the specified item identifier.
                  
         - Parameter identifier: The toolbar item identifier.
         */
        public override init(_ identifier: NSToolbarItem.Identifier? = nil) {
            self.toolbarItem = NSToolbarItem(itemIdentifier: identifier ?? Toolbar.automaticIdentifier(for: "\(type(of: self))"))
            super.init(toolbarItem.itemIdentifier)
        }
    }
}
#endif
