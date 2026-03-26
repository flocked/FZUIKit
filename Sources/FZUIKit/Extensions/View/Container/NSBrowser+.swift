//
//  NSBrowser+.swift
//
//
//  Created by Florian Zand on 07.03.26.
//

#if os(macOS)
import AppKit

public extension NSBrowser {
    /// The default column width of the browser’s columns.
    var defaultColumnWidth: CGFloat {
        get { defaultColumnWidth() }
        set { setDefaultColumnWidth(newValue) }
    }
    
    /// The items selected in the brwoser.
    var selectedItems: [Any] {
        selectionIndexPaths.compactMap({ item(at: $0) })
    }
    
    /// Tthe item selected in the browser.
    var selectedItem: Any? {
        guard let selectionIndexPath = selectionIndexPath else { return nil }
        return item(at: selectionIndexPath)
    }
    
    /// Selects the row at the specifie index path.
    func selectItem(at indexPath: IndexPath, scrollToVisible: Bool = false) {
        guard !indexPath.isEmpty else { return }
        for column in 0..<indexPath.count {
            let row = indexPath[column]
            selectRow(row, inColumn: column)
        }
        guard scrollToVisible else { return }
        scrollToItem(at: indexPath)
    }
    
    func scrollToItem(at indexPath: IndexPath) {
        guard !indexPath.isEmpty else { return }
        scrollColumnToVisible(indexPath.count-1)
        scrollRowToVisible(indexPath.last!, inColumn: indexPath.count-1)
    }
    
    func scrollColumnToItem(at indexPath: IndexPath) {
        guard !indexPath.isEmpty else { return }
        scrollColumnToVisible(indexPath.count-1)
    }
    
    func scrollRowToItem(at indexPath: IndexPath) {
        guard !indexPath.isEmpty else { return }
        scrollRowToVisible(indexPath.last!, inColumn: indexPath.count-1)
    }
}

public extension NSBrowserCell {
    /// The table view that displays the cell.
    var tableView: NSTableView? {
        controlView as? NSTableView
    }
}
#endif
