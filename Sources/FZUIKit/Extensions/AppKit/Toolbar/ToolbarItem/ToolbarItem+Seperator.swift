//
//  ToolbarItem+Seperator.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

@available(macOS 11.0, *)
public extension ToolbarItem {    
    class TrackingSeparator: ToolbarItem {
        internal lazy var separatorItem = NSTrackingSeparatorToolbarItem(identifier)
        override internal var item: NSToolbarItem {
            return separatorItem
        }

        @discardableResult
        public func splitView(_ splitView: NSSplitView) -> Self {
            separatorItem.splitView = splitView
            return self
        }

        @discardableResult
        public func dividerIndex(_ index: Int) -> Self {
            separatorItem.dividerIndex = index
            return self
        }

        public init(
            _ identifier: NSToolbarItem.Identifier,
            splitView: NSSplitView,
            dividerIndex: Int
        ) {
            super.init(identifier)
            self.splitView(splitView)
            self.dividerIndex(dividerIndex)
        }
    }
}

#endif
