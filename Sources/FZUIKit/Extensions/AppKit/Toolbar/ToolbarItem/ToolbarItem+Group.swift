//
//  ToolbarItem+Group.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    /**
     A group of subitems in a toolbar item.
     
     It can be used as an item of a ``Toolbar``.
     */
    class Group: ToolbarItem {
        public typealias SelectionMode = NSToolbarItemGroup.SelectionMode
        public typealias ControlRepresentation = NSToolbarItemGroup.ControlRepresentation

        internal lazy var groupItem = NSToolbarItemGroup(identifier)
        override internal var item: NSToolbarItem {
            return groupItem
        }

        @discardableResult
        /// The selection mode of the grouped toolbar item.
        public func selectionMode(_ mode: SelectionMode) -> Self {
            groupItem.selectionMode = mode
            return self
        }
        
        /// The selection mode of the grouped toolbar item.
        public var selectionMode: SelectionMode {
            get { groupItem.selectionMode }
            set { groupItem.selectionMode = newValue}
        }

        @discardableResult
        /// A value that represents how a toolbar displays the grouped toolbar item.
        public func controlRepresentation(_ representation: ControlRepresentation) -> Self {
            groupItem.controlRepresentation = representation
            return self
        }
        
        /// A value that represents how a toolbar displays the grouped toolbar item.
        public var controlRepresentation: ControlRepresentation {
            get { groupItem.controlRepresentation }
            set { groupItem.controlRepresentation = newValue}
        }

        @discardableResult
        /// The subitems of the grouped toolbar item.
        public func subitems(_ items: [NSToolbarItem]) -> Self {
            groupItem.subitems = items
            return self
        }
        
        /// The subitems of the grouped toolbar item.
        public var subitems: [NSToolbarItem] {
            get { groupItem.subitems }
            set { groupItem.subitems = newValue}
        }
        
        @discardableResult
        /// The index value for the most recently selected subitem of the grouped toolbar item.
        public func selectedIndex(_ selectedIndex: Int) -> Self {
            self.selectedIndex = selectedIndex
            return self
        }
        
        /// The index value for the most recently selected subitem of the grouped toolbar item.
        public var selectedIndex: Int {
            get { groupItem.selectedIndex }
            set { groupItem.selectedIndex = newValue}
        }
        
        @discardableResult
        /// The index values of the selected items in the group.
        public func selectedIndexes(_ selectedIndexes: [Int]) -> Self {
            self.selectedIndexes = selectedIndexes
            return self
        }
        
        /// The index values of the selected items in the group.
        public var selectedIndexes: [Int] {
            get { groupItem.selectedIndexes }
            set { groupItem.selectedIndexes = newValue}
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
