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
            toolbarItem.validateSwizzled(item: self)
        }
        
        /**
         The handler that is called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        public var validateHandler: ((Toolbar.CustomItem)->())?
        
        /**
         Sets the handler that is called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        @discardableResult
        public func validateHandler(_ validation: ((Toolbar.CustomItem)->())?) -> Self {
            self.validateHandler = validation
            return self
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

extension NSToolbarItem {
    func validateSwizzled(item: Toolbar.CustomItem) -> Self {
        swizzleValidate(item: item)
        return self
    }
    
    private var didSwizzleValidate: Bool {
        get { getAssociatedValue("didSwizzleValidate") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleValidate") }
    }
    
    private func swizzleValidate(item: Toolbar.CustomItem) {
        guard !didSwizzleValidate else { return }
        didSwizzleValidate = true
        do {
            try hookAfter(#selector(NSToolbarItem.validate)) {
                item.validate()
                item.validateHandler?(item)
            }
        } catch {
            Swift.print(error)
        }
    }
}

#endif
