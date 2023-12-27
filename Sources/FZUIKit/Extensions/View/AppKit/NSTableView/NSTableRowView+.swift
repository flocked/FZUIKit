//
//  NSTableRowView+.swift
//
//
//  Created by Florian Zand on 26.01.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTableRowView {
    /**
     The array of cell views embedded in the current row.

     This array contains zero or more NSTableCellView objects that represent the cell views embedded in the current row view’s content.
     */
    public var cellViews: [NSTableCellView] {
        (0 ..< numberOfColumns).compactMap { self.view(atColumn: $0) as? NSTableCellView }
        //    self.subviews.compactMap({$0 as? NSTableCellView})
    }

    /**
     The  cell views for the column.
     */
    public func cellView(for column: NSTableColumn) -> NSTableCellView? {
        if let index = tableView?.tableColumns.firstIndex(of: column), index < cellViews.count {
            return (view(atColumn: index) as? NSTableCellView)
        }
        return nil
    }

    /**
     The table view that displays the current row view.

     The table view that displays the current row view. The value of this property is nil when the row view is not displayed in a table view.
     */
    public var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }
    
    /// The row index of the row, or `nil` if the row isn't displayed in a table view.
    public var row: Int? {
        guard let tableView = self.tableView else { return nil }
        return tableView.row(for: self)
    }
    
    /// The next row view,  or `nil` if there isn't a next row view or the row isn't displayed in a table view.
    public var nextRowView: Self? {
        guard let tableView = self.tableView, let row = self.row else { return nil }
        return tableView.rowView(atRow: row+1, makeIfNecessary: false) as? Self
    }
    
    /// The previous row view,  or `nil` if there isn't a next row view or the row isn't displayed in a table view.
    public var previousRowView: Self? {
        guard let tableView = self.tableView, let row = self.row else { return nil }
        return tableView.rowView(atRow: row+1, makeIfNecessary: false) as? Self
    }
}
#endif
