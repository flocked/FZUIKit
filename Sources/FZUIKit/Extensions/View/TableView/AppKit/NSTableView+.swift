//
//  NSTableView+.swift
//
//
//  Created by Florian Zand on 09.09.22.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

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
        
        
        
        var isSelectedRowsObservable: Bool {
            get { selectedRowGestureRecognizer != nil }
            set {
                guard newValue != isSelectedRowsObservable else { return }
                if newValue {
                    selectedRowGestureRecognizer = SelectedRowGestureRecognizer(selectedRows: selectedRowIndexes)
                    addGestureRecognizer(selectedRowGestureRecognizer!)
                } else {
                    selectedRowGestureRecognizer?.removeFromView()
                    selectedRowGestureRecognizer = nil
                }
            }
        }
        
        internal var selectedRowGestureRecognizer: SelectedRowGestureRecognizer? {
            get { getAssociatedValue(key: "selectedRowGestureRecognizer", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "selectedRowGestureRecognizer", object: self) }
        }
        
        internal class SelectedRowGestureRecognizer: NSGestureRecognizer {
            public init(selectedRows: IndexSet) {
                self.selectedRows = selectedRows
                super.init(target: nil, action: nil)
            }
            
            override func mouseDown(with event: NSEvent) {
                super.mouseDown(with: event)
                checkSelection()
            }
            
            override func keyDown(with event: NSEvent) {
                super.keyDown(with: event)
                checkSelection()
            }
            
            func checkSelection() {
                Swift.print("checkSelection", tableView?.selectedRowIndexes.compactMap({$0}).sorted() ?? "nil")
                guard let tableView = tableView, selectedRows != tableView.selectedRowIndexes else { return }
                selectedRows = tableView.selectedRowIndexes
                tableView.willChangeValue(for: \.selectedRowIndexes)
                tableView.didChangeValue(for: \.selectedRowIndexes)
            }
            
            var selectedRows: IndexSet
            
            var tableView: NSTableView? {
                view as? NSTableView
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }


#endif
