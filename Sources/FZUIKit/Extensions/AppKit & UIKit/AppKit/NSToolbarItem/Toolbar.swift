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

public class Toolbar: NSObject {
    private let identifier: NSToolbar.Identifier

    internal lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: self.identifier)
        toolbar.delegate = self
        return toolbar
    }()

    public var onItemSelectionChange: ((ToolbarItem?) -> Void)? = nil
    public var canInsertItemHandler: ((_ item: ToolbarItem, _ index: Int) -> Bool)? = nil
    public var willAddItemHandler: ((_ item: ToolbarItem) -> Void)? = nil
    public var didRemoveItemHandler: ((_ item: ToolbarItem) -> Void)? = nil

    public var isVisible: Bool {
        get { toolbar.isVisible }
        set { toolbar.isVisible = newValue }
    }

    public var displayMode: NSToolbar.DisplayMode {
        get { toolbar.displayMode }
        set { toolbar.displayMode = newValue }
    }

    public var showsBaselineSeparator: Bool {
        get { toolbar.showsBaselineSeparator }
        set { toolbar.showsBaselineSeparator = newValue }
    }

    public var allowsUserCustomization: Bool {
        get { toolbar.allowsUserCustomization }
        set { toolbar.allowsUserCustomization = newValue }
    }

    public var allowsExtensionItems: Bool {
        get { toolbar.allowsExtensionItems }
        set { toolbar.allowsExtensionItems = newValue }
    }

    public var autosavesConfiguration: Bool {
        get { toolbar.autosavesConfiguration }
        set { toolbar.autosavesConfiguration = newValue }
    }

    public func runCustomizationPalette(_ sender: Any?) {
        toolbar.runCustomizationPalette(sender)
    }

    public var customizationPaletteIsRunning: Bool { toolbar.customizationPaletteIsRunning }

    public var visibleItems: [NSToolbarItem]? { toolbar.visibleItems }

    public var attachedWindow: NSWindow? {
        didSet {
            if let attachedWindow = attachedWindow {
                attachedWindow.toolbar = toolbar
            }
        }
    }

    private var items: [ToolbarItem] = []

    internal var toolbarItemSelectionObserver: NSKeyValueObservation? = nil
    internal func setupToolbarItemSelectionObserver() {
        if toolbarItemSelectionObserver == nil {
            toolbarItemSelectionObserver = observeChange(\.toolbar.selectedItemIdentifier) { [weak self] _,_, identifier in
                guard let self = self else { return }
                if let identifier = identifier {
                    guard let item = self.items.first(where: { $0.identifier == identifier }) else { return }
                    self.onItemSelectionChange?(item)
                } else {
                    self.onItemSelectionChange?(nil)
                }
            }
        }
    }

    public init(
        _ identifier: NSToolbar.Identifier,
        allowsUserCustomization: Bool = false,
        items: [ToolbarItem]
    ) {
        self.identifier = identifier
        self.items = items
        super.init()
        toolbar.allowsUserCustomization = allowsUserCustomization
        if allowsUserCustomization {
            toolbar.autosavesConfiguration = true
        }
    }
}

extension Toolbar: NSToolbarDelegate {
    public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        Swift.print("toolbarDefaultItemIdentifiers",items.filter { $0.item.isDefaultItem }.count )

        return items.filter { $0.item.isDefaultItem }
            .map { $0.identifier }
    }

    public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
        return Set(items.filter { $0.item.isImmovableItem }
            .map { $0.identifier })
    }

    public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        var items = items.map { $0.identifier }
        Swift.print("toolbarAllowedItemIdentifiers", self.items.count + 2 )

        items.append(contentsOf: [NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier.space])
        return items.uniqued()
    }

    public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return items.filter { $0.item._isSelectable }.map { $0.identifier }
    }

    public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        Swift.print("itemForItemIdentifier", items.first { $0.identifier == itemIdentifier }?.item ?? "")

        return items.first { $0.identifier == itemIdentifier }?.item
    }

    public func toolbarWillAddItem(_ notification: Notification) {
        guard let willAdd = willAddItemHandler else { return }
        guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
        willAdd(item)
    }

    public func toolbarDidRemoveItem(_ notification: Notification) {
        guard let didRemove = didRemoveItemHandler else { return }
        guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = items.first(where: { $0.item == toolbarItem }) else { return }
        didRemove(item)
    }

    public func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
        guard let canInsert = canInsertItemHandler else { return true }
        guard let item = items.first(where: { $0.identifier == itemIdentifier }) else { return true }
        return canInsert(item, index)
    }
}

public class TToolbar: NSToolbar {
    public struct ItemHandler {
        var onSelectionChange: ((NSToolbarItem?) -> Void)? = nil
        var canInsert: ((_ item: NSToolbarItem, _ index: Int) -> Bool)? = nil
        var willAdd: ((_ item: NSToolbarItem) -> Void)? = nil
        var didRemove: ((_ item: NSToolbarItem) -> Void)? = nil
    }

    public var itemHandler: ItemHandler = .init()
    private var _items: [NSToolbarItem] = []

    internal var _toolbarItemSelectionObserver: NSKeyValueObservation? = nil
    internal func _setupToolbarItemSelectionObserver() {
        if _toolbarItemSelectionObserver == nil {
            _toolbarItemSelectionObserver = observeChange(\.selectedItemIdentifier) { [weak self] _,_, identifier in
                guard let self = self else { return }
                if let identifier = identifier  {
                    guard let item = self._items.first(where: { $0.itemIdentifier == identifier }) else { return }
                    self.itemHandler.onSelectionChange?(item)
                } else {
                    self.itemHandler.onSelectionChange?(nil)
                }
            }
        }
    }

    public init(
        _ identifier: NSToolbar.Identifier,
        allowsUserCustomization _: Bool = false,
        items: [NSToolbarItem]
    ) {
        super.init(identifier: identifier)
        _items = items
        delegate = self
    }

    public convenience init(
        _ identifier: NSToolbar.Identifier,
        allowsUserCustomization: Bool = false,
        @NSToolbar.Builder builder: () -> [NSToolbarItem]
    ) {
        self.init(identifier, allowsUserCustomization: allowsUserCustomization, items: builder())
    }
}

extension TToolbar: NSToolbarDelegate {
    public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return _items.filter { $0.isDefaultItem }
            .map { $0.itemIdentifier }
    }

    public func toolbarImmovableItemIdentifiers(_: NSToolbar) -> Set<NSToolbarItem.Identifier> {
        return Set(_items.filter { $0.isImmovableItem }
            .map { $0.itemIdentifier })
    }

    public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        var items = _items.map { $0.itemIdentifier }
        items.append(contentsOf: [NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier.space])
        return items.uniqued()
    }

    public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return _items.filter { $0._isSelectable }.map { $0.itemIdentifier }
    }

    public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        let toolbarItem = _items.first { item -> Bool in
            item.itemIdentifier == itemIdentifier
        }
        return toolbarItem
    }

    public func toolbarWillAddItem(_ notification: Notification) {
        guard let willAdd = itemHandler.willAdd else { return }
        guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = _items.first(where: { $0 == toolbarItem }) else { return }
        willAdd(item)
    }

    public func toolbarDidRemoveItem(_ notification: Notification) {
        guard let didRemove = itemHandler.didRemove else { return }
        guard let toolbarItem = notification.userInfo?["itemKey"] as? NSToolbarItem, let item = _items.first(where: { $0 == toolbarItem }) else { return }
        didRemove(item)
    }

    public func toolbar(_: NSToolbar, itemIdentifier: NSToolbarItem.Identifier, canBeInsertedAt index: Int) -> Bool {
        guard let canInsert = itemHandler.canInsert else { return true }
        guard let item = _items.first(where: { $0.itemIdentifier == itemIdentifier }) else { return true }
        return canInsert(item, index)
    }
}
#endif
