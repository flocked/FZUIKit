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
    
    /// Merges all cells.
    public func mergeCells() {
        mergeCells(in: 0..<numberOfCells)
    }
    
    /// Merges the cells at the specified range.
    public func mergeCells(in range: Range<Int>) {
        guard numberOfCells > 0 else { return }
        gridRow?.mergeCells(in: range.clamped(max: numberOfCells).nsRange)
    }
    
    /// Merges the cells at the specified range.
    public func mergeCells(in range: ClosedRange<Int>) {
        mergeCells(in: range.lowerBound..<range.upperBound-1)
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
    public var height: CGFloat {
        get { gridRow?.height ?? properties.height }
        set {
            gridRow?.height = newValue
            properties.height = newValue
        }
    }
    
    /// Sets the row height.
    @discardableResult
    public func height(_ height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
    /// The y-placement of the views.
    public var yPlacement: Placement {
        get { .init(rawValue: (gridRow?.yPlacement ?? properties.yPlacement).rawValue) ?? .inherited }
        set {
            gridRow?.yPlacement = newValue.placement
            properties.yPlacement = newValue.placement
        }
    }
    
    /// Sets the y-placement of the views.
    @discardableResult
    public func yPlacement(_ placement: Placement) -> Self {
        yPlacement = placement
        return self
    }
    
    /// The row alignment.
    public var rowAlignment: NSGridRow.Alignment {
        get { gridRow?.rowAlignment ?? properties.rowAlignment }
        set {
            gridRow?.rowAlignment = newValue
            properties.rowAlignment = newValue
        }
    }
    
    /// Sets the row alignment.
    @discardableResult
    public func rowAlignment(_ alignment: NSGridRow.Alignment) -> Self {
        rowAlignment = alignment
        return self
    }
    
    /// Creates a grid row with the specified views.
    public init(views: [NSView?] = []) {
        properties.views = views
    }
    
    /// Creates a grid row with the specified views.
    public init(@NSGridView.Builder _ views: () -> [NSView?]) {
        properties.views = views()
    }
    
    init(_ gridRow: NSGridRow) {
        self.gridRow = gridRow
    }
    
    var properties = Properties()
    let id = UUID()
    var numberOfCells: Int { gridRow?.numberOfCells ?? properties.views.count }
    weak var gridRow: NSGridRow? {
        didSet {
            if let gridRow = gridRow {
                gridRow.views = properties.views
                gridRow.isHidden = properties.isHidden
                gridRow.bottomPadding = properties.bottomPadding
                gridRow.topPadding = properties.topPadding
                gridRow.yPlacement = properties.yPlacement
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
    public enum Placement: Int, CustomStringConvertible {
        /// Inherited.
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
            case .inherited: return "inherited"
            case .none: return "none"
            case .top: return "top"
            case .bottom: return "bottom"
            case .center: return "center"
            case .fill: return "fill"
            }
        }
        
        var placement: NSGridCell.Placement {
            .init(rawValue: rawValue)!
        }
    }
    
    struct Properties {
        var views: [NSView?] = []
        var isHidden = false
        var yPlacement: NSGridCell.Placement = .inherited
        var height: CGFloat = 1.1754943508222875e-38
        var topPadding: CGFloat = 0.0
        var bottomPadding: CGFloat = 0.0
        var rowAlignment: NSGridRow.Alignment = .inherited
    }
    
    public var description: String {
        return "GridRow(views: \(views.count), yPlacement: \(yPlacement),  height: \(height))"
    }
    
    public var debugDescription: String {
        let views = views.compactMap({ if let view = $0 { return "\(type(of: view))"} else { return "Empty"} })
        var strings = ["GridRow:"]
        strings += "  - views: [\(views.joined(separator: ", "))]"
        strings += "  - yPlacement: \(yPlacement)"
        strings += "  - rowAlignment: \(rowAlignment)"
        strings += "  - height: \(height == 1.1754943508222875e-38 ? "automatic" : "\(height)")"
        strings += "  - bottomPadding: \(bottomPadding), topPadding: \(topPadding)"
        strings += "  - isHidden: \(isHidden)"
        return strings.joined(separator: "\n")
    }
    
    public static func == (lhs: GridRow, rhs: GridRow) -> Bool {
        if let lhs = lhs.gridRow, let rhs = rhs.gridRow {
            return lhs === rhs
        }
        return lhs.id == rhs.id
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
#endif
