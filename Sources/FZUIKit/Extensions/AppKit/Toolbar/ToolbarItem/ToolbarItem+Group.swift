//
//  ToolbarItem+Group.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

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
            items[0].isSelectable
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
        
        /// The index for the most recently selected subitem.
        open var lastSelectedIndex: Int? {
            groupItem.selectedIndex >= 0 && groupItem.selectedIndex < subitems.count ? groupItem.selectedIndex : nil
        }
        
        /// The most recently selected subitem.
        open var lastSelectedItem: ToolbarItem? {
            get { subitems[safe: lastSelectedIndex ?? -1] }
        }
        
        /// The index values of the selected items in the group.
        open var selectedIndexes: [Int] {
            get { groupItem.selectedIndexes }
            set { groupItem.selectedIndexes = newValue.uniqued().sorted().clamped(to: 0...subitems.count-1) }
        }
        
        /// Sets the index values of the selected items in the group.
        @discardableResult
        open func selectedIndexes(_ indexes: [Int]) -> Self {
            selectedIndexes = indexes
            return self
        }
        
        /// The selected subitems of the group item.
        open var selectedItems: [ToolbarItem] {
            get {
                let indexes = selectedIndexes
                return subitems.indexed().compactMap({ indexes.contains($0.index) ? $0.element : nil })
            }
            set { selectedIndexes = subitems.indexed().compactMap({ newValue.contains($0.element) ? $0.index : nil }) }
        }
        
        /// Sets the selected subitems of the group item.
        @discardableResult
        open func selectedItems(_ items: [ToolbarItem]) -> Self {
            selectedItems = items
            return self
        }
        
        /**
         Selects the subitem at the specified index by extending the selection.
         
         To only select a item at a specific index, use ``selectedIndexes(_:)``.
         
         - Parameter index: The index of the item to select.
         */
        @discardableResult
        open func selectItem(at index: Int) -> Self {
            groupItem.setSelected(true, at: index)
            return self
        }
        
        /**
         Selects the subitems at the specified indexes.
         
         To only select items at specific indexes, use ``selectedIndexes(_:)``.
         
         - Parameter indexes: The indexes of the items to select.
         */
        @discardableResult
        open func selectItems(at indexes: [Int]) -> Self {
            indexes.clamped(to: 0...subitems.count-1).forEach({ selectItem(at: $0) })
            return self
        }
        
        /**
         The handler that gets called when the user clicks the item.
         
         If a subitem of the group has an action set on it, the group uses that action instead of its own when the user clicks or taps on that item. The system prefers the subitem’s action if it exists, otherwise it uses the ``actionBlock``.
         */
        open var actionBlock: ((_ item: Group)->())? {
            didSet {
                if let actionBlock = actionBlock {
                    groupItem.actionBlock = { _ in
                        actionBlock(self)
                    }
                } else {
                    groupItem.actionBlock = nil
                }
            }
        }
        
        /**
         Sets the handler that gets called when the user clicks the item.
         
         If a subitem of the group has an action set on it, the group uses that action instead of its own when the user clicks or taps on that item. The system prefers the subitem’s action if it exists, otherwise it uses the ``actionBlock``.
         */
        @discardableResult
        open func onAction(_ action: ((_ item: Group)->())?) -> Self {
            actionBlock = action
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
            _ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .momentary, @Toolbar.Builder items: () -> [ToolbarItem]) {
                self.init(identifier, selectionMode: selectionMode, items: items())
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
