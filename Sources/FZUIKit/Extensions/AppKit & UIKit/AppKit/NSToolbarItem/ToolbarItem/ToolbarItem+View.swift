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
        internal var view: NSView? {
            get { item.view }
            set { item.view = newValue }
        }

        @discardableResult
        public func view(_ view: NSView) -> Self {
            self.view = view
            return self
        }

        @discardableResult
        public func view(_ view: some SwiftUI.View) -> Self {
            self.view = NSHostingView(rootView: view)
            return self
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
