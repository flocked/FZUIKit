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
            let numberOfColumns = numberOfColumns
            let existing = newValue.filter({$0.gridColumn != nil })
            let added = newValue.filter({$0.gridColumn == nil })
            columns.filter({ column in !existing.contains(where: { $0.gridColumn === column.gridColumn }) }).reversed().forEach({ $0.remove() })
            for column in added {
                addColumn(with: [])
                column.gridColumn = self.column(at: self.numberOfColumns - 1)
            }
            var columns = columns
            for (index, column) in newValue.indexed() {
                if let oldIndex = columns.firstIndex(of: column), oldIndex != index {
                    moveColumn(at: oldIndex, to: index)
                    columns.swapAt(oldIndex, index)
                }
            }
            newValue.forEach({ $0.applyMerge() })
            if self.numberOfColumns > numberOfColumns {
                rows.filter({ $0.properties.autoMerge }).forEach({ $0.applyMerge() })
            }
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
            
            rows.filter({ row in !existing.contains(where: { $0.gridRow === row.gridRow }) }).reversed().forEach({ $0.remove() })
            for row in added {
                addRow(with: [])
                row.gridRow = self.row(at: numberOfRows - 1)
            }
            var rows = rows
            for (index, row) in newValue.indexed() {
                if let oldIndex = rows.firstIndex(of: row), oldIndex != index {
                    moveRow(at: oldIndex, to: index)
                    rows.swapAt(oldIndex, index)
                }
            }
            newValue.forEach({ $0.applyMerge() })
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
}

extension NSGridView {
    /// The alignment of grid cells.
    public struct Alignment: CustomStringConvertible {
        /// The horizontal alignment of grid cells.
        public enum Horizontal: Int, CustomStringConvertible {
            /// None.
            case none
            /// Leading.
            case leading
            /// Trailing.
            case trailing
            /// Center.
            case center
            /// Fill.
            case fill
            
            public var description: String {
                switch self {
                case .none: return "none"
                case .leading: return "leading"
                case .trailing: return "trailing"
                case .center: return "center"
                case .fill: return "fill"
                }
            }
            
            init(_ placement: NSGridCell.Placement) {
                self = .init(rawValue: placement.rawValue) ?? .none
            }
            
            var placement: NSGridCell.Placement {
                .init(rawValue: rawValue) ?? .leading
            }
        }
        
        /// The vertical alignment of grid cells.
        public enum Vertical: Int, CustomStringConvertible {
            /// None.
            case none
            /// Top.
            case top
            /// Bottom.
            case bottom
            /// Center.
            case center
            /// Fill.
            case fill
            /// First baseline.
            case firstBaseline
            /// Last baseline.
            case lastBaseline
            
            public var description: String {
                switch self {
                case .none: return "none"
                case .top: return "top"
                case .bottom: return "bottom"
                case .center: return "center"
                case .fill: return "fill"
                case .firstBaseline: return "firstBaseline"
                case .lastBaseline: return "lastBaseline"
                }
            }
            
            init(_ placement: NSGridCell.Placement, _ alignment: NSGridRow.Alignment) {
                if alignment == .firstBaseline || alignment == .lastBaseline {
                    self = alignment == .firstBaseline ? .firstBaseline : .lastBaseline
                } else {
                    self = .init(rawValue: placement.rawValue) ?? .none
                }
            }
            
            var placement: NSGridCell.Placement {
                if self == .firstBaseline || self == .lastBaseline { return .none }
                return .init(rawValue: rawValue) ?? .bottom
            }
            
            var rowAlignment: NSGridRow.Alignment {
                switch self {
                case .firstBaseline: return .firstBaseline
                case .lastBaseline: return .lastBaseline
                default: return .none
                }
            }
        }
        
        /// The horizontal alignment of the grid cells.
        public var x: Horizontal = .none
        
        /// The vertical alignment of the grid cells.
        public var y: Vertical = .none
        
        public var description: String {
            "(x: \(x), y: \(y))"
        }
        
        init(_ gridView: NSGridView) {
            x = .init(gridView.xPlacement)
            y = .init(gridView.yPlacement, gridView.rowAlignment)
        }
    }
    
    /// The alignment of the grid cells.
    public var alignment: Alignment {
        get { Alignment(self) }
        set {
            xPlacement = newValue.x.placement
            yPlacement = newValue.y.placement
            rowAlignment = newValue.y.rowAlignment
        }
    }
}

extension NSGridView {
    /// A function builder type that produces an array of views for grid view cells.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: [NSView?]...) -> [NSView?] {
            components.flatMap { $0 }
        }
            
        public static func buildExpression(_ expression: NSView) -> [NSView?] {
            [expression]
        }
        
        public static func buildExpression(_ expression: NSView?) -> [NSView?] {
            [expression]
        }
        
        public static func buildExpression(_ expression: [NSView]) -> [NSView?] {
            expression.map { $0 }
        }
        
        public static func buildExpression(_ expression: [NSView?]) -> [NSView?] {
            expression
        }
            
        public static func buildOptional(_ component: [NSView?]?) -> [NSView?] {
            component ?? []
        }
            
        public static func buildArray(_ components: [[NSView?]]) -> [NSView?] {
            components.flatMap { $0 }
        }
            
        public static func buildEither(first component: [NSView?]) -> [NSView?] {
            component
        }
        
        public static func buildEither(second component: [NSView?]) -> [NSView?] {
            component
        }
        
        public static func buildExpression(_ expression: String) -> [NSView?] {
            [NSTextField.wrapping(expression)]
        }
        
        public static func buildExpression(_ expression: [String?]) -> [NSView?] {
            expression.map { $0.map(NSTextField.wrapping) }
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
