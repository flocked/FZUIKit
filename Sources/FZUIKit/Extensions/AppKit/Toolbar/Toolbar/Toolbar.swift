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
    public class Toolbar: NSObject {
        
        /// The identifier of the toolbar.
        public let identifier: NSToolbar.Identifier
        
        private lazy var delegate = Delegate(self)
        let toolbar: NotifyingToolbar
        
        /**
         Creates a newly toolbar with the specified identifier.

         - Parameters:
            - identifier: A string to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
            - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
            - items: An array of toolbar items.

         - Returns: The initialized `Toolbar` object.
         */
        public init(_ identifier: NSToolbar.Identifier? = nil, allowsUserCustomization: Bool = true, items: [ToolbarItem]) {
            self.identifier = identifier ?? Self.automaticIdentifier(for: "\(type(of: self))").rawValue
            self.items = items
            toolbar = NotifyingToolbar(identifier: self.identifier)
            super.init()
            toolbar.delegate = delegate
            toolbar.manager = self
            self.allowsUserCustomization = allowsUserCustomization
            autosavesConfiguration = allowsUserCustomization
            if #available(macOS 13.0, *) {
                centeredItems = Set(items.filter(\.isCentered))
            }
            selectedItem = items.first
        }

        /**
         Creates a newly toolbar with the specified identifier.

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
            didSet {
                guard oldValue != attachedWindow else { return }
                oldValue?.toolbar = nil
                attachedWindow?.toolbar = toolbar
            }
        }

        @discardableResult
        /// Sets the window of the toolbar.
        public func attachedWindow(_ window: NSWindow?) -> Self {
            attachedWindow = window
            return self
        }

        /// A Boolean value that indicates whether the toolbar is visible.
        public var isVisible: Bool {
            get { toolbar.isVisible }
            set { toolbar.isVisible = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar is visible.
        @discardableResult
        public func isVisible(_ isVisible: Bool) -> Self {
            self.isVisible = isVisible
            return self
        }

        @available(macOS 11.0, *)
        /// The style that determines the appearance and location of the toolbar in relation to the title bar.
        public var style: NSWindow.ToolbarStyle? {
            get { attachedWindow?.toolbarStyle }
            set {
                if let newValue = newValue {
                    attachedWindow?.toolbarStyle = newValue
                }
            }
        }

        @available(macOS 11.0, *)
        /// Sets the style that determines the appearance and location of the toolbar in relation to the title bar.
        @discardableResult
        public func style(_ style: NSWindow.ToolbarStyle) -> Self {
            self.style = style
            return self
        }

        /// A value that indicates whether the toolbar displays items using a name, icon, or combination of elements.
        public var displayMode: NSToolbar.DisplayMode {
            get { toolbar.displayMode }
            set { toolbar.displayMode = newValue }
        }
        
        /// Sets the value that indicates whether the toolbar displays items using a name, icon, or combination of elements.
        @discardableResult
        public func displayMode(_ mode: NSToolbar.DisplayMode) -> Self {
            displayMode = mode
            return self
        }

        /// A Boolean value that indicates whether the toolbar shows the separator between the toolbar and the main window contents.
        public var showsBaselineSeparator: Bool {
            get { toolbar.showsBaselineSeparator }
            set { toolbar.showsBaselineSeparator = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar shows the separator between the toolbar and the main window contents.
        @discardableResult
        public func showsBaselineSeparator(_ shows: Bool) -> Self {
            showsBaselineSeparator = shows
            return self
        }

        /// A Boolean value that indicates whether users can modify the contents of the toolbar.
        public var allowsUserCustomization: Bool {
            get { toolbar.allowsUserCustomization }
            set { toolbar.allowsUserCustomization = newValue }
        }
        
        /// Sets the Boolean value that indicates whether users can modify the contents of the toolbar.
        @discardableResult
        public func allowsUserCustomization(_ allows: Bool) -> Self {
            allowsUserCustomization = allows
            return self
        }

        /// A Boolean value that indicates whether the toolbar can add items for Action extensions.
        public var allowsExtensionItems: Bool {
            get { toolbar.allowsExtensionItems }
            set { toolbar.allowsExtensionItems = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar can add items for Action extensions.
        @discardableResult
        public func allowsExtensionItems(_ allows: Bool) -> Self {
            allowsExtensionItems = allows
            return self
        }
        
        /**
         The items that are managed by the toolbar.
         
         It includes all items, regardless if they are currently displayed.
         
         To update the displayed items, use ``displayedItems``.
         */
        public var items: [ToolbarItem] = [] {
            didSet {
                items = items.uniqued()
                items.difference(to: oldValue).removed.forEach({
                    if let index = displayedItems.firstIndex(of: $0) {
                        toolbar.removeItem(at: index)
                    }
                })
                guard #available(macOS 13.0, *) else { return }
                centeredItems = Set(items.filter(\.isCentered))
            }
        }
        
        /// The currenlty displayed items in the toolbar, in order.
        public var displayedItems: [ToolbarItem] {
            get {
                items.filter({ item in toolbar.items.contains(where: {$0.itemIdentifier == item.identifier}) })
            }
            set {
                let newValue = newValue.uniqued()
                let diff = newValue.difference(from: displayedItems)
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
        public func displayedItems(_ items: [ToolbarItem]) -> Self {
            displayedItems = items
            return self
        }
        
        /// Sets the displayed items in the toolbar.
        @discardableResult
        public func displayedItems(@Builder items: () -> [ToolbarItem]) -> Self {
            displayedItems = items()
            return self
        }
        
        /// The currenlty visible items in the toolbar that aren't in the overflow menu.
        public var visibleItems: [ToolbarItem] {
            toolbar.visibleItems?.compactMap { item in self.items.first(where: { $0.item == item }) } ?? []
        }
        
        /**
         The toolbar’s currently selected item.
         
         This property is key-value observable (KVO).
         */
        @objc dynamic public var selectedItem: ToolbarItem? {
            get {
                guard let selectedID = toolbar.selectedItemIdentifier else { return nil }
                return items.first(where: { $0.identifier == selectedID })
            }
            set {
                guard newValue != selectedItem else { return }
                if newValue == nil {
                    toolbar.selectedItemIdentifier = nil
                } else if let newValue = newValue, displayedItems.contains(newValue) {
                    toolbar.selectedItemIdentifier = newValue.identifier
                }
            }
        }
        
        @available(macOS 13.0, *)
        /// The items displayed in the center in the toolbar.
        internal var centeredItems: Set<ToolbarItem> {
            get { Set(toolbar.centeredItemIdentifiers.compactMap { identifier in items.first(where: { $0.identifier == identifier }) }) }
            set { toolbar.centeredItemIdentifiers = Set(newValue.map({$0.identifier})) }
        }

        /// Displays the toolbar’s customization palette and handles any user-initiated customizations.
        @objc public func runCustomizationPalette(_ sender: Any? = nil) {
            toolbar.runCustomizationPalette(sender)
        }

        /// A Boolean value that indicates whether the toolbar’s customization palette is in use.
        public var customizationPaletteIsRunning: Bool { toolbar.customizationPaletteIsRunning }
        
        /// A Boolean value that indicates whether the toolbar autosaves its configuration.
        public var autosavesConfiguration: Bool {
            get { toolbar.autosavesConfiguration }
            set { toolbar.autosavesConfiguration = newValue }
        }
        
        /// Sets the Boolean value that indicates whether the toolbar autosaves its configuration.
        @discardableResult
        public func autosavesConfiguration(_ autosaves: Bool) -> Self {
            autosavesConfiguration = autosaves
            return self
        }
        
        /**
         A dictionary containing the current configuration details for the toolbar.
         
         Use this property to retrieve the toolbar’s configuration details so you can save them to disk yourself. The dictionary in this property contains the identifiers of the current toolbar items and the values of important properties such as ``displayMode`` and ``isVisible``.
         */
        public var configuration: [String : Any] { toolbar.configuration }
        
        /**
         Specifies the new configuration details for the toolbar.
         
         If you implement your own autosave mechanism, call this method to restore the configuration of your toolbar to a previously saved state. The dictionary you read from disk must match the format of the dictionary in the ``configuration`` property.
                  
         - Parameter configuration:  A dictionary with the toolbar configuration details. The toolbar ignores any keys it doesn’t recognize. Typically, you save the original configuration dictionary from the ``configuration`` property to disk and recreate it before passing it in this parameter.
         */
        public func setConfiguration(_ configuration: [String : Any]) {
            toolbar.setConfiguration(configuration)
        }

        /// Toolbar item handlers.
        public var itemHandlers = ItemHandlers()

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
            
            init(_ toolbar: Toolbar) {
                self.toolbar = toolbar
            }
            
            public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                items.filter(\.isDefault).ids
            }

            public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
                Set(items.filter(\.isImmovable).ids)
            }

            public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                items.ids
            }

            public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                items.filter(\.isSelectable).ids
            }

            public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
                return items[id: itemIdentifier]?.item
            }

            public func toolbarWillAddItem(_ notification: Notification) {
                guard let willAdd = toolbar?.itemHandlers.willAdd else { return }
                guard let toolbarItem = notification.userInfo?["item"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
                willAdd(item)
            }

            public func toolbarDidRemoveItem(_ notification: Notification) {
                guard let didRemove = toolbar?.itemHandlers.didRemove else { return }
                guard let toolbarItem = notification.userInfo?["item"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
                didRemove(item)
            }

            public func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
                guard let canInsert = toolbar?.itemHandlers.canInsert else { return true }
                guard let item = items.first(where: { $0.identifier == itemIdentifier }) else { return true }
                return canInsert(item, index)
            }
        }
        
        class NotifyingToolbar: NSToolbar {
            weak var manager: Toolbar?
            
            override var selectedItemIdentifier: NSToolbarItem.Identifier? {
                willSet {
                    manager?.willChangeValue(for: \.selectedItem) }
                didSet {
                    manager?.didChangeValue(for: \.selectedItem)
                    guard oldValue != selectedItemIdentifier else { return }
                    manager?.itemHandlers.selectionChanged?(manager?.selectedItem)
                }
            }
        }
    }

extension Toolbar {
    private static var automaticIdentifiers = [String: Int]()
    private static let lock = DispatchQueue(label: "com.toolbaritem.lock")

    static func automaticIdentifier(for name: String) -> NSToolbarItem.Identifier {
        return lock.sync {
            let count = automaticIdentifiers[name, default: -1] + 1
            automaticIdentifiers[name] = count
            return NSToolbarItem.Identifier("\(name) \(count)")
        }
    }
}

extension NSToolbar {
    /// Returns the ``Toolbar`` representation of the toolbar if it is managed by it.
    public var managed: Toolbar? {
        (delegate as? Toolbar.Delegate)?.toolbar
    }
}

#endif
