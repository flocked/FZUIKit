//
//  ToolbarItem.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    /// A toolbar item that can be used with ``Toolbar``.
    public class ToolbarItem: NSObject {
        /// The identifier of the toolbar item.
        public let identifier: NSToolbarItem.Identifier

        /// A Boolean value that indicates whether the item is available on the 'default' toolbar presented to the user.
        public var isDefault = true
        
        /// A Boolean value that indicates whether the item can be selected.
        public var isSelectable = false
        
        /// A Boolean value that indicates whether the item can't be removed or rearranged by the user.
        public var isImmovable = false
        
        /// A Boolean value that indicates whether the item displays in the center of the toolbar.
        public var isCentered = false
        
        public var isHidden = false {
            didSet {
                guard let toolbar = toolbar else { return }
                if isHidden, toolbar.items.contains(self) {
                    
                } else if !isHidden, !toolbar.items.contains(self) {
                    
                }
            }
        }
        
        /*
        /// A Boolean value that indicates whether the item is selected.
        var isSelected: Bool {
            get { toolbar?.selectedItem == self }
            set {
                guard isSelectable, let toolbar = toolbar, newValue != isSelected else { return }
                if newValue {
                    toolbar.selectedItem = self
                } else if toolbar.selectedItemIdentifier == identifier {
                    toolbar.selectedItemIdentifier = nil
                }
            }
        }
        */
      
        lazy var rootItem = NSToolbarItem(itemIdentifier: self.identifier)
        var item: NSToolbarItem {
            rootItem
        }

        /// Creates a toolbar item.
        public init(_ identifier: NSToolbarItem.Identifier? = nil) {
            self.identifier = identifier ?? .random
        }
    }

    public extension ToolbarItem {
        /**
         A Boolean value that indicates whether the item is currently visible in the toolbar, and not in the overflow menu.

         The value of this property is true when the item is visible in the toolbar, and false when it isn’t in the toolbar or is present in the toolbar’s overflow menu. This property is key-value observing (KVO) compliant.
         */
        @available(macOS 12.0, *)
        var isVisible: Bool { item.isVisible }

        /// The toolbar that currently includes the item.
        var toolbar: Toolbar? { item.toolbar?.delegate as? Toolbar }

        /// The label that appears for this item in the toolbar.
        var label: String {
            get { item.label }
            set { item.label = newValue }
        }
        
        /// Sets the label that appears for this item in the toolbar.
        @discardableResult
        func label(_ label: String?) -> Self {
            item.label = label ?? ""
            return self
        }
        
        /**
         The set of labels that the item might display.

         Use this property to specify all of the labels you might possibly use for the toolbar item. Specify all strings in the current locale. To ensure there’s space for the longest label, the item sizes itself using the strings you provide.
         */
        @available(macOS 13.0, *)
        var possibleLabels: Set<String> {
            get { item.possibleLabels }
            set { item.possibleLabels = newValue }
        }

        /**
         Sets the set of labels that the item might display.

         Use this property to specify all of the labels you might possibly use for the toolbar item. Specify all strings in the current locale. To ensure there’s space for the longest label, the item sizes itself using the strings you provide.
         */
        @available(macOS 13.0, *)
        @discardableResult
        func possibleLabels(_ labels: Set<String>) -> Self {
            item.possibleLabels = labels
            return self
        }
        
        /**
         The label that appears when the toolbar item is in the customization palette.

         If you support toolbar customizations, you must provide palette labels for your items. In most cases, you can apply the same value to this property and the label property. However, you might use this property to offer a more descriptive string, or to provide a label string when the label property contains an empty string.
         */
        var paletteLabel: String {
            get { item.paletteLabel }
            set { item.paletteLabel = newValue }
        }

        /**
         Sets the label that appears when the toolbar item is in the customization palette.

         If you support toolbar customizations, you must provide palette labels for your items. In most cases, you can apply the same value to this property and the label property. However, you might use this property to offer a more descriptive string, or to provide a label string when the label property contains an empty string.
         */
        @discardableResult
        func paletteLabel(_ paletteLabel: String?) -> Self {
            item.paletteLabel = paletteLabel ?? ""
            return self
        }
        
        /**
         An tag to identify the toolbar item.

         The toolbar doesn’t use this value. You can use it for your own custom purposes.
         */
        var tag: Int {
            get { item.tag }
            set { item.tag = newValue }
        }

        /**
         Sets the tag to identify the toolbar item.

         The toolbar doesn’t use this value. You can use it for your own custom purposes.
         */
        @discardableResult
        func tag(_ tag: Int) -> Self {
            item.tag = tag
            return self
        }
        
        /// A Boolean value that indicates whether the item is enabled.
        var isEnabled: Bool {
            get { item.isEnabled }
            set { item.isEnabled = newValue }
        }

        /// Sets the Boolean value that indicates whether the item is enabled.
        @discardableResult
        func isEnabled(_ isEnabled: Bool) -> Self {
            item.isEnabled = isEnabled
            return self
        }

        /// Sets the Boolean value that indicates whether the item can be selected.
        @discardableResult
        func isSelectable(_ isSelectable: Bool) -> Self {
            self.isSelectable = isSelectable
            return self
        }

        /// Sets the Boolean value that indicates whether the item is available on the 'default' toolbar presented to the user.
        @discardableResult
        func isDefault(_ isDefault: Bool) -> Self {
            self.isDefault = isDefault
            return self
        }

        /// Sets the Boolean value that indicates whether the item can't be removed or rearranged by the user.
        @discardableResult
        func isImmovable(_ isImmovable: Bool) -> Self {
            self.isImmovable = isImmovable
            return self
        }
        
        /// Sets the Boolean value that indicates whether the item displays in the center of the toolbar.
        @available(macOS 13.0, *)
        @discardableResult
        func isCentered(_ isCentered: Bool) -> Self {
            self.isCentered = isCentered
            return self
        }
        
        /// The tooltip to display when someone hovers over the item in the toolbar.
        var toolTip: String? {
            get { item.toolTip }
            set { item.toolTip = newValue }
        }

        /// Sets the tooltip to display when someone hovers over the item in the toolbar.
        @discardableResult
        func toolTip(_ toolTip: String?) -> Self {
            item.toolTip = toolTip
            return self
        }
        
        /**
         The display priority associated with the toolbar item.

         The default value of this property is standard. Assign a higher priority to give preference to the toolbar item when space is limited.

         When a toolbar doesn’t have enough space to fit all of its items, it pushes lower-priority items to the overflow menu first. When two or more items have the same priority, the toolbar removes them one at a time starting from the trailing edge.
         */
        var visibilityPriority: NSToolbarItem.VisibilityPriority {
            get { item.visibilityPriority }
            set { item.visibilityPriority = newValue }
        }

        /**
         Sets the display priority associated with the toolbar item.

         The default value of this property is standard. Assign a higher priority to give preference to the toolbar item when space is limited.

         When a toolbar doesn’t have enough space to fit all of its items, it pushes lower-priority items to the overflow menu first. When two or more items have the same priority, the toolbar removes them one at a time starting from the trailing edge.
         */
        @discardableResult
        func visibilityPriority(_ priority: NSToolbarItem.VisibilityPriority) -> Self {
            item.visibilityPriority = priority
            return self
        }
        
        /**
         The menu item to use when the toolbar item is in the overflow menu.

         The toolbar provides an initial default menu form representation that uses the toolbar item’s label as the menu item’s title. You can customize this menu item by changing the title or adding a submenu. When the toolbar is in text only mode, this menu item provides the text for the toolbar item. If the menu item in this property has a submenu and is visbile, clicking the toolbar item displays that submenu. If the toolbar item isn’t visible because it’s in the overflow menu, the menu item and submenu appear there.
         */
        var menuFormRepresentation: NSMenuItem? {
            get { item.menuFormRepresentation }
            set { item.menuFormRepresentation = newValue }
        }

        /**
         Sets the menu item to use when the toolbar item is in the overflow menu.

         The toolbar provides an initial default menu form representation that uses the toolbar item’s label as the menu item’s title. You can customize this menu item by changing the title or adding a submenu. When the toolbar is in text only mode, this menu item provides the text for the toolbar item. If the menu item in this property has a submenu and is visbile, clicking the toolbar item displays that submenu. If the toolbar item isn’t visible because it’s in the overflow menu, the menu item and submenu appear there.
         */
        @discardableResult
        func menuFormRepresentation(_ menuItem: NSMenuItem?) -> Self {
            item.menuFormRepresentation = menuItem
            return self
        }
        
        internal func apply(_ modifier: @escaping (Self) -> Void) -> Self {
            modifier(self)
            return self
        }

        internal func set<Value>(_ keyPath: ReferenceWritableKeyPath<ToolbarItem, Value>, to value: Value) -> Self {
            apply {
                $0[keyPath: keyPath] = value
            }
        }
    }

public extension Sequence where Element == ToolbarItem {
    /// An array of identifier of the toolbar items.
    var ids: [NSToolbarItem.Identifier] {
        compactMap(\.identifier)
    }
    
    /// The toolbar item with the specified identifier, or `nil` if the sequence doesn't contain an item with the identifier.
    subscript(id id: NSToolbarItem.Identifier) -> Element? {
        first(where: { $0.identifier == id })
    }

    /// The toolbar items with the specified identifiers.
    subscript<S: Sequence<NSToolbarItem.Identifier>>(ids ids: S) -> [Element] {
        filter { ids.contains($0.identifier) }
    }
}
#endif
