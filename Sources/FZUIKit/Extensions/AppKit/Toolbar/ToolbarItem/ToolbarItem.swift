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
        public typealias ActionBlock = (ToolbarItem)->()

        /// The identifier of the toolbar item.
        public let identifier: NSToolbarItem.Identifier

        var isDefault = true
        var isSelectable = false
        var isImmovableItem = false

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
        var toolbar: NSToolbar? { item.toolbar }

        /// Sets the label that appears for this item in the toolbar.
        @discardableResult
        func label(_ label: String?) -> Self {
            set(\.item.label, to: label ?? "")
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
         Sets the label that appears when the toolbar item is in the customization palette.

         If you support toolbar customizations, you must provide palette labels for your items. In most cases, you can apply the same value to this property and the label property. However, you might use this property to offer a more descriptive string, or to provide a label string when the label property contains an empty string.
         */
        @discardableResult
        func paletteLabel(_ paletteLabel: String?) -> Self {
            set(\.item.paletteLabel, to: paletteLabel ?? "")
        }

        /**
         Sets the tag to identify the toolbar item.

         The toolbar doesn’t use this value. You can use it for your own custom purposes.
         */
        @discardableResult
        func tag(_ tag: Int) -> Self {
            set(\.item.tag, to: tag)
        }

        /// Sets the Boolean value that indicates whether the item is enabled.
        @discardableResult
        func isEnabled(_ isEnabled: Bool) -> Self {
            set(\.item.isEnabled, to: isEnabled)
        }

        /**
         Sets the Boolean value that indicates whether the item can be selected.
         */
        @discardableResult
        func isSelectable(_ isSelectable: Bool) -> Self {
            set(\.isSelectable, to: isSelectable)
        }

        /// Mark the item as available on the 'default' toolbar presented to the user
        @discardableResult
        func isDefault(_ isDefault: Bool) -> Self {
            set(\.isDefault, to: isDefault)
        }

        /// Sets the Boolean value that indicates whether the item can be removed or rearranged by the user.
        @discardableResult
        func isImmovable(_ isImmovable: Bool) -> Self {
            set(\.isImmovableItem, to: isImmovable)
        }

        /// Sets the tooltip to display when someone hovers over the item in the toolbar.
        @discardableResult
        func toolTip(_ toolTip: String?) -> Self {
            set(\.item.toolTip, to: toolTip)
        }

        /**
         Sets the display priority associated with the toolbar item.

         The default value of this property is standard. Assign a higher priority to give preference to the toolbar item when space is limited.

         When a toolbar doesn’t have enough space to fit all of its items, it pushes lower-priority items to the overflow menu first. When two or more items have the same priority, the toolbar removes them one at a time starting from the trailing edge.
         */
        @discardableResult
        func visibilityPriority(_ priority: NSToolbarItem.VisibilityPriority) -> Self {
            set(\.item.visibilityPriority, to: priority)
        }

        /**
         Sets the menu item to use when the toolbar item is in the overflow menu.

         The toolbar provides an initial default menu form representation that uses the toolbar item’s label as the menu item’s title. You can customize this menu item by changing the title or adding a submenu. When the toolbar is in text only mode, this menu item provides the text for the toolbar item. If the menu item in this property has a submenu and is visbile, clicking the toolbar item displays that submenu. If the toolbar item isn’t visible because it’s in the overflow menu, the menu item and submenu appear there.
         */
        @discardableResult
        func menuFormRepresentation(_ menuItem: NSMenuItem?) -> Self {
            set(\.item.menuFormRepresentation, to: menuItem)
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
#endif
