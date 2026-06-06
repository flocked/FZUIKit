//
//  GridCell.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

/// A cell within a `NSGridView`.
public class GridCell {
    /// The view of the cell.
    public var view: NSView? {
        get { gridCell?.contentView ?? properties.view }
        set {
            if let gridCell = gridCell {
                let contentView = gridCell.contentView
                gridCell.contentView = newValue
                contentView?.removeFromSuperview()
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
        get { Alignment(self) }
        set {
            gridCell?.xPlacement = newValue.x.placement
            gridCell?.yPlacement = newValue.y.placement
            gridCell?.rowAlignment = newValue.y.rowAlignment
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
    public var columnIndexes: IndexSet {
        gridCell?.columnIndexes ?? []
    }
    
    /// The row indexes of the cell.
    public var rowIndexes: IndexSet {
        gridCell?.rowIndexes ?? []
    }
    
    /// The grid cell above.
    public var topCell: GridCell? {
        guard let cell = gridCell?.topCell else { return nil }
        return GridCell(cell)
    }
    
    /// The grid cell below.
    public var bottomCell: GridCell? {
        guard let cell = gridCell?.bottomCell else { return nil }
        return GridCell(cell)
    }
    
    /// The leading grid cell.
    public var leadingCell: GridCell? {
        guard let cell = gridCell?.leadingCell else { return nil }
        return GridCell(cell)
    }
    
    /// The trailing grid cell.
    public var trailingCell: GridCell? {
        guard let cell = gridCell?.trailingCell else { return nil }
        return GridCell(cell)
    }
    
    /// The size of a cell.
    public struct Size {
        /// The width of the cell.
        public var width: Int = 1 {
            didSet { width = width.clamped(min: 1) }
        }
        
        /// The height of the cell.
        public var height: Int = 1 {
            didSet { height = height.clamped(min: 1) }
        }
        
        var needsMerge: Bool {
            width > 1 || height > 1
        }
        
        /// Creates a size with the specified width and height.
        public init(width: Int = 1, height: Int = 1) {
            self.width = width.clamped(min: 1)
            self.height = height.clamped(min: 1)
        }
        
        
        /// Creates a size with the specified width and height.
        public init(_ widthHeight:  Int) {
            self.width = widthHeight.clamped(min: 1)
            self.height = widthHeight.clamped(min: 1)
        }
    }
    
    /// The size of the cell.
    public var size: Size {
        get {
            guard gridCell != nil else { return properties.size }
            return Size(width: columnIndexes.count, height: rowIndexes.count)
        }
        set {
            if let gridCell = gridCell {
                gridCell.resize(to: newValue)
            } else {
                properties.size = newValue
            }
        }
    }
    
    /// Sets the size of the cell.
    @discardableResult
    public func size(_ size: Size) -> Self {
        self.size = size
        return self
    }
    
    /// Sets the width of the cell.
    @discardableResult
    public func width(_ width: Int) -> Self {
        size.width = width
        return self
    }
    
    /// Sets the height of the cell.
    @discardableResult
    public func height(_ height: Int) -> Self {
        size.height = height
        return self
    }
    
    /// A Boolean value indicating whether the cell is merged with one or several other cells.
    public var isMerged: Bool {
        gridCell?.isMerged ?? false
    }
    
    /// Unmerges the cell and all related cells.
    public func unmerge() {
        gridCell?.unmerge()
    }
    
    public init(_ view: NSView? = nil) {
        properties.view = view
    }
    
    public init(_ view: some View) {
        properties.view = NSHostingView(rootView: view)
    }
    
    public init(_ text: String, font: NSFont = .body) {
        properties.view = NSTextField.wrapping(text)
    }
    
    init(_ gridCell: NSGridCell) {
        self.gridCell = gridCell
    }
    
    weak var gridCell: NSGridCell? {
        didSet {
            guard oldValue !== gridCell else { return }
            if gridCell != nil {
                view = properties.view
                alignment = properties.alignment
                size = properties.size
                properties.view = nil
            } else if let oldValue = oldValue {
                properties.view = oldValue.contentView
                properties.alignment = .init(oldValue)
                properties.size = .init(width: oldValue.columnIndexes.count, height: oldValue.rowIndexes.count)
            }
        }
    }
    
    var properties = Properties()
    
    struct Properties {
        var view: NSView?
        var alignment = Alignment()
        var size = Size()
    }
}

extension NSGridCell {
    fileprivate func resize(to size: GridCell.Size) {
        guard let gridView = row?.gridView,
              let columnStart = columnIndexes.first,
              let rowStart = rowIndexes.first else { return }
        
        unmerge()
        
        guard size.needsMerge else { return }
        let desiredColumnEnd = columnStart + size.width
        let desiredRowEnd = rowStart + size.height
        
        if desiredColumnEnd > gridView.numberOfColumns {
            for _ in gridView.numberOfColumns..<desiredColumnEnd {
                gridView.addColumn(with: [])
            }
        }
        if desiredRowEnd > gridView.numberOfRows {
            for _ in gridView.numberOfRows..<desiredRowEnd {
                gridView.addRow(with: [])
            }
        }
        
        let columnEnd = min(desiredColumnEnd, gridView.numberOfColumns)
        let rowEnd = min(desiredRowEnd, gridView.numberOfRows)
        guard columnStart < columnEnd, rowStart < rowEnd else { return }
        
        gridView.mergeCells(inHorizontalRange: columnStart..<columnEnd, verticalRange: rowStart..<rowEnd)
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
            
            init(_ placement: NSGridCell.Placement) {
                self = .init(rawValue: placement.rawValue) ?? .none
            }
            
            var placement: NSGridCell.Placement {
                .init(rawValue: rawValue) ?? .inherited
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
                case .inherited: return "inherited"
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
            
            var rowAlignment: NSGridRow.Alignment {
                switch self {
                case .firstBaseline: return .firstBaseline
                case .lastBaseline: return .lastBaseline
                default: return .inherited
                }
            }
            
            var placement: NSGridCell.Placement {
                if self == .firstBaseline || self == .lastBaseline { return .inherited }
                return .init(rawValue: rawValue) ?? .inherited
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
        
        init(_ gridCell: GridCell) {
            if let gridCell = gridCell.gridCell {
                self = .init(gridCell)
            } else {
                self = gridCell.properties.alignment
            }
        }
        
        init(_ gridCell: NSGridCell) {
            x = .init(gridCell.xPlacement)
            y = .init(gridCell.yPlacement, gridCell.rowAlignment)
            customConstraints = gridCell.customPlacementConstraints
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
        let alignment = debug ? ", alignment: \(alignmentString)" : ""
        let indexes = (row: row?.index, column: column?.index)
        let row = indexes.row != nil ? "row: \(indexes.row!), " : debug ? "row: -, " : ""
        let column = indexes.column != nil ? "column: \(indexes.column!), " : debug ? "column: -, " : ""
        if let view = view {
            return "GridCell(\(row)\(column)view: \(view)\(alignment))"
        }
        return "GridCell(\(row)\(column)\(alignment))"
    }
    
    var alignmentString: String {
        "(x: \(column?.cellAlignmentString ?? alignment.x.description), y: \(row?.cellAlignmentString ?? alignment.y.description))"
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
        
        public static func buildExpression(_ expression: NSView?) -> [GridCell] {
            [GridCell(expression)]
        }
        
        public static func buildExpression(_ expression: [NSView?]) -> [GridCell] {
            expression.map { GridCell($0) }
        }
        
        public static func buildExpression(_ expression: some View) -> [GridCell] {
            [GridCell(NSHostingView(rootView: expression))]
        }
        
        public static func buildExpression(_ expression: String) -> [GridCell] {
            [GridCell(NSTextField.wrapping(expression))]
        }

        public static func buildExpression(_ expression: [String?]) -> [GridCell] {
            expression.map { GridCell($0.map(NSTextField.wrapping)) }
        }
    }
}
#endif
