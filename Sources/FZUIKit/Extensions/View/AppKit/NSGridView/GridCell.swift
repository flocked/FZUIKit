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
        get { gridCell?.contentView ?? properties.view }
        set {
            if let gridCell = gridCell {
                gridCell.contentView = newValue
            } else {
                properties.view = newValue
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
        get { Alignment(for: self) }
        set {
            gridCell?.xPlacement = .init(rawValue: newValue.x.rawValue) ?? .inherited
            gridCell?.yPlacement = .init(rawValue: newValue.y.rawValue) ?? .inherited
            gridCell?.customPlacementConstraints = newValue.customConstraints
            properties.alignment = newValue
        }
    }
    
    /// Sets the alignment of the cell.
    @discardableResult
    public func alignment(x: Alignment.Horizontal, y: Alignment.Vertical) -> Self {
        alignment.x = x
        alignment.y = y
        return self
    }
    
    /// Sets the horizontal alignment of the cell.
    @discardableResult
    public func alignment(x: Alignment.Horizontal) -> Self {
        alignment.x = x
        return self
    }
    
    /// Sets the vertical alignment of the cell.
    @discardableResult
    public func alignment(y: Alignment.Vertical) -> Self {
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
    
    /// Unmerges the cell and all related cells.
    public func unmerge() {
        gridCell?.unmerge()
    }
    
    init(_ view: NSView?) {
        properties.view = view
    }
    
    static var empty: GridCell {
        GridCell(nil)
    }
    
    init(_ gridCell: NSGridCell) {
        self.gridCell = gridCell
    }
    
    weak var gridCell: NSGridCell?
    var properties = Properties()
    
    struct Properties {
        var view: NSView?
        var alignment = Alignment()
    }
}

extension GridCell {
    /// The alignment of a cell.
    public struct Alignment: CustomStringConvertible, CustomDebugStringConvertible {
        /// The horizontal alignment of a cell.
        public enum Horizontal: Int, CustomStringConvertible {
            /// Inherited from the cell's column alignment.
            case inherited
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
                case .inherited: return "inherited"
                }
            }
        }
        
        /// The vertical alignment of a cell.
        public enum Vertical: Int, CustomStringConvertible {
            /// Inherited from the cell's row alignment.
            case inherited
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
            
            public var description: String {
                switch self {
                case .none: return "none"
                case .top: return "top"
                case .bottom: return "bottom"
                case .center: return "center"
                case .fill: return "fill"
                case .inherited: return "inherited"
                }
            }
        }
        
        /// The horizontal alignment of the cell.
        public var x: Horizontal = .inherited
        
        /// The vertical alignment of the cell.
        public var y: Vertical = .inherited
        
        /// The custom alignment layout constraints.
        public var customConstraints: [NSLayoutConstraint] = []
        
        public var description: String {
            "(x: \(x), y: \(y), customConstraints: \(customConstraints.count))"
        }
        
        public var debugDescription: String {
            "(x: \(x), y: \(y), customConstraints: \(customConstraints)))"
        }
        
        init() { }
        
        init(for gridCell: GridCell) {
            if let gridCell = gridCell.gridCell {
                x = .init(rawValue: (gridCell.xPlacement).rawValue) ?? .inherited
                y = .init(rawValue: (gridCell.yPlacement).rawValue) ?? .inherited
                customConstraints = gridCell.customPlacementConstraints
            } else {
                self = gridCell.properties.alignment
            }
        }
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
    enum Builder {
        public static func buildBlock(_ components: [GridCell]...) -> [GridCell] {
            components.flatMap { $0 }
        }
            
        public static func buildExpression(_ expression: GridCell) -> [GridCell] {
            [expression]
        }
        
        /*
        public static func buildExpression(_ expression: GridCell?) -> [GridCell] {
            [expression].nonNil
        }
         */
        
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
        
        /*
        public static func buildExpression(_ expression: NSView?) -> [GridCell] {
            [GridCell(expression)]
        }
        
        public static func buildExpression(_ expression: [NSView?]) -> [GridCell] {
            expression.map { GridCell($0) }
        }
        
        public static func buildExpression(_ expression: String) -> [GridCell] {
            [GridCell(NSTextField.wrapping(expression))]
        }

        public static func buildExpression(_ expression: [String?]) -> [GridCell] {
            expression.map { GridCell($0.map(NSTextField.wrapping)) }
        }
         */
    }
}
#endif
