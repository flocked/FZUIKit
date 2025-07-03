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
        fileprivate lazy var rootItem = ValidateToolbarItem(for: self)
        
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
         The handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        public var validateHandler: ((Toolbar.View)->())?
        
        /**
         Sets the handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        @discardableResult
        public func validateHandler(_ validation: ((Toolbar.View)->())?) -> Self {
            self.validateHandler = validation
            return self
        }
        
        /// The handler that gets called when the user clicks the toolbar item.
        public var actionBlock: ((_ item: Toolbar.View)->())? {
            didSet {
                if let actionBlock = actionBlock {
                    item.actionBlock = { _ in
                        actionBlock(self)
                    }
                } else {
                    item.actionBlock = nil
                }
            }
        }
        
        /// Sets the handler that gets called when the user clicks the toolbar item.
        @discardableResult
        public func onAction(_ action: ((_ item: Toolbar.View)->())?) -> Self {
            actionBlock = action
            return self
        }
        
        /// The action method to call when someone clicks on the toolbar item.
        public var action: Selector? {
            get { item.actionBlock == nil ? item.action : nil }
            set {
                actionBlock = nil
                item.action = newValue
            }
        }
        
        /// Sets the action method to call when someone clicks on the toolbar item.
        @discardableResult
        public func action(_ action: Selector?) -> Self {
            self.action = action
            return self
        }
        
        /// The object that defines the action method the toolbar item calls when clicked.
        public var target: AnyObject? {
            get { item.actionBlock == nil ? item.target : nil }
            set {
                actionBlock = nil
                item.target = newValue
            }
        }
        
        /// Sets the object that defines the action method the toolbar item calls when clicked.
        @discardableResult
        public func target(_ target: AnyObject?) -> Self {
            self.target = target
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
