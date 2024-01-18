//
//  NSToolbarItemGroup+.swift
//
//
//  Created by Florian Zand on 16.11.23.
//

#if os(macOS)

    import AppKit

    public extension NSToolbarItemGroup {
        /// The indexes of the selected items in the group. Setting the indexes will deselect all items which indexes aren't included in the new value.
        var selectedIndexes: [Int] {
            get {
                var selectedIndexes: [Int] = []
                for index in 0 ..< subitems.count {
                    if isSelected(at: index) {
                        selectedIndexes.append(index)
                    }
                }
                return selectedIndexes
            }
            set {
                for index in 0 ..< subitems.count {
                    setSelected(newValue.contains(index), at: index)
                }
            }
        }
    }

#endif
