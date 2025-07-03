//
//  ToolbarItem+Button.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

extension Toolbar {
    /// A toolbar item that contains a button.
    open class Button: ToolbarItem {
        fileprivate lazy var rootItem = ValidateToolbarItem(for: self)
        
        override var item: NSToolbarItem {
            rootItem
        }
        
        /// The button of the item.
        public let button: NSButton
        
        /// Sets the title of the button.
        @discardableResult
        public func title(_ title: String) -> Self {
            button.title = title
            return self
        }
        
        /// Sets the alternate title of the button.
        @discardableResult
        public func alternateTitle(_ title: String) -> Self {
            button.alternateTitle = title
            return self
        }
        
        /// Sets the attributed title of the button.
        @discardableResult
        public func attributedTitle(_ title: NSAttributedString) -> Self {
            button.attributedTitle = title
            return self
        }
        
        /// Sets the attributed alternate title of the button.
        @discardableResult
        public func attributedAlternateTitle(_ title: NSAttributedString) -> Self {
            button.attributedAlternateTitle = title
            return self
        }
        
        /// Sets the button’s type, which affects its user interface and behavior when clicked.
        @discardableResult
        public func type(_ type: NSButton.ButtonType) -> Self {
            button.setButtonType(type)
            return self
        }
        
        /// Sets the button’s state.
        @discardableResult
        public func state(_ state: NSControl.StateValue) -> Self {
            button.state = state
            return self
        }
        
        /// Sets the button’s state.
        @discardableResult
        public func state(_ state: Bool) -> Self {
            button.state = state ? .on : .off
            return self
        }
        
        /// Sets the Boolean Value indiciating whether the button has a border.
        @discardableResult
        public func bordered(_ isBordered: Bool) -> Self {
            button.isBordered = isBordered
            return self
        }
        
        /// Sets the image of the button, or `nil` if none.
        @discardableResult
        public func image(_ image: NSImage?) -> Self {
            button.image = image
            return self
        }
        
        /// Sets the symbol image of the button.
        @available(macOS 11.0, *)
        @discardableResult
        public func symbolImage(_ symbolName: String) -> Self {
            button.image = NSImage(systemSymbolName: symbolName) ?? button.image
            return self
        }
        
        /// Sets the alternate image of the button, or `nil` if none.
        @discardableResult
        public func alternateImage(_ image: NSImage?) -> Self {
            button.alternateImage = image
            return self
        }
        
        /// Sets the alternate symbol image of the button.
        @available(macOS 11.0, *)
        @discardableResult
        public func alternateImage(symbolName: String) -> Self {
            button.alternateImage = NSImage(systemSymbolName: symbolName) ?? button.image
            return self
        }
        
        /// Sets the position of the button’s image relative to its title.
        @discardableResult
        public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
            button.imagePosition = position
            return self
        }
        
        /// Sets the image scaling of the button.
        @discardableResult
        public func imageScaling(_ imageScaling: NSImageScaling) -> Self {
            button.imageScaling = imageScaling
            return self
        }
        
        /// Sets the appearance of the button’s border.
        @discardableResult
        public func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
            button.bezelStyle = style
            return self
        }
        
        /// Sets the color of the button's bezel, in appearances that support it.
        @discardableResult
        public func bezelColor(_ color: NSColor?) -> Self {
            button.bezelColor = color
            return self
        }
        
        /// Sets the color of the button's bezel, in appearances that support it.
        public func contentTintColor(_ color: NSColor?) -> Self {
            button.contentTintColor = color
            return self
        }
        
        /// Sets the key-equivalent character and modifier mask of the button.
        @discardableResult
        public func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
            button.keyEquivalent = shortcut
            button.keyEquivalentModifierMask = modifiers
            return self
        }
        
        /**
         The handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        public var validateHandler: ((Toolbar.Button)->())?
        
        /**
         Sets the handler that gets called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        @discardableResult
        public func validateHandler(_ validation: ((Toolbar.Button)->())?) -> Self {
            self.validateHandler = validation
            return self
        }
        
        /// The handler that gets called when the user clicks the toolbar item.
        public var actionBlock: ((_ item: Toolbar.Button)->())? {
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
        public func onAction(_ action: ((_ item: Toolbar.Button)->())?) -> Self {
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
         Creates a button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Button` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - action: The handler that gets called when the user clicks the button.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, action: ((_ item: Toolbar.Button)->())? = nil) {
            self.button = NSButton.toolbar(title).translatesAutoresizingMaskIntoConstraints(false)
            super.init(identifier)
            sharedInit(action)
        }
        
        /**
         Creates a button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Button` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - image: The image of the button.
            - action: The handler that gets called when the user clicks the button.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, image: NSImage, action: ((_ item: Toolbar.Button)->())? = nil) {
            self.button = NSButton.toolbar(title ?? "", image: image).translatesAutoresizingMaskIntoConstraints(false)
            super.init(identifier)
            sharedInit(action)
        }
        
        /**
         Creates a button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Button` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - symbolName: The name for the symbol image of the button.
            - action: The handler that gets called when the user clicks the button.
         */
        @available(macOS 11.0, *)
        public init?(_ identifier: NSToolbarItem.Identifier? = nil, title: String? = nil, symbolName: String, action: ((_ item: Toolbar.Button)->())? = nil) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            self.button = NSButton.toolbar("", image: image).translatesAutoresizingMaskIntoConstraints(false)
            super.init(identifier)
            sharedInit(action)
        }
        
        /**
         Creates a button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Button` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - button: The button.
            - action: The handler that gets called when the user clicks the button.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, action: ((_ item: Toolbar.Button)->())? = nil) {
            self.button = button
            super.init(identifier)
            sharedInit(action)
        }
        
        private func sharedInit(_ action: ((_ item: Toolbar.Button)->())? = nil) {
            button.invalidateIntrinsicContentSize()
            button.translatesAutoresizingMaskIntoConstraints = false
            item.view = button
            onAction(action)
        }
        
        fileprivate class ValidateToolbarItem: NSToolbarItem {
            weak var item: Toolbar.Button?
            
            init(for item: Toolbar.Button) {
                super.init(itemIdentifier: item.identifier)
                self.item = item
            }
            
            override func validate() {
                super.validate()
                guard let item = item else { return }
                item.validate()
                item.validateHandler?(item)
            }
        }
    }
}
#endif
