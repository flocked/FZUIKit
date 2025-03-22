//
//  GridCell.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A cell within a `NSGridView`.
public class GridCell {
    /// The view of the cell.
    public var view: NSView? {
        get { gridCell?.contentView ?? contentView }
        set {
            if let gridCell = gridCell {
                gridCell.contentView = newValue
            } else {
                contentView = newValue
            }
        }
    }
    
    /// Sets the view of the cell.
    @discardableResult
    public func view(_ view: NSView?) -> Self {
        self.view = view
        return self
    }
    
    /// The alignment of the cell.
    public var alignment: Alignment {
        get { Alignment(column, row, gridCell?.customPlacementConstraints ?? []) }
        set {
            column?.alignment = newValue.x
            row?.alignment = newValue.y
            gridCell?.customPlacementConstraints = newValue.customConstraints
        }
    }
    
    /// The alignment of the cell.
    public struct Alignment: CustomStringConvertible, CustomDebugStringConvertible {
        /// The alignment of the cell on the x-coordinate.
        public var x: GridColumn.Alignment
        
        /// The alignment of the cell on the y-coordinate.
        public var y: GridRow.Alignment
        
        /// The custom alignment layout constraints.
        public var customConstraints: [NSLayoutConstraint]
        
        public var description: String {
            "(x: \(x), y: \(y), customConstraints: \(customConstraints.count))"
        }
        
        public var debugDescription: String {
            "(x: \(x), y: \(y), customConstraints: \(customConstraints)))"
        }
        
        init(_ x: GridColumn?, _ y: GridRow?, _ customConstraints: [NSLayoutConstraint]) {
            self.x = x?.alignment ?? .init(.inherited)
            self.y = y?.alignment ?? .init(.inherited, .inherited)
            self.customConstraints = customConstraints
        }
    }
    
    /// Sets the alignment of the cell.
    @discardableResult
    public func alignment(x: GridColumn.Alignment, y: GridRow.Alignment) -> Self {
        alignment.x = x
        alignment.y = y
        return self
    }
    
    /// Sets the alignment of the cell on the x-coordinate.
    @discardableResult
    public func alignment(x: GridColumn.Alignment) -> Self {
        alignment.x = x
        return self
    }
    
    /// Sets the alignment of the cell on the y-coordinate.
    @discardableResult
    public func alignment(y: GridRow.Alignment) -> Self {
        alignment.y = y
        return self
    }
    
    /// Sets the custom alignment layout constraints.
    @discardableResult
    public func customAlignmentConstraints(_ constraints: [NSLayoutConstraint]) -> Self {
        alignment.customConstraints = constraints
        return self
    }
    
    /// The column of the grid cell.
    public var column: GridColumn? {
        get {
            guard let column = gridCell?.column else { return nil }
            return GridColumn(column)
        }
    }
    
    /// The row of the grid cell.
    public var row: GridRow? {
        get {
            guard let row = gridCell?.row else { return nil }
            return GridRow(row)
        }
    }
    
    /// The column indexes of the cell.
    public var columnIndexes: [Int] {
        gridCell?.columnIndexes ?? []
    }
    
    /// The row indexes of the cell.
    public var rowIndexes: [Int] {
        gridCell?.rowIndexes ?? []
    }
    
    /// The grid cell above.
    public var topCell: GridCell? {
        guard let cells = row?.cells, let index = cells.firstIndex(of: self), index > 0 else { return nil }
        return cells[safe: index-1]
    }
    
    /// The grid cell bellow.
    public var bottomCell: GridCell? {
        guard let cells = row?.cells, let index = cells.firstIndex(of: self), index+1 < cells.count else { return nil }
        return cells[safe: index+1]
    }
    
    /// The grid cell leading.
    public var leadingCell: GridCell? {
        guard let cells = column?.cells, let index = cells.firstIndex(of: self), index > 0 else { return nil }
        return cells[safe: index-1]
    }
    
    /// The grid cell trailing.
    public var trailingCell: GridCell? {
        guard let cells = column?.cells, let index = cells.firstIndex(of: self), index+1 < cells.count else { return nil }
        return cells[safe: index+1]
    }
    
    init(_ gridCell: NSGridCell) {
        self.gridCell = gridCell
    }
    
    weak var gridCell: NSGridCell?
    var contentView: NSView?
    
    init(_ view: NSView?) {
        contentView = view
    }
}

extension GridCell: Equatable {
    public static func == (lhs: GridCell, rhs: GridCell) -> Bool {
        if let lhs = lhs.gridCell, let rhs = rhs.gridCell {
            return lhs === rhs
        }
        return lhs === rhs
    }
}

extension GridCell: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        description(debug: false)
    }
    
    public var debugDescription: String {
        description(debug: true)
    }
    
    func description(debug: Bool) -> String {
        let alignment = debug ? ", alignment: \(alignment)" : ""
        let indexes = (row: row?.index, column: column?.index)
        let row = indexes.row != nil ? "row: \(indexes.row!), " : debug ? "row: -, " : ""
        let column = indexes.column != nil ? "column: \(indexes.column!), " : debug ? "column: -, " : ""
        if let view = view {
            return "GridCell(\(row)\(column)view: \(view)\(alignment))"
        }
        return "GridCell(\(row)\(column)\(alignment))"
    }
}

extension GridCell {
    /// A function builder type that produces an array of grid column.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: [GridCell]...) -> [GridCell] {
            components.flatMap { $0 }
        }
            
        public static func buildExpression(_ expression: GridCell) -> [GridCell] {
            [expression]
        }
        
        public static func buildExpression(_ expression: GridCell?) -> [GridCell] {
            expression != nil ? [expression!] : []
        }
        
        public static func buildExpression(_ expression: [GridCell]) -> [GridCell] {
            expression.map { $0 }
        }
            
        public static func buildOptional(_ component: [GridCell]?) -> [GridCell] {
            component ?? []
        }
            
        public static func buildArray(_ components: [[GridCell]]) -> [GridCell] {
            components.flatMap { $0 }
        }
            
        public static func buildEither(first component: [GridCell]) -> [GridCell] {
            component
        }
        
        public static func buildEither(second component: [GridCell]) -> [GridCell] {
            component
        }
    }
}
#endif
