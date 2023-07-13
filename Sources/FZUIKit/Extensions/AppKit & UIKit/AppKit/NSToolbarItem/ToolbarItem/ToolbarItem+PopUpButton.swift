//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import Cocoa

public extension ToolbarItem {
    class PopupButton: ToolbarItem {
        public let button: NSPopUpButton

        @discardableResult
        public func onSelect(_ action: ToolbarItem.ActionBlock?) -> Self {
            self.button.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                action?(self.item)
            }
            return self
        }

        @discardableResult
        public func onSelect(_ handler: @escaping () -> Void) -> Self {
            self.button.actionBlock = { _ in
                handler()
            }
            return self
        }

        @discardableResult
        public func menu(_ menu: NSMenu) -> Self {
            button.menu = menu
            return self
        }

        @discardableResult
        public func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            button.menu = NSMenu(title: "", items: items())
            return self
        }

        @discardableResult
        public func title(_ title: String) -> Self {
            button.setTitle(title)
            return self
        }

        public func pullsDown(pullsDown: Bool) -> Self {
            button.pullsDown = pullsDown
            return self
        }

        public var indexOfSelectedItem: Int? { (button.indexOfSelectedItem != -1) ? button.indexOfSelectedItem : nil }

        public var selectedItem: NSMenuItem? { button.selectedItem }

        public func selectItem(at index: Int) -> Self {
            button.selectItem(at: index)
            return self
        }

        public func selectItem(withTitle title: String) -> Self {
            button.selectItem(withTitle: title)
            return self
        }

        public func selectItem(withTag tag: Int) -> Self {
            button.selectItem(withTag: tag)
            return self
        }

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
