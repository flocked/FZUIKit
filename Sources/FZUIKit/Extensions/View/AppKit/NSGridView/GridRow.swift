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
public class GridRow: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    /// The grid view of the row.
    public var gridView: NSGridView? { gridRow?.gridView }
    
    /// The index of the row inside it's grid view, or `nil` if the row isn't displayed in a grid view.
    public var index: Int? { gridRow?.index }
    
    /// The cells of the row.
    public var cells: [GridCell] { (gridRow?.cells ?? []).compactMap({ GridCell($0) }) }
    
    /// Merges the cells of the row.
    @discardableResult
    public func mergeCells() -> Self {
        if gridRow != nil {
            mergeCells(in: 0..<numberOfCells)
        } else {
            properties.merge = true
        }
        return self
    }
    
    /// Merges the cells at the specified range.
    @discardableResult
    public func mergeCells(in range: Range<Int>) -> Self {
        if gridRow != nil {
            guard numberOfCells > 0 else { return self }
            gridRow?.mergeCells(in: range.clamped(max: numberOfCells).nsRange)
        } else {
            properties.mergeRange = range.toClosedRange
        }
        return self
    }
    
    /// Merges the cells at the specified range.
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
    
    /// The content views of the grid row cells.
    public var views: [NSView?] {
        get { gridRow?.views ?? properties.views }
        set {
            if let gridRow = gridRow {
                gridRow.views = newValue
            } else {
                properties.views = newValue
            }
        }
    }
    
    /// Sets the content views of the grid row cells.
    @discardableResult
    public func views(@NSGridView.Builder _ views: () -> [NSView]) -> Self {
        self.views = views()
        return self
    }
    
    /// Sets the content views of the grid row cells.
    @discardableResult
    public func views(_ views: [NSView]) -> Self {
        self.views = views
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
            return height == NSGridView.automaticSizing ? nil : height
        }
        set {
            gridRow?.height = newValue ?? NSGridView.automaticSizing
            properties.height = newValue ?? NSGridView.automaticSizing
        }
    }
    
    /// Sets the row height.
    @discardableResult
    public func height(_ height: CGFloat?) -> Self {
        self.height = height
        return self
    }
    
    /// The alignment of the views of the y-coordinate.
    public var alignment: Alignment {
        get {
            if let gridRow = gridRow {
                return .init(gridRow.yPlacement, gridRow.rowAlignment)
            }
            return .init(properties.yAlignment, properties.rowAlignment)
        }
        set {
            gridRow?.yPlacement = newValue.placement ?? .inherited
            gridRow?.rowAlignment = newValue.rowAlignment ?? .inherited
            properties.yAlignment = newValue.placement ?? .inherited
            properties.rowAlignment = newValue.rowAlignment ?? .inherited
        }
    }
    
    /// Sets the alignment of the views of the y-coordinate.
    @discardableResult
    public func alignment(_ alignment: Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// A grid row with a line.
    public static var line: GridRow { GridRow(NSBox.horizontalLine()).mergeCells() }
    
    /// A grid row with the specific spacing.
    public static func spacing(_ height: CGFloat) -> GridRow {
        let spacer = NSView()
        spacer.heightAnchor.constraint(equalToConstant: height).activate()
        return GridRow(spacer)
    }
    
    /// Creates a grid row with the specified views.
    public init(views: [NSView?] = []) {
        properties.views = views
    }
    
    /// Creates a grid row with the specified views.
    public init(@NSGridView.Builder views: () -> [NSView?]) {
        properties.views = views()
    }
    
    /// Creates a grid row with the specified view.
    public init(_ view: NSView) {
        properties.views = [view]
    }
    
    init(_ gridRow: NSGridRow) {
        self.gridRow = gridRow
    }
    
    var properties = Properties()
    var numberOfCells: Int { gridRow?.numberOfCells ?? properties.views.count }
    weak var gridRow: NSGridRow? {
        didSet {
            if let gridRow = gridRow {
                gridRow.views = properties.views
                gridRow.isHidden = properties.isHidden
                gridRow.bottomPadding = properties.bottomPadding
                gridRow.topPadding = properties.topPadding
                gridRow.yPlacement = properties.yAlignment
                gridRow.rowAlignment = properties.rowAlignment
                properties.views = []
            } else if let gridRow = oldValue {
                properties.views = gridRow.views
            }
        }
    }
}

extension GridRow {
    /// The y-placement of the views.
    public enum Alignment: Int, CustomStringConvertible {
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
        
        var placement: NSGridCell.Placement? {
            switch self {
            case .none: return NSGridCell.Placement.none
            case .top: return .top
            case .bottom: return .bottom
            case .center: return .center
            case .fill: return .fill
            default: return nil
            }
        }
        var rowAlignment: NSGridRow.Alignment? {
            switch self {
            case .firstBaseline: return .firstBaseline
            case .lastBaseline: return .lastBaseline
            default: return nil
            }
        }
    }
    
    struct Properties {
        var views: [NSView?] = []
        var isHidden = false
        var yAlignment: NSGridCell.Placement = .inherited
        var height: CGFloat = NSGridView.automaticSizing
        var topPadding: CGFloat = 0.0
        var bottomPadding: CGFloat = 0.0
        var rowAlignment: NSGridRow.Alignment = .inherited
        var merge: Bool = false
        var mergeRange: ClosedRange<Int>? = nil
    }
    
    public var description: String {
        let height = gridRow?.height ?? properties.height
        return "GridRow(views: \(views.count), alignment: \(alignment),  height: \(height == NSGridView.automaticSizing ? "automatic" : "\(height)"))"
    }
    
    public var debugDescription: String {
        let height = gridRow?.height ?? properties.height
        var strings = ["GridRow:"]
        strings += "views: [\(views.compactMap({ if let view = $0 { return "\(type(of: view))"} else { return "Empty"} }).joined(separator: ", "))]"
        strings += "alignment: \(alignment)"
        strings += "height: \(height == NSGridView.automaticSizing ? "automatic" : "\(height)")"
        strings += "bottomPadding: \(bottomPadding), topPadding: \(topPadding)"
        strings += "isHidden: \(isHidden)"
        return strings.joined(separator: "\n  - ")
    }
    
    public static func == (lhs: GridRow, rhs: GridRow) -> Bool {
        if let lhs = lhs.gridRow, let rhs = rhs.gridRow {
            return lhs === rhs
        }
        return lhs === rhs
    }
}

extension GridRow {
    /// A function builder type that produces an array of grid rows.
    @resultBuilder
    public enum Builder {
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

        public static func buildExpression(_ expression: [GridRow]?) -> [GridRow] {
            expression ?? []
        }

        public static func buildExpression(_ expression: GridRow?) -> [GridRow] {
            expression.map { [$0] } ?? []
        }
        
        public static func buildExpression(_ expression: NSView) -> [GridRow] {
            [GridRow(views: [expression])]
        }
        
        public static func buildExpression(_ expression: [NSView]) -> [GridRow] {
            expression.map({ GridRow(views: [$0]) })
        }
    }
}

extension GridRow.Alignment {
    init(_ placement: NSGridCell.Placement, _ alignment: NSGridRow.Alignment) {
        if alignment == .firstBaseline || alignment == .lastBaseline {
            self = alignment == .firstBaseline ? .firstBaseline : .lastBaseline
        } else {
            switch placement {
            case .top, .leading, .inherited: self = .top
            case .bottom, .trailing: self = .bottom
            case .center: self = .center
            case .fill: self = .fill
            default: self = .none
            }
        }
    }
}
#endif
