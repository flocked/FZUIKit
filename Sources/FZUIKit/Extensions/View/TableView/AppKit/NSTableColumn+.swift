//
//  NSTableColumn+.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
    import AppKit

    public extension NSTableColumn {
        /// A Boolean value that indicates whether the column is visible.
        var isVisible: Bool {
            tableView?.visibleColumns.contains(self) ?? false
        }
    }

#endif
