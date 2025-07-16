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
}
#endif
