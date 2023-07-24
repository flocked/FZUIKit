//
//  ToolbarItem+Group.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import Cocoa

public extension ToolbarItem {
    class Group: ToolbarItem {
        public typealias SelectionMode = NSToolbarItemGroup.SelectionMode
        public typealias ControlRepresentation = NSToolbarItemGroup.ControlRepresentation

        internal lazy var groupItem = NSToolbarItemGroup(identifier)
        override internal var item: NSToolbarItem {
            return groupItem
        }

        @discardableResult
        public func selectionMode(_ mode: SelectionMode) -> Self {
            groupItem.selectionMode = mode
            return self
        }

        @discardableResult
        public func controlRepresentation(_ representation: ControlRepresentation) -> Self {
            groupItem.controlRepresentation = representation
            return self
        }

        @discardableResult
        public func selectddionMode(_ mode: SelectionMode) -> Self {
            groupItem.selectionMode = mode
            return self
        }

        @discardableResult
        public func subitems(_ items: [NSToolbarItem]) -> Self {
            groupItem.subitems = items
            return self
        }

        @discardableResult
        public func subitems(@NSToolbar.Builder builder: () -> [NSToolbarItem]) -> Self {
            groupItem.subitems = builder()
            return self
        }

        public init(
            _ identifier: NSToolbarItem.Identifier,
            selectionMode: SelectionMode = .momentary,
            children: [NSToolbarItem]
        ) {
            super.init(identifier)
            groupItem.subitems = children
            groupItem.selectionMode = selectionMode
        }

        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            selectionMode: SelectionMode = .momentary,
            _ items: NSToolbarItem...
        ) {
            self.init(identifier, selectionMode: selectionMode, children: items)
        }

        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            selectionMode: SelectionMode = .momentary,
            @NSToolbar.Builder builder: () -> [NSToolbarItem]
        ) {
            self.init(identifier, selectionMode: selectionMode, children: builder())
        }
    }
}

public extension NSToolbar {
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ block: [NSToolbarItem]...) -> [NSToolbarItem] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [NSToolbarItem]?) -> [NSToolbarItem] {
            item ?? []
        }

        public static func buildEither(first: [NSToolbarItem]?) -> [NSToolbarItem] {
            first ?? []
        }

        public static func buildEither(second: [NSToolbarItem]?) -> [NSToolbarItem] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSToolbarItem]]) -> [NSToolbarItem] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [NSToolbarItem]?) -> [NSToolbarItem] {
            expr ?? []
        }

        public static func buildExpression(_ expr: NSToolbarItem?) -> [NSToolbarItem] {
            expr.map { [$0] } ?? []
        }

        public static func buildExpression(_ expr: ToolbarItem?) -> [NSToolbarItem] {
            expr.map { [$0.item] } ?? []
        }
    }
}
#endif
