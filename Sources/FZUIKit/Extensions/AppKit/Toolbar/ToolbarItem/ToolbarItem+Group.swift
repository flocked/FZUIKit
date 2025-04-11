//
//  ToolbarItem+Group.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    extension ToolbarItem {
        /**
         A group of subitems in a toolbar item.

         The item represents a collection set of subitems in a toolbar that the system displays based on available space and settings that you specify. The system uses the views and labels of the subitems, but the parent’s attributes take precedence. This differs from other toolbar items because they’re attached — the user drags them together as a single item rather than separately.
         
         If a subitem of the group has an action set on it, the group uses that action instead of its own when the user clicks or taps on that item. The system prefers the subitem’s action if it exists, otherwise it uses the group’s action.
         */
        open class Group: ToolbarItem {
            
            /// A value that indicates how a group item selects its subitems.
            public typealias SelectionMode = NSToolbarItemGroup.SelectionMode
            
            /// A value that represents how a toolbar displays a group item.
            public typealias ControlRepresentation = NSToolbarItemGroup.ControlRepresentation

            lazy var groupItem = ValidateToolbarItemGroup(for: self)
            override var item: NSToolbarItem {
                groupItem
            }
            
            /// The subitems of the group item.
            open var subitems: [ToolbarItem] = [] {
                didSet {
                    guard oldValue != subitems else { return }
                    groupItem.subitems = subitems.compactMap({ $0.item })
                }
            }

            /// Sets the subitems of the grouped toolbar item.
            @discardableResult
            open func subitems(_ items: [ToolbarItem]) -> Self {
                subitems = items
                return self
            }
            
            /// Sets the subitems of the group item.
            @discardableResult
            open func subitems(@Toolbar.Builder builder: () -> [ToolbarItem]) -> Self {
                subitems = builder()
                return self
            }
            
            /// The selection mode of the grouped toolbar item.
            open var selectionMode: SelectionMode {
                get { groupItem.selectionMode }
                set { groupItem.selectionMode = newValue }
            }

            /// Sets the selection mode of the grouped toolbar item.
            @discardableResult
            open func selectionMode(_ mode: SelectionMode) -> Self {
                groupItem.selectionMode = mode
                return self
            }
            
            /// The value that represents how a toolbar displays the item.
            open var controlRepresentation: ControlRepresentation {
                get { groupItem.controlRepresentation }
                set { groupItem.controlRepresentation = newValue }
            }

            /// Sets the value that represents how a toolbar displays the item.
            @discardableResult
            open func controlRepresentation(_ representation: ControlRepresentation) -> Self {
                groupItem.controlRepresentation = representation
                return self
            }

            /// The index value for the most recently selected subitem.
            open var selectedIndex: Int {
                get { groupItem.selectedIndex }
                set { groupItem.selectedIndex = newValue }
            }
            
            /// Selects the subitem at the specified index.
            @discardableResult
            open func selectItem(at index: Int) -> Self {
                selectedIndex = index
                return self
            }

            /// The index values of the selected items in the group.
            open var selectedIndexes: [Int] {
                get { groupItem.selectedIndexes }
                set { groupItem.selectedIndexes = newValue }
            }
            
            /// Selects the subitems at the specified indexes.
            @discardableResult
            open func selectItems(at indexes: [Int]) -> Self {
                self.selectedIndexes = indexes
                return self
            }

            /**
             Creates a group toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Group` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - selectionMode: The selection mode of the item. The default value is `momentary`.
                - items: The subitems.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .momentary, items: [ToolbarItem]) {
                super.init(identifier)
                subitems = items
                groupItem.subitems = subitems.compactMap({ $0.item })
                groupItem.selectionMode = selectionMode
            }

            /**
             Creates a group toolbar item.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Group` toolbar items.

             - Parameters:
                - identifier: The item identifier.
                - selectionMode: The selection mode of the item. The default value is `momentary`.
                - items: The subitems.
             */
            public convenience init(
                _ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .momentary, view: NSView? = nil, @Toolbar.Builder items: () -> [ToolbarItem]) {
                self.init(identifier, selectionMode: selectionMode, items: items())
                self.item.view = view
            }
        }
    }

class ValidateToolbarItemGroup: NSToolbarItemGroup {
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
