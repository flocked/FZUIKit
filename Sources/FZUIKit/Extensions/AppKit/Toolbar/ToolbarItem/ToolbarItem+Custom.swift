//
//  ToolbarItem+Custom.swift
//
//
//  Created by Florian Zand on 30.11.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension ToolbarItem {
    /// A custom toolbar item.
    open class Custom<Item: NSToolbarItem>: ToolbarItem {
        /// The `NSToolbarItem` that represents the item.
        public let toolbarItem: Item
        
        override var item: NSToolbarItem {
            toolbarItem.validateSwizzled(item: self)
        }
        
        /**
         Creates a toolbar item with the specified `NSToolbarItem`.
                  
         - Parameter item: The toolbar item.
         */
        public init(item: Item) {
            self.toolbarItem = item
            super.init(item.itemIdentifier)
        }
    }
}

extension NSToolbarItem {
    func validateSwizzled(item: ToolbarItem) -> Self {
        swizzleValidate(item: item)
        return self
    }
    
    private var didSwizzleValidate: Bool {
        get { getAssociatedValue("didSwizzleValidate") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleValidate") }
    }
    
    private func swizzleValidate(item: ToolbarItem) {
        guard !didSwizzleValidate else { return }
        didSwizzleValidate = true
        do {
            try hookAfter(#selector(NSToolbarItem.validate)) {
                item.validate()
            }
        } catch {
            Swift.print(error)
        }
    }
}

#endif
