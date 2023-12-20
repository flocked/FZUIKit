//
//  NSTableCellView.swift
//
//
//  Created by Florian Zand on 03.04.23.
//

#if os(macOS)
import AppKit

public extension NSTableCellView {
    /**
     The row view this cell is currently displaying.

     If a cell gets displayed inside a table view this property returns the ´´´NSTableRowView´´.
     */
    var rowView: NSTableRowView? {
        return firstSuperview(for: NSTableRowView.self)
    }

    /**
     The table view this cell is currently displaying.
     */
    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }

    /**
     The index of the column that displays the cell.
     */
    var columnIndex: Int? { rowView?.cellViews.firstIndex(of: self) }

    /**
     A Boolean value that indicates whether the column displaying the cell is selected.
     */
    var isColumnSelected: Bool { if let columnIndex = columnIndex {
        return tableView?.selectedColumnIndexes.contains(columnIndex) ?? false
    }
    return false
    }

    /**
     A Boolean value that indicates whether the row displaying the cell is selected.
     */
    var isRowSelected: Bool { rowView?.isSelected ?? false }
}
#endif
