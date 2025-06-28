//
//  ToolbarItem+Popover.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

extension Toolbar {
    /// A toolbar item that displys a popover.
    open class Popover: ToolbarItem {
        fileprivate lazy var rootItem = ValidateToolbarItem(for: self)
        
        override var item: NSToolbarItem {
            rootItem
        }
        
        /// The button of the toolbar item that opens the popover.
        public let button: NSButton
        
        /// The popover of the item.
        open var popover: NSPopover {
            didSet {
                guard oldValue != popover else { return }
                oldValue.close()
                popover.isDetachable = oldValue.isDetachable
                popover.isArrowVisible = oldValue.isArrowVisible
            }
        }
        
        /// Sets the popover of the item.
        @discardableResult
        open func popover(_ popover: NSPopover) -> Self {
            self.popover = popover
            return self
        }
        
        /// Sets the view controller that manages the content of the popover.
        @discardableResult
        open func popoverViewController(_ viewController: NSViewController) -> Self {
            popover.contentViewController = viewController
            return self
        }
        
        /// Sets the view of the popover.
        @discardableResult
        open func popoverView(_ view: NSView) -> Self {
            popover.contentView = view
            return self
        }
        
        /// The title of the button.
        open var title: String? {
            get { button.title == "" ? nil : button.title }
            set {
                button.title = newValue ?? ""
                updateImagePosition()
            }
        }
        
        /// Sets the title of the button.
        @discardableResult
        open func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// The attributed title of the button.
        open var attributedTitle: NSAttributedString {
            get { button.attributedTitle }
            set {
                button.attributedTitle = newValue
                updateImagePosition()
            }
        }
        
        /// Sets the attributed title of the button.
        @discardableResult
        open func attributedTitle(_ title: NSAttributedString) -> Self {
            attributedTitle = title
            return self
        }
        
        /// The image of the button.
        open var image: NSImage? {
            get { button.image }
            set {
                button.image = newValue
                updateImagePosition()
            }
        }
        
        /// Sets the image of the button.
        @discardableResult
        open func image(_ image: NSImage?) -> Self {
            button.image = image
            updateImagePosition()
            return self
        }
        
        /// Sets the symbol image of the button with the symbol name.
        @available(macOS 11.0, *)
        @discardableResult
        open func symbolImage(_ symbolName: String) -> Self {
            image(NSImage(systemSymbolName: symbolName))
        }
        
        /// The image scaling of the button.
        open var imageScaling: NSImageScaling {
            get { button.imageScaling }
            set { button.imageScaling = newValue }
        }
        
        /// Sets the image scaling of the button.
        @discardableResult
        open func imageScaling(_ imageScaling: NSImageScaling) -> Self {
            self.imageScaling = imageScaling
            return self
        }
        
        /// The bezel style of the button.
        open var bezel: NSButton.BezelStyle {
            get { button.bezelStyle }
            set { button.bezelStyle = newValue }
        }
        
        /// Sets the bezel style of the button.
        @discardableResult
        open func bezel(_ bezel: NSButton.BezelStyle) -> Self {
            self.bezel = bezel
            return self
        }
        
        /// Sets the key-equivalent character and modifier keys of the button.
        @discardableResult
        open func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
            button.keyEquivalent = shortcut
            button.keyEquivalentModifierMask = modifiers
            return self
        }
        
        /// A Boolean value that indicates whether the popover is detachable by the user.
        open var isDetachable: Bool = false {
            didSet {
                guard oldValue != isDetachable else { return }
                popover.isDetachable = isDetachable
            }
        }
        
        /// Sets the Boolean value that indicates whether the popover is detachable by the user.
        @discardableResult
        open func isDetachable(_ isDetachable: Bool) -> Self {
            self.isDetachable = isDetachable
            return self
        }
        
        /// A Boolean value that indicates whether the popover hides it's arrow.
        open var hidesArrow: Bool = false {
            didSet {
                guard oldValue != hidesArrow else { return }
                popover.isArrowVisible = !hidesArrow
            }
        }
        
        /// Sets the Boolean value that indicates whether the popover hides it's arrow.
        @discardableResult
        open func hidesArrow(_ hidesArrow: Bool) -> Self {
            self.hidesArrow = hidesArrow
            return self
        }
        
        /// The handler that gets called when the user clicks the popover button.
        open var actionBlock: ((_ item: Toolbar.Popover)->())? = nil {
            didSet {
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.showPopover()
                    self.actionBlock?(self)
                }
            }
            
        }
        
        /// Sets the handler that gets called when the user clicks the popover button.
        @discardableResult
        open func onAction(_ action: ((_ item: Toolbar.Popover)->())?) -> Self {
            actionBlock = action
            return self
        }
        
        func showPopover() {
            guard popover.isShown == false else { return }
            popover.behavior = .transient
            popover.isDetachable = isDetachable
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY, hideArrow: false)
        }
        
        func updateImagePosition() {
            button.imagePosition = (button.title == "" && button.image != nil) ? .imageOnly : (button.title != "" && button.image == nil) ? .noImage : .imageLeft
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - image: The image of the button.
            - popoverViewController: The view controller that manages the content of the popover.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil,
                                title: String? = nil,
                                image: NSImage? = nil,
                                popoverViewController: NSViewController) {
            self.button = NSButton.toolbar(title ?? "", image: image).translatesAutoresizingMaskIntoConstraints(false)
            self.popover = .init(viewController: popoverViewController)
            super.init(identifier)
            sharedInit()
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - symbolName: The image of the button.
            - popoverViewController: The view controller that manages the content of the popover.
         */
        @available(macOS 11.0, *)
        public init(_ identifier: NSToolbarItem.Identifier? = nil,
                                symbolName: String,
                                popoverViewController: NSViewController) {
            self.button = NSButton.toolbar("", image: NSImage(systemSymbolName: symbolName)).translatesAutoresizingMaskIntoConstraints(false)
            self.popover = .init(viewController: popoverViewController)
            super.init(identifier)
            sharedInit()
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - title: The title of the button.
            - image: The image of the button.
            - popoverView: The view of the popover.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil,
                                title: String? = nil,
                                image: NSImage? = nil,
                                popoverView: NSView) {
            self.button = NSButton.toolbar(title ?? "", image: image).translatesAutoresizingMaskIntoConstraints(false)
            self.popover = .init(view: popoverView)
            super.init(identifier)
            sharedInit()
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - symbolName: The image of the button.
            - popoverView: The view of the popover.
         */
        @available(macOS 11.0, *)
        public init(_ identifier: NSToolbarItem.Identifier? = nil,
                                symbolName: String,
                                popoverView: NSView) {
            self.button = NSButton.toolbar("", image: NSImage(systemSymbolName: symbolName)).translatesAutoresizingMaskIntoConstraints(false)
            self.popover = .init(view: popoverView)
            super.init(identifier)
            sharedInit()
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - button: The popover button.
            - popoverViewController: The view controller that manages the content of the popover.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, popoverViewController: NSViewController) {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.button = button
            self.popover = .init(viewController: popoverViewController)
            super.init(identifier)
            sharedInit()
        }
        
        /**
         Creates a toolbar item that displays a popover.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Popover` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - button: The popover button.
            - popoverView: The view of the popover.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, popoverView: NSView) {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.button = button
            self.popover = .init(view: popoverView)
            super.init(identifier)
            sharedInit()
        }
        
        private func sharedInit() {
            item.view = button
            button.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.showPopover()
            }
            updateImagePosition()
        }
    }
}
#endif
