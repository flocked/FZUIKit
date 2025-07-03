//
//  ToolbarItem+Menu.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

extension Toolbar {
    /**
     A toolbar item that presents a menu.
     
     If you set an action on the item item, the user invokes the action when clicking on it through pressing and holding to display the menu. If you set an action on the item and ``showsIndicator`` to `true`, the system displays the indicator as a separate segment so the user can invoke the menu with a click on that segment.
     
     If you don’t set an action, a simple click invokes the menu, and the indicator is purely decorative.
     */
    open class Menu: ToolbarItem {
        
        fileprivate lazy var menuItem = ValidateMenuToolbarItem(for: self)
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
        open func symbolImage(_ symbolName: String) -> Self {
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
        
        /**
         The handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        public var validateHandler: ((Toolbar.Menu)->())?
        
        /**
         Sets the handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        @discardableResult
        public func validateHandler(_ validation: ((Toolbar.Menu)->())?) -> Self {
            self.validateHandler = validation
            return self
        }
        
        /// The handler that gets called when the user clicks the toolbar item.
        public var actionBlock: ((_ item: Toolbar.Menu)->())? {
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
        
        /// Sets the handler that gets called when the user clicks the toolbar item.
        @discardableResult
        public func onAction(_ action: ((_ item: Toolbar.Menu)->())?) -> Self {
            actionBlock = action
            return self
        }
        
        /// The action method to call when someone clicks on the toolbar item.
        public var action: Selector? {
            get { item.actionBlock == nil ? item.action : nil }
            set {
                actionBlock = nil
                item.action = newValue
            }
        }
        
        /// Sets the action method to call when someone clicks on the toolbar item.
        @discardableResult
        public func action(_ action: Selector?) -> Self {
            self.action = action
            return self
        }
        
        /// The object that defines the action method the toolbar item calls when clicked.
        public var target: AnyObject? {
            get { item.actionBlock == nil ? item.target : nil }
            set {
                actionBlock = nil
                item.target = newValue
            }
        }
        
        /// Sets the object that defines the action method the toolbar item calls when clicked.
        @discardableResult
        public func target(_ target: AnyObject?) -> Self {
            self.target = target
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
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
            super.init(identifier)
            menuItem.menu = NSMenu(items: items())
            self.title = title
        }
        
        /**
         Creates a menu toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Menu` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - image: The image of the item.
            - items: The items of the menu.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, image: NSImage, @MenuBuilder _ items: () -> [NSMenuItem]) {
            super.init(identifier)
            menuItem.menu = NSMenu(items: items())
            self.image = image
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
        public init(_ identifier: NSToolbarItem.Identifier? = nil, symbolName: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
            super.init(identifier)
            menuItem.menu = NSMenu(items: items())
            image = NSImage(systemSymbolName: symbolName)
        }
    }
}

fileprivate class ValidateMenuToolbarItem: NSMenuToolbarItem {
    weak var item: Toolbar.Menu?
    
    init(for item: Toolbar.Menu) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        guard let item = item else { return }
        item.validate()
        item.validateHandler?(item)
    }
}

#endif
