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
        /// Creates a table view with an enclosing scroll view.
        static func scrolling() -> NSTableView {
            let tableView = NSTableView()
            tableView.addEnclosingScrollView()
            return tableView
        }
        
        /// Toggles the sorting order of the sort descriptor.
        func toggleSortDescriptorOrder() {
            var sortDescriptors = sortDescriptors
            if let reversed = sortDescriptors.first?.reversed {
                sortDescriptors.removeFirst()
                sortDescriptors = [reversed] + sortDescriptors
                self.sortDescriptors = sortDescriptors
            }
        }
        
        /**
         An index set containing the indexes for a right event.
         
         - Parameter event: The right click event.
         
         The returned indexset contains:
         - if right-click on a **selected row**, all selected rows,
         - else if right-click on a **non-selected row**, that row,
         - else an empty index set.
         */
        func rightClickRowIndexes(for event: NSEvent) -> IndexSet {
            rightClickRowIndexes(for: event.location(in: self))
        }
        
        /**
         An index set containing the indexes for a point.
         
         - Parameter location: The point in the table view’s bound.

         The returned indexset contains:
         - if right-click on a **selected row**, all selected rows,
         - else if right-click on a **non-selected row**, that row,
         - else an empty index set.
         */
        func rightClickRowIndexes(for point: CGPoint) -> IndexSet {
            let row = row(at: point)
            let selectedRowIndexes = selectedRowIndexes
            return row != -1 ? selectedRowIndexes.contains(row) ? selectedRowIndexes : [row] : []
        }
        
        /**
         Deselects the rows at the specified indexes.

         - Parameter indexes: The indexes of the rows to deselect.
         */
        func deselectRows(at indexes: IndexSet) {
            indexes.forEach({ deselectRow($0) })
        }
        
        /**
         Selects the row after the currently selected.
         
         If no row is currently selected, the first row is selected.
         
         - Parameter extend: A Boolean value that indicates whether the selection should be extended.
         */
        func selectNextRow(byExtendingSelection extend: Bool = false) {
            let row = (selectedRowIndexes.last ?? -1) + 1
            guard numberOfRows > 0, row < numberOfRows else { return }
            selectRowIndexes(IndexSet(integer: row), byExtendingSelection: extend)
        }
        
        /**
         Selects the row before the currently selected.
         
         If no row is currently selected, the last row is selected.
         
         - Parameter extend: A Boolean value that indicates whether the selection should be extended.
         */
        func selectPreviousRow(byExtendingSelection extend: Bool = false) {
            let row = (selectedRowIndexes.first ?? numberOfRows) - 1
            guard numberOfRows > 0, row > 0, row < numberOfRows else { return }
            selectRowIndexes(IndexSet(integer: row), byExtendingSelection: extend)
        }
        
        /**
         Marks the table view as needing redisplay, so it will reload the data for visible cells and draw the new values.
         
         - Parameter maintainingSelection: A Boolean value that indicates whether the table view should maintain it's selection after reloading.
         */
        func reloadData(maintainingSelection: Bool) {
            let selectedRowIndexes = selectedRowIndexes
            reloadData()
            if maintainingSelection, !selectedRowIndexes.isEmpty {
                selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
            }
        }

        /// Returns the row indexes currently visible.
        func visibleRowIndexes() -> IndexSet {
            IndexSet(rows(in: visibleRect).array)
        }

        /// Returns the row views currently visible.
        func visibleRows() -> [NSTableRowView] {
            visibleRowIndexes().compactMap{rowView(atRow: $0, makeIfNecessary: false)}
        }
        
        /// Returns the column indexes currently visible.
        var visibleColumnIndexes: IndexSet {
            columnIndexes(in: visibleRect)
        }

        /// Returns the columns currently visible.
        var visibleColumns: [NSTableColumn] {
            visibleColumnIndexes.compactMap { tableColumns[$0] }
        }
        
        /// Returns the cell views currently visible.
        func visibleCells() -> [NSTableCellView] {
            visibleRows().flatMap({ $0.cellViews })
        }

        /**
         Returns the cell views of a column currently visible.
         
         - Parameter column: The column fot the visible cell views.
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
        
        /// Creates a table view with the specified table columns.
        convenience init(@ColumnBuilder columns: () -> [NSTableColumn]) {
            self.init(frame: .zero)
            tableColumns(columns)
        }
        
        /// Sets the table columns.
        @discardableResult
        func tableColumns(_ columns: [NSTableColumn]) -> Self {
            let toRemove = tableColumns.filter({!columns.contains($0)})
            toRemove.forEach({removeTableColumn($0)})
            let toAdd = columns.filter({!tableColumns.contains($0)})
            toAdd.forEach({addTableColumn($0)})
            for (index, column) in columns.enumerated() {
                if let oldIndex = tableColumns.firstIndex(of: column) {
                    moveColumn(oldIndex, toColumn: index)
                }
            }
            return self
        }
        
        /// Sets the table columns.
        @discardableResult
        func tableColumns(@ColumnBuilder _ columns: () -> [NSTableColumn]) -> Self {
            tableColumns(columns())
        }
        
        /// Sets the selection highlight style used by the table view to indicate row and column selection.
        @discardableResult
        func selectionHighlightStyle(_ style: SelectionHighlightStyle) -> Self {
            self.selectionHighlightStyle = style
            return self
        }
        
        /// Sets the row size style (small, medium, large, or custom) used by the table view.
        @discardableResult
        func rowSizeStyle(_ style: RowSizeStyle) -> Self {
            self.rowSizeStyle = style
            return self
        }
        
        /// Sets the grid lines drawn by the table view.
        @discardableResult
        func gridStyleMask(_ gridStyleMask: GridLineStyle) -> Self {
            self.gridStyleMask = gridStyleMask
            return self
        }
        
        /// Sets the view used to draw headers over columns.
        @discardableResult
        func headerView(_ headerView: NSTableHeaderView?) -> Self {
            self.headerView = headerView
            return self
        }
        
        /// Sets the Boolean value indicating whether a table row’s actions are visible.
        @discardableResult
        func rowActionsVisible(_ visible: Bool) -> Self {
            self.rowActionsVisible = visible
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to type characters to select rows.
        @discardableResult
        func allowsTypeSelect(_ allows: Bool) -> Self {
            self.allowsTypeSelect = allows
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view draws grouped rows as if they are floating.
        @discardableResult
        func floatsGroupRows(_ floats: Bool) -> Self {
            self.floatsGroupRows = floats
            return self
        }
          
        /// Sets the Boolean value indicating whether the table view uses alternating row colors for its background.
        @discardableResult
        func usesAlternatingRowBackgroundColors(_ uses: Bool) -> Self {
            self.usesAlternatingRowBackgroundColors = uses
            return self
        }
        
        /// Sets the color used to draw the background of the table.
        @discardableResult
        func backgroundColor(_ color: NSColor) -> Self {
            self.backgroundColor = color
            return self
        }
        
        /// Sets the color used to draw grid lines.
        @discardableResult
        func gridColor(_ color: NSColor) -> Self {
            self.gridColor = color
            return self
        }
        
        /// Sets the style that the table view uses.
        @available(macOS 11.0, *)
        @discardableResult
        func style(_ style: Style) -> Self {
            self.style = style
            return self
        }
        
        /// Sets height of each row in the table.
        @discardableResult
        func rowHeight(_ rowHeight: CGFloat) -> Self {
            self.rowHeight = rowHeight
            return self
        }
        
        /// Sets horizontal and vertical spacing between cells.
        @discardableResult
        func intercellSpacing(_ spacing: CGSize) -> Self {
            self.intercellSpacing = spacing
            return self
        }
        
        /// Sets the Boolean value that indicates whether the table view uses autolayout to calculate the height of rows.
        @discardableResult
        func usesAutomaticRowHeights(_ uses: Bool) -> Self {
            self.usesAutomaticRowHeights = uses
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to select columns by clicking their headers.
        @discardableResult
        func allowsColumnSelection(_ allows: Bool) -> Self {
            self.allowsColumnSelection = allows
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to rearrange columns by dragging their headers.
        @discardableResult
        func allowsColumnReordering(_ allows: Bool) -> Self {
            self.allowsColumnReordering = allows
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to resize columns by dragging between their headers.
        @discardableResult
        func allowsColumnResizing(_ allows: Bool) -> Self {
            self.allowsColumnResizing = allows
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to select zero columns or rows.
        @discardableResult
        func allowsEmptySelection(_ allows: Bool) -> Self {
            self.allowsEmptySelection = allows
            return self
        }
        
        /// Sets the Boolean value indicating whether the table view allows the user to select more than one column or row at a time.
        @discardableResult
        func allowsMultipleSelection(_ allows: Bool) -> Self {
            self.allowsMultipleSelection = allows
            return self
        }
        
        /// A function builder type that produces an array of table columns.
        @resultBuilder
        enum ColumnBuilder {
            public static func buildBlock(_ block: [NSTableColumn]...) -> [NSTableColumn] {
                block.flatMap { $0 }
            }

            public static func buildOptional(_ item: [NSTableColumn]?) -> [NSTableColumn] {
                item ?? []
            }

            public static func buildEither(first: [NSTableColumn]?) -> [NSTableColumn] {
                first ?? []
            }

            public static func buildEither(second: [NSTableColumn]?) -> [NSTableColumn] {
                second ?? []
            }

            public static func buildArray(_ components: [[NSTableColumn]]) -> [NSTableColumn] {
                components.flatMap { $0 }
            }

            public static func buildExpression(_ expr: [NSTableColumn]?) -> [NSTableColumn] {
                expr ?? []
            }

            public static func buildExpression(_ expr: NSTableColumn?) -> [NSTableColumn] {
                expr.map { [$0] } ?? []
            }
        }
    }

extension NSTableView {
    
    /**
     A Boolean value indicating whether the selection of rows is toggled when the uses clicks a row.
     
     The default value is `false`.
     */
    public var togglesSelection: Bool {
        get { toggleGestureRecognizer != nil }
        set {
            guard newValue != togglesSelection else { return }
            if newValue {
                toggleGestureRecognizer = ToggleGestureRecognizer()
                addGestureRecognizer(toggleGestureRecognizer!)
            } else {
                toggleGestureRecognizer?.removeFromView()
                toggleGestureRecognizer = nil
            }
        }
    }
    
    var toggleGestureRecognizer: ToggleGestureRecognizer? {
        get { getAssociatedValue("toggleGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "toggleGestureRecognizer") }
    }
    
    class ToggleGestureRecognizer: NSGestureRecognizer {
        init() {
            super.init(target: nil, action: nil)
            delaysPrimaryMouseButtonEvents = true
            reattachesAutomatically = true
        }
        
        override func mouseDown(with event: NSEvent) {
            state = .began
            if let tableView = view as? NSTableView, tableView.isEnabled, tableView.allowsEmptySelection, tableView.allowsMultipleSelection {
                let row = tableView.row(at: location(in: tableView))
                if row != -1 {
                    var indexes = tableView.selectedRowIndexes
                    if tableView.selectedRowIndexes.contains(row) {
                        indexes.remove(row)
                        if indexes == tableView.delegate?.tableView?(tableView, selectionIndexesForProposedSelection: indexes) ?? indexes {
                            tableView.deselectRow(row)
                            tableView.delegate?.tableViewSelectionDidChange?(Notification(name: NSTableView.selectionDidChangeNotification, object: tableView))
                        }
                    } else {
                        indexes.insert(row)
                        var shouldSelect = true
                        if let delegate = tableView.delegate {
                            if let proposedSelection = delegate.tableView(_:selectionIndexesForProposedSelection:) {
                                shouldSelect = proposedSelection(tableView, indexes) == indexes
                            } else if let should = tableView.delegate?.tableView(_:shouldSelectRow:) {
                                shouldSelect = should(tableView, row)
                            }
                        }
                        if shouldSelect {
                            tableView.selectRowIndexes([row], byExtendingSelection: true)
                            tableView.delegate?.tableViewSelectionDidChange?(Notification(name: NSTableView.selectionDidChangeNotification, object: tableView))
                        }
                    }
                    state = .ended
                }
            }
            if state != .ended {
                state = .failed
            }
        }
        
        override func mouseUp(with event: NSEvent) {
            state = .began
            state = .failed
        }
                    
        override func mouseDragged(with event: NSEvent) {
            state = .began
            state = .failed
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension NSTableView {
    /// The handler that gets called when the table view is double clicked.
    public var doubleClickHandler: ((_ row: Int?)->())? {
        get { getAssociatedValue("doubleClickHandler") }
        set {
            setAssociatedValue(newValue, key: "doubleClickHandler")
            doubleClickGesture?.removeFromView()
            doubleClickGesture = nil
            if let newValue = newValue {
                doubleClickGesture = .init { [weak self] _ in
                    guard let self = self else { return }
                    newValue(self.selectedRow != -1 ? self.selectedRow : nil)
                }
            }
        }
    }
    
   @objc private func didDoubleClick(_ gesture: NSClickGestureRecognizer) {
        doubleClickHandler?(selectedRow != -1 ? selectedRow : nil)
    }
    
    private var doubleClickGesture: DoubleClickGestureRecognizer? {
        get { getAssociatedValue("doubleClickGesture") }
        set { setAssociatedValue(newValue, key: "doubleClickGesture") }
    }
}

#endif
