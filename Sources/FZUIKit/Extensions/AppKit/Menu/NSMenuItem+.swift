//
//  NSMenuItem+.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)

    import AppKit
    import Foundation
    import SwiftUI

    public extension NSMenuItem {
        /**
         Initializes and returns a menu item with the specified title.
         - Parameter title: The title of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(_ title: String) {
            self.init(title: title)
        }

        /**
         Initializes and returns a menu item with the specified title.
         - Parameter title: The title of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(title: String) {
            self.init(title: title, action: nil, keyEquivalent: "")
            isEnabled = true
        }

        /**
         Initializes and returns a menu item with the specified image.
         - Parameter image: The image of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(image: NSImage) {
            self.init(title: "")
            self.image = image
        }

        /**
         Initializes and returns a menu item with the view.

         - Parameters:
            - view: The view of the menu item.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(view: NSView, showsHighlight: Bool = true) {
            self.init(title: "")
            self.view(view)
            if showsHighlight {
                let highlightableView = HighlightableView(frame: view.frame)
                highlightableView.addSubview(withConstraint: view)
                self.view = highlightableView
            } else {
                self.view = view
            }
        }

        /**
         Initializes and returns a menu item with the `SwiftUI` view.

         - Parameters:
            - view: The view of the menu item.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init<V: View>(showsHighlight: Bool = true, view: V) {
            self.init(title: "")
            self.view = NSMenu.MenuItemHostingView(showsHighlight: showsHighlight, contentView: view)
        }

        /**
         Initializes and returns a menu item with the specified title and submenu containing the specified menu items.

         - Parameters:
            - title: The title for the menu item.
            - items: The items of the submenu.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(title: String,
                         @MenuBuilder items: () -> [NSMenuItem])
        {
            self.init(title: title)
            submenu = NSMenu(title: "", items: items())
        }
        
        /// A Boolean value that indicates whether the menu item is enabled.
        @discardableResult
        func isEnabled(_ isEnabled: Bool) -> Self {
            self.isEnabled = isEnabled
            return self
        }
        
        /// A Boolean value that indicates whether the menu item is hidden.
        @discardableResult
        func isHidden(_ isHidden: Bool) -> Self {
            self.isHidden = isHidden
            return self
        }
        
        /// The menu item's tag.
        @discardableResult
        func tag(_ tag: Int) -> Self {
            self.tag = tag
            return self
        }
        
        /// The menu item's title.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// A custom string for a menu item.
        @discardableResult
        func attributedTitle(_ attributedTitle: NSAttributedString?) -> Self {
            self.attributedTitle = attributedTitle
            return self
        }
        
        /// The state of the menu item.
        @discardableResult
        func state(_ state: NSControl.StateValue) -> Self {
            self.state = state
            return self
        }
        
        /// The menu item’s image.
        @discardableResult
        func image(_ image: NSImage?) -> Self {
            self.image = image
            return self
        }
        
        /// The image of the menu item that indicates an “on” state.
        @discardableResult
        func onStateImage(_ image: NSImage!) -> Self {
            onStateImage = image
            return self
        }
        
        /// The image of the menu item that indicates an “off” state.
        @discardableResult
        func offStateImage(_ image: NSImage?) -> Self {
            offStateImage = image
            return self
        }
        
        /// The image of the menu item that indicates a “mixed” state, that is, a state neither “on” nor “off.”
        @discardableResult
        func mixedStateImage(_ image: NSImage!) -> Self {
            mixedStateImage = image
            return self
        }
        
        /// The menu item’s badge.
        @available(macOS 14.0, *)
        @discardableResult
        func badge(_ badge: NSMenuItemBadge?) -> Self {
            self.badge = badge
            return self
        }
        
        /// The menu item’s unmodified key equivalent.
        @discardableResult
        func keyEquivalent(_ keyEquivalent: String) -> Self {
            self.keyEquivalent = keyEquivalent
            return self
        }
        
        /// The menu item’s keyboard equivalent modifiers.
        @discardableResult
        func keyEquivalentModifierMask(_ modifierMask: NSEvent.ModifierFlags) -> Self {
            keyEquivalentModifierMask = modifierMask
            return self
        }
        
        /// A Boolean value that marks the menu item as an alternate to the previous menu item.
        @discardableResult
        func isAlternate(_ isAlternate: Bool) -> Self {
            self.isAlternate = isAlternate
            return self
        }
        
        /// The menu item indentation level for the menu item.
        @discardableResult
        func indentationLevel(_ level: Int) -> Self {
            indentationLevel = level
            return self
        }
        
        /**
         Displays a content view instead of the title or attributed title.
                           
         By default, a highlight background will be drawn behind the view whenever the menu item is highlighted. You can disable this and handle highlighting yourself by passing `showsHighlight: false`
         
         - Parameters:
            - view: The  view of the menu item.
            - showsHighlight: A Boolean value that indicates whether to draw the highlight when the item is highlighted.
         */
        @discardableResult
        func view(_ view: NSView?, showsHighlight: Bool = true) -> Self {
            if let view = view {
                if showsHighlight {
                    let highlightableView = HighlightableView(frame: view.frame)
                    highlightableView.addSubview(withConstraint: view)
                    self.view = view
                } else {
                    self.view = view
                }
            } else {
                self.view = nil
            }
            return self
        }
        
        /**
         Displays a SwiftUI `View` instead of the title or attributed title.
         
         Any views inside a menu item can use the `menuItemIsHighlighted` environment value to alter their appearance when highlighted.
         
         By default, a highlight background will be drawn behind the view whenever `menuItemIsHighlighted` is `true`. You can disable this and handle highlighting yourself by passing `showsHighlight: false`
         
         - Parameters:
            - showsHighlight: A Boolean value that indicates whether to draw the highlight when the item is highlighted.
            - content: The  SwiftUI `View`.
         */
        @discardableResult
        func view<Content: View>(showsHighlight: Bool = true, @ViewBuilder _ content: () -> Content) -> Self {
            view(NSMenu.MenuItemHostingView(showsHighlight: showsHighlight, contentView: content()))
        }
        
        /// A help tag for the menu item.
        @discardableResult
        func toolTip(_ toolTip: String?) -> Self {
            self.toolTip = toolTip
            return self
        }
        
        /// The object represented by the menu item.
        @discardableResult
        func representedObject(_ object: Any?) -> Self {
            representedObject = object
            return self
        }
        
        /// A Boolean value that determines whether the system automatically remaps the keyboard shortcut to support localized keyboards.
        @available(macOS 12.0, *)
        @discardableResult
        func allowsAutomaticKeyEquivalentLocalization(_ allows: Bool) -> Self {
            self.allowsAutomaticKeyEquivalentLocalization = allows
            return self
        }
         
        /// A Boolean value that determines whether the system automatically swaps input strings for some keyboard shortcuts when the interface direction changes.
        @available(macOS 12.0, *)
        @discardableResult
        func allowsAutomaticKeyEquivalentMirroring(_ allows: Bool) -> Self {
            self.allowsAutomaticKeyEquivalentMirroring = allows
            return self
        }
        
        /// A Boolean value that determines whether the item allows the key equivalent when hidden.
        @discardableResult
        func allowsKeyEquivalentWhenHidden(_ allows: Bool) -> Self {
            self.allowsKeyEquivalentWhenHidden = allows
            return self
        }
        
        /// The menu item’s menu.
        @discardableResult
        func menu(_ menu: NSMenu?) -> Self {
            self.menu = menu
            return self
        }
        
        /// The submenu of the menu item.
        @discardableResult
        func submenu(_ menu: NSMenu?) -> Self {
            submenu = menu
            return self
        }        
    }

@available(macOS 14.0, *)
public extension NSMenuItem {
    static func palette(
        images: [NSImage],
        titles: [String] = [],
        selectionMode: NSMenu.SelectionMode = .selectAny,
        onSelectionChange: ((IndexSet) -> Void)? = nil
    ) -> NSMenuItem {
        let paletteItem = NSMenuItem()
        let menu = NSMenu()
        menu.presentationStyle = .palette
        for (index, image) in images.enumerated() {
            let item = NSMenuItem(image: image)
            item.title = titles[safe: index] ?? ""
            item.image = image
            menu.addItem(item)
        }
        Swift.print("mmm", menu.items)
        paletteItem.submenu = menu
        return paletteItem
    }
    
    static func palette(
        symbolImages: [String],
        titles: [String] = [],
        selectionMode: NSMenu.SelectionMode = .selectAny,
        onSelectionChange: ((IndexSet) -> Void)? = nil
    ) -> NSMenuItem {
        let paletteItem = NSMenuItem()
        let menu = NSMenu()
        menu.presentationStyle = .palette
        let images = symbolImages.compactMap({NSImage(systemSymbolName: $0)})
        for (index, image) in images.enumerated() {
            let item = NSMenuItem(image: image)
            item.title = titles[safe: index] ?? ""
            menu.addItem(item)
        }
        paletteItem.submenu = menu
        return paletteItem
    }
    
    /**
     Creates a palette style menu item displaying user-selectable color tags that tint using the specified array of colors.
     
     - Parameters:
        - colors: The display colors for the menu items.
        - titles: The menu item titles.
        - template: The image the system displays for the menu items.
        - selectionMode:
        - onSelectionChange: The closure to invoke when someone selects the menu item.
     
     - Returns: A menu item that presents with a palette.
     */
    static func palette(
        colors: [NSColor],
        titles: [String] = [],
        template: NSImage? = nil,
        offStateTemplate: NSImage? = nil,
        selectionMode: NSMenu.SelectionMode = .selectAny,
        onSelectionChange: (([NSColor]) -> Void)? = nil
    ) -> NSMenuItem {
        let paletteItem = NSMenuItem()
        let menu: NSMenu
        if let offStateTemplate = offStateTemplate {
            menu = .palette(colors: colors, titles: titles) { menu in
                guard let onSelectionChange = onSelectionChange else { return }
                let indexes = menu.selectedItems.compactMap({menu.items.firstIndex(of:$0)})
                let colors = indexes.compactMap({colors[safe: $0]})
                onSelectionChange(colors)
            }
            menu.items.forEach({$0.onStateImage = template})
            menu.items.forEach({$0.offStateImage = offStateTemplate})
        } else {
            menu = .palette(colors: colors, titles: titles, template: template) { menu in
                guard let onSelectionChange = onSelectionChange else { return }
                let indexes = menu.selectedItems.compactMap({menu.items.firstIndex(of:$0)})
                let colors = indexes.compactMap({colors[safe: $0]})
                onSelectionChange(colors)
            }
        }
        menu.selectionMode = selectionMode
        paletteItem.submenu = menu
        return paletteItem
    }
}
#endif
