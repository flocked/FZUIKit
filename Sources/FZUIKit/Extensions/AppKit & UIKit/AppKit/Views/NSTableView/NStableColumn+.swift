//
//  File.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
    import AppKit

    public extension NSTableColumn {
        var isVisible: Bool {
            tableView?.visibleColumns.contains(self) ?? false
        }
    }

#endif
