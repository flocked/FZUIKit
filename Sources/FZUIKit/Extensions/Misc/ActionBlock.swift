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

extension TargetActionProvider {
    /// Sends the `action` message to the `target` if it responds to the selector.
    public func performAction() {
        let target = target ?? self
        guard let action = action, target.responds(to: action) else { return }
        if let self = self as? NSControl {
            self.sendAction(action, to: target)
        } else {
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
