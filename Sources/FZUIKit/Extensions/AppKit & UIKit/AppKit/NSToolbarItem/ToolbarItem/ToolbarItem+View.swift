//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import Cocoa
import SwiftUI

public extension ToolbarItem {
    class View: ToolbarItem {
        public var view: NSView {
            get { item.view! }
            set { item.view = newValue }
        }

        public init(
            _ identifier: NSToolbarItem.Identifier,
            view: NSView
        ) {
            super.init(identifier)
            self.view = view
        }

        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            view: some SwiftUI.View
        ) {
            self.init(identifier, view: NSHostingView(rootView: view))
        }
    }
}

#endif
