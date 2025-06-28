//
//  Toolbar.swift
//
//  Adpted from dagronf/DSFToolbar
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// `Toolbar` configurates a window toolbar and it's items.
open class Toolbar: NSObject {
    
    /// The identifier of the toolbar.
    public let identifier: NSToolbar.Identifier
    
    private var delegate: Delegate!
    private var toolbar: MangedToolbar!
    private var toolbarObservation: KeyValueObservation?
    private var toolbarStyle: Any?

    /**
     Creates a newly toolbar with the specified identifier.
     
     - Note: The identifier is used for autosaving the toolbar. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple toolbars.
     
     - Parameters:
        - identifier: A string to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
        - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
        - items: An array of toolbar items.
     
     - Returns: The initialized `Toolbar` object.
     */
    public init(_ identifier: NSToolbar.Identifier? = nil, allowsUserCustomization: Bool = true, items: [ToolbarItem]) {
        self.identifier = identifier ?? Self.automaticIdentifier(for: "\(type(of: self))").rawValue
        self.items = items
        super.init()
        toolbar = .init(for: self)
        delegate = Delegate(for: self)
        self.allowsUserCustomization = allowsUserCustomization
        autosavesConfiguration = allowsUserCustomization
        if #available(macOS 13.0, *) {
            centeredItems = Set(items.filter(\.isCentered))
        }
        selectedItem = items.first
    }
    
    /**
     Creates a newly toolbar with the specified identifier.
     
     - Note: The identifier is used for autosaving the toolbar. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple toolbars.
     
     - Parameters:
        - identifier: A string to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
        - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
        - items: The toolbar items.
     
     - Returns: The initialized `Toolbar` object.
     */
    public convenience init(_ identifier: NSToolbar.Identifier? = nil, allowsUserCustomization: Bool = true, @Builder items: () -> [ToolbarItem]) {
        self.init(identifier, allowsUserCustomization: allowsUserCustomization, items: items())
    }
    
    /// The window of the toolbar.
    public var attachedWindow: NSWindow? {
        get { _attachedWindow }
        set { _attachedWindow = newValue }
    }
    
    private weak var _attachedWindow: NSWindow? {
        didSet {
            guard oldValue != attachedWindow else { return }
            if #available(macOS 11.0, *), let window = attachedWindow {
                window.toolbarStyle = style.style ?? window.toolbarStyle
            }
            if #available(macOS 11.0, *) {
                items.compactMap({ $0 as? Toolbar.TrackingSeparator }).forEach({ $0.updateAutodetectSplitView(toolbar: self) })
            }
            toolbarObservation = attachedWindow?.observeChanges(for: \.toolbar) { [weak self] old, new in
                guard let self = self, new !== self.toolbar else { return }
                self.attachedWindow = nil
                self.toolbarObservation = nil
            }
            if oldValue?.toolbar === toolbar {
                oldValue?.toolbar = nil
            }
            attachedWindow?.toolbar = toolbar
        }
    }
        
    /// Sets the window of the toolbar.
    @discardableResult
    open func attachedWindow(_ window: NSWindow?) -> Self {
        attachedWindow = window
        return self
    }
    
    /// A Boolean value that indicates whether the toolbar is visible.
    open var isVisible: Bool {
        get { toolbar.isVisible }
        set { toolbar.isVisible = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the toolbar is visible.
    @discardableResult
    open func isVisible(_ isVisible: Bool) -> Self {
        self.isVisible = isVisible
        return self
    }
        
    /// The appearance and location of a toolbar in relation to the attached window's title bar.
    @available(macOS 11.0, *)
    public enum Style: Int, Hashable, Codable {
        /// A style indicating that the system determines the toolbar’s appearance and location.
        case automatic
        /// A style indicating that the toolbar appears below the window title.
        case expanded
        /// A style indicating that the toolbar appears below the window title with toolbar items centered in the toolbar.
        case preference
        /// A style indicating that the toolbar appears next to the window title.
        case unified
        /// A style indicating that the toolbar appears next to the window title and with reduced margins to allow more focus on the window’s contents.
        case unifiedCompact
        /// The style specified by the attached window's `toolbarStyle`.
        case window = -100
        
        @available(macOS 11.0, *)
        var style: NSWindow.ToolbarStyle? {
            .init(rawValue: rawValue)
        }
    }
    
    /// The style that determines the appearance and location of the toolbar in relation to the attached window's title bar.
    @available(macOS 11.0, *)
    open var style: Style {
        get { toolbarStyle as? Style ?? .window }
        set {
            toolbarStyle = newValue
            guard let window = attachedWindow else { return }
            window.toolbarStyle = newValue.style ?? window.toolbarStyle
        }
    }
    
    /// Sets the style that determines the appearance and location of the toolbar in relation to the attached window's title bar.
    @available(macOS 11.0, *)
    @discardableResult
    open func style(_ style: Style) -> Self {
        self.style = style
        return self
    }
        
    /// A value that indicates whether the toolbar displays items using a name, icon, or combination of elements.
    open var displayMode: NSToolbar.DisplayMode {
        get { toolbar.displayMode }
        set { toolbar.displayMode = newValue }
    }
    
    /// Sets the value that indicates whether the toolbar displays items using a name, icon, or combination of elements.
    @discardableResult
    open func displayMode(_ mode: NSToolbar.DisplayMode) -> Self {
        displayMode = mode
        return self
    }
    
    /// A Boolean value that indicates whether the toolbar shows the separator between the toolbar and the main window contents.
    open var showsBaselineSeparator: Bool {
        get { toolbar.showsBaselineSeparator }
        set { toolbar.showsBaselineSeparator = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the toolbar shows the separator between the toolbar and the main window contents.
    @discardableResult
    open func showsBaselineSeparator(_ shows: Bool) -> Self {
        showsBaselineSeparator = shows
        return self
    }
    
    /// A Boolean value that indicates whether users can modify the contents of the toolbar.
    open var allowsUserCustomization: Bool {
        get { toolbar.allowsUserCustomization }
        set { toolbar.allowsUserCustomization = newValue }
    }
    
    /// Sets the Boolean value that indicates whether users can modify the contents of the toolbar.
    @discardableResult
    open func allowsUserCustomization(_ allows: Bool) -> Self {
        allowsUserCustomization = allows
        return self
    }
    
    /// A Boolean value that indicates whether the toolbar can add items for Action extensions.
    open var allowsExtensionItems: Bool {
        get { toolbar.allowsExtensionItems }
        set { toolbar.allowsExtensionItems = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the toolbar can add items for Action extensions.
    @discardableResult
    open func allowsExtensionItems(_ allows: Bool) -> Self {
        allowsExtensionItems = allows
        return self
    }
    
    /**
     The items that are managed by the toolbar.
     
     It includes all items, regardless if they are currently displayed.
     
     To update the displayed items, use ``displayingItems``.
     */
    open var items: [ToolbarItem] = [] {
        didSet {
            items = items.uniqued()
            items.difference(to: oldValue).removed.forEach({
                if let index = displayingItems.firstIndex(of: $0) {
                    toolbar.removeItem(at: index)
                }
            })
            guard #available(macOS 13.0, *) else { return }
            centeredItems = Set(items.filter(\.isCentered))
        }
    }
    
    /// The currenlty displayed items in the toolbar, in order.
    open var displayingItems: [ToolbarItem] {
        get {
            items.filter({ item in toolbar.items.contains(where: {$0.itemIdentifier == item.identifier}) })
        }
        set {
            let newValue = newValue.uniqued()
            let diff = newValue.difference(from: displayingItems)
            items = items + newValue.filter({ !items.contains($0) })
            for val in diff {
                switch val {
                case .insert(offset: let index, element: let item, associatedWith: _):
                    toolbar.insertItem(withItemIdentifier: item.identifier, at: index)
                case .remove(offset: let index, element: _, associatedWith: _):
                    toolbar.removeItem(at: index)
                }
            }
        }
    }
    
    /// Sets the displayed items in the toolbar.
    @discardableResult
    open func displayingItems(_ items: [ToolbarItem]) -> Self {
        displayingItems = items
        return self
    }
    
    /// Sets the displayed items in the toolbar.
    @discardableResult
    open func displayingItems(@Builder items: () -> [ToolbarItem]) -> Self {
        displayingItems = items()
        return self
    }
    
    /// The currenlty visible items in the toolbar that aren't in the overflow menu.
    open var visibleItems: [ToolbarItem] {
        toolbar.visibleItems?.compactMap { item in self.items.first(where: { $0.item == item }) } ?? []
    }
    
    /**
     The toolbar’s currently selected item.
     
     This property is key-value observable (KVO).
     */
    @objc dynamic open var selectedItem: ToolbarItem? {
        get { items.first(where: { $0.identifier == toolbar.selectedItemIdentifier ?? "_none" }) }
        set {
            guard newValue != selectedItem else { return }
            if newValue == nil {
                toolbar.selectedItemIdentifier = nil
            } else if let newValue = newValue, displayingItems.contains(newValue) {
                toolbar.selectedItemIdentifier = newValue.identifier
            }
        }
    }
    
    /// The items displayed in the center in the toolbar.
    @available(macOS 13.0, *)
    internal var centeredItems: Set<ToolbarItem> {
        get { Set(toolbar.centeredItemIdentifiers.compactMap { identifier in items.first(where: { $0.identifier == identifier }) }) }
        set { toolbar.centeredItemIdentifiers = Set(newValue.map({$0.identifier})) }
    }
    
    /**
     Displays the toolbar’s customization palette and handles any user-initiated customizations.
     
     - Parameter sender: The control sending the message.
     */
    @objc open func displayCustomizationPalette(_ sender: Any? = nil) {
        toolbar.runCustomizationPalette(sender)
    }
    
    /// A Boolean value that indicates whether the toolbar’s customization palette is in use.
    open var customizationPaletteIsDisplaying: Bool {
        toolbar.customizationPaletteIsRunning
    }
    
    /// A Boolean value that indicates whether the toolbar autosaves its configuration.
    open var autosavesConfiguration: Bool {
        get { toolbar.autosavesConfiguration }
        set { toolbar.autosavesConfiguration = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the toolbar autosaves its configuration.
    @discardableResult
    open func autosavesConfiguration(_ autosaves: Bool) -> Self {
        autosavesConfiguration = autosaves
        return self
    }
    
    /**
     A dictionary containing the current configuration details for the toolbar.
     
     Use this property to retrieve the toolbar’s configuration details so you can save them to disk yourself. The dictionary in this property contains the identifiers of the current toolbar items and the values of important properties such as ``displayMode`` and ``isVisible``.
     */
    open var configuration: [String : Any] {
        toolbar.configuration
    }
    
    /**
     Specifies the new configuration details for the toolbar.
     
     If you implement your own autosave mechanism, call this method to restore the configuration of your toolbar to a previously saved state. The dictionary you read from disk must match the format of the dictionary in the ``configuration`` property.
     
     - Parameter configuration:  A dictionary with the toolbar configuration details. The toolbar ignores any keys it doesn’t recognize. Typically, you save the original configuration dictionary from the ``configuration`` property to disk and recreate it before passing it in this parameter.
     */
    open func setConfiguration(_ configuration: [String : Any]) {
        toolbar.setConfiguration(configuration)
    }
    
    /// Toolbar item handlers.
    open var itemHandlers = ItemHandlers()
    
    /// Toolbar item handlers.
    public struct ItemHandlers {
        /// Handler that gets called when the selected item changed.
        public var selectionChanged: ((_ selectedItem: ToolbarItem?) -> Void)?
        /// Handler that determines whether an item can be inserted.
        public var canInsert: ((_ item: ToolbarItem, _ index: Int) -> Bool)?
        /// Handler that gets called when a item will be added.
        public var willAdd: ((_ item: ToolbarItem) -> Void)?
        /// Handler that gets called when a item did remove.
        public var didRemove: ((_ item: ToolbarItem) -> Void)?
    }
    
    class Delegate: NSObject, NSToolbarDelegate {
        weak var toolbar: Toolbar?
        
        var items: [ToolbarItem] {
            toolbar?.items ?? []
        }
        
        func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            items.filter(\.isDefault).ids
        }
        
        func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
            Set(items.filter(\.isImmovable).ids)
        }
        
        func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            items.ids
        }
        
        func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            items.filter(\.isSelectable).ids
        }
        
        func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
            items[id: itemIdentifier]?.item
        }
        
        func toolbarWillAddItem(_ notification: Notification) {
            guard let willAdd = toolbar?.itemHandlers.willAdd, let toolbarItem = notification.userInfo?["item"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
            willAdd(item)
        }
        
        func toolbarDidRemoveItem(_ notification: Notification) {
            guard let didRemove = toolbar?.itemHandlers.didRemove, let toolbarItem = notification.userInfo?["item"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
            didRemove(item)
        }
        
        func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
            guard let canInsert = toolbar?.itemHandlers.canInsert, let item = items.first(where: { $0.identifier == itemIdentifier }) else { return true }
            return canInsert(item, index)
        }
        
        init(for toolbar: Toolbar) {
            super.init()
            self.toolbar = toolbar
            toolbar.toolbar.delegate = self
        }
    }
    
    private class MangedToolbar: NSToolbar {
        var toolbar: Toolbar?
        
        init(for toolbar: Toolbar) {
            super.init(identifier: toolbar.identifier)
            self.toolbar = toolbar
        }
        
        override var selectedItemIdentifier: NSToolbarItem.Identifier? {
            willSet {
                toolbar?.willChangeValue(for: \.selectedItem) }
            didSet {
                toolbar?.didChangeValue(for: \.selectedItem)
                guard oldValue != selectedItemIdentifier else { return }
                toolbar?.itemHandlers.selectionChanged?(toolbar?.selectedItem)
            }
        }
    }

    /// A function builder type that produces an array of toolbar items.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ block: [ToolbarItem]...) -> [ToolbarItem] {
            block.flatMap { $0 }
        }
        
        public static func buildOptional(_ item: ToolbarItem?) -> [ToolbarItem] {
            if let item = item {
                return [item]
            }
            return []
        }
        
        public static func buildOptional(_ item: [ToolbarItem]?) -> [ToolbarItem] {
            item ?? []
        }
        
        public static func buildEither(first: [ToolbarItem]?) -> [ToolbarItem] {
            first ?? []
        }
        
        public static func buildEither(second: [ToolbarItem]?) -> [ToolbarItem] {
            second ?? []
        }
        
        public static func buildArray(_ components: [[ToolbarItem]]) -> [ToolbarItem] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expr: [ToolbarItem]?) -> [ToolbarItem] {
            expr ?? []
        }
        
        public static func buildExpression(_ expr: ToolbarItem?) -> [ToolbarItem] {
            expr.map { [$0] } ?? []
        }
    }
}

extension Toolbar {
    private static var automaticIdentifiers: [String: Int] = [:]
    private static let automaticIdentifierLock = DispatchQueue(label: "FZUIKit.automaticIdentifierLock")
    
    static func automaticIdentifier(for name: String) -> NSToolbarItem.Identifier {
        automaticIdentifierLock.sync {
            let count = automaticIdentifiers[name, default: -1] + 1
            automaticIdentifiers[name] = count
            return NSToolbarItem.Identifier("\(name) \(count)")
        }
    }
}

extension NSToolbar {
    /// Returns the ``Toolbar`` representation of toolbar if it is managed by it.
    public var managed: Toolbar? {
        (delegate as? Toolbar.Delegate)?.toolbar
    }
}

extension NSWindow {
    /// Returns the ``Toolbar`` representation of the window’s toolbar if it is managed by it.
    public var managedToolbar: Toolbar? {
        toolbar?.managed
    }
}

#endif
