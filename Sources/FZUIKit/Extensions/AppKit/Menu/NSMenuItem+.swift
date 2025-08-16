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
import FZSwiftUtils

public extension NSMenuItem {
    /**
     Initializes and returns a menu item with the specified title.
     
     - Parameters:
        - title: The title of the menu item.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(_ title: String, action: ActionBlock? = nil) {
        self.init(title: title, action: nil, keyEquivalent: "")
        actionBlock = action
    }
    
    /**
     Initializes and returns a menu item with the specified title.
     
     - Parameters:
        - title: The title of the menu item.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(_ title: NSAttributedString, action: ActionBlock? = nil) {
        self.init("", action: action)
        attributedTitle = title
    }
    
    /**
     Initializes and returns a menu item with the specified localized title.
     
     - Parameters:
        - localizedTitle: The localized title of the menu item.
        - table: The table of the localization.
        - bundle: The bundle of the localization.
        - locale: The language.
        - comment: The comment of the localization.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    @available(macOS 12, *)
    convenience init(_ localizedTitle: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale = .current, comment: StaticString? = nil, action: ActionBlock? = nil) {
        self.init(String(localized: localizedTitle, table: table, bundle: bundle, locale: locale, comment: comment), action: action)
    }
    
    /**
     Initializes and returns a menu item with the specified image.
     
     - Parameters:
        - title: The title of the menu item.
        - image: The image of the menu item.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(_ title: String? = nil, image: NSImage, action: ActionBlock? = nil) {
        self.init(title ?? "", action: action)
        self.image = image
    }
    
    /**
     Initializes and returns a menu item with the view.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     - Parameters:
        - view: The view of the menu item.
        - showsHighlight: A Boolean value indicating whether menu item should highlight on interaction.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(view: NSView, showsHighlight: Bool = true, action: ActionBlock? = nil) {
        self.init("", action: action)
        self.view(view, showsHighlight: showsHighlight)
    }
    
    /**
     Initializes and returns a menu item with the `SwiftUI` view.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.
          
     - Parameters:
        - view: The view of the menu item.
        - showsHighlight: A Boolean value indicating whether menu item should highlight on interaction.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init<Content: View>(view: Content, showsHighlight: Bool = true, action: ActionBlock? = nil) {
        self.init("", action: action)
        self.view(view, showsHighlight: showsHighlight)
    }
    
    /**
     Initializes and returns a menu item with the `SwiftUI` view.
          
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.
     
     - Parameters:
        - view: The view of the menu item.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `view`.
        - showsHighlight: A Boolean value indicating whether menu item should highlight on interaction.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    @available(macOS 13.0, *)
    convenience init<Content: View>(view: Content, sizingOptions: NSHostingSizingOptions, showsHighlight: Bool = true, action: ActionBlock? = nil) {
        self.init("", action: action)
        self.view(view, sizingOptions: sizingOptions, showsHighlight: showsHighlight)
    }
    
    /**
     Initializes and returns a menu item with the `SwiftUI` view.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.
     
     - Parameters:
        - view: The view of the menu item.
        - showsHighlight: A Boolean value indicating whether menu item should highlight on interaction.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init<Content: View>(@ViewBuilder view: () -> Content, showsHighlight: Bool = true, action: ActionBlock? = nil) {
        self.init("", action: action)
        self.view(view, showsHighlight: showsHighlight)
    }
    
    /**
     Initializes and returns a menu item with the `SwiftUI` view.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.
     
     - Parameters:
        - content: The view of the menu item.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `rootView`.
        - showsHighlight: A Boolean value indicating whether menu item should highlight on interaction.
        - action: The action handler.
     
     - Returns: An instance of `NSMenuItem`.
     */
    @available(macOS 13.0, *)
    convenience init<Content: View>(@ViewBuilder view: () -> Content, sizingOptions: NSHostingSizingOptions, showsHighlight: Bool = true, action: ActionBlock? = nil) {
        self.init("", action: action)
        self.view(view, sizingOptions: sizingOptions, showsHighlight: showsHighlight)
    }
    
    /**
     Initializes and returns a menu item with the specified title and submenu containing the specified menu items.
     
     - Parameters:
        - title: The title for the menu item.
        - items: The items of the submenu.
     
     - Returns: An instance of `NSMenuItem`.
     */
    convenience init(_ title: String, @MenuBuilder items: () -> [NSMenuItem]) {
        self.init(title)
        submenu = NSMenu(title: "", items: items())
    }
    
    /// The font of the menu item.
    var font: NSFont? {
        get { value(forKeySafely: "font") as? NSFont }
        set { setValue(safely: newValue, forKey: "font") }
    }
    
    /// Sets the font of the menu item.
    @discardableResult
    func font(_ font: NSFont) -> Self {
        self.font = font
        return self
    }
    
    /// A Boolean value indicating whether the menu item is enabled.
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    /// A Boolean value indicating whether the menu item is hidden.
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
    
    /// The state of the menu item.
    @discardableResult
    func state(_ state: Bool) -> Self {
        self.state = state ? .on : .off
        return self
    }
    
    /// The menu item’s image.
    @discardableResult
    func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    /// The image of the menu item indicating an “on” state.
    @discardableResult
    func onStateImage(_ image: NSImage!) -> Self {
        onStateImage = image
        return self
    }
    
    /// The image of the menu item indicating an “off” state.
    @discardableResult
    func offStateImage(_ image: NSImage?) -> Self {
        offStateImage = image
        return self
    }
    
    /// The image of the menu item indicating a “mixed” state, that is, a state neither “on” nor “off.”
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
    
    /**
     Sets the menu item as an alternate to the previous menu item in the menu, that is displayed when the specified modifier flags are hold.

     If you set this value to `[]`, the item isn't an alternative and displayed all the time.
     */
    func alternateModifierFlags(_ modifierFlags: NSEvent.ModifierFlags) -> Self {
        isAlternate = modifierFlags != []
        keyEquivalentModifierMask = modifierFlags
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
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).

     - Parameters:
        - view: The  view of the menu item.
        - showsHighlight: A Boolean value indicating whether to draw the highlight when the item is highlighted.
     */
    @discardableResult
    func view(_ view: NSView?, showsHighlight: Bool = true) -> Self {
        if let view = view {
            if showsHighlight {
                self.view = NSMenuItemView(content: view)
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
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.

     - Parameters:
        - view: The  SwiftUI `View`.
        - showsHighlight: A Boolean value indicating whether to draw the highlight when the item is highlighted.
     */
    @discardableResult
    func view<V: View>(_ view: V, showsHighlight: Bool = true) -> Self {
        self.view = NSMenuItemHostingView(rootView: view, showsHighlight: showsHighlight)
        return self
    }
    
    /**
     Displays a SwiftUI `View` instead of the title or attributed title.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.

     - Parameters:
        - view: The  SwiftUI `View`.
        - showsHighlight: A Boolean value indicating whether to draw the highlight when the item is highlighted.
     */
    @discardableResult
    func view<Content: View>(@ViewBuilder _ view: () -> Content, showsHighlight: Bool = true) -> Self {
        self.view(view(), showsHighlight: showsHighlight)
    }
    
    /**
     Displays a SwiftUI `View` instead of the title or attributed title.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.

     - Parameters:
        - view: The  SwiftUI `View`.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `view`.
        - showsHighlight: A Boolean value indicating whether to draw the highlight when the item is highlighted.
     */
    @available(macOS 13.0, *)
    @discardableResult
    func view<V: View>(_ view: V, sizingOptions: NSHostingSizingOptions, showsHighlight: Bool = true) -> Self {
        self.view = NSMenuItemHostingView(rootView: view, showsHighlight: showsHighlight, sizingOptions: sizingOptions)
        return self
    }
    
    /**
     Displays a SwiftUI `View` instead of the title or attributed title.
     
     If `showsHighlight` is set to `true`, a highlight background will be drawn behind the view whenever the menu item is highlighted (the mouse is hovering the item).
     
     To observe the `isEnabled` and `highlight` state of the menu item inside the `SwiftUI` view, use ``SwiftUICore/EnvironmentValues/menuItemIsEnabled`` and ``SwiftUICore/EnvironmentValues/menuItemIsHighlighted``.
          
     - Parameters:
        - view: The  SwiftUI `View`.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `SwiftUI` view.
        - showsHighlight: A Boolean value indicating whether to draw the highlight when the item is highlighted.
     */
    @available(macOS 13.0, *)
    @discardableResult
    func view<Content: View>(@ViewBuilder _ view: () -> Content, sizingOptions: NSHostingSizingOptions, showsHighlight: Bool = true) -> Self {
        self.view = NSMenuItemHostingView(rootView: view(), showsHighlight: showsHighlight, sizingOptions: sizingOptions)
        return self
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
    
    /// Sets the menu item’s menu.
    @discardableResult
    func menu(_ menu: NSMenu?) -> Self {
        self.menu = menu
        return self
    }
    
    /// Sets the menu item’s menu.
    @discardableResult
    func menu(@MenuBuilder _ items: @escaping () -> [NSMenuItem]) -> Self {
        menu = NSMenu().items(items)
        return self
    }
    
    /// The submenu of the menu item.
    @discardableResult
    func submenu(_ menu: NSMenu?) -> Self {
        submenu = menu
        return self
    }
    
    /// The submenu of the menu item.
    @discardableResult
    func submenu(@MenuBuilder _ items: @escaping () -> [NSMenuItem]) -> Self {
        submenu = NSMenu().items(items)
        return self
    }
    
    /// The visibility of a menu item.
    enum Visibility: Int {
        /// The item is always visible.
        case always
        /// The item is visible only while the Option key is held down.
        case whileHoldingOption
        /// The item is visible only if the Option key is pressed at the moment the menu is opened.
        case onMenuOpenHoldingOption
    }
    
    /**
     The visibility of the menu item.
     
     Set this property to restrict the visibility of a menu item depending on whether the Option key is held during interaction.
     
     - Note: This property is evaluated in addition to the menu item's `isHidden` property, which must be `false` for the item to be shown.
     */
    var visibility: Visibility {
        get { getAssociatedValue("visibility") ?? .always }
        set {
            setAssociatedValue(newValue, key: "visibility")
            setupMenuDelegateProxy()
        }
    }
    
    /**
     Sets the visibility of the item.
     
     Use this method to restrict the visibility of a menu item depending on whether the Option key is held during interaction.
     
     - Note: This property is evaluated in addition to the menu item's `isHidden` property, which must be `false` for the item to be shown.
     */
    @discardableResult
    func visibility(_ visibility: Visibility) -> Self {
        self.visibility = visibility
        return self
    }
    
    /// The handler that gets called to update the item before it gets displayed.
    var updateHandler: ((_ item: NSMenuItem)->())? {
        get { getAssociatedValue("updateHandler") }
        set {
            setAssociatedValue(newValue, key: "updateHandler")
            setupMenuDelegateProxy()
        }
    }
    
    /// Sets the handler that gets called to update the item before it gets displayed.
    @discardableResult
    func updateHandler(_ handler: ((_ item: NSMenuItem)->())?) -> Self {
        self.updateHandler = handler
        return self
    }
    
    /**
     The alternate menu item displayed when the option key is held.
     
     To change the modifier flag required to hold, use the alternate item's `keyEquivalentModifierMask` property.
     */
    var alternateItem: NSMenuItem? {
        get { getAssociatedValue("alternateItem") }
        set {
            guard newValue != alternateItem else { return }
            alternateItem?.isAlternate = false
            alternateItem?.keyEquivalentModifierMask = []
            newValue?.isAlternate = true
            newValue?.keyEquivalentModifierMask = [.option]
            if !alternateItemIsDisplayableWhenHidden {
                newValue?.keyEquivalentModifierMask = isHidden ? [] : [.option]
            }
            setAssociatedValue(newValue, key: "alternateItem")
            setupMenuDelegateProxy()
        }
    }
    
    /**
     Sets the alternate menu item displayed when the option key is hold.
     
     To change the modifier flag required to hold, use the alternate item's `keyEquivalentModifierMask` property.

     - Parameters:
        - item: The alternate item.
        - isDisplayableWhenHidden: A Boolean value indicating whether the alternate item can be displayed even if the item is hidden.
     */
    @discardableResult
    func alternateItem(_ item: NSMenuItem?, isDisplayableWhenHidden: Bool = true) -> Self {
        alternateItem = item
        alternateItemIsDisplayableWhenHidden = isDisplayableWhenHidden
        return self
    }
    
    /**
     A Boolean value indicating whether the ``AppKit/NSMenuItem/alternateItem`` can be displayed if the item is hidden.
     
     The default value is `true`.
     */
    var alternateItemIsDisplayableWhenHidden: Bool {
        get { alternateItemIsHiddenObservation == nil }
        set {
            guard newValue != alternateItemIsDisplayableWhenHidden else { return }
            if newValue {
                alternateItemIsHiddenObservation = nil
                alternateItem?.keyEquivalentModifierMask = [.option]
            } else {
                alternateItemIsHiddenObservation = observeChanges(for: \.isHidden) { [weak self] old, new in
                    guard let self = self else { return }
                    self.alternateItem?.keyEquivalentModifierMask = new ? [] : [.option]
                }
                alternateItem?.keyEquivalentModifierMask = isHidden ? [] : [.option]
            }
        }
    }
    
    /**
     Sets the Boolean value indicating whether the ``AppKit/NSMenuItem/alternateItem`` can be displayed if the item is hidden.
     
     The default value is `true`.
     */
    @discardableResult
    func alternateItemIsDisplayableWhenHidden(_ isDisplayable: Bool) -> Self {
        alternateItemIsDisplayableWhenHidden = isDisplayable
        return self
    }
    
    private var alternateItemIsHiddenObservation: KeyValueObservation? {
        get { getAssociatedValue("alternateItemIsHiddenObservation") }
        set { setAssociatedValue(newValue, key: "alternateItemIsHiddenObservation") }
    }
    
    /// Removes the item from it's menu.
    func removeFromMenu() {
        menu?.removeItem(self)
    }
    
    /// The estimate width of the item.
    internal var estimatedWidth: CGFloat {
        if let view = view {
            return view.frame.width
        }

        var titleWidth = 0.0
        if let attributed = attributedTitle {
            titleWidth = attributed.size().width
        } else {
            titleWidth = (title as NSString).size(withAttributes: [.font: font ?? NSFont.menuFont(ofSize: 0)]).width
        }

        var imageWidth = 0.0
        if let image = image {
            imageWidth = image.size.width + 6
        }

        let alternateWidth = alternateItem?.estimatedWidth ?? 0.0
        let width = titleWidth + imageWidth + 30
        return max(width, alternateWidth)
    }
        
    internal func setupMenuDelegateProxy() {
        menu?.setupDelegateProxy()
        if !needsDelegateProxy {
            menuObservation = nil
        } else {
            menuObservation = observeChanges(for: \.menu) { old, new in
                old?.setupDelegateProxy()
                new?.setupDelegateProxy()
            }
        }
    }
    
    internal var needsDelegateProxy: Bool {
        alternateItem != nil || updateHandler != nil || visibility != .always
    }
    
    internal var menuObservation: KeyValueObservation? {
        get { getAssociatedValue("menuObservation") }
        set { setAssociatedValue(newValue, key: "menuObservation") }
    }
    
    /// The width of the item.
    internal var width: CGFloat? {
        guard let menu = menu else { return nil }
        return (title as NSString).size(withAttributes: [.font:menu.font]).width
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
