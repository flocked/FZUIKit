//
//  NSGridColumn+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit

public extension NSGridColumn {
    /// The index of the column inside it's grid view, or `nil` if the column isn't displayed in a grid view.
    var index: Int? {
        gridView?.index(of: self)
    }
    
    /// The content views of the grid column cells.
    var views: [NSView?] {
        get { cells.map({$0.contentView}) }
        set {
            guard let gridView = gridView else { return }
            if newValue.count > gridView.numberOfRows {
                (0..<(newValue.count - gridView.numberOfRows)).forEach({ _ in
                    gridView.addRow(with: [])
                })
            }
            let cells = cells
            newValue.enumerated().forEach({
                cells[$0.offset].contentView = $0.element ?? NSGridCell.emptyContentView
            })
        }
    }
    
    /// The cells of the grid column.
    var cells: [NSGridCell] {
        guard let gridView = gridView else { return [] }
        return (0..<numberOfCells).compactMap({ gridView.cell(atColumnIndex: gridView.index(of: self), rowIndex: $0) })
    }
}
#endif
