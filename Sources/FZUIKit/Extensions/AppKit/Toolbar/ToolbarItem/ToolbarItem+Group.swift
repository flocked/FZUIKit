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

         The item can be used with ``Toolbar``.
         */
        class Group: ToolbarItem {
            /// The selection mode of a grouped toolbar item.
            public typealias SelectionMode = NSToolbarItemGroup.SelectionMode
            /// Display style of a grouped toolbar item.
            public typealias ControlRepresentation = NSToolbarItemGroup.ControlRepresentation

            lazy var groupItem = NSToolbarItemGroup(identifier)
            override var item: NSToolbarItem {
                groupItem
            }

            /// The selection mode of the grouped toolbar item.
            @discardableResult
            public func selectionMode(_ mode: SelectionMode) -> Self {
                groupItem.selectionMode = mode
                return self
            }

            /// The selection mode of the grouped toolbar item.
            public var selectionMode: SelectionMode {
                get { groupItem.selectionMode }
                set { groupItem.selectionMode = newValue }
            }

            /// A value that represents how a toolbar displays the grouped toolbar item.
            @discardableResult
            public func controlRepresentation(_ representation: ControlRepresentation) -> Self {
                groupItem.controlRepresentation = representation
                return self
            }

            /// A value that represents how a toolbar displays the grouped toolbar item.
            public var controlRepresentation: ControlRepresentation {
                get { groupItem.controlRepresentation }
                set { groupItem.controlRepresentation = newValue }
            }

            /// The subitems of the grouped toolbar item.
            @discardableResult
            public func subitems(_ items: [NSToolbarItem]) -> Self {
                groupItem.subitems = items
                return self
            }

            /// The subitems of the grouped toolbar item.
            public var subitems: [NSToolbarItem] {
                get { groupItem.subitems }
                set { groupItem.subitems = newValue }
            }

            /// The index value for the most recently selected subitem of the grouped toolbar item.
            @discardableResult
            public func selectedIndex(_ selectedIndex: Int) -> Self {
                self.selectedIndex = selectedIndex
                return self
            }

            /// The index value for the most recently selected subitem of the grouped toolbar item.
            public var selectedIndex: Int {
                get { groupItem.selectedIndex }
                set { groupItem.selectedIndex = newValue }
            }

            /// The index values of the selected items in the group.
            @discardableResult
            public func selectedIndexes(_ selectedIndexes: [Int]) -> Self {
                self.selectedIndexes = selectedIndexes
                return self
            }

            /// The index values of the selected items in the group.
            public var selectedIndexes: [Int] {
                get { groupItem.selectedIndexes }
                set { groupItem.selectedIndexes = newValue }
            }

            /// The subitems of the item.
            @discardableResult
            public func subitems(@NSToolbar.Builder builder: () -> [NSToolbarItem]) -> Self {
                groupItem.subitems = builder()
                return self
            }

            /**
             Creates a group toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - selectionMode: The selection mode of the item. The default value is `momentary`.
                - items: The subitems.
             */
            public init(
                _ identifier: NSToolbarItem.Identifier? = nil,
                selectionMode: SelectionMode = .momentary,
                items: [NSToolbarItem]
            ) {
                super.init(identifier)
                groupItem.subitems = items
                groupItem.selectionMode = selectionMode
            }

            /**
             Creates a group toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - selectionMode: The selection mode of the item. The default value is `momentary`.
                - items: The subitems.
             */
            public convenience init(
                _ identifier: NSToolbarItem.Identifier? = nil,
                selectionMode: SelectionMode = .momentary,
                view: NSView? = nil,
                _ items: NSToolbarItem...
            ) {
                self.init(identifier, selectionMode: selectionMode, items: items)
                self.item.view = view
            }

            /**
             Creates a group toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - selectionMode: The selection mode of the item. The default value is `momentary`.
                - items: The subitems.
             */
            public convenience init(
                _ identifier: NSToolbarItem.Identifier? = nil,
                selectionMode: SelectionMode = .momentary,
                view: NSView? = nil,
                @NSToolbar.Builder items: () -> [NSToolbarItem]
            ) {
                self.init(identifier, selectionMode: selectionMode, items: items())
                self.item.view = view
            }
        }
    }

    public extension NSToolbar {
        /// A function builder type that produces an array of toolbar items.
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
