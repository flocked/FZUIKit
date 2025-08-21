//
//  NSGridRow+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSGridRow {
    /// The index of the row inside it's grid view, or `nil` if the row isn't displayed in a grid view.
    var index: Int? {
        gridView?.index(of: self)
    }
    
    /// The content views of the grid row cells.
    var views: [NSView?] {
        get { cells.map({ $0.contentView }) }
        set {
            guard let gridView = gridView else { return }
            var newValue = newValue
            let cellsCount = cells.count
            if newValue.count > cellsCount {
                (0..<(newValue.count - cellsCount)).forEach({ _ in
                    gridView.addColumn(with: [])
                })
            } else if newValue.count < cellsCount {
                newValue += Array(repeating: nil, count: cellsCount - newValue.count)
            }
            zip(cells, newValue).forEach({
                if $0.0.contentView !== $0.1 {
                    let contentView = $0.0.contentView
                    $0.0.contentView = $0.1
                    contentView?.removeFromSuperview()
                }
            })
        }
    }
    
    /// The cells of the grid row.
    var cells: [NSGridCell] {
        allCells.uniqueCells
    }
    
    internal var allCells: [NSGridCell] {
        (0..<numberOfCells).map({ cell(at: $0) })
    }
    
    internal var allCells_: [NSGridCell] {
        value(forKeySafely: "_cells") as? [NSGridCell] ?? []
    }
    
    /*
    var _cells: [NSGridCell] {
        value(forKeySafely: "_cells") as? [NSGridCell] ?? []
    }
     */
    
    internal var autoMerge: Bool {
        get { getAssociatedValue("autoMerge") ?? false }
        set { setAssociatedValue(newValue, key: "autoMerge") }
    }
    
    /// The top boundary layout anchor.
    var topBoundaryAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_topBoundaryAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The top content layout anchor.
    var topContentAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_topContentAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The bottom boundary layout anchor.
    var bottomBoundaryAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_bottomBoundaryAnchor") as? NSLayoutXAxisAnchor
    }
    
    /// The bottom content layout anchor.
    var bottomContentAnchor: NSLayoutXAxisAnchor? {
        value(forKeySafely: "_bottomContentAnchor") as? NSLayoutXAxisAnchor
    }
}

extension NSGridRow.Alignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inherited: return "inherited"
        case .firstBaseline: return "firstBaseline"
        case .lastBaseline: return "lastBaseline"
        default: return "none"
        }
    }
}
#endif
