//
//  ToolbarItem+PopoverButton.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    public extension ToolbarItem {
        /**
         A toolbar item that contains a popover button.

         The item can be used with ``Toolbar``.
         */
        class PopoverButton: ToolbarItem, NSPopoverDelegate {
            /// The button of the toolbar item that opens the popover.
            public let button: NSButton

            /// The view controller of the popover.
            public weak var popoverViewController: NSViewController?

            weak var popover: NSPopover?

            /// The title of the button.
            @discardableResult
            public func title(_ title: String) -> Self {
                set(\.button.title, to: title)
            }

            /// The alternate title of the button.
            @discardableResult
            public func alternateTitle(_ title: String) -> Self {
                set(\.button.alternateTitle, to: title)
            }

            /// The attributed title of the button.
            @discardableResult
            public func attributedTitle(_ title: NSAttributedString) -> Self {
                set(\.button.attributedTitle, to: title)
            }

            /// The attributed alternate title of the button.
            @discardableResult
            public func attributedAlternateTitle(_ title: NSAttributedString) -> Self {
                set(\.button.attributedAlternateTitle, to: title)
            }

            /// The button type.
            @discardableResult
            public func type(_ type: NSButton.ButtonType) -> Self {
                button.setButtonType(type)
                return self
            }

            /// The state of the button.
            @discardableResult
            public func state(_ state: NSControl.StateValue) -> Self {
                set(\.button.state, to: state)
            }

            /// The state of the button.
            public var state: NSControl.StateValue {
                get { button.state }
                set { button.state = newValue }
            }

            /// A Boolean value that determines whether the button has a border.
            @discardableResult
            public func bordered(_ isBordered: Bool) -> Self {
                set(\.button.isBordered, to: isBordered)
            }

            /// A Boolean value that determines whether the button is transparent..
            @discardableResult
            public func transparent(_ isTransparent: Bool) -> Self {
                set(\.button.isTransparent, to: isTransparent)
            }

            /// The image of the button, or `nil` if none.
            @discardableResult
            public func image(_ image: NSImage?) -> Self {
                set(\.button.image, to: image)
            }

            /// The alternate image of the button, or `nil` if none.
            @discardableResult
            public func alternateImage(_ image: NSImage?) -> Self {
                set(\.button.alternateImage, to: image)
            }

            /// The image position of the button.
            @discardableResult
            public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
                set(\.button.imagePosition, to: position)
            }

            /// The image scaling of the button.
            @discardableResult
            public func imageScaling(_ imageScaling: NSImageScaling) -> Self {
                set(\.button.imageScaling, to: imageScaling)
            }

            /// The bezel style of the button.
            @discardableResult
            public func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
                set(\.button.bezelStyle, to: style)
            }

            /// The bezel color of the button, or `nil` if none.
            @discardableResult
            public func bezelColor(_ color: NSColor?) -> Self {
                set(\.button.bezelColor, to: color)
            }

            /// The key-equivalent character and modifier keys of the button.
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

            func showPopover() {
                if let p = popover {
                    p.close()
                    self.popover = nil
                }

                let popover = NSPopover()
                popover.contentViewController = popoverViewController
                popover.behavior = .transient
                popover.delegate = self
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                self.popover = popover
            }

            func closePopover() {
                popover?.close()
                popover = nil
            }

            static func button(for type: NSButton.ButtonType) -> NSButton {
                let button = NSButton(frame: .zero)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.bezelStyle = .texturedRounded
                button.setButtonType(type)
                return button
            }

            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - popoverContentController: The view controller of the popover button.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, popoverContentController: NSViewController) {
                let button = Self.button(for: .momentaryChange)
                self.init(identifier, button: button, popoverContentController: popoverContentController)
            }

            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - popoverContentController: The popover button.
                - popoverContentController: The view controller of the popover button.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, popoverContentController: NSViewController) {
                self.button = button
                popoverViewController = popoverContentController
                super.init(identifier)
                self.button.translatesAutoresizingMaskIntoConstraints = false
                item.view = self.button
            }
        }
    }
#endif
