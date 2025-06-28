//
//  ToolbarItem.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

/// A toolbar item that can be used with ``Toolbar``.
open class ToolbarItem: NSObject {
    
    /// The identifier of the toolbar item.
    public let identifier: NSToolbarItem.Identifier
    
    fileprivate lazy var rootItem = ValidateToolbarItem(for: self)
    var item: NSToolbarItem {
        rootItem
    }
    
    /// A Boolean value that indicates whether the item is available on the 'default' toolbar presented to the user.
    open var isDefault = true
    
    /// Sets the Boolean value that indicates whether the item is available on the 'default' toolbar presented to the user.
    @discardableResult
    open func isDefault(_ isDefault: Bool) -> Self {
        self.isDefault = isDefault
        return self
    }
    
    /// A Boolean value that indicates whether the item can be selected.
    open var isSelectable = false
    
    /// Sets the Boolean value that indicates whether the item can be selected.
    @discardableResult
    open func isSelectable(_ isSelectable: Bool) -> Self {
        self.isSelectable = isSelectable
        return self
    }
    
    /// A Boolean value that indicates whether the item can't be removed or rearranged by the user.
    open var isImmovable = false
    
    /// Sets the Boolean value that indicates whether the item can't be removed or rearranged by the user.
    @discardableResult
    open func isImmovable(_ isImmovable: Bool) -> Self {
        self.isImmovable = isImmovable
        return self
    }
    
    /// A Boolean value that indicates whether the item displays in the center of the toolbar.
    @available(macOS 13.0, *)
    open var isCentered: Bool {
        get { _isCentered }
        set { _isCentered = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the item displays in the center of the toolbar.
    @available(macOS 13.0, *)
    @discardableResult
    open func isCentered(_ isCentered: Bool) -> Self {
        self.isCentered = isCentered
        return self
    }
    
    private var _isCentered = false {
        didSet {
            guard #available(macOS 13.0, *), oldValue != _isCentered else { return }
            toolbar?.centeredItems[self] = isCentered
        }
    }
    
    /**
     A Boolean value that indicates whether the toolbar automatically validates the item.
     
     If the value of this property is `true`, the toolbar automatically validates the item; otherwise, it doesn’t validate the item automatically. The default value of this property is `true`.
     */
    open var autovalidates: Bool {
        get { item.autovalidates }
        set { item.autovalidates = newValue }
    }
    
    /**
     Sets the Boolean value that indicates whether the toolbar automatically validates the item.
     
     If the value of this property is `true`, the toolbar automatically validates the item; otherwise, it doesn’t validate the item automatically. The default value of this property is `true`.
     */
    @discardableResult
    open func autovalidates(_ autovalidates: Bool) -> Self {
        self.autovalidates = autovalidates
        return self
    }
    
    /// A Boolean value that indicates whether the item is selected.
    var isSelected: Bool {
        get { toolbar?.selectedItem == self }
        set {
            guard isSelectable, let toolbar = toolbar, newValue != isSelected else { return }
            if newValue {
                toolbar.selectedItem = self
            } else if toolbar.selectedItem === self {
                toolbar.selectedItem = nil
            }
        }
    }
    
    /**
     A Boolean value that indicates whether the item is currently visible in the toolbar, and not in the overflow menu.
     
     The value of this property is true when the item is visible in the toolbar, and false when it isn’t in the toolbar or is present in the toolbar’s overflow menu. This property is key-value observing (KVO) compliant.
     */
    @available(macOS 12.0, *)
    open var isVisible: Bool { item.isVisible }
    
    /// The toolbar that currently includes the item.
    public var toolbar: Toolbar? { (item.toolbar?.delegate as? Toolbar.Delegate)?.toolbar }
    
    /// The label that appears for this item in the toolbar.
    open var label: String {
        get { item.label }
        set {
            guard newValue != label else { return }
            item.label = newValue
            if newValue == "", let item = self as? Toolbar.SegmentedControl, !item.groupItem.subitems.isEmpty {
                item.updateSegments()
            }
        }
    }
    
    /// Sets the label that appears for this item in the toolbar.
    @discardableResult
    open func label(_ label: String?) -> Self {
        self.label = label ?? ""
        return self
    }
    
    /**
     The set of labels that the item might display.
     
     Use this property to specify all of the labels you might possibly use for the toolbar item. Specify all strings in the current locale. To ensure there’s space for the longest label, the item sizes itself using the strings you provide.
     */
    @available(macOS 13.0, *)
    open var possibleLabels: Set<String> {
        get { item.possibleLabels }
        set { item.possibleLabels = newValue }
    }
    
    /**
     Sets the set of labels that the item might display.
     
     Use this property to specify all of the labels you might possibly use for the toolbar item. Specify all strings in the current locale. To ensure there’s space for the longest label, the item sizes itself using the strings you provide.
     */
    @available(macOS 13.0, *)
    @discardableResult
    open func possibleLabels(_ labels: Set<String>) -> Self {
        item.possibleLabels = labels
        return self
    }
    
    /**
     The label that appears when the toolbar item is in the customization palette.
     
     If you support toolbar customizations, you must provide palette labels for your items. In most cases, you can apply the same value to this property and the label property. However, you might use this property to offer a more descriptive string, or to provide a label string when the label property contains an empty string.
     */
    open var paletteLabel: String {
        get { item.paletteLabel }
        set { item.paletteLabel = newValue }
    }
    
    /**
     Sets the label that appears when the toolbar item is in the customization palette.
     
     If you support toolbar customizations, you must provide palette labels for your items. In most cases, you can apply the same value to this property and the label property. However, you might use this property to offer a more descriptive string, or to provide a label string when the label property contains an empty string.
     */
    @discardableResult
    open func paletteLabel(_ paletteLabel: String?) -> Self {
        item.paletteLabel = paletteLabel ?? ""
        return self
    }
    
    /**
     An tag to identify the toolbar item.
     
     The toolbar doesn’t use this value. You can use it for your own custom purposes.
     */
    open var tag: Int {
        get { item.tag }
        set { item.tag = newValue }
    }
    
    /**
     Sets the tag to identify the toolbar item.
     
     The toolbar doesn’t use this value. You can use it for your own custom purposes.
     */
    @discardableResult
    open func tag(_ tag: Int) -> Self {
        item.tag = tag
        return self
    }
    
    /// A Boolean value that indicates whether the item is enabled.
    open var isEnabled: Bool {
        get { item.isEnabled }
        set { item.isEnabled = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the item is enabled.
    @discardableResult
    open func isEnabled(_ isEnabled: Bool) -> Self {
        item.isEnabled = isEnabled
        return self
    }
    
    /// The tooltip to display when someone hovers over the item in the toolbar.
    open var toolTip: String? {
        get { item.toolTip }
        set { item.toolTip = newValue }
    }
    
    /// Sets the tooltip to display when someone hovers over the item in the toolbar.
    @discardableResult
    open func toolTip(_ toolTip: String?) -> Self {
        item.toolTip = toolTip
        return self
    }
    
    /**
     The display priority associated with the toolbar item.
     
     The default value of this property is `standard`. Assign a higher priority to give preference to the toolbar item when space is limited.
     
     When a toolbar doesn’t have enough space to fit all of its items, it pushes lower-priority items to the overflow menu first. When two or more items have the same priority, the toolbar removes them one at a time starting from the trailing edge.
     */
    open var visibilityPriority: NSToolbarItem.VisibilityPriority {
        get { item.visibilityPriority }
        set { item.visibilityPriority = newValue }
    }
    
    /**
     Sets the display priority associated with the toolbar item.
     
     The default value of this property is standard. Assign a higher priority to give preference to the toolbar item when space is limited.
     
     When a toolbar doesn’t have enough space to fit all of its items, it pushes lower-priority items to the overflow menu first. When two or more items have the same priority, the toolbar removes them one at a time starting from the trailing edge.
     */
    @discardableResult
    open func visibilityPriority(_ priority: NSToolbarItem.VisibilityPriority) -> Self {
        item.visibilityPriority = priority
        return self
    }
    
    /**
     The menu item to use when the toolbar item is in the overflow menu.
     
     The toolbar provides an initial default menu form representation that uses the toolbar item’s label as the menu item’s title. You can customize this menu item by changing the title or adding a submenu. When the toolbar is in text only mode, this menu item provides the text for the toolbar item. If the menu item in this property has a submenu and is visbile, clicking the toolbar item displays that submenu. If the toolbar item isn’t visible because it’s in the overflow menu, the menu item and submenu appear there.
     */
    open var menuFormRepresentation: NSMenuItem? {
        get { item.menuFormRepresentation }
        set { item.menuFormRepresentation = newValue }
    }
    
    /**
     Sets the menu item to use when the toolbar item is in the overflow menu.
     
     The toolbar provides an initial default menu form representation that uses the toolbar item’s label as the menu item’s title. You can customize this menu item by changing the title or adding a submenu. When the toolbar is in text only mode, this menu item provides the text for the toolbar item. If the menu item in this property has a submenu and is visbile, clicking the toolbar item displays that submenu. If the toolbar item isn’t visible because it’s in the overflow menu, the menu item and submenu appear there.
     */
    @discardableResult
    open func menuFormRepresentation(_ menuItem: NSMenuItem?) -> Self {
        item.menuFormRepresentation = menuItem
        return self
    }
    
    @objc open func validate() {
        
    }
    
    /// A Boolean value that indicates whether the item is hidden.
    @available(macOS 15.0, *)
    open var isHidden: Bool {
        get { item.isHidden }
        set { item.isHidden = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the item is hidden.
    @available(macOS 15.0, *)
    @discardableResult
    open func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    init(_ identifier: NSToolbarItem.Identifier? = nil) {
        self.identifier = identifier ?? Toolbar.automaticIdentifier(for: "\(type(of: self))")
    }
}

public extension Sequence where Element == ToolbarItem {
    /// The identifiers of the toolbar items.
    var ids: [NSToolbarItem.Identifier] {
        map(\.identifier)
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

/// A toolbar item that can be validated.
public protocol ToolbarItemValidation: ToolbarItem {
    /**
     The handler that gets called to validate the toolbar item.
     
     The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
     */
    var validateHandler: ((Self)->())? { get set }
    
    /**
     Sets the handler that gets called to validate the toolbar item.
     
     The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
     */
    func validateHandler(_ validation: ((Self)->())?) -> Self
    
    /**
     Validates the toolbar item.
          
     Typically, you don’t call this method directly. When ``ToolbarItem/autovalidates`` is enabled, the toolbar calls this method to validate the item. The method is e.g. called when the toolbar's visibilty or window key state changes.
     
     If you disable ``ToolbarItem/autovalidates``, toolbar items remain enabled and clickable, including when someone switches to another app or window. However, you can still call this method manually to validate the toolbar item.
     
     You can alternative implement ``validateHandler-10ojy``.
    */
    func validate()
}

extension ToolbarItem: ToolbarItemValidation { }

extension ToolbarItemValidation {
    public var validateHandler: ((Self)->())? {
        get { getAssociatedValue("validateHandler") }
        set { setAssociatedValue(newValue, key: "validateHandler") }
    }
    
    @discardableResult
    public func validateHandler(_ validation: ((Self)->())?) -> Self {
        self.validateHandler = validation
        return self
    }
}

/// A toolbar item that that calls an action method when the user clicks the item.
public protocol ToolbarItemActionProvider: ToolbarItem {
    /// The handler that gets called when the user clicks the toolbar item.
    var actionBlock: ((_ item: Self)->())? { get set }
    
    /// Sets the handler that gets called when the user clicks the toolbar item.
    func onAction(_ action: ((_ item: Self)->())?) -> Self
    
    /// The action method to call when someone clicks on the toolbar item.
    var action: Selector? { get set }
    
    /// Sets the action method to call when someone clicks on the toolbar item.
    func action(_ action: Selector?) -> Self
    
    /// The object that defines the action method the toolbar item calls when clicked.
    var target: AnyObject? { get set }
    
    /// Sets the object that defines the action method the toolbar item calls when clicked.
    func target(_ target: AnyObject?) -> Self
}

extension ToolbarItemActionProvider {
    public var actionBlock: ((_ item: Self)->())? {
        get { getAssociatedValue("actionBlock") }
        set {
            setAssociatedValue(newValue, key: "actionBlock")
            if let actionBlock = newValue {
                item.actionBlock = { _ in
                    actionBlock(self)
                }
            } else {
                item.actionBlock = nil
            }
        }
    }
    
    @discardableResult
    public func onAction(_ action: ((_ item: Self)->())?) -> Self {
        actionBlock = action
        return self
    }
    
    public var action: Selector? {
        get { item.actionBlock == nil ? item.action : nil }
        set {
            actionBlock = nil
            item.action = newValue
        }
    }
    
    @discardableResult
    public func action(_ action: Selector?) -> Self {
        self.action = action
        return self
    }
    
    public var target: AnyObject? {
        get { item.actionBlock == nil ? item.target : nil }
        set {
            actionBlock = nil
            item.target = newValue
        }
    }
    
    @discardableResult
    public func target(_ target: AnyObject?) -> Self {
        self.target = target
        return self
    }
}

extension Toolbar.Button: ToolbarItemActionProvider { }
extension Toolbar.Group: ToolbarItemActionProvider { }
extension Toolbar.Item: ToolbarItemActionProvider { }
extension Toolbar.Menu: ToolbarItemActionProvider { }
extension Toolbar.PopUpButton: ToolbarItemActionProvider { }
extension Toolbar.Popover: ToolbarItemActionProvider { }
extension Toolbar.SharingServicePicker: ToolbarItemActionProvider { }
extension Toolbar.SegmentedControl: ToolbarItemActionProvider { }
extension Toolbar.View: ToolbarItemActionProvider { }

class ValidateToolbarItem<Item: ToolbarItem>: NSToolbarItem {
    weak var item: Item?
    
    init(for item: Item) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        guard let item = item else { return }
        item.validate()
        item.validateHandler?(item)
    }
}

#endif
