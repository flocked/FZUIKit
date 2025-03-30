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
        
        private var _items: [ToolbarItem] = []
        private var selectedItemObservation: KeyValueObservation?
        private lazy var delegate = Delegate(self)
        private lazy var toolbar: NSToolbar = {
            let toolbar = NSToolbar(identifier: identifier)
            toolbar.delegate = delegate
            return toolbar
        }()
        
        /**
         Creates a newly toolbar with the specified identifier.

         - Parameters:
            - identifier: A string to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
            - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
            - items: An array of toolbar items.

         - Returns: The initialized `Toolbar` object.
         */
        public init(_ identifier: NSToolbar.Identifier? = nil, allowsUserCustomization: Bool = true,
            items: [ToolbarItem]) {
            self.identifier = identifier ?? UUID().uuidString
            _items = items
            super.init()
            if #available(macOS 13.0, *) {
                toolbar.centeredItemIdentifiers = Set(items.filter(\.isCentered).ids)
            }
            self.allowsUserCustomization = allowsUserCustomization
            if allowsUserCustomization {
                autosavesConfiguration = true
            }
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
                oldValue?.toolbar = nil
                if let attachedWindow = attachedWindow {
                    attachedWindow.toolbar = toolbar
                }
            }
        }

        @discardableResult
        /// The window of the toolbar.
        public func attachedWindow(_ window: NSWindow?) -> Self {
            attachedWindow = window
            return self
        }

        /// A Boolean value that indicates whether the toolbar is visible.
        public var isVisible: Bool {
            get { toolbar.isVisible }
            set { toolbar.isVisible = newValue }
        }
        
        /// A Boolean value that indicates whether the toolbar is visible.
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
        /// The style that determines the appearance and location of the toolbar in relation to the title bar.
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
        
        /// A value that indicates whether the toolbar displays items using a name, icon, or combination of elements.
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
        
        /// A Boolean value that indicates whether the toolbar shows the separator between the toolbar and the main window contents.
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
        
        /// A Boolean value that indicates whether users can modify the contents of the toolbar.
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
        
        /// A Boolean value that indicates whether the toolbar can add items for Action extensions.
        @discardableResult
        public func allowsExtensionItems(_ allows: Bool) -> Self {
            allowsExtensionItems = allows
            return self
        }

        /// An array containing the toolbar’s current items, in order.
        public var items: [ToolbarItem] {
            get { toolbar.items.compactMap { item in self._items.first(where: { $0.item == item }) } }
        }

        /// An array containing the toolbar’s currently visible items.
        public var visibleItems: [ToolbarItem]? {
            toolbar.visibleItems?.compactMap { item in self._items.first(where: { $0.item == item }) }
        }

        @available(macOS 13.0, *)
        /// The set of custom items to display in the center of the toolbar.
        public var centeredItems: [ToolbarItem] {
            toolbar.centeredItemIdentifiers.compactMap { identifier in self._items.first(where: { $0.identifier == identifier }) }
        }

        /*
        /// The currently selected item.
        public var selectedItem: ToolbarItem? {
            get {
                guard let selectedItemIdentifier = toolbar.selectedItemIdentifier else { return nil }
                return _items.first(where: { $0.identifier == selectedItemIdentifier })
            }
            set {
                guard newValue != selectedItem else { return }
                if let newValue = newValue {
                    toolbar.selectedItemIdentifier = newValue.identifier
                    if !_items.contains(newValue) {
                        _items.append(<#T##newElement: ToolbarItem##ToolbarItem#>)
                    }
                }
            }
        }
        */
        /*
        var _selectedItem: ToolbarItem? {
            guard let selectedItemIdentifier = toolbar.selectedItemIdentifier else { return nil }
            return _items.first(where: { $0.identifier == selectedItemIdentifier })
        }
        */

        /// A Boolean value that indicates whether the toolbar autosaves its configuration.
        public var autosavesConfiguration: Bool {
            get { toolbar.autosavesConfiguration }
            set { toolbar.autosavesConfiguration = newValue }
        }
        
        /// A Boolean value that indicates whether the toolbar autosaves its configuration.
        @discardableResult
        public func autosavesConfiguration(_ autosaves: Bool) -> Self {
            autosavesConfiguration = autosaves
            return self
        }

        /// Displays the toolbar’s customization palette and handles any user-initiated customizations.
        public func runCustomizationPalette(_ sender: Any?) {
            toolbar.runCustomizationPalette(sender)
        }

        /// A Boolean value that indicates whether the toolbar’s customization palette is in use.
        public var customizationPaletteIsRunning: Bool { toolbar.customizationPaletteIsRunning }

        /// Toolbar item handlers.
        public var itemHandlers = ItemHandlers() {
            didSet { setupSelectedItemObserver() }
        }

        /**
         Inserts an item into the toolbar at the specified index.

         Any changes you make to the toolbar appear in all `Toolbar` objects with the same identifier.

         - Parameters:
            - item: The toolbar item to insert.
            - index: The index at which to insert the item.

         */
        public func insertItem(_ item: ToolbarItem, at index: Int) {
            toolbar.insertItem(withItemIdentifier: item.identifier, at: index)
        }

        /**
         Removes the item at the specified index in the toolbar.

         Any changes you make to the toolbar appear in all `Toolbar` objects with the same identifier.

         - Parameter index: The index of the item to remove.
         */
        public func removeItem(at index: Int) {
            toolbar.removeItem(at: index)
        }

        /// Toolbar item handlers.
        public struct ItemHandlers {
            /// Handler that gets called when the selected item changed.
            public var selectionChanged: ((ToolbarItem?) -> Void)?
            /// Handler that determines whether an item can be inserted.
            public var canInsert: ((_ item: ToolbarItem, _ index: Int) -> Bool)?
            /// Handler that gets called when a item will be added.
            public var willAdd: ((_ item: ToolbarItem) -> Void)?
            /// Handler that gets called when a item did remove.
            public var didRemove: ((_ item: ToolbarItem) -> Void)?
        }

        func setupSelectedItemObserver() {
            if itemHandlers.selectionChanged == nil {
                selectedItemObservation = nil
            } else if selectedItemObservation == nil {
                selectedItemObservation = observeChanges(for: \.toolbar.selectedItemIdentifier) { [weak self] _, identifier in
                    guard let self = self else { return }
                    if let identifier = identifier {
                        guard let item = self._items[id: identifier] else { return }
                        self.itemHandlers.selectionChanged?(item)
                    } else {
                        self.itemHandlers.selectionChanged?(nil)
                    }
                }
            }
        }
        
        var itemsAlt: [ToolbarItem] {
            get { _items }
            set {
                let diff = _items.difference(from: newValue)
                for val in diff {
                    switch val {
                    case .insert(offset: let index, element: let item, associatedWith: _):
                        self._items.insert(item, at: index)
                        self.insertItem(item, at: index)
                    case .remove(offset: let index, element: _, associatedWith: _):
                        self._items.remove(at: index)
                        self.removeItem(at: index)
                    }
                }
            }
        }
    }

    extension Toolbar {
        class Delegate: NSObject, NSToolbarDelegate {
            weak var toolbar: Toolbar?
            var items: [ToolbarItem] {
                toolbar?._items ?? []
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
                items[id: itemIdentifier]?.item
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
    }

extension NSToolbar {
    /// Returns the ``Toolbar`` representation of the toolbar if it is managed by it.
    public var managed: Toolbar? {
        (delegate as? Toolbar.Delegate)?.toolbar
    }
}

#endif
