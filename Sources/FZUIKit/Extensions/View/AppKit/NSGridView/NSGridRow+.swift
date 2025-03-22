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
            } else if newValue.count < gridView.numberOfColumns, let index = gridView.nsColumns.indexed().firstIndex(where: {$0.element.cells.compactMap({$0.contentView}).count == 0 && $0.index >= newValue.count}) {
                (index..<gridView.numberOfColumns).reversed().forEach({
                    gridView.removeColumn(at: $0)
                })
            }
            let cells = cells
            cells.forEach({$0.contentView?.removeFromSuperview() })
            for (index, view) in newValue.enumerated() {
                cells[safe: index]?.contentView = view
            }
        }
    }
    
    /// Sets the content views of the grid row cells.
    @discardableResult
    public func views(_ views: [NSView?]) -> Self {
        self.views = views
        return self
    }
    
    /// Sets the content views of the grid row cells.
    @discardableResult
    public func views(@NSGridView.Builder _ views: () -> [NSView]) -> Self {
        self.views = views()
        return self
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
