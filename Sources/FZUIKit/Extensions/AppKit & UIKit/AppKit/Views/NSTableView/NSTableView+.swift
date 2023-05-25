//
//  File.swift
//
//
//  Created by Florian Zand on 09.09.22.
//

#if os(macOS)
    import AppKit

    public extension NSTableView {
        func reloadOnMainThread(maintainingSelection: Bool = false, completionHandler: (() -> Void)? = nil) {
            DispatchQueue.main.async {
                if maintainingSelection {
                    self.reloadMaintainingSelection()
                } else {
                    self.reloadData()
                }
                completionHandler?()
            }
        }

        internal func reloadMaintainingSelection(completionHandler: (() -> Void)? = nil) {
            let selectedRowIndexes = selectedRowIndexes
            reloadData()
            if selectedRowIndexes.isEmpty == false {
                selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
            }
            completionHandler?()
        }

        var nonSelectedRowIndexes: IndexSet {
            let selected = selectedRowIndexes
            var nonSelectedRowIndexes = IndexSet()
            for i in 0 ..< numberOfRows {
                if selected.contains(i) == false {
                    nonSelectedRowIndexes.insert(i)
                }
            }
            return nonSelectedRowIndexes
        }

        /**
         Returns the row indexes currently visible.

         - Returns: The array of row indexes corresponding to the currently visible rows.
         */
        func visibleRowIndexes() -> [Int] {
            let visibleRects = visibleRect
            let visibleRange = self.rows(in: visibleRects)
            var rows = [Int]()
            for i in visibleRange.location ... visibleRange.location + visibleRange.length {
                rows.append(i)
            }
            return rows
        }

        /**
         Returns the row views currently visible.

         - Returns: The array of row views corresponding to the currently visible row views.
         */
        func visibleRows(makeIfNecessary: Bool) -> [NSTableRowView] {
            return visibleRowIndexes().compactMap { self.rowView(atRow: $0, makeIfNecessary: makeIfNecessary) }
        }

        /**
         Returns the columns currently visible.

         - Returns: The array of columns corresponding to the currently visible table columns.
         */
        var visibleColumns: [NSTableColumn] {
            columnIndexes(in: visibleRect).compactMap { self.tableColumns[$0] }
        }

        /**
         Returns the cell views of a column currently visible.

         - Returns: The array of row views corresponding to the currently visible cell view.
         */
        func visibleCells(for column: NSTableColumn, makeIfNecessary: Bool) -> [NSTableCellView] {
            let rowIndexes = visibleRowIndexes()
            var cells = [NSTableCellView]()
            if let columnIndex = tableColumns.firstIndex(of: column) {
                for rowIndex in rowIndexes {
                    if let cellView = view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: makeIfNecessary) as? NSTableCellView {
                        cells.append(cellView)
                    }
                }
            }
            return cells
        }

        static func tableRowHeight(text: ContentConfiguration.Text.FontSize, secondaryText: ContentConfiguration.Text.FontSize? = nil, textPadding: CGFloat = 0.0, verticalPadding: CGFloat = 2.0) -> CGFloat {
            return tableRowHeight(fontSize: text.value, secondaryTextFontSize: secondaryText?.value, textPadding: textPadding, verticalPadding: verticalPadding)
        }

        static func tableRowHeight(fontSize: CGFloat, secondaryTextFontSize: CGFloat? = nil, textPadding: CGFloat = 0.0, verticalPadding: CGFloat = 2.0) -> CGFloat {
            let textField = NSTextField()

            textField.font = .systemFont(ofSize: fontSize)
            textField.stringValue = " "
            textField.isBezeled = false
            textField.isEditable = false
            textField.isSelectable = false
            textField.drawsBackground = false
            textField.usesSingleLineMode = true

            textField.maximumNumberOfLines = 1
            textField.lineBreakMode = .byTruncatingTail

            var height = textField.fittingSize.height + (2.0 * verticalPadding)
            if let secondaryTextFontSize = secondaryTextFontSize {
                height = height + tableRowHeight(fontSize: secondaryTextFontSize, textPadding: 0.0, verticalPadding: 0.0) + textPadding
            }
            return height
        }
    }
#endif
