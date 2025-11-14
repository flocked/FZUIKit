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
#endif
