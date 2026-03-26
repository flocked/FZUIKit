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
        get { getAssociatedValue("_arrowPosition", initialValue: (cell as? NSPopUpButtonCell)?.arrowPosition ?? .arrowAtBottom) }
        set {
            guard newValue != arrowPosition else { return }
            setAssociatedValue(newValue, key: "_arrowPosition")
            updateArrowVisibility()
        }
    }
    
    /// Sets the arrow position.
    @discardableResult
    func arrowPosition(_ position: ArrowPosition) -> Self {
        self.arrowPosition = position
        return self
    }
    
    /**
     A Boolean value indicating whether the popup button displays the arrow only when the mouse is hovering the button.
     
     The default value is `false` and always displays the arrow at the `arrowPosition`.
     */
    var displaysArrowOnlyOnHover: Bool {
        get { hoverTrackingArea != nil }
        set {
            guard newValue != displaysArrowOnlyOnHover else { return }
            if newValue {
                hoverTrackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect])
                do {
                    hoverHooks += try hook(#selector(NSPopUpButton.updateTrackingAreas), closure: {
                        original, button, selector in
                        original(button, selector)
                        button.hoverTrackingArea?.update()
                    } as @convention(block) ((NSPopUpButton, Selector) -> (), NSPopUpButton, Selector) -> ())
                    hoverHooks += try hook(#selector(NSPopUpButton.mouseEntered(with:)), closure: {
                        original, button, selector, event in
                        original(button, selector, event)
                        button.mouseIsInside = true
                        button.updateArrowVisibility()
                    } as @convention(block) ((NSPopUpButton, Selector, NSEvent) -> (), NSPopUpButton, Selector, NSEvent) -> ())
                    hoverHooks += try hook(#selector(NSPopUpButton.mouseExited(with:)), closure: {
                        original, button, selector, event in
                        original(button, selector, event)
                        button.mouseIsInside = false
                        button.updateArrowVisibility()
                    } as @convention(block) ((NSPopUpButton, Selector, NSEvent) -> (), NSPopUpButton, Selector, NSEvent) -> ())
                } catch {
                    Swift.print(error)
                }
            } else {
                hoverHooks.forEach({try? $0.revert() })
                hoverHooks = []
                hoverTrackingArea = nil
            }
            updateArrowVisibility()
        }
    }
    
    /**
     Sets the Boolean value indicating whether the popup button displays the arrow only when the mouse is hovering the button.
     
     The default value is `false` and always displays the arrow at the `arrowPosition`.
     */
    @discardableResult
    func displaysArrowOnlyOnHover(_ displaysArrowOnlyOnHover: Bool) -> Self {
        self.displaysArrowOnlyOnHover = displaysArrowOnlyOnHover
        return self
    }
    
    private func updateArrowVisibility() {
        guard let cell = self.cell as? NSPopUpButtonCell else { return }
        if displaysArrowOnlyOnHover {
            cell.arrowPosition = isMouseInside ? arrowPosition : .noArrow
        } else {
            cell.arrowPosition = arrowPosition
        }
    }
    
    private var isMouseInside: Bool {
        get { getAssociatedValue("isMouseInside") ?? false }
        set { setAssociatedValue(newValue, key: "isMouseInside") }
    }
    
    private var hoverTrackingArea: TrackingArea? {
        get { getAssociatedValue("hoverTrackingArea") }
        set { setAssociatedValue(newValue, key: "hoverTrackingArea") }
    }
    
    private var hoverHooks: [Hook] {
        get { getAssociatedValue("hoverHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "hoverHooks") }
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
