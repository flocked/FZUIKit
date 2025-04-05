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

         Use a `TrackingSeparator` to divide a toolbar into sections that visually align with the views on either side of the divider of the ``splitView``. This keeps toolbar items above the content that’s the target for the item’s target.
         
         The ``splitView`` must be in the same window as the toolbar containing this item before showing the toolbar.
         */
        class TrackingSeparator: ToolbarItem {
            let separatorItem: NSTrackingSeparatorToolbarItem
            override var item: NSToolbarItem {
                separatorItem
            }
            
            /**
             The vertical split view to align with the toolbar separator.
             
             The `splitView` must be in the same window as the toolbar containing the item before showing the toolbar.
             */
            public var splitView: NSSplitView {
                get { separatorItem.splitView }
                set { separatorItem.splitView = newValue }
            }

            /**
             Sets the vertical split view to align with the toolbar separator.
             
             The `splitView` must be in the same window as the toolbar containing the item before showing the toolbar.
             */
            @discardableResult
            public func splitView(_ splitView: NSSplitView) -> Self {
                self.splitView = splitView
                return self
            }
            
            /// The index of the split view divider to align with the tracking separator.
            public var dividerIndex: Int {
                get { separatorItem.dividerIndex }
                set { separatorItem.dividerIndex = newValue }
            }

            /// Sets the index of the split view divider to align with the tracking separator.
            @discardableResult
            public func dividerIndex(_ index: Int) -> Self {
                self.dividerIndex = index
                return self
            }

            /**
             Creates a tracking sseperator toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - splitView: The tracked split view.
                - dividerIndex: The index of the divider.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, splitView: NSSplitView, dividerIndex: Int) {
                self.separatorItem = .init(identifier: identifier ?? .random, splitView: splitView, dividerIndex: dividerIndex)
                super.init(separatorItem.itemIdentifier)
            }
        }
    }

#endif
