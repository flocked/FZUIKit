//
//  NSOutlineView+.swift
//  
//
//  Created by Florian Zand on 08.11.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSOutlineView {
    /// The items that are selected.
    public var selectedItems: [Any] {
      selectedRowIndexes.compactMap({ item(atRow: $0) })
    }
    
    /// The items that are currently expanded in the outline view.
    public var expandedItems: [Any] {
        collectItems(isExpanded: true)
    }
    
    /// The items that are currently collapsed in the outline view.
    public var collapsedItems: [Any] {
        collectItems(isExpanded: false)
    }
    
    /**
     Expands a given item.
     
     - Parameters:
        - item: The item to expand.
        - eclusively: A Boolean value indicating whether all currently expanded items should be collapsed.
     */
    public func expandItem(_ item: Any?, eclusively: Bool) {
        if !eclusively {
            expandItem(item)
        } else {
            let expandedItems = expandedItems
            expandItem(item)
            expandedItems.forEach({ collapseItem($0) })
        }
    }
    
    /**
     Expands a specified item and, optionally, its children.
     
     - Parameters:
        - item: The item to expand.
        - expandChildren: A Boolean value indicating whether all child items of `item` should be expanded.
        - eclusively: A Boolean value indicating whether all currently expanded items should be collapsed.
     */
    public func expandItem(_ item: Any?, expandChildren: Bool, eclusively: Bool) {
        if !eclusively {
            expandItem(item, expandChildren: expandChildren)
        } else {
            let expandedItems = expandedItems
            expandItem(item, expandChildren: expandChildren)
            expandedItems.forEach({ collapseItem($0) })
        }
    }
    
    /**
     Selects the specified items.
     
     - Parameters:
        - items: The items to select.
        - extend: `true` if the selection should be extended, `false` if the current selection should be changed.
     */
    public func selectItems(_ items: [Any], byExtendingSelection extend: Bool = false) {
      guard !items.isEmpty else { return }
      items.forEach({ expandItem($0) })
      let rowIndexes = items.compactMap({ row(forItem: $0) }).filter({$0 != -1})
      guard !rowIndexes.isEmpty else { return }
      selectRowIndexes(IndexSet(rowIndexes), byExtendingSelection: extend)
    }
    
    /**
     Deselects the specified items.
     
     - Parameter items: The items to deselect.
     */
    public func deselectItems(_ items: [Any]) {
        let rowIndexes = items.compactMap({ row(forItem: $0) }).filter({$0 != -1})
        deselectRows(at: IndexSet(rowIndexes))
    }
    
    /**
     Scrolls the outline view so the specified item is visible.
     
     - Parameter item: The item.
     */
    public func scrollRowToVisible(_ item: Any) {
        let row = row(forItem: item)
        guard row != -1 else { return }
        scrollRowToVisible(row)
    }
    
    /// A Boolean value indicating whether the indicator view should be centered.
    public var centersIndicator: Bool {
        get { centerIndicatorHook != nil }
        set {
            guard newValue != centersIndicator else { return }
            if newValue {
                do {
                    centerIndicatorHook = try hook(#selector(NSOutlineView.frameOfOutlineCell(atRow:)), closure: {
                        original, outlineview, selector, frame in
                        original(outlineview, selector, frame)
                    } as @convention(block) ((NSOutlineView, Selector, Int) -> CGRect, NSOutlineView, Selector, Int) -> CGRect)
                } catch {
                    Swift.print(error)
                }
            } else {
                try? centerIndicatorHook?.revert()
                centerIndicatorHook = nil
            }
            
        }
    }
    
    /// Sets the Boolean value indicating whether the indicator view should be centered.
    @discardableResult
    public func centersIndicator(_ centersIndicator: Bool) -> Self {
        self.centersIndicator = centersIndicator
        return self
    }
    
    fileprivate var centerIndicatorHook: Hook? {
        get { getAssociatedValue("centerIndicatorHook") }
        set { setAssociatedValue(newValue, key: "centerIndicatorHook") }
    }

    /// Recursively walks the outline view collecting items based on expansion state.
    private func collectItems(isExpanded: Bool, parent: Any? = nil) -> [Any] {
        let childCount = dataSource?.outlineView?(self, numberOfChildrenOfItem: parent) ?? 0
        var result: [Any] = []
        for index in 0..<childCount {
            guard let item = dataSource?.outlineView?(self, child: index, ofItem: parent) else {
                continue
            }

            let expanded = isItemExpanded(item)
            if expanded == isExpanded {
                result += item
            }

            // Only descend into children if the item is expanded
            if expanded {
                result += collectItems(isExpanded: isExpanded, parent: item)
            }
        }
        return result
    }
}

#endif
