//
//  GridRow.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A row within a `NSGridView`.
public class GridRow {
    /// The grid view of the row.
    public var gridView: NSGridView? { gridRow?.gridView }
    
    /// The index of the row inside it's grid view, or `nil` if the row isn't displayed in a grid view.
    public var index: Int? { gridRow?.index }
    
    /// The cells of the row.
    public var cells: [GridCell] { 
        get { gridRow?.cells.compactMap({ GridCell($0)}) ?? properties.cells }
        set {
            if let gridRow = gridRow, let gridView = gridView {
                let numberOfCells = numberOfCells
                let cellsCount = cells.count
                if newValue.count > cells.count {
                    (0..<(newValue.count - cellsCount)).forEach({ _ in
                        gridView.addColumn(with: [])
                    })
                }
                zip(gridRow.cells[safe: 0..<newValue.count], newValue).forEach { gridCell, cell in
                    cell.gridCell = gridCell
                }
            } else {
                properties.cells = newValue
            }
        }
    }
    
    var allCells: [GridCell] { (gridRow?.allCells ?? []).compactMap({ GridCell($0) }) }
    
    /// Sets the cells of the grid row.
    @discardableResult
    public func cells(@GridCell.Builder _ cells: () -> [GridCell]) -> Self {
        self.cells = cells()
        return self
    }
    
    /// Sets the cells of the grid row.
    @discardableResult
    public func cells(_ cells: [GridCell]) -> Self {
        self.cells = cells
        return self
    }
    
    /// The top padding of the row.
    public var topPadding: CGFloat {
        get { gridRow?.topPadding ?? properties.topPadding }
        set {
            gridRow?.topPadding = newValue
            properties.topPadding = newValue
        }
    }
    
    /// Sets the top padding of the row.
    @discardableResult
    public func topPadding(_ padding: CGFloat) -> Self {
        topPadding = padding
        return self
    }
    
    /// The bottom padding of the row.
    public var bottomPadding: CGFloat {
        get { gridRow?.bottomPadding ?? properties.bottomPadding }
        set {
            gridRow?.bottomPadding = newValue
            properties.bottomPadding = newValue
        }
    }
    
    /// Sets the bottom padding of the row.
    @discardableResult
    public func bottomPadding(_ padding: CGFloat) -> Self {
        bottomPadding = padding
        return self
    }
    
    /// A Boolean value that indicates whether the row is hidden.
    public var isHidden: Bool {
        get { gridRow?.isHidden ?? properties.isHidden }
        set {
            gridRow?.isHidden = newValue
            properties.isHidden = newValue
        }
    }
    
    /// Sets the boolean value that indicates whether the row is hidden.
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    /// The row height.
    public var height: CGFloat? {
        get {
            let height = gridRow?.height ?? properties.height
            return height == NSGridView.sizedForContent ? nil : height
        }
        set {
            gridRow?.height = newValue ?? NSGridView.sizedForContent
            properties.height = newValue ?? NSGridView.sizedForContent
        }
    }
    
    /// Sets the row height.
    @discardableResult
    public func height(_ height: CGFloat?) -> Self {
        self.height = height
        return self
    }
    
    /// The vertical alignment of the row's cells.
    public var alignment: Alignment {
        get {
            if let gridRow = gridRow {
                return .init(gridRow.yPlacement, gridRow.rowAlignment)
            }
            return .init(properties.alignment, properties.rowAlignment)
        }
        set {
            gridRow?.yPlacement = newValue.placement
            gridRow?.rowAlignment = newValue.rowAlignment
            properties.alignment = newValue.placement
            properties.rowAlignment = newValue.rowAlignment
        }
    }
    
    /// Sets the vertical alignment of the row's cells.
    @discardableResult
    public func alignment(_ alignment: Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// Merges the cells of the row.
    @discardableResult
    public func mergeCells() -> Self {
        if gridRow != nil {
            mergeCells(in: 0..<numberOfCells)
        } else {
            properties.mergeStart = 0
        }
        return self
    }
    
    /// Merges the cells at the specified range.
    @discardableResult
    public func mergeCells(in range: Range<Int>) -> Self {
        if gridRow != nil {
            guard numberOfCells > 0 else { return self }
            let allCells = allCells.uniqued().compactMap({ (cell: $0, view: $0.view) })
            gridRow?.mergeCells(in: range.clamped(max: numberOfCells).nsRange)
            let newAllCells = self.allCells.uniqued()
            var views = allCells.filter({ !newAllCells.contains($0.cell) }).compactMap({ $0.view })
            views = views.filter({ view in !newAllCells.contains(where: {$0.view === view }) })
            views.forEach({ $0.removeFromSuperview() })
        } else {
            properties.mergeStart = range.lowerBound
            properties.mergeEnd = range.upperBound
        }
        return self
    }
    
    /// Merges the cells at the specified range.
    @discardableResult
    public func mergeCells(in range: ClosedRange<Int>) -> Self {
        mergeCells(in: range.toRange)
    }
    
    /// Merges the cells of the row starting from the specified index.
    @discardableResult
    public func mergeCells(in range: PartialRangeFrom<Int>) -> Self {
        if gridRow != nil {
            mergeCells(in: range.lowerBound..<numberOfCells)
        } else {
            properties.mergeStart = range.lowerBound
            properties.mergeEnd = nil
        }
        return self
    }
    
    /// Merges the cells of the row upto the specified index.
    @discardableResult
    public func mergeCells(in range: PartialRangeUpTo<Int>) -> Self {
        if gridRow != nil {
            mergeCells(in: 0..<range.upperBound)
        } else {
            properties.mergeStart = nil
            properties.mergeEnd = range.upperBound
        }
        return self
    }
    
    /// Merges the cells from the first view to the second view.
    @discardableResult
    public func mergeCells(from firstView: NSView, to secondView: NSView) -> Self {
        let cells = cells
        if let startIndex = cells.firstIndex(where: { $0.view === firstView} ), let endIndex = cells.firstIndex(where: { $0.view === secondView } ), startIndex <= endIndex {
            mergeCells(in: startIndex..<endIndex)
        }
        return self
    }
    
    /// Unmerges the cells of the row.
    @discardableResult
    public func unmergeCells() -> Self {
        let cells = gridRow?.cells ?? []
        cells.filter({ if let head = $0.headOfMergedCell { return cells.contains(head) } else { return false } }).forEach({ $0.unmerge() })
        return self
    }
    
    /// Unmerges the cells of the row containing the cell at the specified index.
    @discardableResult
    public func unmergeCells(at index: Int) -> Self {
        let cells = gridRow?.cells ?? []
        guard let cell = cells[safe: index], let head = cell.headOfMergedCell, cells.contains(head) else { return self }
        cell.unmerge()
        return self
    }
    
    /// Unmerges the cells of the row at the specified range.
    @discardableResult
    public func unmergeCells(in range: ClosedRange<Int>) -> Self {
        (gridRow?.cells ?? [])[safe: range].forEach({ $0.unmerge() })
        return self
    }
    
    /// Unmerges the cells of the row at the specified range.
    @discardableResult
    public func unmergeCells(in range: Range<Int>) -> Self {
        (gridRow?.cells ?? [])[safe: range].forEach({ $0.unmerge() })
        return self
    }
    
    /// Unmerges the cells of the row starting from the specified range's lowerBound value.
    @discardableResult
    public func unmergeCells(in range: PartialRangeFrom<Int>) -> Self {
        (gridRow?.cells ?? [])[safe: range].forEach({ $0.unmerge() })
        return self
    }
    
    /// Unmerges the cells of the row upto the specified range's upperBound value.
    @discardableResult
    public func unmergeCells(in range: PartialRangeUpTo<Int>) -> Self {
        (gridRow?.cells ?? [])[safe: range].forEach({ $0.unmerge() })
        return self
    }
    
    /// A grid row with a line.
    public static var line: GridRow { 
        let row = GridRow(NSBox.horizontalLine()).mergeCells()
        row.properties.autoMerge = true
        return row
    }
    
    /// Creates a grid row with cells displaying the specified cells.
    public init(_ cells: [GridCell] = []) {
        properties.cells = cells
    }
    
    /// Creates a grid row with cells displaying the specified cells.
    public init(@GridCell.Builder cells: () -> [GridCell]) {
        properties.cells = cells()
    }
    
    /// Creates a grid row with a cell displaying the specified view.
    public init(_ view: NSView) {
        properties.cells = [GridCell(view)]
    }
    
    init(_ gridRow: NSGridRow) {
        self.gridRow = gridRow
        self.properties.autoMerge = gridRow.autoMerge
    }
    
    var properties = Properties()
    
    var numberOfCells: Int { gridRow?.numberOfCells ?? properties.cells.count }
    
  //  var autoMerge: Bool { properties.autoMerge }
    
    weak var gridRow: NSGridRow? {
        didSet {
            if let gridRow = gridRow {
                cells = properties.cells
                gridRow.isHidden = properties.isHidden
                gridRow.bottomPadding = properties.bottomPadding
                gridRow.topPadding = properties.topPadding
                gridRow.yPlacement = properties.alignment
                gridRow.rowAlignment = properties.rowAlignment
                gridRow.height = properties.height
                gridRow.autoMerge = properties.autoMerge
                properties.cells = []
            } else if let gridRow = oldValue {
                properties.cells = gridRow.cells.compactMap({ GridCell($0)})
                properties.isHidden = gridRow.isHidden
                properties.height = gridRow.height
                properties.bottomPadding = gridRow.bottomPadding
                properties.topPadding = gridRow.topPadding
                properties.alignment = gridRow.yPlacement
                properties.rowAlignment = gridRow.rowAlignment
            }
        }
    }
}

extension GridRow {
    /// The vertical alignment of a row cells.
    public enum Alignment: Int, CustomStringConvertible {
        /// Inherited from the grid view's row alignment.
        case inherited = 0
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
            case .inherited: return "inherited"
            case .none: return "none"
            case .top: return "top"
            case .bottom: return "bottom"
            case .center: return "center"
            case .fill: return "fill"
            case .firstBaseline: return "firstBaseline"
            case .lastBaseline: return "lastBaseline"
            }
        }
        
        var placement: NSGridCell.Placement {
            if self == .firstBaseline || self == .lastBaseline { return .inherited }
            return NSGridCell.Placement(rawValue: rawValue) ?? .inherited
        }
        
        var rowAlignment: NSGridRow.Alignment {
            switch self {
            case .firstBaseline: return .firstBaseline
            case .lastBaseline: return .lastBaseline
            case .inherited: return .inherited
            default: return .none
            }
        }
        
        init(_ placement: NSGridCell.Placement, _ alignment: NSGridRow.Alignment) {
            if alignment == .firstBaseline || alignment == .lastBaseline {
                self = alignment == .firstBaseline ? .firstBaseline : .lastBaseline
            } else {
                self = .init(rawValue: placement.rawValue) ?? .inherited
            }
        }
    }
    
    struct Properties {
        var cells: [GridCell] = []
        var isHidden = false
        var alignment: NSGridCell.Placement = .inherited
        var height: CGFloat = NSGridView.sizedForContent
        var topPadding: CGFloat = 0.0
        var bottomPadding: CGFloat = 0.0
        var rowAlignment: NSGridRow.Alignment = .inherited
        var mergeStart: Int? = nil
        var mergeEnd: Int? = nil
        var autoMerge: Bool = false
    }
    
    func applyMerge() {
        if properties.mergeStart != nil || properties.mergeEnd != nil {
            mergeCells(in: (properties.mergeStart ?? 0)..<(properties.mergeEnd ?? numberOfCells))
            properties.mergeStart = nil
            properties.mergeEnd = nil
        } else if properties.autoMerge {
            mergeCells()
        }
    }
    
    func remove() {
        guard let index = index, let gridView = gridView else { return }
        cells.forEach({ $0.unmerge() })
        gridRow = nil
        gridView.removeRow(at: index)
    }

    /// A function builder type that produces an array of grid rows.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: [GridRow]...) -> [GridRow] {
            components.flatMap { $0 }
        }
            
        public static func buildExpression(_ expression: GridRow) -> [GridRow] {
            [expression]
        }
        
        /*
        public static func buildExpression(_ expression: GridRow?) -> [GridRow] {
            [expression]
        }
         */
        
        public static func buildExpression(_ expression: [GridRow]) -> [GridRow] {
            expression.map { $0 }
        }
            
        public static func buildOptional(_ component: [GridRow]?) -> [GridRow] {
            component ?? []
        }
            
        public static func buildArray(_ components: [[GridRow]]) -> [GridRow] {
            components.flatMap { $0 }
        }
            
        public static func buildEither(first component: [GridRow]) -> [GridRow] {
            component
        }
        
        public static func buildEither(second component: [GridRow]) -> [GridRow] {
            component
        }

        public static func buildExpression(_ expression: NSView?) -> [GridRow] {
            [GridRow([expression].map({ GridCell($0)}))]
        }
        
        public static func buildExpression(_ expression: [NSView?]) -> [GridRow] {
            [GridRow(expression.map({ GridCell($0)}))]
        }
        
        public static func buildExpression(_ expression: String) -> [GridRow] {
            [GridRow([GridCell(NSTextField(wrappingLabelWithString: expression))])]
        }

        public static func buildExpression(_ expression: [String?]) -> [GridRow] {
            [GridRow(expression.map { GridCell($0.map(NSTextField.wrapping)) })]
        }
        
        public static func buildExpression(_ expression: GridCell) -> [GridRow] {
            [GridRow([expression])]
        }
        
        public static func buildExpression(_ expression: [GridCell]) -> [GridRow] {
            [GridRow(expression)]
        }
    }
}

extension GridRow: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let height = gridRow?.height ?? properties.height
        return "GridRow(cells: \(cells.count), alignment: \(alignment),  height: \(height == NSGridView.sizedForContent ? "sizedForContent" : "\(height)"))"
    }
    
    public var debugDescription: String {
        let height = gridRow?.height ?? properties.height
        var strings = ["GridRow:"]
        strings += "cells: [\(cells.compactMap({ if let view = $0.view { return "\(type(of: view))"} else { return "Empty"} }).joined(separator: ", "))]"
        strings += "alignment: \(alignmentString)"
        strings += "height: \(height == NSGridView.sizedForContent ? "sizedForContent" : "\(height)")"
        strings += "bottomPadding: \(bottomPadding), topPadding: \(topPadding)"
        strings += "isHidden: \(isHidden)"
        return strings.joined(separator: "\n  - ")
    }
    
    var alignmentString: String {
        if alignment == .inherited, let description = gridView?.alignment.y.description {
            return "inherited(\(description))"
        }
        return alignment.description
    }
    
    var cellAlignmentString: String? {
        if alignment == .inherited, let description = gridView?.alignment.y.description {
            return "inherited(\(description))"
        } else if alignment != .inherited {
            return "inherited(\(alignment.description))"
        }
        return nil
    }
}

extension GridRow: Equatable {
    public static func == (lhs: GridRow, rhs: GridRow) -> Bool {
        if let lhs = lhs.gridRow, let rhs = rhs.gridRow {
            return lhs === rhs
        }
        return lhs === rhs
    }
}

#endif
