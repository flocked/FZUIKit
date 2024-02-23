//
//  NSGridRow+.swift
//
//
//  Created by Florian Zand on 23.02.24.
//

#if os(macOS)
import AppKit

extension NSGridRow {
    /// The index of the row inside it's grid view, or `nil` if the row isn't displayed in a grid view.
    public var index: Int? {
        gridView?.nsRows.firstIndex(of: self)
    }
    
    /// The cells of the grid row.
    public var cells: [NSGridCell] {
        get { (0..<numberOfCells).compactMap({cell(at: $0)}) }
    }
    
    /// The content views of the grid row cells.
    public var views: [NSView?] {
        get { cells.compactMap({$0.contentView}) }
        set {
            guard let gridView = self.gridView else { return }
            if newValue.count > gridView.numberOfColumns {
                let count = newValue.count - gridView.numberOfColumns
                for _ in (0..<count) {
                    gridView.addColumn(with: [])
                }
            }
            let cells = self.cells
            cells.forEach({$0.contentView?.removeFromSuperview() })
            for (index, view) in newValue.enumerated() {
                self.cells[safe: index]?.contentView = view
             // self.cells[safe: index]?.contentView = (view as? GridSpacer) != nil ? nil : view
            }
            if newValue.count < gridView.numberOfColumns {
                let columns = gridView.nsColumns
                for index in stride(from: columns.count-1, to: newValue.count-1, by: -1) {
                    if let column = columns[safe: index] {
                        if column.cells.compactMap({$0.contentView}).count == 0 {
                            gridView.removeColumn(at: index)
                        }
                    }
                }
            }
            /*
            for index in newValue.indexes(where: {($0 as? GridSpacer) != nil}) {
                if let value = (newValue[safe: index] as? GridSpacer)?.value, index < gridView.numberOfColumns, gridView.column(at: index).views.count == 0 {
                    gridView.column(at: index).width = value
                }
            }
            */
        }
    }
}


#endif
