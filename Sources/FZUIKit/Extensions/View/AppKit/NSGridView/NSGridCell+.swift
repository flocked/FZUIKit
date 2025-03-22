//
//  NSGridCell+.swift
//
//
//  Created by Florian Zand on 22.03.25.
//

#if os(macOS)
import AppKit

public extension NSGridCell {
    /// The column indexes of the cell.
    var columnIndexes: [Int] {
        guard let cells = column?.cells, let startIndex = cells.firstIndex(of: self), let endIndex = cells.lastIndex(of: self) else { return [] }
        return (startIndex...endIndex).map({$0})
    }
    
    /// The row indexes of the cell.
    var rowIndexes: [Int] {
        guard let cells = row?.cells, let startIndex = cells.firstIndex(of: self), let endIndex = cells.lastIndex(of: self) else { return [] }
        return (startIndex...endIndex).map({$0})
    }
}

#endif
