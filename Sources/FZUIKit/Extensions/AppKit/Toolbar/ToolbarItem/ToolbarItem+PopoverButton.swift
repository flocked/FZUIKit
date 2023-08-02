//
//  ToolbarItem+PopoverButton.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    class PopoverButton: ToolbarItem, NSPopoverDelegate {
        public let button: NSButton
        internal weak var popoverController: NSViewController?
        internal weak var popover: NSPopover?

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

        @discardableResult
        public func type(_ type: NSButton.ButtonType) -> Self {
            button.setButtonType(type)
            return self
        }

        @discardableResult
        public func state(_ state: NSControl.StateValue) -> Self {
            button.state = state
            return self
        }

        @discardableResult
        public func bordered(_ isBordered: Bool) -> Self {
            button.isBordered = isBordered
            return self
        }

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

        @discardableResult
        public func alternateImage(_ image: NSImage?) -> Self {
            button.alternateImage = image
            return self
        }

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

        @discardableResult
        public func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
            button.bezelStyle = style
            return self
        }

        @discardableResult
        public func bezelColor(_ color: NSColor?) -> Self {
            button.bezelColor = color
            return self
        }

        @discardableResult
        public func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
            button.keyEquivalent = shortcut
            button.keyEquivalentModifierMask = modifiers
            return self
        }

        @discardableResult
        public func onAction(_ action: ToolbarItem.ActionBlock?) -> Self {
            self.button.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                action?(self.item)
            }
            return self
        }

        @discardableResult
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
