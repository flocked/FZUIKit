//
//  NSTableCellView+.swift
//
//
//  Created by Florian Zand on 03.04.23.
//

#if os(macOS)
    import AppKit

    public extension NSTableCellView {
        /// The row view that displays this cell.
        var rowView: NSTableRowView? {
            firstSuperview(for: NSTableRowView.self)
        }

        /// The table view that displays this cell.
        var tableView: NSTableView? {
            firstSuperview(for: NSTableView.self)
        }

        /// The row of the table cell, or `nil` if the cell isn't displayed in a table view.
        var row: Int? {
            tableView?.row(for: self)
        }

        /// The index of the column that displays the cell, or `nil` if the cell isn't displayed in a table view.
        var columnIndex: Int? { tableView?.column(for: self) }

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
