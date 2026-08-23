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

extension NSControl: TargetActionProvider { }
extension NSCell: TargetActionProvider { }
extension NSToolbarItem: TargetActionProvider { }
extension NSMenuItem: TargetActionProvider { }
extension NSGestureRecognizer: TargetActionProvider { }
extension NSColorPanel: TargetActionProvider { }
extension ToolbarItem: TargetActionProvider { }

extension TargetActionProvider {
    /**
     Sends the `action` message to the `target` if it responds to the selector.
     
     - Returns: `true` if the message was successfully sent; otherwise, `false`.
     */
    @discardableResult
    public func performAction() -> Bool {
        guard let action = action else { return false }
        if let control = self as? NSControl {
            return control.sendAction(action, to: target)
        } else {
            return NSApp.sendAction(action, to: target, from: self)
        }
    }
    
    /// A Boolean value indicating whether the action can currently be performed by a reachable target.
    public func canPerformAction() -> Bool {
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

extension NSToolbarItem {
    /// Returns a Boolean value indicating whether the toolbar item’s action can currently be performed by a reachable target.
    public func canPerformAction() -> Bool {
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

extension NSMenuItem {
    /// Returns a Boolean value indicating whether the menu item’s action can currently be performed by a reachable target.
    public func canPerformAction() -> Bool {
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
    var action: (T) -> Void
    
    init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    @objc func performAction(sender: NSObject) {
        guard let sender = sender as? T else { return }
        action(sender)
    }
}

extension ActionTrampoline {
    final class Redirect<Object: AnyObject>: ActionTrampoline {
          let handler: (Object) -> Void
          weak var object: Object?

          init(to object: Object, handler: @escaping (Object) -> Void) {
              self.object = object
              self.handler = handler
              super.init { _ in }
              self.action = { [weak self] _ in
                  guard let self, let object = self.object else { return }
                  self.handler(object)
              }
          }
      }
}

extension TargetActionProvider {
    func setRedirectedAction<Object: AnyObject>(to object: Object, handler: ((Object) -> Void)?) {
        if let handler {
            let trampoline = ActionTrampoline<Self>.Redirect(to: object, handler: handler)
            actionTrampoline = trampoline
            target = trampoline
            action = #selector(ActionTrampoline<Self>.performAction(sender:))
        } else if let trampoline = actionTrampoline as? ActionTrampoline<Self>.Redirect<Object>, trampoline.object === object {
            if target === trampoline {
                target = nil
            }
            if action == #selector(ActionTrampoline<Self>.performAction(sender:)) {
                action = nil
            }
            actionTrampoline = nil
        }
    }

    func redirectedActionHandler<Object: AnyObject>(for object: Object) -> ((Object) -> Void)? {
        guard let trampoline = actionTrampoline as? ActionTrampoline<Self>.Redirect<Object>,
              trampoline.object === object else {
            return nil
        }
        return trampoline.handler
    }
}

extension TargetActionProvider {
    var actionBlockID: ObjectIdentifier? {
        actionTrampoline?.objectID
    }
}

public extension TargetActionProvider {
    /// The action handler of the object.
    var actionBlock: ActionBlock? {
        set {
            if let newValue {
                let trampoline = ActionTrampoline(action: newValue)
                actionTrampoline = trampoline
                target = trampoline
                action = #selector(ActionTrampoline<Self>.performAction(sender:))
            } else if let trampoline = actionTrampoline {
                if target === trampoline {
                    target = nil
                }
                if action == #selector(ActionTrampoline<Self>.performAction(sender:)) {
                    action = nil
                }
                actionTrampoline = nil
            }
        }
        get {
            guard let trampoline = actionTrampoline, target === trampoline, action == #selector(ActionTrampoline<Self>.performAction(sender:))
            else {
                actionTrampoline = nil
                return nil
            }
            return trampoline.action
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
    
    private var actionTrampoline: ActionTrampoline<Self>? {
        get { FZSwiftUtils.getAssociatedValue("actionTrampoline", object: self) }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "actionTrampoline", object: self) }
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

#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
import FZSwiftUtils

public extension NSObjectProtocol where Self: UIGestureRecognizer {
    typealias ActionBlock = ((Self) -> Void)
    
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
        get { getAssociatedValue("actionBlock") }
        set {
            if newValue != nil, actionBlock == nil {
                addTarget(self, action: #selector(performActionBlock(sender:)))
            } else if newValue == nil, actionBlock != nil {
                removeTarget(self, action: #selector(performActionBlock(sender:)))
            }
            setAssociatedValue(newValue, key: "actionBlock")
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
    
    fileprivate var actionBlocks: [UInt: ((Self) -> Void)] {
        get { getAssociatedValue("actionBlocks") ?? [:] }
        set { setAssociatedValue(newValue, key: "actionBlocks") }
    }
}

fileprivate extension UIControl {
    @objc func performActionBlock(for event: UIControl.Event, sender: NSObject) {
        actionBlocks[event]?(self)
    }
}
#endif
