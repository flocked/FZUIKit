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
        guard let reversed = sortDescriptors.first?.reversed else { return }
        sortDescriptors.removeFirst()
        sortDescriptors = [reversed] + sortDescriptors
        self.sortDescriptors = sortDescriptors
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
        guard event.isMouse else { return [] }
        return rightClickRowIndexes(for: event.location(in: self))
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
        return row >= 0 ? selectedRowIndexes.contains(row) ? selectedRowIndexes : [row] : []
    }
        
    /**
     Deselects the rows at the specified indexes.

     - Parameter indexes: The indexes of the rows to deselect.
     */
    func deselectRows(at indexes: IndexSet) {
        indexes.forEach { deselectRow($0) }
    }
        
    /**
     Selects the row after the currently selected.
         
     If no row is currently selected, the first row is selected.
         
     - Parameter extend: A Boolean value indicating whether the selection should be extended.
     */
    func selectNextRow(byExtendingSelection extend: Bool = false) {
        let row = (selectedRowIndexes.last ?? -1) + 1
        guard numberOfRows > 0, row < numberOfRows else { return }
        selectRowIndexes(IndexSet(integer: row), byExtendingSelection: extend)
    }
        
    /**
     Selects the row before the currently selected.
         
     If no row is currently selected, the last row is selected.
         
     - Parameter extend: A Boolean value indicating whether the selection should be extended.
     */
    func selectPreviousRow(byExtendingSelection extend: Bool = false) {
        let row = (selectedRowIndexes.first ?? numberOfRows) - 1
        guard numberOfRows > 0, row > 0, row < numberOfRows else { return }
        selectRowIndexes(IndexSet(integer: row), byExtendingSelection: extend)
    }
        
    /**
     Marks the table view as needing redisplay, so it will reload the data for visible cells and draw the new values.
         
     - Parameter maintainingSelection: A Boolean value indicating whether the table view should maintain it's selection after reloading.
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
        IndexSet(rows(in: visibleRect).values)
    }

    /// Returns the row views currently visible.
    func visibleRows() -> [NSTableRowView] {
        visibleRowIndexes().compactMap { rowView(atRow: $0, makeIfNecessary: false) }
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
        visibleRows().flatMap { $0.cellViews }
    }

    /**
     Returns the cell views of a column currently visible.
         
     - Parameter column: The column fot the visible cell views.
     */
    func visibleCells(for column: NSTableColumn) -> [NSTableCellView] {
        guard let columnIndex = self.column(of: column) else { return [] }
        return visibleRowIndexes().compactMap { view(atColumn: columnIndex, row: $0, makeIfNecessary: false) as? NSTableCellView }
    }

    /**
     Returns the row view at the specified location.

     - Parameters:
        - location: The location of the row view.
        - makeIfNecessary: A Boolean value indicating whether to create the row view if it doesn't exist.
     - Returns: The row view, or `nil` if there isn't any row view at the location.
     */
    func rowView(at location: CGPoint, makeIfNecessary: Bool = false) -> NSTableRowView? {
        let row = row(at: location)
        guard row >= 0 else { return nil }
        return rowView(atRow: row, makeIfNecessary: makeIfNecessary)
    }

    /**
     Returns the table cell view at the specified location.

     - Parameters:
        - location: The location of the table cell view.
        - makeIfNecessary: A Boolean value indicating whether to create the table cell view if it doesn't exist.
     - Returns: The table cell view, or `nil` if there isn't any table cell view at the location.
     */
    func cellView(at location: CGPoint, makeIfNecessary: Bool = false) -> NSTableCellView? {
        cellView(atColumn: column(at: location), row: row(at: location), makeIfNecessary: makeIfNecessary)
    }
    
    /**
     Returns a view at the specified row and column indexes, creating one if necessary.
     
     - Parameters:
        - column: The index of the column.
        - row: The row index.
        - makeIfNecessary: `true` if a view is required, `false` if you want to update properties on a view, if one is available.
     - Returns: The table cell view, or `nil` if there isn't a cell view at the specified column and row.

     This method first attempts to return an available view, which is generally in the visible area. If there is no available view, and `makeIfNecessary` is true, a prepared temporary view is returned. If `makeIfNecessary` is false, and the view is not available, nil will be returned.
     
     In general, `makeIfNecessary` should be true if you require a resulting view, and false if you only want to update properties on a view only if it is available (generally this means it is visible).
     
     An exception will be thrown if row is not within the numberOfRows. The returned result should generally not be held onto for longer than the current run loop cycle. Instead they should re-query the table view for the row view.
     */
    func cellView(atColumn column: Int, row: Int, makeIfNecessary: Bool = false) -> NSTableCellView? {
        guard column < numberOfColumns, row < numberOfRows else { return nil }
        return view(atColumn: column, row: row, makeIfNecessary: makeIfNecessary) as? NSTableCellView
    }
    
    /**
     Scrolls the table view so the specified row is at the top.
     
     - Parameters:
        - row: The row index.
        - padding: Additional spacing to leave above the row.
     */
    func scrollRowToTop(_ row: Int, padding: CGFloat = 0) {
        scrollRowToVisible(row)
        guard row >= 0, row < numberOfRows, let scrollView = enclosingScrollView else { return }
        let clipView = scrollView.contentView
        var origin = clipView.bounds.origin
        var offset = padding
        if floatsGroupRows, !isGroupRow(row), let groupRow = precedingGroupRow(for: row) {
            offset += rect(ofRow: groupRow).height + intercellSpacing.height
        }
        origin.y = rect(ofRow: row).minY - offset
        let minY = bounds.minY
        // let maxY = max(minY, bounds.maxY - clipView.bounds.height)
        let maxY = max(minY, bounds.maxY - scrollView.documentVisibleRect.height)
        origin.y = min(max(origin.y, minY), maxY)
        clipView.scroll(to: origin)
        scrollView.reflectScrolledClipView(clipView)
    }

    private func precedingGroupRow(for row: Int) -> Int? {
        row > 0 ? stride(from: row - 1, through: 0, by: -1).first(where: { isGroupRow($0) }) : nil
    }
    
    /// A Boolean value indicating whether the specified row is a group row.
    func isGroupRow(_ row: Int) -> Bool {
        delegate?.tableView?(self, isGroupRow: row) ?? false
    }
        
    /// Creates a table view with the specified table columns.
    convenience init(@ColumnBuilder columns: () -> [NSTableColumn]) {
        self.init(frame: .zero)
        tableColumns(columns)
    }
        
    /**
     Returns the index of the specified column in the table view.
         
     - Parameter tableColumn: The table column.
     - Returns: The index of the specified column in the [tableColumns](https://developer.apple.com/documentation/appkit/nstableview/tablecolumns) array, or `–1` if no columns is found.
     */
    func column(of tableColumn: NSTableColumn) -> Int? {
        tableColumns.firstIndex(of: tableColumn)
    }
        
    /// Sets the table columns.
    @discardableResult
    func tableColumns(_ columns: [NSTableColumn]) -> Self {
        let toRemove = tableColumns.filter { !columns.contains($0) }
        toRemove.forEach { removeTableColumn($0) }
        let toAdd = columns.filter { !tableColumns.contains($0) }
        toAdd.forEach { addTableColumn($0) }
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
        
    /// Sets the Boolean value indicating whether the table view uses autolayout to calculate the height of rows.
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
    
    /**
     Informs the table view that the rows specified in indexSet have changed height.
     
     - Parameters:
        - indexSet: Index set of rows that have changed their height.
        - animated: A Boolean value indicating whether changes to the row height should be animated.
     
     If the delegate implements [tableView(_:heightOfRow:)](https://developer.apple.com/documentation/appkit/nstableviewdelegate/tableview(_:heightofrow:)) this method immediately retiles the table view using the row heights the delegate provides.
     */
    func noteHeightOfRows(withIndexesChanged indexSet: IndexSet, animated: Bool) {
        if animated {
            noteHeightOfRows(withIndexesChanged: indexSet)
        } else {
            NSView.performWithoutAnimation {
                self.noteHeightOfRows(withIndexesChanged: indexSet)
            }
        }
    }
    
    /**
     Performs the updates to the table view provided be the specified handler.
     
      - Parameter updates: The handler that provides updates to the table view.
     
      For view-based table views, multiple row changes—that is, insertions, deletions, and moves—are animated simultaneously by calling those methods inside the provided handler. This method is nestable.
     
      The selected rows are maintained during the series of insertions, deletions, moves, and scrolling. If a selected row is deleted, a selection changed notification occurs after [removeRowsAtIndexes:withAnimation:](https://developer.apple.com/documentation/appkit/nstableview/removerows(at:withanimation:)) is called.
     
      It is not necessary to call this method if only one insertion, deletion, or move is occurring.
      */
    func performUpdates(_ updates: () -> ()) {
        beginUpdates()
        updates()
        endUpdates()
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
     The handler that is called when the table view is double clicked.
     
     The handler provides the row that is double clicked.
     */
    public var doubleClickHandler: ((_ row: Int?, _ column: Int?) -> ())? {
        get { getAssociatedValue("doubleClickHandler") }
        set {
            setAssociatedValue(newValue, key: "doubleClickHandler")
            doubleClickGesture?.removeFromView()
            doubleClickGesture = nil
            guard let handler = newValue else { return }
            doubleClickGesture = .init { [weak self] gesture in
                guard let self = self else { return }
                let location = gesture.location(in: self)
                let row = self.row(at: location)
                let column = self.column(at: location)
                handler(row >= 0 ? row : nil, column >= 0 ? column : nil)
            }.reattaches(true)
            addGestureRecognizer(doubleClickGesture!)
        }
    }
    
    fileprivate var doubleClickGesture: DoubleClickGestureRecognizer? {
        get { getAssociatedValue("doubleClickGesture") }
        set { setAssociatedValue(newValue, key: "doubleClickGesture") }
    }
    
    /// A Boolean value indicating whether clicking a row toggles its selection instead of replacing the current selection.
    public var togglesSelection: Bool {
        get { toggleGestureRecognizer != nil }
        set {
            guard newValue != togglesSelection else { return }
            toggleGestureRecognizer?.removeFromView()
            toggleGestureRecognizer = nil
            guard newValue else { return }
            toggleGestureRecognizer = .init()
            addGestureRecognizer(toggleGestureRecognizer!)
        }
    }
    
    /// Sets the Boolean value indicating whether clicking a row toggles its selection instead of replacing the current selection.
    @discardableResult
    public func togglesSelection(_ toggles: Bool) -> Self {
        togglesSelection = toggles
        return self
    }
    
    fileprivate var toggleGestureRecognizer: ToggleGestureRecognizer? {
        get { getAssociatedValue("toggleGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "toggleGestureRecognizer") }
    }
    
    fileprivate final class ToggleGestureRecognizer: NSGestureRecognizer {
        init() {
            super.init(target: nil, action: nil)
            delaysPrimaryMouseButtonEvents = true
            reattachesAutomatically = true
        }
        
        override func mouseDown(with event: NSEvent) {
            guard let tableView = view as? NSTableView, tableView.isEnabled else {
                state = .failed
                return
            }
            
            let row = tableView.row(at: event.location(in: tableView))
            guard row >= 0 else {
                state = .failed
                return
            }
            
            var proposedSelection = tableView.selectedRowIndexes
            if !proposedSelection.contains(row) {
                proposedSelection.insert(row)
                guard tableView.allowsMultipleSelection || proposedSelection.count <= 1 else {
                    state = .failed
                    return
                }
                guard allowsProposedSelection(proposedSelection, row: row) else {
                    return
                }
                tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: true)
            } else {
                proposedSelection.remove(row)
                guard !proposedSelection.isEmpty || tableView.allowsEmptySelection else {
                    return
                }
                guard allowsProposedSelection(proposedSelection, row: row) else {
                    return
                }
                tableView.deselectRow(row)
            }
            state = .recognized
        }
        
        override func mouseDragged(with event: NSEvent) {
            state = .failed
        }

        override func mouseUp(with event: NSEvent) {
            guard state == .possible else { return }
            state = .failed
        }
        
        private func allowsProposedSelection(_ proposedSelection: IndexSet, row: Int) -> Bool {
            guard let tableView = view as? NSTableView else { return false }
            if let filteredSelection = tableView.delegate?.tableView?(tableView, selectionIndexesForProposedSelection: proposedSelection) {
                return filteredSelection == proposedSelection
            }
            if proposedSelection.contains(row) {
                return tableView.delegate?.tableView?(tableView, shouldSelectRow: row) ?? true
            }
            return true
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/*
 /// Describes how clicking toggles the selection of a table rows.
 public enum ToggleSelectionInteraction: ExpressibleByBooleanLiteral {
     /// Disables toggling row selection by clicking.
     case disabled
     /// Toggles the clicked row only.
     case byClick
     /// Toggles the clicked row and extends the same action while dragging across additional rows.
     case byClickAndDrag

     public init(booleanLiteral value: Bool) {
         self = value ? .byClick : .disabled
     }
 }

 /*
  A value indicating whether clicking a row toggles its selection instead of replacing the current selection.

  Set this property to `.clickAndDrag` to continue selecting or deselecting matching rows while dragging.
 
  The default value is `.disabled`.
  */
 public var togglesSelection: ToggleSelectionInteraction {
     get { toggleGestureRecognizer?.option ?? .disabled }
     set {
         guard newValue != togglesSelection else { return }
         toggleGestureRecognizer?.removeFromView()
         toggleGestureRecognizer = nil
         guard newValue != .disabled else { return }
         toggleGestureRecognizer = ToggleGestureRecognizer(newValue)
         addGestureRecognizer(toggleGestureRecognizer!)
     }
 }

 /// Sets the value indicating whether clicking a row toggles its selection instead of replacing the current selection.
 @discardableResult
 public func togglesSelection(_ toggles: ToggleSelectionInteraction) -> Self {
     self.togglesSelection = toggles
     return self
 }

 fileprivate var toggleGestureRecognizer: ToggleGestureRecognizer? {
     get { getAssociatedValue("toggleGestureRecognizer") }
     set { setAssociatedValue(newValue, key: "toggleGestureRecognizer") }
 }

 fileprivate final class ToggleGestureRecognizer: NSGestureRecognizer {

     let option: ToggleSelectionInteraction
     private weak var tableView: NSTableView?
     private var isSelecting: Bool?
     private var visitedRows = IndexSet()

     init(_ option: ToggleSelectionInteraction) {
         self.option = option
         super.init(target: nil, action: nil)
         delaysPrimaryMouseButtonEvents = true
         reattachesAutomatically = true
     }

     override func mouseDown(with event: NSEvent) {
         guard let tableView = view as? NSTableView, tableView.isEnabled, option != .disabled
         else {
             state = .failed
             return
         }

         let row = tableView.row(at: event.location(in: tableView))
         guard row >= 0 else {
             state = .failed
             return
         }

         self.tableView = tableView
         self.visitedRows = []
         isSelecting = !tableView.selectedRowIndexes.contains(row)
         applyToRow(row)

         switch option {
         case .disabled:
             state = .failed
         case .byClick:
             state = .recognized
         case .byClickAndDrag:
             state = .began
         }
     }
    
     override func mouseDragged(with event: NSEvent) {
         guard let tableView else {
             state = .failed
             return
         }
         guard option == .byClickAndDrag else {
             state = .ended
             return
         }
         let row = tableView.row(at: event.location(in: tableView))
         guard row >= 0 else { return }
         applyToRow(row)
         state = .changed
     }

     override func mouseUp(with event: NSEvent) {
         if state == .began || state == .changed {
             state = .ended
         } else if state == .possible {
             state = .failed
         }
     }

     override func reset() {
         super.reset()
         tableView = nil
         isSelecting = nil
         visitedRows = []
     }

     private func applyToRow(_ row: Int) {
         guard let tableView, let isSelecting, !visitedRows.contains(row) else { return }
         visitedRows.insert(row)
         if isSelecting {
             var proposedSelection = tableView.selectedRowIndexes
             proposedSelection.insert(row)
             guard tableView.allowsMultipleSelection || proposedSelection.count <= 1 else {
                 state = .failed
                 return
             }
             guard allowsProposedSelection(proposedSelection, row: row) else {
                 return
             }
             tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: true)
         } else {
             var proposedSelection = tableView.selectedRowIndexes
             proposedSelection.remove(row)
             guard !proposedSelection.isEmpty || tableView.allowsEmptySelection else {
                 return
             }
             guard allowsProposedSelection(proposedSelection, row: row) else {
                 return
             }
             tableView.deselectRow(row)
         }
     }
    
     private func allowsProposedSelection(_ proposedSelection: IndexSet, row: Int) -> Bool {
         guard let tableView else { return false }
         if let filteredSelection = tableView.delegate?.tableView?(tableView, selectionIndexesForProposedSelection: proposedSelection) {
             return filteredSelection == proposedSelection
         }
         if proposedSelection.contains(row) {
             return tableView.delegate?.tableView?(tableView, shouldSelectRow: row) ?? true
         }
         return true
     }

     @available(*, unavailable)
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
 }
 */

#endif
