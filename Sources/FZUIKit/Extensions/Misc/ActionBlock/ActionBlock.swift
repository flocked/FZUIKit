//
//  ActionBlock.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)

    import AppKit
    import Foundation

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

    extension NSControl: TargetActionProtocol {}
    extension NSCell: TargetActionProtocol {}
    extension NSToolbarItem: TargetActionProtocol {}

    extension NSPanGestureRecognizer: TargetActionProtocol {}
    extension NSMagnificationGestureRecognizer: TargetActionProtocol {}
    extension NSClickGestureRecognizer: TargetActionProtocol {}
    extension NSPressGestureRecognizer: TargetActionProtocol {}
    extension NSRotationGestureRecognizer: TargetActionProtocol {}

    extension NSMenuItem: TargetActionProtocol {}

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

    private let ActionBlockAssociatedObjectKey = "ActionBlock".address

    fileprivate extension String {
        var address: UnsafeRawPointer {
            UnsafeRawPointer(bitPattern: abs(hashValue))!
        }
    }

    public extension TargetActionProtocol {
        /// The action handler of the control.
        @discardableResult
        func action(_ action: ActionBlock?) -> Self {
            actionBlock = action
            return self
        }
        
        /// The action handler of the control.
        var actionBlock: ActionBlock? {
            set {
                guard let action = newValue else {
                    objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, nil,
                                             .OBJC_ASSOCIATION_RETAIN)
                    return
                }
                let trampoline = ActionTrampoline(action: action)
                target = trampoline
                self.action = #selector(trampoline.performAction(sender:))
                objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
            }
            get {
                guard let trampoline: ActionTrampoline =
                    objc_getAssociatedObject(self, ActionBlockAssociatedObjectKey) as? ActionTrampoline<Self> else { return nil }
                return trampoline.action
            }
        }

        private func setup(setup: (Self) -> Void) -> Self {
            setup(self)
            return self
        }
    }

#elseif os(iOS) || os(tvOS)
    import Foundation
    import UIKit

    public protocol TargetActionProtocol: AnyObject {
        typealias ActionBlock = (Self) -> Void
        func addTarget(_ target: Any, action: Selector)
        func removeTarget(_ target: Any?, action: Selector?)
    }

    extension UISwipeGestureRecognizer: TargetActionProtocol {}
    extension UIPanGestureRecognizer: TargetActionProtocol {}
    extension UILongPressGestureRecognizer: TargetActionProtocol {}
    extension UITapGestureRecognizer: TargetActionProtocol {}

    #if os(iOS)
        extension UIPinchGestureRecognizer: TargetActionProtocol {}
        extension UIRotationGestureRecognizer: TargetActionProtocol {}
        extension UIHoverGestureRecognizer: TargetActionProtocol {}
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

    private let ActionBlockAssociatedObjectKey = "ActionBlock".address

    fileprivate extension String {
        var address: UnsafeRawPointer {
            UnsafeRawPointer(bitPattern: abs(hashValue))!
        }
    }

    public extension TargetActionProtocol {
        var actionBlock: ActionBlock? {
            set {
                guard let action = newValue else {
                    if let trampoline: ActionTrampoline =
                        objc_getAssociatedObject(self, ActionBlockAssociatedObjectKey) as? ActionTrampoline<Self>
                    {
                        removeTarget(trampoline, action: #selector(trampoline.performAction(sender:)))
                    }
                    objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, nil,
                                             .OBJC_ASSOCIATION_RETAIN)
                    return
                }
                let trampoline = ActionTrampoline(action: action)
                addTarget(trampoline, action: #selector(trampoline.performAction(sender:)))
                objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
            }
            get {
                guard let trampoline: ActionTrampoline =
                    objc_getAssociatedObject(self, ActionBlockAssociatedObjectKey) as? ActionTrampoline<Self> else { return nil }
                return trampoline.action
            }
        }

        private func setup(setup: (Self) -> Void) -> Self {
            setup(self)
            return self
        }
    }
#endif
