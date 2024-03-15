//
//  NSGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 15.03.24.
//

#if os(macOS)
import AppKit

extension NSGestureRecognizer {
    /// The mouse button (or buttons) required to recognize a gesture.
    public struct ButtonMask: OptionSet, Sendable {
        /// Left mouse button.
        public static var left = ButtonMask(rawValue: 1 << 0)

        /// Right mouse button.
        public static var right = ButtonMask(rawValue: 1 << 1)

        /// Third mouse button.
        public static var other = ButtonMask(rawValue: 1 << 2)
        
        /// The mouse button at the specified index.
        public static func button(at index: Int) -> ButtonMask {
            ButtonMask(rawValue: 1 << index.clamped(min: 0))
        }
        
        /// Left, right and other mouse button.
        public static var all: ButtonMask {
            [.left, .right, .other]
        }

        /// Creates a structure that represents the corners of a rectangle.
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
}

extension NSClickGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this gesture.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
}

extension NSPressGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this gesture.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
}

#endif
