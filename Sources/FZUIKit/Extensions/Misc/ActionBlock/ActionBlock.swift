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

extension NSPanGestureRecognizer: TargetActionProtocol { }
extension NSMagnificationGestureRecognizer: TargetActionProtocol { }
extension NSClickGestureRecognizer: TargetActionProtocol { }
extension NSPressGestureRecognizer: TargetActionProtocol { }
extension NSRotationGestureRecognizer: TargetActionProtocol { }

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
    /// Sets the action handler of the object.
    @discardableResult
    func action(_ action: ActionBlock?) -> Self {
        actionBlock = action
        return self
    }
    
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
    
    internal var actionTrampoline: ActionTrampoline<Self>? {
        get { getAssociatedValue(key: "actionTrampoline", object: self) }
        set { set(associatedValue: newValue, key: "actionTrampoline", object: self) }
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

/// An object with a target and action.
public protocol TargetActionProtocol: AnyObject {
    typealias ActionBlock = (Self) -> Void
    func addTarget(_ target: Any, action: Selector)
    func removeTarget(_ target: Any?, action: Selector?)
}

extension UISwipeGestureRecognizer: TargetActionProtocol { }
extension UIPanGestureRecognizer: TargetActionProtocol { }
extension UILongPressGestureRecognizer: TargetActionProtocol { }
extension UITapGestureRecognizer: TargetActionProtocol { }

#if os(iOS)
extension UIPinchGestureRecognizer: TargetActionProtocol { }
extension UIRotationGestureRecognizer: TargetActionProtocol { }
extension UIHoverGestureRecognizer: TargetActionProtocol { }
#endif

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
    /// Sets the action handler of the object.
    @discardableResult
    func action(_ action: ActionBlock?) -> Self {
        actionBlock = action
        return self
    }
    
    /// The action handler of the object.
    var actionBlock: ActionBlock? {
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
        get { getAssociatedValue(key: "actionTrampoline", object: self) }
        set { set(associatedValue: newValue, key: "actionTrampoline", object: self) }
    }
}
#endif
