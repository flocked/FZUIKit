//
//  ToolbarItem+Button.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    /**
     A toolbar item that contains a button.
     
     It can be used as an item of a ``Toolbar``.
     */
    class Button: ToolbarItem {
        public let button: NSButton
        
        @discardableResult
        /// The title of the button.
        public func title(_ title: String) -> Self {
            button.title = title
            return self
        }
        
        @discardableResult
        /// The alternate title of the button.
        public func alternateTitle(_ title: String) -> Self {
            button.alternateTitle = title
            return self
        }

        @discardableResult
        /// The attributed title of the button.
        public func attributedTitle(_ title: NSAttributedString) -> Self {
            button.attributedTitle = title
            return self
        }

        @discardableResult
        /// The attributed alternate title of the button.
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

        /// Sets             whether the button has a border.
        @discardableResult
        public func bordered(_ isBordered: Bool) -> Self {
            button.isBordered = isBordered
            return self
        }

        /// Sets whether the button is transparent.
        @discardableResult
        public func transparent(_ isTransparent: Bool) -> Self {
            button.isTransparent = isTransparent
            return self
        }

        @discardableResult
        /// The image of the button, or `nil` if none.
        public func image(_ image: NSImage?) -> Self {
            button.image = image
            return self
        }

        @available(macOS 11.0, *)
        @discardableResult
        public func image(symbolName: String) -> Self {
            button.image = NSImage(systemSymbolName: symbolName) ?? button.image
            return self
        }

        @discardableResult
        /// The alternate image of the button, or `nil` if none.
        public func alternateImage(_ image: NSImage?) -> Self {
            button.alternateImage = image
            return self
        }

        /// Sets the position of the button’s image relative to its title.
        @discardableResult
        public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
            button.imagePosition = position
            return self
        }

        @discardableResult
        /// The image scaling of the button.
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

        /// Sets the key-equivalent character and modifier mask of the button.
        @discardableResult
        public func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
            button.keyEquivalent = shortcut
            button.keyEquivalentModifierMask = modifiers
            return self
        }

        @discardableResult
        /// The action block of the button.
        public func onAction(_ action: ToolbarItem.ActionBlock?) -> Self {
            self.button.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                action?(self.item)
            }
            return self
        }

        @discardableResult
        /// The action block of the button.
        public func onAction(_ handler: @escaping () -> Void) -> Self {
            self.button.actionBlock = { _ in
                handler()
            }
            return self
        }

        internal static func button(for type: NSButton.BezelStyle) -> NSButton {
            let button = NSButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bezelStyle = type
            return button
        }
        
        public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, type: NSButton.BezelStyle = .texturedRounded) {
            let button = Self.button(for: type)
            button.title = title
            self.init(identifier, button: button)
        }
        
        public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, image: NSImage, type: NSButton.BezelStyle = .texturedRounded) {
            let button = Self.button(for: type)
            button.title = ""
            button.image = image
            self.init(identifier, button: button)
        }
        
        @available(macOS 11.0, *)
        public convenience init?(_ identifier: NSToolbarItem.Identifier? = nil, symbolName: String, type: NSButton.BezelStyle = .texturedRounded) {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            let button = Self.button(for: type)
            button.title = ""
            button.image = image
            self.init(identifier, button: button)
        }

        public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, image: NSImage, type: NSButton.BezelStyle = .texturedRounded) {
            let button = Self.button(for: type)
            button.title = title
            button.image = image
            self.init(identifier, button: button)
        }

        public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton) {
            self.button = button
            super.init(identifier)
            self.button.invalidateIntrinsicContentSize()
            self.button.translatesAutoresizingMaskIntoConstraints = false
            self.item.view = self.button
        }
    }
}
#endif
