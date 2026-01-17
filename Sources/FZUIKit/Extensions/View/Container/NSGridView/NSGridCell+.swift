//
//  NSGridCell+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSGridCell {
    /// The column indexes of the cell.
    var columnIndexes: IndexSet {
        guard let cells = column?.allCells, let startIndex = cells.firstIndex(of: self), let endIndex = cells.lastIndex(of: self) else { return [] }
        return IndexSet((startIndex...endIndex).map({$0}))
    }
    
    /// The row indexes of the cell.
    var rowIndexes: IndexSet {
        guard let cells = row?.allCells, let startIndex = cells.firstIndex(of: self), let endIndex = cells.lastIndex(of: self) else { return [] }
        return IndexSet(((startIndex...endIndex).map({$0})))
    }
    
    /// The grid cell above.
    var topCell: NSGridCell? {
        guard let row = row, let column = column, let gridView = row.gridView else { return nil }
        let rowIndex = gridView.index(of: row)
        guard rowIndex > 0 else { return nil }
        return gridView.cell(atColumnIndex: gridView.index(of: column), rowIndex: rowIndex-1)
    }
    
    /// The grid bellow.
    var bottomCell: NSGridCell? {
        guard let row = row, let column = column, let gridView = row.gridView else { return nil }
        let rowIndex = gridView.index(of: row)
        guard rowIndex+1 < gridView.numberOfRows else { return nil }
        return gridView.cell(atColumnIndex: gridView.index(of: column), rowIndex: rowIndex+1)
    }
    
    /// The grid cell leading.
    var leadingCell: NSGridCell? {
        guard let row = row, let column = column, let gridView = row.gridView else { return nil }
        let columnIndex = gridView.index(of: column)
        guard columnIndex > 0 else { return nil }
        return gridView.cell(atColumnIndex: columnIndex-1, rowIndex: gridView.index(of: row))
    }
    
    /// The grid cell trailing.
    var trailingCell: NSGridCell? {
        guard let row = row, let column = column, let gridView = row.gridView else { return nil }
        let columnIndex = gridView.index(of: column)
        guard columnIndex+1 < gridView.numberOfColumns else { return nil }
        return gridView.cell(atColumnIndex: columnIndex+1, rowIndex: gridView.index(of: row))
    }
    
    /// A Boolean value indicating whether the cell is merged with one or several other cells.
    var isMerged: Bool {
        value(forKeySafely: "_isMerged") as? Bool ?? false
    }
    
    /// Unmerges the cell and all related cells.
    func unmerge() {
        guard let headCell = headOfMergedCell else { return }
        columnCells.unmerge(headCell)
        rowCells.unmerge(headCell)
        (row?.allCells_ ?? []).unmerge(headCell)
    }
    
    internal var rowCells: [NSGridCell] {
        row?.allCells ?? []
    }
    
    internal var columnCells: [NSGridCell] {
        column?.allCells ?? []
    }
    
    internal var headOfMergedCell: NSGridCell? {
        get { value(forKeySafely: "_headOfMergedCell") as? NSGridCell }
        set { setValue(safely: newValue, forKey: "_headOfMergedCell")}
    }
}

extension NSGridCell.Placement: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .inherited: return "inherited"
        case .none: return "none"
        case .leading: return "leading"
        case .top: return "top"
        case .trailing: return "trailing"
        case .bottom: return "bottom"
        case .center: return "center"
        default: return "fill"
        }
    }
}

extension Collection where Element == NSGridCell {
    var uniqueCells: [NSGridCell] {
        var cells: [NSGridCell] = []
        var headCell: NSGridCell?
        for cell in self {
            if let headOfMergedCell = cell.headOfMergedCell {
                if headCell !== headOfMergedCell {
                    cells += cell
                    headCell = headOfMergedCell
                }
            } else {
                cells += cell
            }
        }
        return cells
    }
    
    fileprivate func unmerge(_ headCell: NSGridCell, unmergeAll: Bool = false) {
        if !unmergeAll {
            guard let index = firstIndex(where: { $0.headOfMergedCell === headCell }) else { return }
            self[safe: index...].filter({ $0.headOfMergedCell === headCell }).reversed().forEach({ $0.headOfMergedCell = nil })
            let filtered = filter({ $0.headOfMergedCell === headCell })
            if filtered.count == 1 {
                filtered.forEach({ $0.headOfMergedCell = nil })
            }
        } else {
            filter({ $0.headOfMergedCell === headCell }).reversed().forEach({ $0.headOfMergedCell = nil })
        }
    }
}

#endif
