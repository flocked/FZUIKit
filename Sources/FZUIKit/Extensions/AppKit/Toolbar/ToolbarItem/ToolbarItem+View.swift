//
//  ToolbarItem+View.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

public extension ToolbarItem {
    /**
     A toolbar item that displays a view.
     
     It can be used as an item of a ``Toolbar``.
     */
    class View: ToolbarItem {
        /// The view of the toolbar item.
        public var view: NSView {
            get { item.view! }
            set { item.view = newValue }
        }

        /**
         Creates a view toolbar item.
         
         - Parameters:
            - identifier: An optional identifier of the item.
            - view: The view of the item.
         */
        public init(
            _ identifier: NSToolbarItem.Identifier,
            view: NSView
        ) {
            super.init(identifier)
            self.view = view
        }

        /**
         Creates a view toolbar item.
         
         - Parameters:
            - identifier: An optional identifier of the item.
            - view: The `SwiftUI` view of the item.
         */
        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            view: some SwiftUI.View
        ) {
            self.init(identifier, view: NSHostingView(rootView: view))
        }
    }
}

#endif
