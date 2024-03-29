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
        /**
         A toolbar separator that aligns with the vertical split view in the same window.

         The item can be used with ``Toolbar``.
         */
        class TrackingSeparator: ToolbarItem {
            lazy var separatorItem = NSTrackingSeparatorToolbarItem(identifier)
            override var item: NSToolbarItem {
                separatorItem
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

            /**
             Creates a tracking sseperator toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - splitView: The tracked split view.
                - splitView: The index of the divider.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil,
                        splitView: NSSplitView,
                        dividerIndex: Int)
            {
                super.init(identifier)
                self.splitView(splitView)
                self.dividerIndex(dividerIndex)
            }
        }
    }

#endif
