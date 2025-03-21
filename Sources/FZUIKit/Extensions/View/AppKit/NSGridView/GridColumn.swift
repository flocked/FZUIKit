//
//  GridColumn.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A column within a `NSGridView`.
public class GridColumn {
    /// The grid view of the column.
    public var gridView: NSGridView? { gridColumn?.gridView }
    
    /// The index of the column inside it's grid view, or `nil` if the column isn't displayed in a grid view.
    public var index: Int? { gridColumn?.index }
    
    /// The cells of the column.
    public var cells: [GridCell] { (gridColumn?.cells ?? []).compactMap({ GridCell($0) }) }
    
    /// The content views of the grid column cells.
    public var views: [NSView?] {
        get { gridColumn?.views ?? properties.views }
        set {
            if let gridColumn = gridColumn {
                gridColumn.views = newValue
            } else {
                properties.views = newValue
            }
        }
    }
    
    /// Sets the content views of the grid column cells.
    @discardableResult
    public func views(@NSGridView.Builder _ views: () -> [NSView]) -> Self {
        self.views = views()
        return self
    }
    
    /// Sets the content views of the grid column cells.
    @discardableResult
    public func views(_ views: [NSView]) -> Self {
        self.views = views
        return self
    }

    /// The leading padding of the column.
    public var leadingPadding: CGFloat {
        get { gridColumn?.leadingPadding ?? properties.leadingPadding }
        set {
            gridColumn?.leadingPadding = newValue
            properties.leadingPadding = newValue
        }
    }
    
    /// Sets the leading padding of the column.
    @discardableResult
    public func leadingPadding(_ padding: CGFloat) -> Self {
        leadingPadding = padding
        return self
    }

    /// The trailing padding of the column.
    public var trailingPadding: CGFloat {
        get { gridColumn?.trailingPadding ?? properties.trailingPadding }
        set {
            gridColumn?.trailingPadding = newValue
            properties.trailingPadding = newValue
        }
    }
    
    /// Sets the trailing padding of the column.
    @discardableResult
    public func trailingPadding(_ padding: CGFloat) -> Self {
        trailingPadding = padding
        return self
    }

    /// A Boolean value that indicates whether the column is hidden.
    public var isHidden: Bool {
        get { gridColumn?.isHidden ?? properties.isHidden }
        set {
            gridColumn?.isHidden = newValue
            properties.isHidden = newValue
        }
    }
    
    /// Sets the Boolean value that indicates whether the column is hidden.
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }

    /// The column width.
    public var width: CGFloat? {
        get {
            let width = gridColumn?.width ?? properties.width
            return width == NSGridView.automaticSizing ? nil : width
        }
        set {
            gridColumn?.width = newValue ?? NSGridView.automaticSizing
            properties.width = newValue ?? NSGridView.automaticSizing
        }
    }
    
    /// Sets the column width.
    @discardableResult
    public func width(_ width: CGFloat?) -> Self {
        self.width = width
        return self
    }

    /// The alignment of the views on the x-coordinate.
    public var alignment: Alignment {
        get {.init(gridColumn?.xPlacement ?? properties.alignment) }
        set {
            gridColumn?.xPlacement = newValue.placement
            properties.alignment = newValue.placement
        }
    }
    
    /// Sets the alignment of the views on the x-coordinate.
    @discardableResult
    public func alignment(_ alignment: Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// Merges the cells of the column.
    @discardableResult
    public func mergeCells() -> Self {
        if gridColumn != nil {
            mergeCells(in: 0..<numberOfCells)
        } else {
            properties.merge = true
        }
        return self
    }
    
    /// Merges the cells of the column at the specified range.
    @discardableResult
    public func mergeCells(in range: Range<Int>) -> Self {
        guard numberOfCells > 0 else { return self }
        if gridColumn != nil {
            guard numberOfCells > 0 else { return self }
            gridColumn?.mergeCells(in: range.clamped(max: numberOfCells).nsRange)
        } else {
            properties.mergeRange = range.toClosedRange
        }
        return self
    }
    
    /// Merges the cells of the column at the specified range.
    @discardableResult
    public func mergeCells(in range: ClosedRange<Int>) -> Self {
        mergeCells(in: range.toRange)
    }
    
    /// Merges the cells from the first view to the second view.
    @discardableResult
    public func mergeCells(from firstView: NSView, to secondView: NSView) -> Self {
        let views = views
        if let startIndex = views.firstIndex(of: firstView), let endIndex = views.firstIndex(of: secondView), startIndex <= endIndex {
            mergeCells(in: startIndex..<endIndex)
        }
        return self
    }
    
    /// A grid column with the specific spacing.
    public static func spacing(_ width: CGFloat) -> GridColumn {
        let spacer = NSView()
        spacer.widthAnchor.constraint(equalToConstant: width).activate()
        return GridColumn(spacer)
    }
    
    /// Creates a grid column with cells displaying the specified views.
    public init(views: [NSView?] = []) {
        properties.views = views
    }
    
    /// Creates a grid column with cells displaying the specified views.
    public init(@NSGridView.Builder views: () -> [NSView?]) {
        properties.views = views()
    }
    
    /// Creates a grid column with a cell displaying the specified view.
    public init(_ view: NSView) {
        properties.views = [view]
    }
    
    /// Creates a grid column with cells displaying text fields with the specified labels.
    public init(labels: [String] = []) {
        properties.views = labels.map({NSTextField.wrapping($0)})
    }
    
    init(_ gridColumn: NSGridColumn) {
        self.gridColumn = gridColumn
    }
    
    var properties = Properties()
    
    var numberOfCells: Int { gridColumn?.numberOfCells ?? properties.views.count }
    
    weak var gridColumn: NSGridColumn? {
        didSet {
            if let gridColumn = gridColumn {
                gridColumn.views = properties.views
                gridColumn.width = properties.width
                gridColumn.isHidden = properties.isHidden
                gridColumn.leadingPadding = properties.leadingPadding
                gridColumn.trailingPadding = properties.trailingPadding
                gridColumn.xPlacement = properties.alignment
                properties.views = []
            } else if let gridColumn = oldValue {
                properties.views = gridColumn.views
                properties.width = gridColumn.width
                properties.isHidden = gridColumn.isHidden
                properties.leadingPadding = gridColumn.leadingPadding
                properties.trailingPadding = gridColumn.trailingPadding
                properties.alignment = gridColumn.xPlacement
            }
        }
    }
}

extension GridColumn {
    /// The alignment of the views on the x-coordinate.
    public enum Alignment: Int, CustomStringConvertible {
        /// None.
        case none = 1
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
        
        var placement: NSGridCell.Placement {
            NSGridCell.Placement(rawValue: rawValue)!
        }
        
        init(_ placement: NSGridCell.Placement) {
            self = .init(rawValue: placement.rawValue) ?? .none
        }
    }
    
    struct Properties {
        var views: [NSView?] = []
        var isHidden = false
        var alignment: NSGridCell.Placement = .inherited
        var width: CGFloat = NSGridView.automaticSizing
        var leadingPadding: CGFloat = 0.0
        var trailingPadding: CGFloat = 0.0
        var merge: Bool = false
        var mergeRange: ClosedRange<Int>? = nil
    }
    
    func applyMerge() {
        if let range = properties.mergeRange {
            properties.mergeRange = nil
            mergeCells(in: range)
        } else if properties.merge {
            properties.merge = false
            mergeCells()
        }
    }
    
    func remove() {
        guard let index = index, let gridView = gridView else { return }
        gridColumn = nil
        gridView.removeColumn(at: index)
    }

    /// A function builder type that produces an array of grid column.
    @resultBuilder
    public enum Builder {
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

        public static func buildExpression(_ expression: [GridColumn]?) -> [GridColumn] {
            expression ?? []
        }

        public static func buildExpression(_ expression: GridColumn?) -> [GridColumn] {
            expression.map { [$0] } ?? []
        }
        
        public static func buildExpression(_ expression: NSView) -> [GridColumn] {
            [GridColumn(views: [expression])]
        }
        
        public static func buildExpression(_ expression: [NSView?]) -> [GridColumn] {
            [GridColumn(views: expression)]
        }
        
        public static func buildExpression(_ expression: String) -> [GridColumn] {
            [GridColumn(views: [NSTextField.wrapping(expression)])]
        }
        
        public static func buildExpression(_ expression: [String]) -> [GridColumn] {
            [GridColumn(views: expression.map({ NSTextField.wrapping($0) }))]
        }
    }
}

extension GridColumn: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let width = gridColumn?.width ?? properties.width
        return "GridColumn(views: \(views.count), alignment: \(alignment),  width: \(width == NSGridView.automaticSizing ? "automatic" : "\(width)"))"
    }
    
    public var debugDescription: String {
        let width = gridColumn?.width ?? properties.width
        var strings = ["GridColumn:"]
        strings += "views: [\(views.compactMap({ if let view = $0 { return "\(type(of: view))"} else { return "Empty"} }).joined(separator: ", "))]"
        strings += "alignment: \(alignment)"
        strings += "width: \(width == NSGridView.automaticSizing ? "automatic" : "\(width)")"
        strings += "leadingPadding: \(leadingPadding), trailingPadding: \(trailingPadding)"
        strings += "isHidden: \(isHidden)"
        return strings.joined(separator: "\n  - ")
    }
}

extension GridColumn: Equatable {
    public static func == (lhs: GridColumn, rhs: GridColumn) -> Bool {
        if let lhs = lhs.gridColumn, let rhs = rhs.gridColumn {
            return lhs === rhs
        }
        return lhs === rhs
    }
}
#endif
