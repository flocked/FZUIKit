//
//  NSTableView+.swift
//
//
//  Created by Florian Zand on 09.09.22.
//

#if os(macOS)
    import AppKit

    public extension NSTableView {
        /**
         Reloads the table view on the main thread.

         - Parameters:
            - maintainingSelection: A Boolean value that indicates whether the table view should maintain it's selection after reloading.
            - completionHandler: The handler that gets called when the table view finishes reloading.
         */
        func reloadOnMainThread(maintainingSelection: Bool = false, completionHandler: (() -> Void)? = nil) {
            DispatchQueue.main.async {
                if maintainingSelection {
                    self.reloadMaintainingSelection()
                } else {
                    self.reloadData()
                }
                completionHandler?()
            }
        }

        internal func reloadMaintainingSelection(completionHandler: (() -> Void)? = nil) {
            let selectedRowIndexes = selectedRowIndexes
            reloadData()
            if selectedRowIndexes.isEmpty == false {
                selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
            }
            completionHandler?()
        }

        /**
         Returns the row indexes currently visible.

         - Returns: The array of row indexes corresponding to the currently visible rows.
         */
        func visibleRowIndexes() -> [Int] {
            let visibleRects = visibleRect
            let visibleRange = rows(in: visibleRects)
            var rows = [Int]()
            for i in visibleRange.location ..< visibleRange.location + visibleRange.length {
                rows.append(i)
            }
            return rows
        }

        /**
         Returns the row views currently visible.

         - Returns: The array of row views corresponding to the currently visible row views.
         */
        func visibleRows() -> [NSTableRowView] {
            visibleRowIndexes().compactMap { self.rowView(atRow: $0, makeIfNecessary: false) }
        }

        /**
         Returns the columns currently visible.

         - Returns: The array of columns corresponding to the currently visible table columns.
         */
        var visibleColumns: [NSTableColumn] {
            columnIndexes(in: visibleRect).compactMap { self.tableColumns[$0] }
        }

        /**
         Returns the cell views of a column currently visible.

         - Returns: The array of row views corresponding to the currently visible cell view.
         */
        func visibleCells(for column: NSTableColumn) -> [NSTableCellView] {
            let rowIndexes = visibleRowIndexes()
            var cells = [NSTableCellView]()
            if let columnIndex = tableColumns.firstIndex(of: column) {
                for rowIndex in rowIndexes {
                    if let cellView = view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: false) as? NSTableCellView {
                        cells.append(cellView)
                    }
                }
            }
            return cells
        }

        /**
         Returns the row view at the specified location.

         - Parameter location: The location of the row view.
         - Returns: The row view, or `nil` if there isn't any row view at the location.
         */
        func rowView(at location: CGPoint) -> NSTableRowView? {
            let index = row(at: location)
            guard index >= 0 else { return nil }
            return rowView(atRow: index, makeIfNecessary: false)
        }

        /**
         Returns the table cell view at the specified location.

         - Parameter location: The location of the table cell view.
         - Returns: The table cell view, or `nil` if there isn't any table cell view at the location.
         */
        func cellView(at location: CGPoint) -> NSTableCellView? {
            guard let rowView = rowView(at: location) else { return nil }
            return rowView.cellViews.first(where: { $0.frame.contains(location) })
        }
    }
#endif
