//
//  NSToolbarItemGroup+.swift
//
//
//  Created by Florian Zand on 16.11.23.
//

#if os(macOS)

import AppKit

public extension NSToolbarItemGroup {
    /// The indexes of the selected subitems in the group.
    var selectedIndexes: [Int] {
        get { (0..<subitems.count).filter({isSelected(at: $0)})}
        set { (0..<subitems.count).forEach({ setSelected(newValue.contains($0), at: $0) }) }
    }
}

#endif
