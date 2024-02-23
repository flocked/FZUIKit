//
//  NSGridCell+.swift
//  
//
//  Created by Florian Zand on 23.02.24.
//

#if os(macOS)
import AppKit

extension NSGridCell {
    /// The index of the column, or `nil` if the cell isn't displayed in a column.
    public var columnIndex: Int? {
        column?.index
    }
    
    /// The index of the row, or `nil` if the cell isn't displayed in a row.
    public var rowIndex: Int? {
        row?.index
    }
}

#endif
