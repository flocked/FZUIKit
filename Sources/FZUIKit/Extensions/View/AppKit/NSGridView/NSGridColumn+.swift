//
//  NSGridColumn+.swift
//  
//
//  Created by Florian Zand on 23.02.24.
//

#if os(macOS)
import AppKit

extension NSGridColumn {
    /// The index of the column inside it's grid view, or `nil` if the column isn't displayed in a grid view.
    public var index: Int? {
        gridView?.nsColumns.firstIndex(of: self)
    }
    
    /// The cells of the grid column.
    public var cells: [NSGridCell] {
        get { (0..<numberOfCells).compactMap({cell(at: $0)}) }
    }
    
    /// The content views of the grid column cells.
    public var contentViews: [NSView?] {
        get { cells.compactMap({$0.contentView}) }
        set {
            guard let gridView = self.gridView else { return }
            if newValue.count > gridView.numberOfRows {
                let count = newValue.count - gridView.numberOfRows
                for _ in (0..<count) {
                    gridView.addRow(with: [])
                }
            }
            let cells = self.cells
            cells.forEach({$0.contentView?.removeFromSuperview() })
            for (index, view) in newValue.enumerated() {
                self.cells[safe: index]?.contentView = view
            }
            if newValue.count < gridView.numberOfRows {
                let rows = gridView.nsRows
                for index in stride(from: rows.count-1, to: newValue.count-1, by: -1) {
                    if let row = rows[safe: index] {
                        if row.cells.compactMap({$0.contentView}).count == 0 {
                            gridView.removeRow(at: index)
                        }
                    }
                }
            }
        }
    }
}

#endif
