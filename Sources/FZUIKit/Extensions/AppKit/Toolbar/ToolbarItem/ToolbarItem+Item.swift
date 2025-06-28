//
//  ToolbarItem+item.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

extension ToolbarItem {
    /// A toolbar item.
    open class Item: ToolbarItem {
        fileprivate lazy var rootItem = ValidateToolbarItem(for: self)
        
        override var item: NSToolbarItem {
            rootItem
        }
        
        /// The title of the item.
        open var title: String {
            get { item.title }
            set { item.title = newValue }
        }
        
        /// Sets the title of the item.
        @discardableResult
        open func title(_ title: String) -> Self {
            item.title = title
            return self
        }
        
        /// The image of the item, or `nil` if none.
        open var image: NSImage? {
            get { item.image }
            set { item.image = newValue }
        }
        
        /// Sets the image of the item, or `nil` if none.
        @discardableResult
        open func image(_ image: NSImage?) -> Self {
            item.image = image
            return self
        }
        
        /// Sets the image with the specified symbol name.
        @available(macOS 11.0, *)
        @discardableResult
        open func symbolImage(_ symbolName: String) -> Self {
            item.image = NSImage(systemSymbolName: symbolName)
            return self
        }
        
        /// A Boolean value that indicates whether the toolbar item has a bordered style.
        open var isBordered: Bool {
            get { item.isBordered }
            set { item.isBordered = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar item has a bordered style.
        @discardableResult
        open func bordered(_ isBordered: Bool) -> Self {
            item.isBordered = isBordered
            return self
        }
        
        /// A Boolean value that indicates whether the toolbar item behaves as a navigation item in the toolbar.
        @available(macOS 11.0, *)
        open var isNavigational: Bool {
            get { item.isNavigational }
            set { item.isNavigational = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar item behaves as a navigation item in the toolbar.
        @available(macOS 11.0, *)
        @discardableResult
        open func isNavigational(_ isNavigational: Bool) -> Self {
            item.isNavigational = isNavigational
            return self
        }
        
        /// The handler that gets called when the user clicks the item.
        open var actionBlock: ((_ item: Item)->())? {
            didSet {
                if let actionBlock = actionBlock {
                    item.actionBlock = { _ in
                        actionBlock(self)
                    }
                } else {
                    item.actionBlock = nil
                }
            }
        }
        
        /// Sets the handler that gets called when the user clicks the item.
        @discardableResult
        open func onAction(_ action: ((_ item: Item)->())?) -> Self {
            actionBlock = action
            return self
        }
        
        /**
         Creates a toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Item` toolbar items.
         
         - Parameter identifier: The item identifier.
         */
        public override init(_ identifier: NSToolbarItem.Identifier? = nil) {
            super.init(identifier)
        }
        
        /**
         Creates a toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Item` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - action: The handler that gets called when the user clicks the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, action: ((_ item: Item)->())? = nil) {
            super.init(identifier)
            self.title = title
            defer { actionBlock = action }
        }
        
        /**
         Creates a toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Item` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - image: The image of the button.
            - action: The handler that gets called when the user clicks the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, image: NSImage, action: ((_ item: Item)->())? = nil) {
            super.init(identifier)
            self.title = title ?? ""
            self.image = image
            defer { actionBlock = action }
        }
        
        /**
         Creates a toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Item` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - symbolName: The name for the symbol image of the button.
            - action: The handler that gets called when the user clicks the item.
         */
        @available(macOS 11.0, *)
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, symbolName: String, action: ((_ item: Item)->())? = nil) {
            super.init(identifier)
            self.title = title ?? ""
            self.image = NSImage(systemSymbolName: symbolName)
            defer { actionBlock = action }
        }
    }
}
#endif
