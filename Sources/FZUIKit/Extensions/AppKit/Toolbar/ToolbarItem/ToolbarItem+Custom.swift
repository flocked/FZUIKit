//
//  ToolbarItem+Custom.swift
//
//
//  Created by Florian Zand on 30.11.24.
//

#if os(macOS)
import AppKit

extension ToolbarItem {
    /**
     A custom toolbar item.

     The item can be used with ``Toolbar``.
     */
    open class Custom: ToolbarItem {
        /// The `NSToolbarItem` that represents the item.
        @objc open var toolbarItem: NSToolbarItem
        
        override var item: NSToolbarItem {
            toolbarItem
        }
        
        /**
         Creates a toolbar item with the specified `NSToolbarItem`.
         
         - Parameter item: The tool bar item.
         */
        init(item: NSToolbarItem) {
            self.toolbarItem = item
            super.init(item.itemIdentifier)
        }
    }
}

#endif
