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

         The item can be used with ``Toolbar``.
         */
        class View: ToolbarItem {
            /// The view of the toolbar item.
            public var view: NSView {
                get { item.view! }
                set { item.view = newValue }
            }
            
            /// Sets the view of the toolbar item.
            @discardableResult
            public func view(_ view: NSView) -> Self {
                self.view = view
                return self
            }
            
            /// Sets a `SwiftUI` view as the view of the toolbar item.
            @discardableResult
            public func view(_ view: some SwiftUI.View) -> Self {
                self.view = NSHostingView(rootView: view)
                return self
            }

            /**
             Creates a view toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - view: The view of the item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, view: NSView) {
                super.init(identifier)
                self.view = view
            }

            /**
             Creates a view toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - view: The `SwiftUI` view of the item.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, view: some SwiftUI.View) {
                self.init(identifier, view: NSHostingView(rootView: view))
            }
        }
    }

#endif
