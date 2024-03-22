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
public protocol TargetActionProtocol: NSObjectProtocol {
    /// The action handler.
    typealias ActionBlock = (Self) -> Void
    var target: AnyObject? { get set }
    var action: Selector? { get set }
}

extension NSColorPanel: TargetActionProtocol {
    public var action: Selector? {
        get { nil }
        set { setAction(newValue) }
    }
    
    public var target: AnyObject? {
        get { value(forKey: "target") as? AnyObject  }
        set { setTarget(newValue) }
    }
}

extension NSControl: TargetActionProtocol { }
extension NSCell: TargetActionProtocol { }
extension NSToolbarItem: TargetActionProtocol { }
extension NSMenuItem: TargetActionProtocol { }
extension NSGestureRecognizer: TargetActionProtocol { }

class ActionTrampoline<T: TargetActionProtocol>: NSObject {
    var action: (T) -> Void
    
    init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    @objc func performAction(sender: NSObject) {
        if let sender = sender as? T {
            action(sender)
        }
    }
}

public extension TargetActionProtocol {
    /// The action handler of the object.
    var actionBlock: ActionBlock? {
        set {
            if let newValue = newValue {
                actionTrampoline = ActionTrampoline(action: newValue)
                target = actionTrampoline
                action = #selector(ActionTrampoline<Self>.performAction(sender:))
            } else if actionTrampoline != nil {
                actionTrampoline = nil
                action = nil
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

public extension TargetActionProtocol where Self: NSGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension TargetActionProtocol where Self: NSControl {
    /// Initializes the control with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension TargetActionProtocol where Self: NSCell {
    /// Initializes the cell with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

class ActionTrampoline<T: AnyObject>: NSObject {
    var action: (T) -> Void
    
    init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    @objc func performAction(sender: NSObject) {
        if let sender = sender as? T {
            action(sender)
        }
    }
}

public extension NSObjectProtocol where Self: UIGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ((Self) -> Void)) {
        self.init()
        actionBlock = action
    }
    
    /// Sets the action handler of the object.
    @discardableResult
    func action(_ action: ((Self) -> Void)?) -> Self {
        actionBlock = action
        return self
    }
    
    /// The action handler of the object.
    var actionBlock: ((Self) -> Void)? {
        set {
            if let action = newValue {
                let trampoline = ActionTrampoline(action: action)
                addTarget(trampoline, action: #selector(trampoline.performAction(sender:)))
                actionTrampoline = trampoline
            } else if let trampoline = actionTrampoline {
                removeTarget(trampoline, action: #selector(trampoline.performAction(sender:)))
                actionTrampoline = nil
            }
        }
        get { actionTrampoline?.action }
    }

    internal var actionTrampoline: ActionTrampoline<Self>? {
        get { getAssociatedValue("actionTrampoline") }
        set { setAssociatedValue(newValue, key: "actionTrampoline") }
    }
}

/*
 public extension NSObjectProtocol where Self: UIControl {
     /// Sets the action handler for the specified event.
     func setAction(for controlEvents: UIControl.Event, action: ((Self) -> Void)?) {
         if let trampoline = actionTrampolines[controlEvents.rawValue] {
             removeTarget(trampoline, action: #selector(trampoline.performAction(sender:)), for: controlEvents)
             actionTrampolines[controlEvents.rawValue] = nil
         }
         if let action = action {
             let trampoline = ActionTrampoline<Self>(action: action)
             addTarget(trampoline, action: #selector(trampoline.performAction(sender:)), for: controlEvents)
             actionTrampolines[controlEvents.rawValue] = trampoline
         }
     }
     
     func removeAllActions() {
         actionTrampolines.forEach({removeTarget($0.value, action: #selector(ActionTrampoline<Self>.performAction(sender:)), for: UIControl.Event(rawValue: $0.key))})
         actionTrampolines.removeAll()
     }
     
     internal var actionTrampolines: [UIControl.Event.RawValue: ActionTrampoline<Self>] {
         get { getAssociatedValue("actionTrampolines", initialValue: [:]) }
         set { setAssociatedValue(newValue, key: "actionTrampolines") }
     }
 }
 */
#endif
