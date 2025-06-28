//
//  ToolbarItem+View.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

extension Toolbar {
    /// A toolbar item that displays a view.
    open class View: ToolbarItem {
        fileprivate lazy var rootItem = NSToolbarItem(identifier).swizzleValidate(for: self)
        
        override var item: NSToolbarItem {
            rootItem
        }
        
        /// The view of the toolbar item.
        open var view: NSView {
            get { item.view! }
            set { item.view = newValue }
        }
        
        /// Sets the view of the toolbar item.
        @discardableResult
        open func view(_ view: NSView) -> Self {
            self.view = view
            return self
        }
        
        /// Sets a `SwiftUI` view as the view of the toolbar item.
        @discardableResult
        open func view(_ view: some SwiftUI.View) -> Self {
            self.view = NSHostingView(rootView: view)
            return self
        }
        
        /**
         Creates a view toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `View` toolbar items.
         
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
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `View` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - view: The `SwiftUI` view of the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, view: some SwiftUI.View) {
            super.init(identifier)
            self.view = NSHostingView(rootView: view)
        }
    }
}

#endif
