//
//  ActionBlock.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/// An object that sends action-messages using `target` and `action`.
public protocol TargetActionProvider: NSObjectProtocol {
    /// The target object that receives action messages from the object.
    var target: AnyObject? { get set }
    /// The action-message selector.
    var action: Selector? { get set }
    /// The action handler of the object.
    typealias ActionBlock = (Self) -> Void
}

extension NSControl: TargetActionProvider {}
extension NSCell: TargetActionProvider {}
extension NSToolbarItem: TargetActionProvider {}
extension NSMenuItem: TargetActionProvider {}
extension NSGestureRecognizer: TargetActionProvider {}
extension NSColorPanel: TargetActionProvider {}
extension ToolbarItem: TargetActionProvider {}

public extension TargetActionProvider {
    /**
     Sends the `action` message to the `target` if it responds to the selector.

     - Returns: `true` if the message was successfully sent; otherwise, `false`.
     */
    @discardableResult
    func performAction() -> Bool {
        guard let action = action else { return false }
        if let control = self as? NSControl {
            return control.sendAction(action, to: target)
        } else {
            return NSApp.sendAction(action, to: target, from: self)
        }
    }

    /// A Boolean value indicating whether the action can currently be performed by a reachable target.
    func canPerformAction() -> Bool {
        guard let action = action else { return false }
        guard let resolvedTarget = NSApp.target(forAction: action, to: target, from: self) else {
            return false
        }
        if let toolbarItem = self as? NSToolbarItem, let validation = resolvedTarget as? NSToolbarItemValidation {
            return validation.validateToolbarItem(toolbarItem)
        }
        if let menuItem = self as? NSMenuItem, let validation = resolvedTarget as? NSMenuItemValidation {
            return validation.validateMenuItem(menuItem)
        }
        if let item = self as? NSValidatedUserInterfaceItem, let validation = resolvedTarget as? NSUserInterfaceValidations {
            return validation.validateUserInterfaceItem(item)
        }
        return true
    }
}

public extension NSToolbarItem {
    /// Returns a Boolean value indicating whether the toolbar item’s action can currently be performed by a reachable target.
    func canPerformAction() -> Bool {
        guard let action = action else { return false }
        guard let resolvedTarget = NSApp.target(forAction: action, to: target, from: self) else {
            return false
        }
        if let validation = resolvedTarget as? NSToolbarItemValidation {
            return validation.validateToolbarItem(self)
        }
        if let validation = resolvedTarget as? NSUserInterfaceValidations {
            return validation.validateUserInterfaceItem(self)
        }
        return true
    }
}

public extension NSMenuItem {
    /// Returns a Boolean value indicating whether the menu item’s action can currently be performed by a reachable target.
    func canPerformAction() -> Bool {
        guard let action = action else { return false }
        guard let resolvedTarget = NSApp.target(forAction: action, to: target, from: self) else {
            return false
        }
        if let validation = resolvedTarget as? NSMenuItemValidation {
            return validation.validateMenuItem(self)
        }
        if let validation = resolvedTarget as? NSUserInterfaceValidations {
            return validation.validateUserInterfaceItem(self)
        }
        return true
    }
}

class ActionTrampoline<T: TargetActionProvider>: NSObject {
    var action: ((T) -> Void)?
    var doubleAction: ((T) -> Void)?
    private weak var senderOverride: T?

    public init(action: ((T) -> Void)? = nil, doubleAction: ((T) -> Void)? = nil, senderOverride: T? = nil) {
        self.action = action
        self.doubleAction = doubleAction
        self.senderOverride = senderOverride
    }

    @objc func performAction(sender: NSObject) {
        guard let sender = senderOverride ?? (sender as? T) else { return }
        action?(sender)
    }

    // Keep toolbar handlers separate from the control's own actionBlock.
    @objc fileprivate func performToolbarAction(sender: NSObject) {
        guard let senderOverride else { return }
        action?(senderOverride)
    }
    
    @objc func performDoubleAction(sender: NSObject) {
        guard let sender = sender as? T else { return }
        doubleAction?(sender)
    }
}

fileprivate let actionTrampolineSelector = #selector(ActionTrampoline<NSMenuItem>.performAction(sender:))
fileprivate let doubleActionTrampolineSelector = #selector(ActionTrampoline<NSMenuItem>.performDoubleAction(sender:))
private let toolbarActionSelector = #selector(ActionTrampoline<NSControl>.performToolbarAction(sender:))

private protocol ToolbarActionTrampoline: AnyObject {
    var toolbarActionOwner: AnyObject? { get }
    func toolbarActionHandler<Object: AnyObject>(for object: Object) -> ((Object) -> Void)?
}

extension ActionTrampoline: ToolbarActionTrampoline {
    fileprivate var toolbarActionOwner: AnyObject? { senderOverride }

    fileprivate func toolbarActionHandler<Object: AnyObject>(for object: Object) -> ((Object) -> Void)? {
        guard senderOverride === object else { return nil }
        return action as? (Object) -> Void
    }
}

class MenuActionTrampoline<Item: NSMenuItem>: ActionTrampoline<Item>, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        menuItem.updateHandler?(menuItem)
        return true
    }
}

extension NSSearchField {
    static func swizzleSetSearchMenuTemplate() {
        guard searchMenuTemplateHook == nil else { return }
        do {
            searchMenuTemplateHook = try hook(setAll: \.searchMenuTemplate) { object, value in
                
               return value
            }
        } catch {
            Swift.print(error)
        }
    }
    
    private static var searchMenuTemplateHook: Hook? {
        get { associatedValue(for: "searchMenuTemplateHook") }
        set { setAssociatedValue(newValue, for: "searchMenuTemplateHook") }
    }
}

public extension TargetActionProvider {
    /// The action handler of the object.
    var actionBlock: ActionBlock? {
        get {
            if let toolbarItem = self as? ToolbarItem,
               let control = toolbarItem.item.resolvedView as? NSControl {
                return control.toolbarActionTrampoline?.toolbarActionHandler(for: self)
            }
            guard let trampoline = actionTrampoline else { return nil }
            guard target === trampoline else {
                actionTrampoline = nil
                return nil
            }
            guard action == actionTrampolineSelector else {
                if trampoline.doubleAction == nil {
                    actionTrampoline = nil
                }
                return nil
            }
            return trampoline.action
        }
        set {
            if let toolbarItem = self as? ToolbarItem,
               let control = toolbarItem.item.resolvedView as? NSControl {
                control.setToolbarAction(newValue, of: self)
                return
            }
            if let newValue {
                // AppKit sends the native toolbar item, but the handler takes its wrapper.
                let senderOverride = self is ToolbarItem ? self : nil
                actionTrampoline = ActionTrampoline(action: newValue, doubleAction: actionTrampoline?.doubleAction, senderOverride: senderOverride)
                target = actionTrampoline
                action = actionTrampolineSelector
            } else {
                if action == actionTrampolineSelector {
                    action = nil
                }
                guard actionTrampoline?.doubleAction == nil else { return }
                if target === actionTrampoline {
                    target = nil
                }
                actionTrampoline = nil
            }
        }
    }
    
    

    /// Sets the action handler of the object.
    @discardableResult
    func action(_ action: ActionBlock?) -> Self {
        actionBlock = action
        return self
    }

    /// Sets the action-message selector.
    @discardableResult
    func action(_ action: Selector?) -> Self {
        self.action = action
        return self
    }

    /// Sets the target object that receives action messages from the object.
    @discardableResult
    func target(_ target: AnyObject?) -> Self {
        self.target = target
        return self
    }
    
    internal func removeTrampoline(_ trampoline: ActionTrampoline<Self>?) {
        if target === trampoline {
            target = nil
        }
        if action == actionTrampolineSelector {
            action = nil
        }
        if (self as? any DoubleActionProvider)?.doubleAction == doubleActionTrampolineSelector {
            (self as? any DoubleActionProvider)?.doubleAction = nil
        }
    }

    internal var actionTrampoline: ActionTrampoline<Self>? {
        get {
            guard let trampoline: ActionTrampoline<Self> = FZSwiftUtils.getAssociatedValue("actionTrampoline", of: self) else { return nil }
            let hasAction = action == actionTrampolineSelector
            let hasDoubleAction = (self as? any DoubleActionProvider)?.doubleAction == doubleActionTrampolineSelector
            guard target === trampoline, hasAction || hasDoubleAction else {
                removeTrampoline(trampoline)
                FZSwiftUtils.setAssociatedValue(Optional<ActionTrampoline<Self>>.none, for: "actionTrampoline", of: self)
                return nil
            }
            return FZSwiftUtils.getAssociatedValue("actionTrampoline", of: self)
        }
        set {
            if let newValue {
                target = newValue
                action = actionTrampolineSelector
            } else {
                removeTrampoline(actionTrampoline)
            }
            FZSwiftUtils.setAssociatedValue(newValue, for: "actionTrampoline", of: self)
        }
    }
}

public extension TargetActionProvider where Self: NSGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension TargetActionProvider where Self: NSCell {
    /// Initializes the cell with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

private extension NSControl {
    func setToolbarAction<Object: TargetActionProvider>(_ handler: ((Object) -> Void)?, of object: Object) {
        if let handler {
            let trampoline = ActionTrampoline(action: handler, senderOverride: object)
            toolbarActionTrampoline = trampoline
            target = trampoline
            action = toolbarActionSelector
        } else if let trampoline = toolbarActionTrampoline, trampoline.toolbarActionOwner === object {
            if target === trampoline {
                target = nil
            }
            if action == toolbarActionSelector {
                action = nil
            }
            toolbarActionTrampoline = nil
        }
    }

    var toolbarActionTrampoline: (NSObject & ToolbarActionTrampoline)? {
        get { associatedValue(for: "toolbarActionTrampoline") }
        set { setAssociatedValue(newValue, for: "toolbarActionTrampoline") }
    }
}

fileprivate extension NSToolbarItem {
    var resolvedView: NSView? {
        view ?? (self as? NSSearchToolbarItem)?.searchField
    }
}

/// An object that sends double action-messages using `target` and `doubleAction`.
public protocol DoubleActionProvider: TargetActionProvider {
    /// The double action-message selector.
    var doubleAction: Selector? { get set }
}

extension NSTableView: DoubleActionProvider { }
extension NSBrowser: DoubleActionProvider { }
extension NSMatrix: DoubleActionProvider { }
extension NSPathControl: DoubleActionProvider { }
extension NSPathCell: DoubleActionProvider { }

public extension DoubleActionProvider {
    /// The double action handler of the object.
    var doubleActionBlock: ActionBlock? {
        get {
            guard let trampoline = actionTrampoline else { return nil }
            guard target === trampoline else {
                actionTrampoline = nil
                return nil
            }
            guard doubleAction == doubleActionTrampolineSelector else {
                if trampoline.action == nil {
                    actionTrampoline = nil
                }
                return nil
            }
            return trampoline.doubleAction
        }
        set {
            if let newValue {
                let action = actionTrampoline?.action
                actionTrampoline = ActionTrampoline(action: action, doubleAction: newValue)
                target = actionTrampoline
                self.action = action == nil ? nil : actionTrampolineSelector
                doubleAction = doubleActionTrampolineSelector
            } else {
                if doubleAction == doubleActionTrampolineSelector {
                    doubleAction = nil
                }
                guard actionTrampoline?.action == nil else { return }
                if target === actionTrampoline {
                    target = nil
                }
                actionTrampoline = nil
            }
        }
    }
    
    /// Sets the double action handler of the object.
    @discardableResult
    func doubleAction(_ action: ActionBlock?) -> Self {
        doubleActionBlock = action
        return self
    }
    
    /**
     Sends the `doubleAction` message to the `target` if it responds to the selector.

     - Returns: `true` if the message was successfully sent; otherwise, `false`.
     */
    @discardableResult
    func performDoubleAction() -> Bool {
        guard let action = doubleAction else { return false }
        if let control = self as? NSControl {
            return control.sendAction(action, to: target)
        } else {
            return NSApp.sendAction(action, to: target, from: self)
        }
    }

    /// A Boolean value indicating whether the `doubleAction` can currently be performed by a reachable target.
    func canPerformDoubleAction() -> Bool {
        guard let action = doubleAction else { return false }
        guard let resolvedTarget = NSApp.target(forAction: action, to: target, from: self) else {
            return false
        }
        if let item = self as? NSValidatedUserInterfaceItem, let validation = resolvedTarget as? NSUserInterfaceValidations {
            return validation.validateUserInterfaceItem(item)
        }
        return true
    }
    
    /// Sets the action-message selector.
    @discardableResult
    func doubleAction(_ action: Selector?) -> Self {
        self.doubleAction = action
        return self
    }
}

#elseif os(iOS) || os(tvOS) || os(visionOS)
import FZSwiftUtils
import UIKit

public extension NSObjectProtocol where Self: UIGestureRecognizer {
    typealias ActionBlock = (Self) -> Void

    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }

    /// Sets the action handler of the gesture recognizer.
    @discardableResult
    func action(_ action: ActionBlock?) -> Self {
        actionBlock = action
        return self
    }

    /// The action handler of the gesture recognizer.
    var actionBlock: ActionBlock? {
        get { associatedValue(for: "actionBlock") }
        set {
            if newValue != nil, actionBlock == nil {
                addTarget(self, action: #selector(performActionBlock(sender:)))
            } else if newValue == nil, actionBlock != nil {
                removeTarget(self, action: #selector(performActionBlock(sender:)))
            }
            setAssociatedValue(newValue, for: "actionBlock")
        }
    }
}

fileprivate extension UIGestureRecognizer {
    @objc func performActionBlock(sender: NSObject) {
        actionBlock?(self)
    }
}

public extension NSObjectProtocol where Self: UIControl {
    /// The action handler for the specific event.
    func action(for event: UIControl.Event) -> ((Self) -> Void)? {
        actionBlocks[event.rawValue]
    }

    /// Sets the action handler for the specific event.
    @discardableResult
    func setAction(for event: UIControl.Event, to action: ((_ control: Self) -> Void)?) -> Self {
        if action != nil, actionBlocks[event.rawValue] == nil {
            addTarget(self, action: #selector(performActionBlock(for:sender:)), for: event)
        } else if action == nil, actionBlocks[event.rawValue] != nil {
            removeTarget(self, action: #selector(performActionBlock(for:sender:)), for: event)
        }
        actionBlocks[event.rawValue] = action
        return self
    }

    fileprivate var actionBlocks: [UInt: (Self) -> Void] {
        get { associatedValue(for: "actionBlocks") ?? [:] }
        set { setAssociatedValue(newValue, for: "actionBlocks") }
    }
}

fileprivate extension UIControl {
    @objc func performActionBlock(for event: UIControl.Event, sender: NSObject) {
        actionBlocks[event]?(self)
    }
}
#endif
