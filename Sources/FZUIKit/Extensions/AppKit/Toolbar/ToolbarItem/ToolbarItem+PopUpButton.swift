//
//  ToolbarItem+PopUpButton.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

extension ToolbarItem {
    /// A toolbar item that contains a popup button.
    open class PopUpButton: ToolbarItem {
        /// The popup button.
        public let button: NSPopUpButton
        
        /// Sets the handler that gets called when the user clicks the pop up button.
        @discardableResult
        open func onAction(_ action: ((_ item: ToolbarItem.PopUpButton)->())?) -> Self {
            if let action = action {
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    action(self)
                }
            } else {
                button.actionBlock = nil
            }
            return self
        }
        
        /// The menu of the popup button.
        open var menu: NSMenu? {
            get { button.menu }
            set { button.menu = newValue }
        }
        
        /// Sets the menu of the popup button.
        @discardableResult
        open func menu(_ menu: NSMenu) -> Self {
            button.menu = menu
            return self
        }
        
        /// Sets the menu items of the popup button.
        @discardableResult
        open func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
            button.menu = NSMenu(title: "", items: items())
            return self
        }
        
        /// Sets the string that is displayed on the popup button when the user isn’t pressing the mouse button.
        @discardableResult
        open func title(_ title: String) -> Self {
            button.setTitle(title)
            return self
        }
        
        /// A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        open var pullsDown: Bool {
            get { button.pullsDown }
            set { button.pullsDown = newValue }
        }
        
        /// Sets the Boolean value indicating whether the button displays a pull-down or pop-up menu.
        @discardableResult
        open func pullsDown(pullsDown: Bool) -> Self {
            button.pullsDown = pullsDown
            return self
        }
        
        /// The index of the selected item, or `nil` if no item is selected.
        open var indexOfSelectedItem: Int? {
            get { (button.indexOfSelectedItem != -1) ? button.indexOfSelectedItem : nil }
            set { button.selectItem(at: newValue ?? -1)
            }
        }
        
        /// The selected menu item, or `nil` if no tem is selected.
        open var selectedItem: NSMenuItem? {
            get { button.selectedItem }
            set { button.select(newValue) }
        }
        
        /// Selects the item of the popup button at the specified index.
        @discardableResult
        open func selectItem(at index: Int) -> Self {
            button.selectItem(at: index)
            return self
        }
        
        /// Selects the item of the popup button with the specified title.
        @discardableResult
        open func selectItem(withTitle title: String) -> Self {
            button.selectItem(withTitle: title)
            return self
        }
        
        /// Selects the item of the popup button with the specified tag.
        @discardableResult
        open func selectItem(withTag tag: Int) -> Self {
            button.selectItem(withTag: tag)
            return self
        }
        
        /// Selects the specified menu item of the popup button.
        @discardableResult
        open func select(_ item: NSMenuItem) -> Self {
            button.select(item)
            return self
        }
        
        /**
         Creates a popup button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `PopUpButton` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - items: The menu items of the popup button.
         */
        public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, @MenuBuilder _ items: () -> [NSMenuItem]) {
            let button = NSPopUpButton(frame: .zero, pullsDown: true)
            button.bezelStyle = .texturedRounded
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
            button.arrowPosition = .arrowAtBottom
            button.menu = NSMenu(title: "", items: items())
            self.init(identifier, popUpButton: button)
        }
        
        /**
         Creates a popup button toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `PopUpButton` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - popUpButton: The popup button of the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, popUpButton: NSPopUpButton) {
            popUpButton.translatesAutoresizingMaskIntoConstraints = true
            button = popUpButton
            super.init(identifier)
            item.view = button
        }
    }
}

#endif
