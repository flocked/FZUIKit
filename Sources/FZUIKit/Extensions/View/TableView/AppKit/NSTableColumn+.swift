//
//  NSTableColumn+.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSTableColumn {
        /**
         Initializes a newly created table column with a string identifier.
         
         - Parameter identifier: The string identifier for the column.
         - Returns: An initialized table column instance with an `NSTextFieldCell` instance as its default cell.
         */
        convenience init(_ identifier: NSUserInterfaceItemIdentifier) {
            self.init(identifier: identifier)
        }
        
        /// Sets the table column’s width.
        @discardableResult
        func width(_ width: CGFloat) -> Self {
            self.width = width
            return self
        }
        
        /// Sets the table column’s minimum width.
        @discardableResult
        func minWidth(_ minWidth: CGFloat) -> Self {
            self.minWidth = minWidth
            return self
        }
        
        /// Sets the table column’s maximum width.
        @discardableResult
        func maxWidth(_ maxWidth: CGFloat) -> Self {
            self.maxWidth = maxWidth
            return self
        }
        
        /// Sets the table column’s resizing mask.
        @discardableResult
        func resizingMask(_ options: ResizingOptions) -> Self {
            self.resizingMask = options
            return self
        }
        
        /// Sets the title of the table column’s header.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// Sets the cell used to draw the table column’s header.
        @discardableResult
        func headerCell(_ headerCell: NSTableHeaderCell) -> Self {
            self.headerCell = headerCell
            return self
        }
        
        /// Sets the identifier string for the table column.
        @discardableResult
        func identifier(_ identifier: NSUserInterfaceItemIdentifier) -> Self {
            self.identifier = identifier
            return self
        }
        
        /// Sets the Boolean that indicates whether a cell-based table’s column cells are user editable.
        @discardableResult
        func isEditable(_ isEditable: Bool) -> Self {
            self.isEditable = isEditable
            return self
        }
        
        /// Sets Boolean that indicates whether the table column is hidden.
        @discardableResult
        func isHidden(_ isHidden: Bool) -> Self {
            self.isHidden = isHidden
            return self
        }
        
        /// Sets the string that’s displayed in a help tag over the table column header.
        @discardableResult
        func headerToolTip(_ toolTip: String?) -> Self {
            self.headerToolTip = toolTip
            return self
        }
        
        /// Sets the table column’s sort descriptor prototype.
        @discardableResult
        func sortDescriptorPrototype(_ sortDescriptor: NSSortDescriptor?) -> Self {
            self.sortDescriptorPrototype = sortDescriptor
            return self
        }
        
        /// A Boolean value that indicates whether the column is visible.
        var isVisible: Bool {
            tableView?.visibleColumns.contains(self) ?? false
        }
        
        /// The index of the column in it's table view.
        var index: Int? {
            tableView?.tableColumns.firstIndex(of: self)
        }
        
        /// Toggles the sorting order of the sort descriptor.
        func toggleSortDescriptorOrder() {
            sortDescriptorPrototype = sortDescriptorPrototype?.reversed
        }
        
        enum SortOrder {
            case ascending
            case descending
        }
        
        var isSortingAscending: SortOrder? {
            get {
                guard let tableView = tableView, let sortDescriptor = sortDescriptorPrototype else { return nil }
                guard tableView.sortDescriptors.first == sortDescriptor else { return nil }
                return sortDescriptor.ascending ? .ascending : .descending
            }
            set {
                guard let tableView = tableView, let sortDescriptor = sortDescriptorPrototype else { return }
                if newValue != nil {
                    if let index = tableView.sortDescriptors.firstIndex(of: sortDescriptor) {
                        tableView.sortDescriptors = tableView.sortDescriptors.remove(at: index) + tableView.sortDescriptors
                    } else {
                        tableView.sortDescriptors = sortDescriptor + tableView.sortDescriptors
                    }
                } else {
                    tableView.sortDescriptors.remove(sortDescriptor)
                }
            }
        }
        
        
        /// A Boolean that indicates whether the table column is sorting the table view.
        var isSorting: Bool {
            get {
                guard let tableView = tableView, let sortDescriptor = sortDescriptorPrototype else { return false }
                return tableView.sortDescriptors.first == sortDescriptor
            }
            set {
                guard let tableView = tableView, let sortDescriptor = sortDescriptorPrototype else { return }
                if newValue {
                    if let index = tableView.sortDescriptors.firstIndex(of: sortDescriptor) {
                        tableView.sortDescriptors = tableView.sortDescriptors.remove(at: index) + tableView.sortDescriptors
                    } else {
                        tableView.sortDescriptors = sortDescriptor + tableView.sortDescriptors
                    }
                } else {
                    tableView.sortDescriptors.remove(sortDescriptor)
                }
            }
        }
        
        /// Sets the Boolean that indicates whether the table column is sorting the table view.
        @discardableResult
        func isSorting(_ isSorting: Bool) -> Self {
            self.isSorting = isSorting
            return self
        }
    }

#endif
