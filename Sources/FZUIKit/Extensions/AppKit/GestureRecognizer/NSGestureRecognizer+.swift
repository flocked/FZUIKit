//
//  NSGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 15.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSGestureRecognizer {
    /// The mouse button (or buttons) required to recognize a gesture.
    struct ButtonMask: OptionSet, Sendable {
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
    
    /// Sets the Boolean value indicating whether the gesture recognizer is able to handle events.
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    /// Sets the Boolean value that indicates whether primary mouse button events are delivered only after gesture recognition fails.
    @discardableResult
    func delaysPrimaryMouseButtonEvents(_ delays: Bool) -> Self {
        delaysPrimaryMouseButtonEvents = delays
        return self
    }
    
    /// Sets the Boolean value that indicates whether secondary mouse button events are delivered only after gesture recognition fails.
    @discardableResult
    func delaysSecondaryMouseButtonEvents(_ delays: Bool) -> Self {
        delaysSecondaryMouseButtonEvents = delays
        return self
    }
    
    /// Sets the Boolean value that indicates whether other mouse button events are delivered only after gesture recognition fails.
    @discardableResult
    func delaysOtherMouseButtonEvents(_ delays: Bool) -> Self {
        delaysOtherMouseButtonEvents = delays
        return self
    }
    
    /// Sets the Boolean value that indicates whether magnification events are delivered only after gesture recognition fails.
    @discardableResult
    func delaysMagnificationEvents(_ delays: Bool) -> Self {
        delaysMagnificationEvents = delays
        return self
    }
    
    /// Sets the Boolean value that indicates whether rotation events are delivered only after gesture recognition fails.
    @discardableResult
    func delaysRotationEvents(_ delays: Bool) -> Self {
        delaysRotationEvents = delays
        return self
    }
    
    /// Sets the the allowed touch types of the gesture recognizer.
    @discardableResult
    func allowedTouchTypes(_ allowedTouchTypes: NSTouch.TouchTypeMask) -> Self {
        self.allowedTouchTypes = allowedTouchTypes
        return self
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
    
    /// Sets the number of touches required in an [NSTouchBar](https://developer.apple.com/documentation/appkit/nstouchbar) object for the gesture recognizer to match.
    @discardableResult
    public func numberOfTouchesRequired(_ numberOfTouches: Int) -> Self {
        numberOfTouchesRequired = numberOfTouches
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
    
    /// Sets the maximum movement of the mouse in the view before the gesture fails.
    @discardableResult
    public func allowableMovement(_ allowableMovement: CGFloat) -> Self {
        self.allowableMovement = allowableMovement
        return self
    }
    
    /// Sets the minimum time (in seconds) that the user must hold the mouse button in the view for a valid gesture.
    @discardableResult
    public func minimumPressDuration(_ minimumPressDuration: TimeInterval) -> Self {
        self.minimumPressDuration = minimumPressDuration
        return self
    }
}

extension NSRotationGestureRecognizer {
    /// Sets the rotation of the gesture in radians.
    @discardableResult
    public func rotation(_ rotation: CGFloat) -> Self {
        self.rotation = rotation
        return self
    }
    
    /// Sets the rotation of the gesture in degrees.
    @discardableResult
    public func rotationInDegrees(_ rotation: CGFloat) -> Self {
        self.rotationInDegrees = rotation
        return self
    }
}
#endif
