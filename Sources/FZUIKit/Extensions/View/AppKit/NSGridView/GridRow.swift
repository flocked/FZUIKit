//
//  GridRow.swift
//
//
//  Created by Florian Zand on 23.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A row within a grid view.
public class GridRow {
    weak var gridRow: NSGridRow?
    
    /// The grid view of the row.
    public var gridView: NSGridView? {
        gridRow?.gridView
    }
    
    /// Merges the cells at the specified range.
    public func mergeCells(in range: Range<Int>) {
        gridRow?.mergeCells(in: range.nsRange)
    }
    
    /// The content views of the grid row cells.
    public var views: [NSView?] {
        get { gridRow?.views ?? _views }
        set {
            if let gridRow = self.gridRow {
                gridRow.views = newValue
            } else {
                _views = newValue
            }
        }
    }
    
    /// Sets the content views of the grid row cells.
    @discardableResult
    public func views(@NSGridView.Builder _ views: () -> [NSView]) -> Self {
        self.views = views()
        return self
    }
    
    /// A Boolean value that indicates whether the row is hidden.
    public var isHidden: Bool {
        get { gridRow?.isHidden ?? _isHidden }
        set {
            gridRow?.isHidden = newValue
            _isHidden = newValue
        }
    }
    
    /// Sets the boolean value that indicates whether the row is hidden.
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    /// The number of cells of the row.
    public var numberOfCells: Int {
        get { gridRow?.numberOfCells ?? _views.count }
    }
    
    /// The top padding of the row.
    public var topPadding: CGFloat {
        get { gridRow?.topPadding ?? _topPadding }
        set {
            gridRow?.topPadding = newValue
            _topPadding = newValue
        }
    }
    
    /// The bottom padding of the row.
    public var bottomPadding: CGFloat {
        get { gridRow?.bottomPadding ?? _bottomPadding }
        set {
            gridRow?.bottomPadding = newValue
            _bottomPadding = newValue
        }
    }
    
    /// Sets the top padding of the row.
    @discardableResult
    public func topPadding(_ padding: CGFloat) -> Self {
        topPadding = padding
        return self
    }
    
    /// Sets the bottom padding of the row.
    @discardableResult
    public func bottomPadding(_ padding: CGFloat) -> Self {
        bottomPadding = padding
        return self
    }
    
    /// The row alignment.
    public var rowAlignment: NSGridRow.Alignment {
        get { gridRow?.rowAlignment ?? _rowAlignment }
        set {
            gridRow?.rowAlignment = newValue
            _rowAlignment = newValue
        }
    }
    
    /// Sets the row alignment.
    @discardableResult
    public func rowAlignment(_ alignment: NSGridRow.Alignment) -> Self {
        rowAlignment = alignment
        return self
    }
    
    /// The row height.
    public var height: CGFloat {
        get { gridRow?.height ?? _height }
        set {
            gridRow?.height = newValue
            _height = newValue
        }
    }
    
    /// Sets the row height.
    @discardableResult
    public func height(_ height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
    /// The y-placement of the row.
    public var yPlacement: NSGridCell.Placement {
        get { gridRow?.yPlacement ?? _yPlacement }
        set {
            gridRow?.yPlacement = newValue
            _yPlacement = newValue
        }
    }
    
    /// Sets the y-placement of the row.
    @discardableResult
    public func yPlacement(_ placement: NSGridCell.Placement) -> Self {
        yPlacement = placement
        return self
    }
    
    var _views: [NSView?] = []
    var _isHidden: Bool = false
    var _topPadding: CGFloat = 0.0
    var _bottomPadding: CGFloat = 0.0
    var _height: CGFloat = 1.1754943508222875e-38
    var _yPlacement: NSGridCell.Placement = .inherited
    var _rowAlignment: NSGridRow.Alignment = .inherited
    
    /// Creates a grid row with the specified views.
    public init(@NSGridView.Builder _ views: () -> [NSView?]) {
        _views = views()
    }
    
    /// Creates a grid row with the specified views.
    public init(views: [NSView?]) {
        _views = views
    }
    
    /// Creates a grid row.
    public init() {
        
    }
    
    init(_ gridRow: NSGridRow) {
        self.gridRow = gridRow
        _isHidden = gridRow.isHidden
        _topPadding = gridRow.topPadding
        _bottomPadding = gridRow.bottomPadding
        _height = gridRow.height
        _yPlacement = gridRow.yPlacement
        _rowAlignment = gridRow.rowAlignment
    }
}

#endif
