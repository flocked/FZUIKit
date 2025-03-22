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
            if newValue.count > gridView.numberOfRows {
                (0..<(newValue.count - gridView.numberOfRows)).forEach({ _ in
                    gridView.addRow(with: [])
                })
            }
            let cells = cells
            newValue.indexed().forEach({
                cells[$0.index].contentView = $0.element ?? NSGridCell.emptyContentView
            })
        }
    }
    
    /// The cells of the grid column.
    var cells: [NSGridCell] {
        (0..<numberOfCells).map({ cell(at: $0) })
    }
}
#endif
