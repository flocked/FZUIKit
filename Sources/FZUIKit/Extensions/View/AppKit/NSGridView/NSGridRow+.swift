//
//  NSGridRow+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit

public extension NSGridRow {
    /// The index of the row inside it's grid view, or `nil` if the row isn't displayed in a grid view.
    var index: Int? {
        gridView?.index(of: self)
    }
    
    /// The content views of the grid row cells.
    var views: [NSView?] {
        get { cells.map({$0.contentView}) }
        set {
            guard let gridView = gridView else { return }
            if newValue.count > gridView.numberOfColumns {
                (0..<(newValue.count - gridView.numberOfColumns)).forEach({ _ in
                    gridView.addColumn(with: [])
                })
            }
            let cells = cells
            newValue.enumerated().forEach({
                cells[$0.offset].contentView = $0.element ?? NSGridCell.emptyContentView
            })
        }
    }
    
    /// The cells of the grid row.
    var cells: [NSGridCell] {
        guard let gridView = gridView else { return [] }
        return (0..<numberOfCells).compactMap({ gridView.cell(atColumnIndex: $0, rowIndex: gridView.index(of: self)) })
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
