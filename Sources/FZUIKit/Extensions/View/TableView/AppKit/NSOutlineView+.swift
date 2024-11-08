//
//  NSOutlineView+.swift
//  
//
//  Created by Florian Zand on 08.11.24.
//

#if os(macOS)

import AppKit

extension NSOutlineView {
    /// Returns the selected items.
    public var selectedItems: [Any] {
      selectedRowIndexes.compactMap({ item(atRow: $0) })
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
}

#endif
