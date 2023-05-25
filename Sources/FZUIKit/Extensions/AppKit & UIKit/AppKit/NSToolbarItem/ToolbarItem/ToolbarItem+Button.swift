//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import Cocoa

    public extension ToolbarItem {
        class Button: ToolbarItem {
            internal let button: NSButton

            @discardableResult
            public func title(_ title: String) -> Self {
                button.title = title
                return self
            }

            @discardableResult
            public func alternateTitle(_ title: String) -> Self {
                button.alternateTitle = title
                return self
            }

            @discardableResult
            public func attributedTitle(_ title: NSAttributedString) -> Self {
                button.attributedTitle = title
                return self
            }

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
            public func onAction(_ action: ToolbarItem.ActionBlock?) -> Self {
                item.actionBlock = action
                return self
            }

            @discardableResult
            public func onAction(_ handler: @escaping () -> Void) -> Self {
                item.actionBlock = { _ in
                    handler()
                }
                return self
            }

            internal static func button(for type: NSButton.ButtonType) -> NSButton {
                let button = NSButton(frame: .zero)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.bezelStyle = .texturedRounded
                button.setButtonType(type)
                return button
            }

            public convenience init(_ identifier: NSToolbarItem.Identifier, type: NSButton.ButtonType = .momentaryLight) {
                let button = Self.button(for: type)
                self.init(identifier, button: button)
            }

            public init(_ identifier: NSToolbarItem.Identifier, button: NSButton) {
                self.button = button
                super.init(identifier)
                self.button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
            }
        }
    }
#endif
