//
//  NSGridView+.swift
//
//
//  Created by Florian Zand on 23.02.24.
//

#if os(macOS)
import AppKit

extension NSGridView {
    /// Creates a new grid view obect with the specified columns.
    public convenience init(@ColumnBuilder columns: () -> [GridColumn]) {
        self.init()
        self.columns = columns()
    }
    
    /// Creates a new grid view object with the specified rows.
    public convenience init(@RowBuilder rows: () -> [GridRow]) {
        self.init()
        self.rows = rows()
    }
    
    /*
    /// The columns of the grid view.
    public var columns: [GridColumn] {
        get { nsColumns.compactMap({GridColumn($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            if newValue.count > numberOfColumns {
                let count = newValue.count - numberOfColumns
                (0..<count).forEach({ _ in addColumn(with: [])})
            } else if newValue.count < numberOfColumns, let index = nsColumns.indexed().firstIndex(where: {$0.element.cells.compactMap({$0.contentView}).count == 0 && $0.index >= newValue.count}) {
                (index..<numberOfColumns).reversed().forEach({
                    removeColumn(at: $0)
                })
            }
            for (index, column) in newValue.indexed() {
                if let columnIndex = column.gridColumn?.index {
                    if columnIndex != index {
                        moveColumn(at: columnIndex, to: index)
                    }
                } else if let gridColumn = nsColumns[safe: index] {
                    gridColumn.isHidden = column._isHidden
                    gridColumn.leadingPadding = column._leadingPadding
                    gridColumn.trailingPadding = column._trailingPadding
                    gridColumn.xPlacement = column._xPlacement
                    gridColumn.width = column._width
                    gridColumn.views = column._views
                    column._views = []
                    column.gridColumn = gridColumn
                }
            }
        }
    }
    */
    
    /// The columns of the grid view.
    public var columns: [GridColumn] {
        get { nsColumns.compactMap({GridColumn($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            let oldColumns = columns
            for index in (0..<oldColumns.count).reversed() where !newValue.contains(where: { $0.gridColumn === oldColumns[index].gridColumn }) {
                removeColumn(at: index)
            }
            
            newValue.filter({$0.gridColumn == nil }).forEach({
                addColumn(with: [])
                $0.gridColumn = column(at: numberOfColumns-1)
            })
            
            for (newIndex, column) in newValue.enumerated() {
                if let oldIndex = columns.firstIndex(where: { $0.gridColumn === column.gridColumn }), oldIndex != newIndex {
                    moveColumn(at: oldIndex, to: newIndex)
                }
            }
        }
    }
    
    /// Sets the columns of the grid view.
    @discardableResult
    public func columns(@ColumnBuilder _ columns: () -> [GridColumn]) -> Self {
        self.columns = columns()
        return self
    }
    
    /*
    /// The rows of the grid view.
    public var rows: [GridRow] {
        get { nsRows.compactMap({GridRow($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            if newValue.count > numberOfRows {
                (0..<(newValue.count - numberOfRows)).forEach({ _ in addRow(with: [])})
            } else if newValue.count < numberOfRows, let index = nsRows.indexed().firstIndex(where: {$0.element.cells.compactMap({$0.contentView}).count == 0 && $0.index >= newValue.count}) {
                (index..<numberOfRows).reversed().forEach({
                    removeRow(at: $0)
                })
            }
            for (index, row) in newValue.indexed() {
                if let rowIndex = row.gridRow?.index {
                    if rowIndex != index {
                        moveRow(at: rowIndex, to: index)
                    }
                } else if let gridRow = nsRows[safe: index] {
                    gridRow.isHidden = row._isHidden
                    gridRow.topPadding = row._topPadding
                    gridRow.bottomPadding = row._bottomPadding
                    gridRow.yPlacement = row._yPlacement
                    gridRow.rowAlignment = row._rowAlignment
                    gridRow.height = row._height
                    gridRow.views = row._views
                    row._views = []
                    row.gridRow = gridRow
                }
            }
        }
    }
     */
    
    /// The rows of the grid view.
    public var rows: [GridRow] {
        get { nsRows.compactMap({GridRow($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            let oldRows = rows
            for index in (0..<oldRows.count).reversed() where !newValue.contains(where: { $0.gridRow === oldRows[index].gridRow }) {
                removeRow(at: index)
            }
            
            newValue.filter({$0.gridRow == nil }).forEach({
                addRow(with: [])
                $0.gridRow = row(at: numberOfRows-1)
            })
            
            for (newIndex, row) in newValue.indexed() {
                if let oldIndex = rows.firstIndex(where: { $0.gridRow === row.gridRow }), oldIndex != newIndex {
                    moveRow(at: oldIndex, to: newIndex)
                }
            }
        }
    }
    
    /// Sets the rows of the grid view.
    @discardableResult
    public func rows(@RowBuilder _ rows: () -> [GridRow]) -> Self {
        self.rows  = rows()
        return self
    }
    
    /// The columns of the grid view as `NSGridColumn`.
    var nsColumns: [NSGridColumn] {
        get { (0..<numberOfColumns).compactMap({column(at: $0)}) }
    }
    
    /// The rows of the grid view as `NSGridRow`.
    var nsRows: [NSGridRow] {
        get { (0..<numberOfRows).compactMap({row(at: $0)}) }
    }
}

extension NSGridView {
    /// A function builder type that produces an array of views for grid view cells.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: NSView?...) -> [NSView?] {
            return components
        }

        public static func buildExpression(_ expression: NSView) -> NSView? {
            return expression
        }
        
        public static func buildExpression(_ expression: NSView?) -> NSView? {
            return expression
        }
        
        public static func buildOptional(_ component: [NSView?]?) -> [NSView?] {
            return component ?? []
        }
        
        public static func buildEither(first component: [NSView?]) -> [NSView?] {
            return component
        }

        public static func buildEither(second component: [NSView?]) -> [NSView?] {
            return component
        }
    }
    
    /// A function builder type that produces an array of grid column.
    @resultBuilder
    public enum ColumnBuilder {
        public static func buildBlock(_ block: [GridColumn]...) -> [GridColumn] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [GridColumn]?) -> [GridColumn] {
            item ?? []
        }

        public static func buildEither(first: [GridColumn]?) -> [GridColumn] {
            first ?? []
        }

        public static func buildEither(second: [GridColumn]?) -> [GridColumn] {
            second ?? []
        }

        public static func buildArray(_ components: [[GridColumn]]) -> [GridColumn] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [GridColumn]?) -> [GridColumn] {
            expr ?? []
        }

        public static func buildExpression(_ expr: GridColumn?) -> [GridColumn] {
            expr.map { [$0] } ?? []
        }
    }
    
    /// A function builder type that produces an array of grid rows.
    @resultBuilder
    public enum RowBuilder {
        public static func buildBlock(_ block: [GridRow]...) -> [GridRow] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [GridRow]?) -> [GridRow] {
            item ?? []
        }

        public static func buildEither(first: [GridRow]?) -> [GridRow] {
            first ?? []
        }

        public static func buildEither(second: [GridRow]?) -> [GridRow] {
            second ?? []
        }

        public static func buildArray(_ components: [[GridRow]]) -> [GridRow] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [GridRow]?) -> [GridRow] {
            expr ?? []
        }

        public static func buildExpression(_ expr: GridRow?) -> [GridRow] {
            expr.map { [$0] } ?? []
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
