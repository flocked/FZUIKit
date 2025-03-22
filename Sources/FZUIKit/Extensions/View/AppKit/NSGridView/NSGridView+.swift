//
//  NSGridView+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSGridView {
    /// Creates a new grid view with the specified columns.
    public convenience init(@GridColumn.Builder columns: () -> [GridColumn]) {
        self.init()
        self.columns = columns()
    }
    
    /// Creates a new grid view with the specified rows.
    public convenience init(@GridRow.Builder rows: () -> [GridRow]) {
        self.init()
        self.rows = rows()
    }
    
    /// The columns of the grid view.
    public var columns: [GridColumn] {
        get { (0..<numberOfColumns).map({ GridColumn(column(at: $0)) }) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            let existing = newValue.filter({$0.gridColumn != nil })
            let added = newValue.filter({$0.gridColumn == nil })
            columns.filter({ column in !existing.contains(where: { $0.gridColumn === column.gridColumn }) }).reversed().forEach({
                if let index = $0.index {
                    $0.gridColumn = nil
                    removeColumn(at: index)
                }
            })
            added.forEach({
                addColumn(with: [])
                $0.gridColumn = column(at: numberOfColumns - 1)
            })
            var columns = columns
            for (index, column) in newValue.indexed() {
                if let oldIndex = columns.firstIndex(of: column), oldIndex != index {
                    moveColumn(at: oldIndex, to: index)
                    columns.swapAt(oldIndex, index)
                }
            }
            newValue.filter({$0.properties.merge}).forEach({
                $0.mergeCells()
                $0.properties.merge = false
            })
            newValue.filter({$0.properties.mergeRange != nil}).forEach({
                if let range = $0.properties.mergeRange {
                    $0.mergeCells(in: range)
                    $0.properties.mergeRange = nil
                }
            })
        }
    }
    
    /// Sets the columns of the grid view.
    @discardableResult
    public func columns(@GridColumn.Builder columns: () -> [GridColumn]) -> Self {
        self.columns = columns()
        return self
    }
    
    /// The rows of the grid view.
    public var rows: [GridRow] {
        get { (0..<numberOfRows).map({ GridRow(row(at: $0)) }) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            let existing = newValue.filter({$0.gridRow != nil })
            let added = newValue.filter({$0.gridRow == nil })
            rows.filter({ row in !existing.contains(where: { $0.gridRow === row.gridRow }) }).reversed().forEach({
                if let index = $0.index {
                    $0.gridRow = nil
                    removeRow(at: index)
                }
            })
            added.filter({$0.gridRow == nil }).forEach({
                addRow(with: [])
                $0.gridRow = row(at: numberOfRows - 1)
            })
            var rows = rows
            for (index, row) in newValue.indexed() {
                if let oldIndex = rows.firstIndex(of: row), oldIndex != index {
                    moveRow(at: oldIndex, to: index)
                    rows.swapAt(oldIndex, index)
                }
            }
            newValue.filter({$0.properties.merge}).forEach({
                $0.mergeCells()
                $0.properties.merge = false
            })
            newValue.filter({$0.properties.mergeRange != nil}).forEach({
                if let range = $0.properties.mergeRange {
                    $0.mergeCells(in: range)
                    $0.properties.mergeRange = nil
                }
            })
        }
    }
    
    /// Sets the rows of the grid view.
    @discardableResult
    public func rows(@GridRow.Builder rows: () -> [GridRow]) -> Self {
        self.rows  = rows()
        return self
    }
    
    /**
     Expands the cell at the top-leading corner of the horizontal and vertical range to cover the entire area.
     
     This function invalidates other cells in the range, and they no longer maintain their layout, constraints, or content views. Cell merging has no effect on the base cell coordinate system of the grid view, and cell references within a merged region refer to the single merged cell.
     
     Use this method to configure the grid geometry before installing views. If the cells being merged contain content views, only the top-leading views are kept.
     */
    public func mergeCells(inHorizontalRange horizontalRange: ClosedRange<Int>, verticalRange: ClosedRange<Int>) {
        mergeCells(inHorizontalRange: horizontalRange.nsRange, verticalRange: verticalRange.nsRange)
    }
    
    /**
     Expands the cell at the top-leading corner of the horizontal and vertical range to cover the entire area.
     
     This function invalidates other cells in the range, and they no longer maintain their layout, constraints, or content views. Cell merging has no effect on the base cell coordinate system of the grid view, and cell references within a merged region refer to the single merged cell.
     
     Use this method to configure the grid geometry before installing views. If the cells being merged contain content views, only the top-leading views are kept.
     */
    public func mergeCells(inHorizontalRange horizontalRange: Range<Int>, verticalRange: Range<Int>) {
        mergeCells(inHorizontalRange: horizontalRange.nsRange, verticalRange: verticalRange.nsRange)
    }
    
    /// Merges the cells of the rows at the specified range.
    public func mergeCells(rows: Range<Int>) {
        mergeCells(inHorizontalRange: 0..<numberOfColumns, verticalRange: rows)
    }
    
    /// Merges the cells of the rows at the specified range.
    public func mergeCells(rows: ClosedRange<Int>) {
        mergeCells(inHorizontalRange: 0...numberOfColumns, verticalRange: rows)
    }
    
    /// Merges the cells of the columns at the specified range.
    public func mergeCells(columns: Range<Int>) {
        mergeCells(inHorizontalRange: columns, verticalRange: 0..<numberOfRows)
    }
    
    /// Merges the cells of the columns at the specified range.
    public func mergeCells(columns: ClosedRange<Int>) {
        mergeCells(inHorizontalRange: columns, verticalRange: 0...numberOfRows)
    }
    
    /// Merges the cells of the specified index range.
    func mergeCells(from fromIndex: (column: Int, row: Int), to toIndex: (column: Int, row: Int)) {
        mergeCells(inHorizontalRange: fromIndex.column..<toIndex.column, verticalRange: fromIndex.row..<toIndex.row)
    }
    
    static let automaticSizing: CGFloat = 1.1754943508222875e-38
}

extension NSGridView {
    /// A function builder type that produces an array of views for grid view cells.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: NSView?...) -> [NSView?] {
            components
        }

        public static func buildExpression(_ expression: NSView) -> NSView? {
            expression
        }
        
        public static func buildExpression(_ expression: NSView?) -> NSView? {
            expression
        }
        
        public static func buildExpression(_ expression: String) -> NSView? {
            NSTextField.wrapping(expression)
        }
        
        public static func buildExpression(_ expression: [String]) -> [NSView?] {
            expression.map({ NSTextField.wrapping($0) })
        }
        
        public static func buildOptional(_ component: [NSView?]?) -> [NSView?] {
            component ?? []
        }
        
        public static func buildEither(first component: [NSView?]) -> [NSView?] {
            component
        }

        public static func buildEither(second component: [NSView?]) -> [NSView?] {
            component
        }
    }
}

extension NSGridCell.Placement: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inherited: return "inherited"
        case .none: return "none"
        case .leading: return "leading"
        case .top: return "top"
        case .trailing: return "trailing"
        case .bottom: return "bottom"
        case .center: return "center"
        default: return "fill"
        }
    }
}
#endif
