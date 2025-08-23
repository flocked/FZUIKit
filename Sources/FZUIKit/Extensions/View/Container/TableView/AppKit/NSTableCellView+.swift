//
//  NSTableCellView+.swift
//
//
//  Created by Florian Zand on 03.04.23.
//

#if os(macOS)
import AppKit

public extension NSTableCellView {
    /// The enclosing row view that displays this cell.
    var rowView: NSTableRowView? {
        firstSuperview(for: NSTableRowView.self)
    }

    /// The enclosing table view that displays this cell.
    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }

    /// The row of the table cell, or `nil` if the cell isn't displayed in a table view.
    var row: Int? {
        guard let row = tableView?.row(for: self), row >= 0 else { return nil }
        return row
    }

    /// The index of the column that displays the cell, or `nil` if the cell isn't displayed in a table view.
    var columnIndex: Int? {
        guard let index = tableView?.column(for: self), index >= 0 else { return nil }
        return index
    }

    /// The table column that displays this cell.
    var column: NSTableColumn? {
        guard let columnIndex = columnIndex else { return nil }
        return tableView?.tableColumns[safe: columnIndex]
    }

    /// A Boolean value indicating whether the column displaying the cell is selected.
    var isColumnSelected: Bool {
        tableView?.selectedColumnIndexes.contains(columnIndex ?? -100) ?? false
    }

    /// A Boolean value indicating whether the row displaying the cell is selected.
    var isRowSelected: Bool { rowView?.isSelected ?? false }
}
#endif
