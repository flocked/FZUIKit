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
     
     It can be used as an item of a ``Toolbar``.
     */
    class PopoverButton: ToolbarItem, NSPopoverDelegate {
        public let button: NSButton
        internal weak var popoverController: NSViewController?
        internal weak var popover: NSPopover?

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

        @discardableResult
        /// The button type.
        public func type(_ type: NSButton.ButtonType) -> Self {
            button.setButtonType(type)
            return self
        }

        @discardableResult
        /// The state of the button.
        public func state(_ state: NSControl.StateValue) -> Self {
            button.state = state
            return self
        }
        
        /// The state of the button.
        public var state: NSControl.StateValue {
            get { button.state }
            set { button.state = newValue }
        }

        @discardableResult
        /// A Boolean value that determines whether the button has a border.
        public func bordered(_ isBordered: Bool) -> Self {
            button.isBordered = isBordered
            return self
        }

        @discardableResult
        /// A Boolean value that determines whether the button is transparent..
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

        @discardableResult
        /// The alternate image of the button, or `nil` if none.
        public func alternateImage(_ image: NSImage?) -> Self {
            button.alternateImage = image
            return self
        }

        @discardableResult
        /// The image position of the button.
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

        @discardableResult
        /// The bezel style of the button.
        public func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
            button.bezelStyle = style
            return self
        }

        @discardableResult
        /// The bezel color of the button, or `nil` if none.
        public func bezelColor(_ color: NSColor?) -> Self {
            button.bezelColor = color
            return self
        }

        @discardableResult
        /// The key-equivalent character and modifier keys of the button.
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

        internal func showPopover() {
            if let p = popover {
                p.close()
                self.popover = nil
            }

            let popover = NSPopover()
            popover.contentViewController = popoverController
            popover.behavior = .transient
            popover.delegate = self
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            self.popover = popover
        }

        internal func closePopover() {
            popover?.close()
            popover = nil
        }

        internal static func button(for type: NSButton.ButtonType) -> NSButton {
            let button = NSButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bezelStyle = .texturedRounded
            button.setButtonType(type)
            return button
        }

        public convenience init(_ identifier: NSToolbarItem.Identifier, popoverContentController: NSViewController) {
            let button = Self.button(for: .momentaryChange)
            self.init(identifier, button: button, popoverContentController: popoverContentController)
        }

        public init(_ identifier: NSToolbarItem.Identifier, button: NSButton, popoverContentController: NSViewController) {
            self.button = button
            popoverController = popoverContentController
            super.init(identifier)
            self.button.translatesAutoresizingMaskIntoConstraints = false
            self.item.view = self.button
        }
    }
}
#endif
