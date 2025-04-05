//
//  NSGridColumn+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSGridColumn {
    /// The index of the column inside it's grid view, or `nil` if the column isn't displayed in a grid view.
    var index: Int? {
        gridView?.index(of: self)
    }
    
    /// The content views of the grid column cells.
    var views: [NSView?] {
        get { cells.map({ $0.contentView }) }
        set {
            guard let gridView = gridView else { return }
            var newValue = newValue
            let cellsCount = cells.count
            if newValue.count > cellsCount {
                (0..<(newValue.count - cellsCount)).forEach({ _ in
                    gridView.addRow(with: [])
                })
            } else if newValue.count < cellsCount {
                newValue += Array(repeating: nil, count: cellsCount - newValue.count)
            }
            zip(cells, newValue).forEach({
                if $0.0.contentView !== $0.1 {
                    $0.0.contentView?.removeFromSuperview()
                    $0.0.contentView = $0.1
                }
            })
        }
    }
    
    /// The cells of the grid column.
    var cells: [NSGridCell] {
        allCells.uniqueCells
    }
    
    internal var allCells: [NSGridCell] {
        (0..<numberOfCells).map({ cell(at: $0) })
    }
    
    /// The leading boundary layout anchor.
    var leadingBoundaryAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_leadingBoundaryAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The leading content layout anchor.
    var leadingContentAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_leadingContentAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The trailing boundary layout anchor.
    var trailingBoundaryAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_trailingBoundaryAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The trailing content layout anchor.
    var trailingContentAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_trailingContentAnchor") as? NSLayoutXAxisAnchor
    }
    
    /*
    internal var _cells: [GridCell] {
        get { (0..<numberOfCells).map({ GridCell(cell(at: $0)) }) }
        set {
            guard let gridView = gridView else { return }
            if newValue.count > gridView.numberOfRows {
                (0..<(newValue.count - gridView.numberOfRows)).forEach({ _ in
                    gridView.addRow(with: [])
                })
            }
            zip(cells, newValue).forEach({
                $0.0.contentView = $0.1.view
                $0.0.xPlacement = $0.1.alignment.x.placement
                $0.0.yPlacement = $0.1.alignment.y.placement
                $0.0.rowAlignment = $0.1.alignment.y.rowAlignment
                $0.0.customPlacementConstraints = $0.1.alignment.customConstraints
            })
        }
    }
     */
}
#endif
