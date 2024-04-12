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

         The item can be used with ``Toolbar``.
         */
        class Button: ToolbarItem {
            /// The button of the item.
            public let button: NSButton

            /// The title of the button.
            @discardableResult
            public func title(_ title: String) -> Self {
                button.title = title
                return self
            }

            /// The alternate title of the button.
            @discardableResult
            public func alternateTitle(_ title: String) -> Self {
                button.alternateTitle = title
                return self
            }

            /// The attributed title of the button.
            @discardableResult
            public func attributedTitle(_ title: NSAttributedString) -> Self {
                button.attributedTitle = title
                return self
            }

            /// The attributed alternate title of the button.
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

            /// The image of the button, or `nil` if none.
            @discardableResult
            public func image(_ image: NSImage?) -> Self {
                button.image = image
                return self
            }

            @available(macOS 11.0, *)
            /// The symbol image of the button.
            @discardableResult
            public func image(symbolName: String) -> Self {
                button.image = NSImage(systemSymbolName: symbolName) ?? button.image
                return self
            }

            /// The alternate image of the button, or `nil` if none.
            @discardableResult
            public func alternateImage(_ image: NSImage?) -> Self {
                button.alternateImage = image
                return self
            }

            @available(macOS 11.0, *)
            /// The alternate symbol image of the button.
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

            /// The image scaling of the button.
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

            /// The action block of the button.
            @discardableResult
            public func onAction(_ action: ToolbarItem.ActionBlock?) -> Self {
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    action?(self)
                }
                return self
            }

            /// The action block of the button.
            @discardableResult
            public func onAction(_ handler: @escaping () -> Void) -> Self {
                button.actionBlock = { _ in
                    handler()
                }
                return self
            }

            static func button(for type: NSButton.BezelStyle) -> NSButton {
                let button = NSButton(frame: .zero)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.bezelStyle = type
                return button
            }

            /**
             Creates a button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the button.
                - type: The button type.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, type: NSButton.BezelStyle = .texturedRounded) {
                let button = Self.button(for: type)
                button.title = title
                self.init(identifier, button: button)
            }

            /**
             Creates a button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - image: The image of the button.
                - type: The button type.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, image: NSImage, type: NSButton.BezelStyle = .texturedRounded) {
                let button = Self.button(for: type)
                button.title = ""
                button.image = image
                self.init(identifier, button: button)
            }

            /**
             Creates a button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - symbolName: The symbol image name of the button.
                - type: The button type.
             */
            @available(macOS 11.0, *)
            public convenience init?(_ identifier: NSToolbarItem.Identifier? = nil, symbolName: String, type: NSButton.BezelStyle = .texturedRounded) {
                guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
                let button = Self.button(for: type)
                button.title = ""
                button.image = image
                self.init(identifier, button: button)
            }

            /**
             Creates a button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the button.
                - image: The image of the button.
                - type: The button type.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, title: String, image: NSImage, type: NSButton.BezelStyle = .texturedRounded) {
                let button = Self.button(for: type)
                button.title = title
                button.image = image
                self.init(identifier, button: button)
            }

            /**
             Creates a button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - button: The button.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton) {
                self.button = button
                super.init(identifier)
                self.button.invalidateIntrinsicContentSize()
                self.button.translatesAutoresizingMaskIntoConstraints = false
                item.view = self.button
            }
        }
    }
#endif
