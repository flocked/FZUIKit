//
//  GridCell.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit

/// A cell within a `NSGridView`.
public class GridCell: CustomStringConvertible, CustomDebugStringConvertible {
    /// The content view of the cell.
    public var contentView: NSView? {
        get { gridCell?.contentView }
        set { gridCell?.contentView = newValue }
    }
    
    /// Sets the content view of the cell.
    @discardableResult
    public func contentView(_ contentView: NSView?) -> Self {
        self.contentView = contentView
        return self
    }
    
    /// The custom placement layout constraits.
    public var customPlacementConstraints: [NSLayoutConstraint] {
        get { gridCell?.customPlacementConstraints ?? [] }
        set { gridCell?.customPlacementConstraints = newValue }
    }
    
    /// Sets the custom placement layout constraits.
    @discardableResult
    public func customPlacementConstraints(_ constraints: [NSLayoutConstraint]) -> Self {
        customPlacementConstraints = constraints
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
    
    init(_ gridCell: NSGridCell) {
        self.gridCell = gridCell
    }
    
    weak var gridCell: NSGridCell?
    
    public var description: String {
        if let columnIndex = column?.index, let rowIndex = row?.index {
            if let contentView = contentView {
                return "GridCell(row: \(rowIndex), column: \(columnIndex), contentView: \(contentView))"
            }
            return "GridCell(row: \(rowIndex), column: \(columnIndex))"
        }
        if let contentView = contentView {
            return "GridCell(contentView: \(contentView))"
        }
        return "GridCell"
    }
    
    public var debugDescription: String {
        let xAlignment: GridColumn.Alignment = column?.alignment ?? .init(.inherited)
        let yAlignment: GridRow.Alignment = row?.alignment ?? .init(.inherited, .inherited)
        if let columnIndex = column?.index, let rowIndex = row?.index {
            if let contentView = contentView {
                return "GridCell(row: \(rowIndex), column: \(columnIndex), contentView: \(contentView), xAlignment: \(xAlignment), yPlacement: \(yAlignment))"
            }
            return "GridCell(row: \(rowIndex), column: \(columnIndex), contentView: -, xAlignment: \(xAlignment), yAlignment: \(yAlignment))"
        }
        if let contentView = contentView {
            return "GridCell(row: -, column: -, contentView: \(contentView), xAlignment: \(xAlignment), yAlignment: \(yAlignment))"
        }
        return "GridCell(row: -, column: -, contentView: -, xAlignment: \(xAlignment), yAlignment: \(yAlignment))"
    }
}
#endif
