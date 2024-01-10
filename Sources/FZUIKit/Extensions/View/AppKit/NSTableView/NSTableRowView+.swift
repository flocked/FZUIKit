//
//  NSTableRowView+.swift
//
//
//  Created by Florian Zand on 26.01.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSTableRowView {
        /// The cell views that the row view is displaying.
        var cellViews: [NSTableCellView] {
            (0 ..< numberOfColumns).compactMap { self.view(atColumn: $0) as? NSTableCellView }
            //    self.subviews.compactMap({$0 as? NSTableCellView})
        }

        /// The  cell view for the specified column.
        func cellView(for column: NSTableColumn) -> NSTableCellView? {
            if let index = tableView?.tableColumns.firstIndex(of: column), index < cellViews.count {
                return (view(atColumn: index) as? NSTableCellView)
            }
            return nil
        }

        /// The table view that displays the row view.
        var tableView: NSTableView? {
            firstSuperview(for: NSTableView.self)
        }

        /// The row index of the row, or `nil` if the row isn't displayed in a table view.
        var row: Int? {
            guard let tableView = tableView else { return nil }
            return tableView.row(for: self)
        }

        /// The next row view,  or `nil` if there isn't a next row view or the row isn't displayed in a table view.
        var nextRowView: Self? {
            guard let tableView = tableView, let row = row else { return nil }
            return tableView.rowView(atRow: row + 1, makeIfNecessary: false) as? Self
        }

        /// The previous row view,  or `nil` if there isn't a next row view or the row isn't displayed in a table view.
        var previousRowView: Self? {
            guard let tableView = tableView, let row = row else { return nil }
            return tableView.rowView(atRow: row + 1, makeIfNecessary: false) as? Self
        }
    }
#endif
