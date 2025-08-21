//
//  NSPopUpButton+.swift
//
//
//  Created by Florian Zand on 29.05.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSPopUpButton {
    /**
     Creates a popup button with the specified menu items.

     - Parameters:
        - items: An array of menu items.
        - pullsDown: A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        - action: The action block of the button.

     - Returns: An initialized `NSPopUpButton` object.
     */
    convenience init(items: [NSMenuItem], pullsDown: Bool = false, action: ActionBlock? = nil) {
        self.init()
        self.items = items
        self.pullsDown = pullsDown
        actionBlock = action
    }
        
    /**
     Creates a popup button with the titles.

     - Parameters:
        - pullsDown: A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        - items: The menu items of the popup button.

     - Returns: An initialized `NSPopUpButton` object.
     */
    convenience init(pullsDown: Bool = false, @MenuBuilder items: () -> [NSMenuItem]) {
        self.init(items: items(), pullsDown: pullsDown)
    }

    /**
     Creates a popup button with the titles.

     - Parameters:
        - titles: An array of titles.
        - pullsDown: A Boolean value indicating whether the button displays a pull-down or pop-up menu.
        - action: The action block of the button.

     - Returns: An initialized `NSPopUpButton` object.
     */
    convenience init(titles: [String], pullsDown: Bool = false, action: ActionBlock? = nil) {
        self.init()
        items = titles.compactMap { NSMenuItem($0) }
        self.pullsDown = pullsDown
        actionBlock = action
    }

    /// The menu items.
    var items: [NSMenuItem] {
        get { menu?.items ?? [] }
        set {
            if let menu = menu {
                let selectedItemTitle = titleOfSelectedItem
                menu.items = newValue
                if let selectedItemTitle = selectedItemTitle, let item = newValue.first(where: { $0.title == selectedItemTitle }) {
                    select(item)
                }
            } else {
                menu = NSMenu(items: newValue)
            }
        }
    }
        
    /// Sets the menu items.
    @discardableResult
    func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
        self.items = items()
        return self
    }
        
    /// Sets the menu items.
    @discardableResult
    func items(_ items: [NSMenuItem]) -> Self {
        self.items = items
        return self
    }
        
    /// Sets the Boolean value indicating whether the button displays a pull-down or pop-up menu.
    @discardableResult
    func pullsDown(_ pullsDown: Bool) -> Self {
        self.pullsDown = pullsDown
        return self
    }
        
    /// Sets the Boolean value indicating whether the button displays a pull-down or pop-up menu.
    @discardableResult
    func autoenablesItems(_ autoenables: Bool) -> Self {
        autoenablesItems = autoenables
        return self
    }
        
    /// Sets rhe edge of the button on which to display the menu when screen space is constrained.
    @discardableResult
    func preferredEdge(_ preferredEdge: NSRectEdge) -> Self {
        self.preferredEdge = preferredEdge
        return self
    }
        
    /// A Boolean value indicating if the control uses an item from the menu for its own title.
    var usesItemFromMenu: Bool {
        get { (cell as? NSPopUpButtonCell)?.usesItemFromMenu ?? true }
        set { (cell as? NSPopUpButtonCell)?.usesItemFromMenu = newValue }
    }
        
    /// Sets the Boolean value indicating if the control uses an item from the menu for its own title.
    @discardableResult
    func usesItemFromMenu(_ usesItemFromMenu: Bool) -> Self {
        self.usesItemFromMenu = usesItemFromMenu
        return self
    }
        
    /// A Boolean value indicating if the pop-up button links the state of the selected menu item to the current selection.
    var altersStateOfSelectedItem: Bool {
        get { (cell as? NSPopUpButtonCell)?.altersStateOfSelectedItem ?? false }
        set { (cell as? NSPopUpButtonCell)?.altersStateOfSelectedItem = newValue }
    }
        
    /// Sets a Boolean value indicating if the pop-up button links the state of the selected menu item to the current selection.
    @discardableResult
    func altersStateOfSelectedItem(_ alters: Bool) -> Self {
        self.altersStateOfSelectedItem = alters
        return self
    }
        
    /// The arrow position.
    var arrowPosition: ArrowPosition {
        get { (cell as? NSPopUpButtonCell)?.arrowPosition ?? .arrowAtBottom }
        set { (cell as? NSPopUpButtonCell)?.arrowPosition = newValue }
    }
        
    /// Sets the arrow position.
    @discardableResult
    func arrowPosition(_ position: ArrowPosition) -> Self {
        self.arrowPosition = position
        return self
    }
        
    /**
     Returns the menu item with the specified tag.
         
     - Parameter tag: A numeric tag associated with a menu item.
     - Returns: The menu item, or `nil` if no item with the specified tag exists in the menu.
     */
    func item(withTag tag: Int) -> NSMenuItem? {
        menu?.item(withTag: tag)
    }
}
#endif
