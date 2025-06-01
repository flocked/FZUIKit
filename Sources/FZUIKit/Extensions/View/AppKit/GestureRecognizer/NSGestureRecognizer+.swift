//
//  NSGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 15.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSGestureRecognizer {
    /// The mouse button (or buttons) required to recognize a gesture.
    public struct ButtonMask: OptionSet, Sendable {
        /// Left mouse button.
        public static var left = ButtonMask(rawValue: 1 << 0)
        /// Right mouse button.
        public static var right = ButtonMask(rawValue: 1 << 1)
        /// Third mouse button.
        public static var other = ButtonMask(rawValue: 1 << 2)
        /// Left, right and other mouse button.
        public static let all: ButtonMask = [.left, .right, .other]

        /// Creates a structure that represents the mouse button (or buttons) required to recognize a gesture.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public let rawValue: Int
    }
}

extension NSPanGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this gesture.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    /// Sets the mouse button (or buttons) required to recognize this gesture.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
}

extension NSClickGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this click.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    /// Sets the mouse button (or buttons) required to recognize this click.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
    
    /// Sets the number of clicks required to match.
    @discardableResult
    public func numberOfClicksRequired(_ clicks: Int) -> Self {
        numberOfClicksRequired = clicks
        return self
    }
}

extension NSPressGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this press.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    
    /// Sets the mouse button (or buttons) required to recognize this press.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
}

extension NSGestureRecognizer {
    /// Handlers of the gesture recognizer.
    public struct Handlers {
        /// The handler that determines whether the gesture recognizer should begin.
        public var shouldBegin: (()->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should process an event.
        public var shouldProcessEvent: ((NSEvent)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should receive a touchbar touch.
        public var shouldReceiveTouch: ((NSTouch)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must wait to recognize it's gesture until the other gesture recognizer fails.
        public var shouldRequireFailure: ((NSGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must fail before the other gesture recognizer is allowed to recognize its gesture.
        public var shouldBeRequiredToFail: ((NSGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should be allowed to recognize it's gesture simultaneously with the other one.
        public var shouldRecognizeSimultaneously: ((NSGestureRecognizer)->(Bool))?
        
        var needsDelegate: Bool {
            shouldProcessEvent != nil || shouldBegin != nil || shouldReceiveTouch != nil || shouldRequireFailure != nil || shouldBeRequiredToFail != nil || shouldRecognizeSimultaneously != nil
        }
    }
    
    /// The handlers of the gesture recognizer.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers", initialValue: Handlers()) }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if !newValue.needsDelegate {
                if delegate === delegateProxy {
                    delegate = nil
                }
                delegateProxy = nil
            } else {
                if delegateProxy == nil {
                    delegateProxy = .init()
                    delegate = delegateProxy!
                }
                delegateProxy?.handlers = newValue
            }
        }
    }
    
    private var delegateProxy: Delegate? {
        get { getAssociatedValue("delegate") }
        set { setAssociatedValue(newValue, key: "delegate") }
    }
    
    private class Delegate: NSObject, NSGestureRecognizerDelegate {
        var handlers = Handlers()
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
            handlers.shouldBegin?() ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
            handlers.shouldReceiveTouch?(touch) ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            handlers.shouldRequireFailure?(otherGestureRecognizer) ?? false
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            handlers.shouldBeRequiredToFail?(otherGestureRecognizer) ?? false
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            handlers.shouldRecognizeSimultaneously?(otherGestureRecognizer) ?? false
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
            handlers.shouldProcessEvent?(event) ?? true
        }
    }
}

#endif
