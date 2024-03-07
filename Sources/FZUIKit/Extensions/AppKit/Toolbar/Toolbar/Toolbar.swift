//
//  Toolbar.swift
//
//  Adpted from dagronf/DSFToolbar
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
    import AppKit

    /// `Toolbar` configurates a window toolbar and it's items.
    public class Toolbar: NSObject {
        /**
         Creates a newly toolbar with the specified identifier.

         - Parameters:
            - identifier: A string used by the class to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
            - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
            - items: An array of toolbar items.

         - Returns: The initialized `Toolbar` object.
         */
        public init(
            _ identifier: NSToolbar.Identifier? = nil,
            allowsUserCustomization: Bool = true,
            items: [ToolbarItem]) {
            self.identifier = identifier ?? UUID().uuidString
            _items = items
            super.init()
            //   self.delegate = DelegateProxy(toolbar: self)
            toolbar.allowsUserCustomization = allowsUserCustomization
            if allowsUserCustomization {
                toolbar.autosavesConfiguration = true
            }
        }

        //  internal var delegate: DelegateProxy!

        /**
         Creates a newly toolbar with the specified identifier.

         - Parameters:
            - identifier: A string used by the class to identify the kind of the toolbar. The default value is `nil`, which provides a unique identifier.
            - allowsUserCustomization: A Boolean value that indicates whether users can modify the contents of the toolbar.
            - items: The toolbar items.

         - Returns: The initialized `Toolbar` object.
         */
        public convenience init(
            _ identifier: NSToolbar.Identifier? = nil,
            allowsUserCustomization: Bool = true,
            @Builder items: () -> [ToolbarItem]) {
            self.init(identifier, allowsUserCustomization: allowsUserCustomization, items: items())
        }

        /// The value you use to identify the toolbar in your app.
        public let identifier: NSToolbar.Identifier

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
            toolbar.items.compactMap { item in self._items.first(where: { $0.item == item }) }
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

        /// The currently selected item.
        public var selectedItem: ToolbarItem? {
            if let selectedItemIdentifier = toolbar.selectedItemIdentifier {
                return _items.first(where: { $0.identifier == selectedItemIdentifier })
            }
            return nil
        }

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
            didSet { }
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

        private var _items: [ToolbarItem] = []

        lazy var toolbar: NSToolbar = {
            let toolbar = NSToolbar(identifier: self.identifier)
            toolbar.delegate = self
            return toolbar
        }()

        var toolbarItemSelectionObserver: NSKeyValueObservation?

        func setupToolbarItemSelectionObserver() {
            if itemHandlers.selectionChanged != nil {
                if toolbarItemSelectionObserver == nil {
                    toolbarItemSelectionObserver = observeChanges(for: \.toolbar.selectedItemIdentifier) { [weak self] _, identifier in
                        guard let self = self else { return }
                        if let identifier = identifier {
                            guard let item = self._items.first(where: { $0.identifier == identifier }) else { return }
                            self.itemHandlers.selectionChanged?(item)
                        } else {
                            self.itemHandlers.selectionChanged?(nil)
                        }
                    }
                }
            } else {
                toolbarItemSelectionObserver = nil
            }
        }
    }

    extension Toolbar: NSToolbarDelegate {
        public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            _items.filter(\.isDefault)
                .map(\.identifier)
        }

        public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
            Set(_items.filter(\.isImmovableItem)
                .map(\.identifier))
        }

        public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            _items.map(\.identifier)
        }

        public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            _items.filter(\.isSelectable).map(\.identifier)
        }

        public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
            _items.first { $0.identifier == itemIdentifier }?.item
        }

        public func toolbarWillAddItem(_ notification: Notification) {
            guard let willAdd = itemHandlers.willAdd else { return }
            guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = _items.first(where: { $0.item == toolbarItem }) else { return }
            willAdd(item)
        }

        public func toolbarDidRemoveItem(_ notification: Notification) {
            guard let didRemove = itemHandlers.didRemove else { return }
            guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = _items.first(where: { $0.item == toolbarItem }) else { return }
            didRemove(item)
        }

        public func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
            guard let canInsert = itemHandlers.canInsert else { return true }
            guard let item = _items.first(where: { $0.identifier == itemIdentifier }) else { return true }
            return canInsert(item, index)
        }
    }

    /*
     internal extension Toolbar {
         class DelegateProxy: NSObject, NSToolbarDelegate {
             weak var toolbar: Toolbar!
             init(toolbar: Toolbar!) {
                 self.toolbar = toolbar
             }

             public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                 return toolbar._items.filter { $0.isDefault }
                     .map { $0.identifier }
             }

             public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
                 return Set(self.toolbar._items.filter { $0.isImmovableItem }
                     .map { $0.identifier })
             }

             public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                 return self.toolbar._items.map { $0.identifier }
             }

             public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
                 return self.toolbar._items.filter { $0.isSelectable }.map { $0.identifier }
             }

             public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
                 return self.toolbar._items.first { $0.identifier == itemIdentifier }?.item
             }

             public func toolbarWillAddItem(_ notification: Notification) {
                 guard let willAdd = self.toolbar.itemHandlers.willAdd else { return }
                 guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = self.toolbar._items.first(where: { $0.item == toolbarItem }) else { return }
                 willAdd(item)
             }

             public func toolbarDidRemoveItem(_ notification: Notification) {
                 guard let didRemove = self.toolbar.itemHandlers.didRemove else { return }
                 guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = self.toolbar._items.first(where: { $0.item == toolbarItem }) else { return }
                 didRemove(item)
             }

             public func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
                 guard let canInsert = self.toolbar.itemHandlers.canInsert else { return true }
                 guard let item = self.toolbar._items.first(where: { $0.identifier == itemIdentifier }) else { return true }
                 return canInsert(item, index)
             }
         }
     }
     */

#endif
