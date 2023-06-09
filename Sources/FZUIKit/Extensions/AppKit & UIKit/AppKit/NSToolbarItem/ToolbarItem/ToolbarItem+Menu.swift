//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import Cocoa
import SwiftUI

public extension ToolbarItem {
    class Menu: ToolbarItem {
        internal lazy var menuItem: NSMenuToolbarItem = .init(identifier)
        override internal var item: NSToolbarItem {
            return menuItem
        }

        public func showsIndicator(_ showsIndicator: Bool) -> Self {
            menuItem.showsIndicator = showsIndicator
            return self
        }

        public func menu(_ menu: NSMenu) -> Self {
            menuItem.menu = menu
            return self
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
