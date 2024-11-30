//
//  ToolbarItem+Menu.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    public extension ToolbarItem {
        /**
         A toolbar item that presents a menu.

         The item can be used with ``Toolbar``.
         */
        class Menu: ToolbarItem {
            
            lazy var menuItem = NSMenuToolbarItem(identifier)
            override var item: NSToolbarItem {
                menuItem
            }
            
            /// The title of the item.
            public var title: String {
                get { menuItem.title }
                set { menuItem.title = newValue }
            }
            
            /// Sets the title of the item.
            @discardableResult
            public func title(_ title: String) -> Self {
                menuItem.title = title
                return self
            }
            
            /// The image of the item.
            public var image: NSImage? {
                get { menuItem.image }
                set { menuItem.image = newValue }
            }
            
            /// Sets the image of the item.
            @discardableResult
            public func image(_ image: NSImage?) -> Self {
                menuItem.image = image
                return self
            }
            
            /// Sets the image of the item.
            @available(macOS 11.0, *)
            public func image(symbolName: String) -> Self {
                menuItem.image = NSImage(systemSymbolName: symbolName)
                return self
            }

            /// Sets the Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
            @discardableResult
            public func showsIndicator(_ showsIndicator: Bool) -> Self {
                menuItem.showsIndicator = showsIndicator
                return self
            }

            /// A Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
            public var showsIndicator: Bool {
                get { menuItem.showsIndicator }
                set { menuItem.showsIndicator = newValue }
            }

            /// Sets the menu presented from the toolbar item.
            @discardableResult
            public func menu(_ menu: NSMenu) -> Self {
                menuItem.menu = menu
                return self
            }

            /// The menu presented from the toolbar item.
            public var menu: NSMenu {
                get { menuItem.menu }
                set { menuItem.menu = newValue }
            }

            /// Sets the menu presented from the toolbar item.
            public func menu(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
                menuItem.menu = NSMenu(items: items())
                return self
            }
            
            /// Sets the action block of the item.
            @discardableResult
            public func onAction(_ action: ((ToolbarItem.Menu)->())?) -> Self {
                menuItem.actionBlock =  { [weak self] _ in
                    guard let self = self else { return }
                    action?(self)
                }
                return self
            }

            /**
             Creates a menu toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the item.
                - image: The image of the item.
                - menu: The menu.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, image: NSImage? = nil, menu: NSMenu) {
                super.init(identifier)
                menuItem.menu = menu
                self.title = title ?? ""
                self.image = image
            }

            /**
             Creates a menu toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the item.
                - image: The image of the item.
                - items: The menu items of the menu.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, image: NSImage? = nil, @MenuBuilder _ items: () -> [NSMenuItem]) {
                self.init(identifier, title: title, image: image, menu: NSMenu(items: items()))
            }
        }
    }

#endif
