//
//  ToolbarItem+PopUpButton.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    /// A toolbar item that contains a popup button.
    class PopupButton: ToolbarItem {
        public let button: NSPopUpButton

        @discardableResult
        /// The action block of the button when the selection changes.
        public func onSelect(_ action: ToolbarItem.ActionBlock?) -> Self {
            self.button.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                action?(self.item)
            }
            return self
        }

        @discardableResult
        /// The action block of the button when the selection changes.
        public func onSelect(_ handler: @escaping () -> Void) -> Self {
            self.button.actionBlock = { _ in
                handler()
            }
            return self
        }

        @discardableResult
        /// The menu of the popup button.
        public func menu(_ menu: NSMenu) -> Self {
            button.menu = menu
            return self
        }

        @discardableResult
        /// The menu items of the popup button.
        public func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            button.menu = NSMenu(title: "", items: items())
            return self
        }

        @discardableResult
        /// The string that is displayed on the popup button when the user isn’t pressing the mouse button.
        public func title(_ title: String) -> Self {
            button.setTitle(title)
            return self
        }

        @discardableResult
        /// A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        public func pullsDown(pullsDown: Bool) -> Self {
            button.pullsDown = pullsDown
            return self
        }

        /// The index of the selected item, or `nil` if none is selected.
        public var indexOfSelectedItem: Int? { (button.indexOfSelectedItem != -1) ? button.indexOfSelectedItem : nil }

        /// The selected menu item, or `nil` if none is selected.
        public var selectedItem: NSMenuItem? { button.selectedItem }

        /// Selects the item of the popup button at the specified index.
        public func selectItem(at index: Int) -> Self {
            button.selectItem(at: index)
            return self
        }

        /// Selects the item of the popup button with the specified title.
        public func selectItem(withTitle title: String) -> Self {
            button.selectItem(withTitle: title)
            return self
        }

        /// Selects the item of the popup button with the specified tag.
        public func selectItem(withTag tag: Int) -> Self {
            button.selectItem(withTag: tag)
            return self
        }

        /// Selects the specified menu item of the popup button.
        public func select(_ item: NSMenuItem) -> Self {
            button.select(item)
            return self
        }

        internal static func button() -> NSPopUpButton {
            let button = NSPopUpButton(frame: .zero, pullsDown: true)
            button.translatesAutoresizingMaskIntoConstraints = true
            button.bezelStyle = .texturedRounded
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .arrowAtBottom
            return button
        }

        public convenience init(_ identifier: NSToolbarItem.Identifier, @MenuBuilder _ items: () -> [NSMenuItem]) {
            let button = Self.button()
            button.menu = NSMenu(title: "", items: items())
            self.init(identifier, popUpButton: button)
        }

        public init(_ identifier: NSToolbarItem.Identifier, popUpButton: NSPopUpButton) {
            self.button = popUpButton
            super.init(identifier)
            self.button.translatesAutoresizingMaskIntoConstraints = false
            self.item.view = self.button
        }
    }
}

#endif
