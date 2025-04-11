//
//  ToolbarItem+Menu.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    extension ToolbarItem {
        /**
         A toolbar item that presents a menu.

         The item can be used with ``Toolbar``.
         */
        open class Menu: ToolbarItem {
            
            lazy var menuItem = ValidateMenuToolbarItem(for: self)
            override var item: NSToolbarItem {
                menuItem
            }
            
            /// The title of the item.
            open var title: String {
                get { menuItem.title }
                set { menuItem.title = newValue }
            }
            
            /// Sets the title of the item.
            @discardableResult
            open func title(_ title: String) -> Self {
                menuItem.title = title
                return self
            }
            
            /// The image of the item.
            open var image: NSImage? {
                get { menuItem.image }
                set { menuItem.image = newValue }
            }
            
            /// Sets the image of the item.
            @discardableResult
            open func image(_ image: NSImage?) -> Self {
                menuItem.image = image
                return self
            }
            
            /// Sets the image of the item.
            @available(macOS 11.0, *)
            open func image(symbolName: String) -> Self {
                menuItem.image = NSImage(systemSymbolName: symbolName)
                return self
            }

            /// Sets the Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
            @discardableResult
            open func showsIndicator(_ showsIndicator: Bool) -> Self {
                menuItem.showsIndicator = showsIndicator
                return self
            }

            /// A Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
            open var showsIndicator: Bool {
                get { menuItem.showsIndicator }
                set { menuItem.showsIndicator = newValue }
            }
            
            /// The menu presented from the toolbar item.
            open var menu: NSMenu {
                get { menuItem.menu }
                set { menuItem.menu = newValue }
            }

            /// Sets the menu presented from the toolbar item.
            @discardableResult
            open func menu(_ menu: NSMenu) -> Self {
                menuItem.menu = menu
                return self
            }

            /// Sets the menu presented from the toolbar item.
            open func menu(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
                menuItem.menu = NSMenu(items: items())
                return self
            }
            
            /// Sets the handler that gets called when the user clicks the item.
            @discardableResult
            open func onAction(_ action: ((_ item: ToolbarItem.Menu)->())?) -> Self {
                if let action = action {
                    item.actionBlock = { _ in
                        action(self)
                    }
                } else {
                    item.actionBlock = nil
                }
                return self
            }

            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - menu: The menu.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, menu: NSMenu) {
                super.init(identifier)
                menuItem.menu = menu
                title = menu.title
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - title: The title of the item.
                - menu: The menu.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, menu: NSMenu) {
                super.init(identifier)
                menuItem.menu = menu
                self.title = title
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - image: The image of the item.
                - menu: The menu.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, image: NSImage, menu: NSMenu) {
                super.init(identifier)
                menuItem.menu = menu
                self.image = image
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - symbolName: The symbol name for the image of the item.
                - menu: The menu.
             */
            @available(macOS 11.0, *)
            public init(_ identifier: NSToolbarItem.Identifier? = nil, symbolName: String, menu: NSMenu) {
                super.init(identifier)
                menuItem.menu = menu
                image = NSImage(systemSymbolName: symbolName)
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - title: The title of the item.
                - items: The items of the menu.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
                self.init(identifier, title: title, menu: NSMenu(items: items()))
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - image: The image of the item.
                - items: The items of the menu.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, image: NSImage, @MenuBuilder _ items: () -> [NSMenuItem]) {
                self.init(identifier, image: image, menu: NSMenu(items: items()))
            }
            
            /**
             Creates a menu toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - symbolName: The symbol name for the image of the item.
                - items: The items of the menu.
             */
            @available(macOS 11.0, *)
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, symbolName: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
                self.init(identifier, symbolName: symbolName, menu: NSMenu(items: items()))
            }
        }
    }

class ValidateMenuToolbarItem: NSMenuToolbarItem {
    weak var item: ToolbarItem?
    
    init(for item: ToolbarItem) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        item?.validate()
    }
}

#endif
