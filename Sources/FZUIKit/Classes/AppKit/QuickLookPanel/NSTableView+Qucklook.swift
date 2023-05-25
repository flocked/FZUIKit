//
//  NSTableView+QLPrevable.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.03.23.
//

#if os(macOS)
import AppKit

public extension NSTableView {
    func quicklookRows(at indexes: [Int], curentIndex: Int? = nil) {
        let rows = indexes.compactMap { self.rowView(atRow: $0, makeIfNecessary: true) }
        var currentRow: NSTableRowView?
        if let curentIndex = curentIndex, selectedRowIndexes.contains(curentIndex) {
            currentRow = rowView(atRow: curentIndex, makeIfNecessary: false)
        }
        quicklookRows(rows, currentRow: currentRow)
    }

    //  PreviewableDataSource

    func quicklookRows(_ rows: [NSTableRowView], currentRow: NSTableRowView? = nil) {
        var currentItemIndex = 0
        var quicklookItems: [QLPreviewable] = []
        for row in rows {
            if let quicklookItem = qlPreviewable(for: row) {
                quicklookItems.append(quicklookItem)
                if row == currentRow {
                    currentItemIndex = quicklookItems.count - 1
                }
            }
        }
        QuicklookPanel.shared.keyDownResponder = self
        QuicklookPanel.shared.present(quicklookItems, currentItemIndex: currentItemIndex)
    }

    internal func qlPreviewable(for rowView: NSTableRowView) -> QLPreviewable? {
        let index = row(for: rowView)
        if let qlItem = (dataSource as? PreviewableDataSource)?.qlPreviewable(for: IndexPath(item: index, section: 0)) {
            return qlItem
        } else if let quicklookItem = rowView as? QLPreviewable {
            return quicklookItem
        } else if var quicklookItem = rowView.cellViews.compactMap({ $0 as? QLPreviewable }).first {
            if quicklookItem.previewItemURL == nil {
                quicklookItem = QuicklookItem(quicklookItem.previewContent, frame: rowView.frame)
            }
            return quicklookItem
        }
        return nil
    }

    func quicklookSelectedRows(currentIndex: Int? = nil) {
        let selectedRows = selectedRowIndexes.compactMap { self.rowView(atRow: $0, makeIfNecessary: true) }
        var currentRow: NSTableRowView?
        if let index = currentIndex, selectedRowIndexes.contains(index) {
            currentRow = rowView(atRow: index, makeIfNecessary: false)
        }
        quicklookRows(selectedRows, currentRow: currentRow)
    }
}

#endif
