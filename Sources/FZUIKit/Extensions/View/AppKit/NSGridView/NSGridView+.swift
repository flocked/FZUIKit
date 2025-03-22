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
    
    /// The columns of the grid view.
    public var columns: [GridColumn] {
        get { nsColumns.compactMap({GridColumn($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            if newValue.count > numberOfColumns {
                let count = newValue.count - numberOfColumns
                (0..<count).forEach({ _ in addColumn(with: [])})
            } else if newValue.count < numberOfColumns, let index = nsColumns.firstIndex(where: {$0.cells.compactMap({$0.contentView}).count == 0}), index <= newValue.count {
                (index..<numberOfColumns).reversed().forEach({
                    removeColumn(at: $0)
                })
            }
            for (index, column) in newValue.enumerated() {
                if let columnIndex = column.gridColumn?.index {
                    if columnIndex != index {
                        moveColumn(at: columnIndex, to: index)
                    }
                } else {
                    if let gridColumn = nsColumns[safe: index] {
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
    }
    
    /// Sets the columns of the grid view.
    @discardableResult
    public func columns(@ColumnBuilder _ columns: () -> [GridColumn]) -> Self {
        self.columns = columns()
        return self
    }
    
    /// The rows of the grid view.
    public var rows: [GridRow] {
        get { nsRows.compactMap({GridRow($0)}) }
        set {
            translatesAutoresizingMaskIntoConstraints = false
            if newValue.count > numberOfRows {
                (0..<(newValue.count - numberOfRows)).forEach({ _ in addRow(with: [])})
            } else if newValue.count < numberOfRows, let index = nsRows.firstIndex(where: {$0.cells.compactMap({$0.contentView}).count == 0}), index <= newValue.count {
                (index..<numberOfRows).reversed().forEach({
                    removeRow(at: $0)
                })
            }
            for (index, row) in newValue.enumerated() {
                if let rowIndex = row.gridRow?.index {
                    if rowIndex != index {
                        moveRow(at: rowIndex, to: index)
                    }
                } else {
                    if let gridRow = nsRows[safe: index] {
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
        public static func buildBlock(_ block: [NSView?]...) -> [NSView?] {
            block.flatMap { $0 }
        }

        /*
        public static func buildOptional(_ item: [NSView?]?) -> [NSView?] {
            item ?? []
        }
         */

        public static func buildEither(first: [NSView?]?) -> [NSView?] {
            first ?? []
        }

        public static func buildEither(second: [NSView?]?) -> [NSView?] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSView?]]) -> [NSView?] {
            components.flatMap { $0 }
        }

        /*
        public static func buildExpression(_ expr: [NSView?]?) -> [NSView?] {
            expr ?? []
        }
*/
        public static func buildExpression(_ expr: NSView??) -> [NSView?] {
            expr.map { [$0] } ?? []
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

#endif
