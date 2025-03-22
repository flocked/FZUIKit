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
    public var views: [NSView?] {
        get { cells.compactMap({$0.contentView}) }
        set {
            guard let gridView = self.gridView else { return }
            if newValue.count > gridView.numberOfRows {
                let count = newValue.count - gridView.numberOfRows
                for _ in (0..<count) {
                    gridView.addRow(with: [])
                }
            } else if newValue.count < gridView.numberOfRows, let index = gridView.nsRows.indexed().firstIndex(where: {$0.element.cells.compactMap({$0.contentView}).count == 0 && $0.index >= newValue.count}) {
                (index..<gridView.numberOfRows).reversed().forEach({
                    gridView.removeRow(at: $0)
                })
            }
            let cells = cells
            cells.forEach({$0.contentView?.removeFromSuperview() })
            for (index, view) in newValue.enumerated() {
                cells[safe: index]?.contentView = view
            }
        }
    }
    
    /// Sets the content views of the grid column cells.
    @discardableResult
    public func views(_ views: [NSView?]) -> Self {
        self.views = views
        return self
    }
    
    /// Sets the content views of the grid column cells.
    @discardableResult
    public func views(@NSGridView.Builder _ views: () -> [NSView]) -> Self {
        self.views = views()
        return self
    }
}

#endif
