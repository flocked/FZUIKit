//
//  ToolbarItem+Menu.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

public extension ToolbarItem {
    /**
     A toolbar item that presents a menu.
     
     It can be used as an item of a ``Toolbar``.
     */
    class Menu: ToolbarItem {
        internal lazy var menuItem: NSMenuToolbarItem = .init(identifier)
        override internal var item: NSToolbarItem {
            return menuItem
        }

        @discardableResult
        /// A Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
        public func showsIndicator(_ showsIndicator: Bool) -> Self {
            menuItem.showsIndicator = showsIndicator
            return self
        }
        
        /// A Boolean value that determines whether the toolbar item displays an indicator of additional functionality.
        public var showsIndicator: Bool {
            get { menuItem.showsIndicator }
            set { menuItem.showsIndicator = newValue }
        }

        @discardableResult
        /// The menu presented from the toolbar item.
        public func menu(_ menu: NSMenu) -> Self {
            menuItem.menu = menu
            return self
        }
        
        /// The menu presented from the toolbar item.
        public var menu: NSMenu {
            get { menuItem.menu }
            set { menuItem.menu = newValue }
        }

        public func menu(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            menuItem.menu = NSMenu(items: items())
            return self
        }

        public init(
            _ identifier: NSToolbarItem.Identifier,
            menu: NSMenu
        ) {
            super.init(identifier)
            menuItem.menu = menu
        }

        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            @MenuBuilder _ items: () -> [NSMenuItem]
        ) {
            self.init(identifier, menu: NSMenu(items: items()))
        }
    }
}

#endif
