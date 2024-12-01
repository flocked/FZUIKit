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
            
            /// The subitems of the group item.
            public var subitems: [ToolbarItem] = [] {
                didSet {
                    guard oldValue != subitems else { return }
                    updateSubitems()
                }
            }

            /// Sets the subitems of the grouped toolbar item.
            @discardableResult
            public func subitems(_ items: [ToolbarItem]) -> Self {
                subitems = items
                return self
            }
            
            /// Sets the subitems of the group item.
            @discardableResult
            public func subitems(@Toolbar.Builder builder: () -> [ToolbarItem]) -> Self {
                subitems = builder()
                return self
            }

            /// Sets the selection mode of the grouped toolbar item.
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

            /// Sets the value that represents how a toolbar displays the grouped toolbar item.
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

            /// Sets the index value for the most recently selected subitem of the grouped toolbar item.
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

            /// Sets the index values of the selected items in the group.
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
            
            private func updateSubitems() {
                groupItem.subitems = subitems.compactMap({ $0.item })
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
                items: [ToolbarItem]) {
                super.init(identifier)
                subitems = items
                updateSubitems()
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
                @Toolbar.Builder items: () -> [ToolbarItem]) {
                self.init(identifier, selectionMode: selectionMode, items: items())
                self.item.view = view
            }
        }
    }
#endif
