//
//  NSMenu+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation
import FZSwiftUtils

extension NSMenu {
    /**
     Initializes and returns a menu having the specified menu items.
     - Parameter items: The menu items for the menu.
     - Returns: The initialized `NSMenu` object.
     */
    public convenience init(items: [NSMenuItem]) {
        self.init(title: "", items: items)
    }
    
    /**
     Initializes and returns a menu having the specified title and menu items.
     
     - Parameters:
        - items: The menu items for the menu.
        - title: The title to assign to the menu.
     
     - Returns: The initialized `NSMenu` object.
     */
    public convenience init(title: String, items: [NSMenuItem]) {
        self.init(title: title)
        self.items = items
    }
    
    /// The menu items in the menu.
    @discardableResult
    public func items(_ items: [NSMenuItem]) -> Self {
        removeAllItems()
        for item in items {
            item.removeFromMenu()
            addItem(item)
        }
        update()
        return self
    }
    
    /// The menu items in the menu.
    @discardableResult
    public func items(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
        self.items(items())
    }
    
    /// A Boolean value that indicates whether the menu automatically enables and disables its menu items.
    @discardableResult
    public func autoenablesItems(_ autoenables: Bool) -> Self {
        autoenablesItems = autoenables
        return self
    }
    
    /// The font of the menu and its submenus.
    @discardableResult
    public func font(_ font: NSFont!) -> Self {
        self.font = font
        return self
    }
    
    /// The title of the menu.
    @discardableResult
    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }
    
    /// The menu items that are currently selected.
    @available(macOS 14.0, *)
    @discardableResult
    public func selectedItems(_ items: [NSMenuItem]) -> Self {
        self.selectedItems = items
        return self
    }
    
    /// The menu items that are currently selected.
    @available(macOS 14.0, *)
    @discardableResult
    public func selectedItems(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
        self.selectedItems = items()
        return self
    }
    
    /// The selection mode of the menu.
    @available(macOS 14.0, *)
    @discardableResult
    public func selectionMode(_ selectionMode: NSMenu.SelectionMode) -> Self {
        self.selectionMode = selectionMode
        return self
    }
    
    /// The minimum width of the menu in screen coordinates.
    @discardableResult
    public func minimumWidth(_ minimumWidth: CGFloat) -> Self {
        self.minimumWidth = minimumWidth
        return self
    }
    
    /// The presentation style of the menu.
    @available(macOS 14.0, *)
    @discardableResult
    public func presentationStyle(_ presentationStyle: NSMenu.PresentationStyle) -> Self {
        self.presentationStyle = presentationStyle
        return self
    }
    
    /// A Boolean value that indicates whether the pop-up menu allows appending of contextual menu plug-in items.
    @discardableResult
    public func allowsContextMenuPlugIns(_ allows: Bool) -> Self {
        allowsContextMenuPlugIns = allows
        return self
    }
    
    /// A Boolean value that indicates whether the menu displays the state column.
    @discardableResult
    public func showsStateColumn(_ shows: Bool) -> Self {
        showsStateColumn = shows
        return self
    }
    
    /// Configures the layout direction of menu items in the menu.
    @discardableResult
    public func userInterfaceLayoutDirection(_ direction: NSUserInterfaceLayoutDirection) -> Self {
        userInterfaceLayoutDirection = direction
        return self
    }
    
    /// The delegate of the menu.
    @discardableResult
    func delegate(_ delegate: NSMenuDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    /**
     Inserts menu items into the menu at a specific location.
     
     - Parameters:
        - items: The menu items to insert.
        - index: An integer index identifying the location of the menu item in the menu.
     */
    public func insertItems(_ items: [NSMenuItem], at index: Int) {
        items.reversed().forEach({ insertItem($0, at: index) })
    }
    
    /// Adds the specified menu item to the end of the menu.
    @discardableResult
    public static func += (_ menu: NSMenu, _ item: NSMenuItem) -> NSMenu {
        menu.addItem(item)
        return menu
    }
    
    /**
     Returns all menu items in the menu and its submenus up to a given depth.
     
     - Parameter depth: The number of submenu levels to include. Use `0` for only top-level items and `.max` for unlimited depth.
     */
    @objc open func items(depth: Int) -> [NSMenuItem] {
        if depth > 0 {
            return items + items.compactMap({ $0.submenu }).flatMap { $0.items(depth: depth - 1) }
        } else {
            return items
        }
    }
    
    /**
     Returns all menu items that satisfy a given predicate, searching up to a given submenu depth.
     
     - Parameters:
        - predicate: A closure that returns `true` for items to include.
        - depth: The number of submenu levels to match. Use `0` for only top-level items and `.max` for unlimited depth.
     */
    @objc open func items(where predicate: (NSMenuItem) -> Bool, depth: Int) -> [NSMenuItem] {
        items(depth: depth).filter(predicate)
    }
    
    /**
     Returns all menu items of a specific item type in the menu and its submenus.
     
     - Parameters:
        - type: The subclass type of `NSMenuItem` to filter.
        - depth: The number of submenu levels to match. Use `0` for only top-level items and `.max` for unlimited depth.
     */
    public func items<V: NSMenuItem>(type _: V.Type, depth: Int = 0) -> [V] {
        items(depth: depth).compactMap { $0 as? V }
    }
    
    /**
     Returns the first menu item with the specific item type, searching recursively through submenus.
     
     - Parameters:
        - type: The subclass type of `NSMenuItem` to search for.
        - depth: The number of submenu levels to match. Use `0` for only top-level items and `.max` for unlimited depth.
     - Returns: The first matching item, or `nil` if none is found.
     */
    public func firstItem<V: NSMenuItem>(type _: V.Type, depth: Int = .max) -> V? {
        items(where: { $0 is V }, depth: depth).first as? V
    }
    
    /**
     Returns the first menu item that satisfies a given predicate, searching recursively through submenus.
     
     - Parameters:
        - predicate: A closure that returns `true` for the item to find.
        - depth: The number of submenu levels to match. Use `0` for only top-level items and `.max` for unlimited depth.
     - Returns: The first matching item, or `nil` if none is found.
     */
    @objc open func firstItem(where predicate: (NSMenuItem) -> Bool, depth: Int) -> NSMenuItem? {
        if let item = items.first(where: predicate) {
            return item
        } else if depth > 0 {
            for item in items {
                if let item = item.submenu?.firstItem(where: predicate, depth: depth - 1) {
                    return item
                }
            }
        }
        return nil
    }
    
    /**
     Returns the first menu item with the specified title, searching recursively through submenus.
     
     - Parameters:
        - title: The title to match.
        - depth: The number of submenu levels to check. Use `0` for only top-level items and `.max` for unlimited depth.
     - Returns: The first matching item, or `nil` if none is found.
     */
    @objc open func firstItem(withTitle title: String, depth: Int = .max) -> NSMenuItem? {
        if let item = item(withTitle: title) {
            return item
        } else if depth > 0 {
            for item in items {
                if let item = item.submenu?.firstItem(withTitle: title, depth: depth - 1) {
                    return item
                }
            }
        }
        return nil
    }
    
    /**
     Returns the first menu item with the specified tag, searching recursively through submenus.
     
     - Parameters:
        - tag: The tag to match.
        - depth: The number of submenu levels to check. Use `0` for only top-level items and `.max` for unlimited depth.
     - Returns: The first matching item, or `nil` if none is found.
     */
    @objc open func firstItem(withTag tag: Int, depth: Int = .max) -> NSMenuItem? {
        if let item = item(withTag: tag) {
            return item
        } else if depth > 0 {
            for item in items {
                if let item = item.submenu?.firstItem(withTag: tag, depth: depth - 1) {
                    return item
                }
            }
        }
        return nil
    }
    
    /// The submenus of the menu.
    @objc open var submenus: [NSMenu] {
        items.compactMap({ $0.submenu })
    }
    
    /**
     Returns all submenus in the menu up to a given depth.
     
     - Parameter depth: The number of submenu levels to include. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    @objc open func submenus(depth: Int) -> [NSMenu] {
        if depth > 0 {
            return items.flatMap({ if let submenu = $0.submenu { return submenu + submenu.submenus(depth: depth-1)
            } else { return [] } })
        } else {
            return items.compactMap({ $0.submenu })
        }
    }
    
    /**
     Returns all submenus that satisfy a given predicate, searching up to a given submenu depth.
     
     - Parameters:
        - predicate: A closure that returns `true` for menus to include.
        - depth: The number of submenu levels to match. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    @objc open func submenus(where predicate: (NSMenu) -> Bool, depth: Int) -> [NSMenu] {
        submenus(depth: depth).filter(predicate)
    }
    
    /**
     Returns all submenus of a specific menu type, searching up to a given submenu depth.
     
     - Parameters:
        - type: The subclass type of `NSMenu` to filter.
        - depth: The number of submenu levels to match. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    public func submenus<V: NSMenu>(type _: V.Type, depth: Int = 0) -> [V] {
        submenus(depth: depth).compactMap { $0 as? V }
    }
    
    /**
     Returns the first submenu with the specified title.
     
     - Parameters:
        - title: The title of the menu.
        - depth: The number of submenu levels to match. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    @objc open func submenu(withTitle title: String, depth: Int = 0) -> NSMenu? {
        firstSubmenu(where: { $0.title == title }, depth: depth)
    }
    
    /**
     Returns the first submenu with the specific menu type, searching recursively through submenus.

     - Parameters:
        - type: The subclass type of `NSMenu` to search for.
        - depth: The number of submenu levels to match. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    public func firstSubmenu<V: NSMenu>(type _: V.Type, depth: Int = .max) -> V? {
        submenus(where: { $0 is V }, depth: depth).first as? V
    }
    
    /**
     Returns the first submenu that satisfies a given predicate, searching recursively through submenus.
     
     - Parameters:
        - predicate: A closure that returns `true` for the submenu to find.
        - depth: The number of submenu levels to match. Use `0` for only top-level submenus and `.max` for unlimited depth.
     */
    @objc open func firstSubmenu(where predicate: (NSMenu) -> Bool, depth: Int) -> NSMenu? {
        let submenus = items.compactMap({ $0.submenu })
        if let submenu = submenus.first(where: predicate) {
            return submenu
        } else if depth > 0 {
            for submenu in submenus {
                if let submenu = submenu.firstSubmenu(where: predicate, depth: depth - 1) {
                    return submenu
                }
            }
        }
        return nil
    }
    
    /**
     A Boolean value indicating whether the menu should auto update it's width.
          
     If set to `true`, the menu width is automatically updated to the width of the items including the item's ``AppKit/NSMenuItem/alternateItem``.
     
     Setting this property to `true`, prevents the menu width from increasing if an ``AppKit/NSMenuItem/alternateItem`` is displayed that is wider than the current menu width.
     
     The default value is `false`.
     */
    public var autoUpdatesWidth: Bool {
        get { getAssociatedValue("autoUpdatesWidth") ?? false }
        set { setAssociatedValue(newValue, key: "autoUpdatesWidth") }
    }
    
    /**
     Sets the Boolean value indicating whether the menu should auto update it's width.
     
     If set to `true`, the menu width is automatically updated to the width of the items including the item's ``AppKit/NSMenuItem/alternateItem``.
     
     Setting this property to `true`, prevents the menu width from increasing if an ``AppKit/NSMenuItem/alternateItem`` is displayed that is wider than the current menu width.
     
     The default value is `false`.
     */
    @discardableResult
    public func autoUpdatesWidth(_ autoUpdates: Bool) -> Self {
        autoUpdatesWidth = autoUpdates
        return self
    }
    
    /**
     The total size of the menu in screen coordinates.
     
     The total size includes the menu's items ``AppKit/NSMenuItem/alternateItem``.
     */
    var totalSize: CGSize {
        var totalSize = size
        let itemsCount = items.count
        items = items.withAlternates()
        totalSize = size
        if itemsCount != items.count {
            items = items.withoutAlternates()
        }
        return totalSize
    }
    
    /**
     Pops up the menu at the specified location using a specified font.

     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.
          
     If `view` is `nil`, the location is interpreted in the screen coordinate system. This allows you to pop up a menu disconnected from any window.

     - Parameters:
        - item: The menu item to be positioned at the specified location in the view.
        - location: The location in the view coordinate system to display the menu item.
        - view: The view to display the menu item over.
        - font: The font for the menu.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, at location: CGPoint, in view: NSView? = nil, with font: NSFont) -> Bool {
        handlers.font = { includeSubmenus in
            includeSubmenus = true
            return font
        }
        handlers.didClose = { [weak self] in
            guard let self = self else { return }
            self.handlers.font = nil
            self.handlers.didClose = nil
        }
        return popUp(positioning: item, at: location, in: view)
    }
    
    
    /**
     Pops up the menu at the current mouse location in the specified view.

     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.
          
     - Parameters:
        - item: The menu item to be positioned at the specified location in the view.
        - view: The view to display the menu item over.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, in view: NSView) -> Bool {
        popUp(positioning: item, at: view.mouseLocationOutsideOfEventStream, in: view)
    }
    
    /**
     Pops up the menu at the current mouse location in the specified view using a specified font.

     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.
          
     - Parameters:
        - item: The menu item to be positioned at the specified location in the view.
        - view: The view to display the menu item over.
        - font: The font for the menu.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, in view: NSView, with font: NSFont) -> Bool {
        popUp(positioning: item, at: view.mouseLocationOutsideOfEventStream, in: view, with: font)
    }
    
    /**
     Pops up the menu at the specified location.
     
     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `view` is `nil`, the location is interpreted in the screen coordinate system. This allows you to pop up a menu disconnected from any window.
     
     - Parameters:
        - item: The menu item to be positioned at the specified location in the view.
        - location: The location in the view coordinate system to display the menu item.
        - view: The view to display the menu item over.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @_disfavoredOverload
    @discardableResult
    public func popUp(positioning item: NSMenuItem, at location: CGPoint, in view: NSView? = nil) -> Bool {
        popUp(positioning: item, at: location, in: view)
    }
    
    /**
     Pops up the menu at the specified location.
     
     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.

     - Parameters:
        - item: The menu item to be positioned at the specified location in the view.
        - location: The location in the view coordinate system to display the menu item.
        - view: The view to display the menu item over.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @_disfavoredOverload
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, at location: CGPoint, in view: NSView) -> Bool {
        popUp(positioning: item, at: location, in: view)
    }
    
    /**
     Pops up the menu at the specified screen location.
     
     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     The menu is positioned such that the top left of the menu content frame is at the given screen location.
     
     - Parameters:
        - screenLocation: The location in the screen coordinate system to display the menu item.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @_disfavoredOverload
    @discardableResult
    public func popUp(at screenLocation: CGPoint) -> Bool {
        popUp(positioning: nil, at: screenLocation, in: nil)
    }

    /**
     Pops up the menu at the specified event location location.
     
     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.
          
     - Parameters:
        - item: The menu item to be positioned at the specified event location in the view.
        - event: The event representing the the location.
        - view: The view to display the menu item over.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, at event: NSEvent, in view: NSView) -> Bool {
        popUp(positioning: item, at: event.location(in: view), in: view)
    }
    
    /**
     Pops up the menu at the specified event location location using a specified font.
     
     Displays the menu as a pop-up menu. The top left corner of the specified item (if specified, item must be present in the menu) is positioned at the specified location in the specified view, interpreted in the view’s own coordinate system.
     
     If `item` is `nil`, the menu is positioned such that the top left of the menu content frame is at the given location.
          
     - Parameters:
        - item: The menu item to be positioned at the specified event location in the view.
        - event: The event representing the the location.
        - view: The view to display the menu item over.
        - font: The font for the menu.
     - Returns: `true` if menu tracking ended because an item was selected, and `false` if menu tracking was cancelled for any reason.
     */
    @discardableResult
    public func popUp(positioning item: NSMenuItem? = nil, at event: NSEvent, in view: NSView, with font: NSFont) -> Bool {
        popUp(positioning: item, at: event.location(in: view), in: view, with: font)
    }
     
    /**
     Pops up the menu as contextual menu for an event.

     - Parameters:
        - event: The event representing the location.
        - view: The view to display the menu item over.
     */
    public func popUpContext(at event: NSEvent, in view: NSView) {
        NSMenu.popUpContextMenu(self, with: event, for: view)
    }
    
    /**
     Pops up the menu as contextual menu for an event using a specified font.
          
     - Parameters:
        - event: The event representing the location.
        - view: The view to display the menu item over.
        - font: The font for the menu.
     */
    public func popUpContext(at event: NSEvent, in view: NSView, with font: NSFont) {
        NSMenu.popUpContextMenu(self, with: event, for: view, with: font)
    }
}

fileprivate extension [NSMenuItem] {
    func withAlternates() -> [NSMenuItem] {
        flatMap { if let alternate = $0.alternateItem, !alternate.keyEquivalentModifierMask.isEmpty { return [$0, alternate] } else { return [$0] } }.uniqued()
    }
    
    func withoutAlternates() -> [Element] {
        let alternateSet = Set(compactMap { $0.alternateItem?.objectID })
        return compactMap { alternateSet.contains($0.objectID) ? nil : $0 }
    }
}
#endif
