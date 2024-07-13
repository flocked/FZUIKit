//
//  ActionBlock.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/// An object with a target and action.
public protocol TargetActionProvider: NSObjectProtocol {
    /// The action handler of the object.
    typealias ActionBlock = (Self) -> Void
    var target: AnyObject? { get set }
    var action: Selector? { get set }
}

extension NSControl: TargetActionProvider { }
extension NSCell: TargetActionProvider { }
extension NSToolbarItem: TargetActionProvider { }
extension NSMenuItem: TargetActionProvider { }
extension NSGestureRecognizer: TargetActionProvider { }
extension NSColorPanel: TargetActionProvider { }

extension TargetActionProvider {
    /// Performs the `action`.
    public func performAction() {
        if let actionBlock = actionBlock {
            actionBlock(self)
        } else if let action = action, let target = target, target.responds(to: action) {
            _ = target.perform(action)
        }
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

public extension TargetActionProvider {
    /// The action handler of the object.
    var actionBlock: ActionBlock? {
        set {
            if let newValue = newValue {
                actionTrampoline = ActionTrampoline(action: newValue)
                target = actionTrampoline
                action = #selector(ActionTrampoline<Self>.performAction(sender:))
            } else {
                actionTrampoline = nil
                if action == #selector(ActionTrampoline<Self>.performAction(sender:)) {
                    action = nil
                }
            }
        }
        get { actionTrampoline?.action }
    }
    
    /// Sets the action handler of the object.
    @discardableResult
    func action(_ action: ActionBlock?) -> Self {
        actionBlock = action
        return self
    }
    
    internal var actionTrampoline: ActionTrampoline<Self>? {
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

public extension TargetActionProvider where Self: NSControl {
    /// Initializes the control with the specified action handler.
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

#elseif os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension NSObjectProtocol where Self: UIGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ((Self) -> Void)) {
        self.init()
        actionBlock = action
    }
    
    /// Sets the action handler of the gesture recognizer.
    @discardableResult
    func action(_ action: ((Self) -> Void)?) -> Self {
        actionBlock = action
        return self
    }
        
    /// The action handler of the gesture recognizer.
    var actionBlock: ((Self) -> Void)? {
        get { getAssociatedValue("actionBlock", initialValue: nil) }
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

extension UIGestureRecognizer {
    @objc func performActionBlock(sender: NSObject) {
        actionBlock?(self)
    }
}
#endif
