//
//  CGEvent+.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension CGEvent {
    /// The location of the mouse pointer.
    public static var mouseLocation: CGPoint? {
        CGEvent(source: nil)?.location
    }
    
    /// `NSEvent` representation of the event.
    public var nsEvent: NSEvent? {
        NSEvent(cgEvent: self)
    }
    
    /// The key code of the event.
    public var keyCode: Int {
        Int(getIntegerValueField(.keyboardEventKeycode))
    }
    
    /// The change on the x- and y-coordinate for scroll wheel, mouse-move, mouse-drag, and swipe events.
    public var delta: CGPoint {
        CGPoint(getDoubleValueField(.mouseEventDeltaX), getDoubleValueField(.mouseEventDeltaY))
    }
    
    /// The button for a mouse event.
    public var mouseButton: CGMouseButton {
        CGMouseButton(rawValue: UInt32(getIntegerValueField(.mouseEventButtonNumber))) ?? .left
    }
    
    /// The number of mouse clicks associated with a mouse-down or mouse-up event.
    public var clickCount: Int {
        Int(getIntegerValueField(.mouseEventClickState))
    }
}

extension CGEventFlags: Swift.Hashable {
    public var modifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if contains(.maskShift) { flags.insert(.shift) }
        if contains(.maskControl) { flags.insert(.control) }
        if contains(.maskCommand) { flags.insert(.command) }
        if contains(.maskNumericPad) { flags.insert(.numericPad) }
        if contains(.maskHelp) { flags.insert(.help) }
        if contains(.maskAlternate) { flags.insert(.option) }
        if contains(.maskSecondaryFn) { flags.insert(.function) }
        if contains(.maskAlphaShift) { flags.insert(.capsLock) }
        return flags
    }
    
    var monitor: Self {
        intersection([.maskShift, .maskControl, .maskCommand, .maskNumericPad, .maskHelp, .maskAlternate, .maskSecondaryFn, .maskShift])
    }
}


extension CGEvent {
    /**
     Creates a key down event with the specified key code.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero) -> CGEvent? {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else { return nil }
        event.location = location
        event.flags = modifierFlags
        event.timestamp = UInt64(TimeInterval.now)
        return event
    }
    
    /**
     Creates a key down event with the specified key.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero) -> CGEvent? {
        keyDown(key.rawValue, modifierFlags: modifierFlags, location: location)
    }
    
    /**
     Creates a key down event with the specified key code.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero) -> CGEvent? {
        keyDown(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: location)
    }
    
    /**
     Creates a key down event with the specified key.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero) -> CGEvent? {
        keyDown(key, modifierFlags: modifierFlags.cgEventFlags, location: location)
    }
    
    /**
     Creates a key up event with the specified key code.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero) -> CGEvent? {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else { return nil }
        event.location = location
        event.flags = modifierFlags
        event.timestamp = UInt64(TimeInterval.now)
        return event
    }
    
    /**
     Creates a key up event with the specified key.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags, location: location)
    }
    
    /**
     Creates a key up event with the specified key code.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero) -> CGEvent? {
        keyUp(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: location)
    }
    
    /**
     Creates a key down event with the specified key code in the specified window.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyDown(keyCode, modifierFlags: modifierFlags, location: window.convertPoint(toScreen: location))
    }

    /**
     Creates a key down event with the specified key code in the specified view.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, view: NSView) -> CGEvent? {
        guard let window = view.window else { return nil }
        return keyDown(keyCode, modifierFlags: modifierFlags, location: view.convert(location, to: nil), window: window)
    }

    /**
     Creates a key down event with the specified key in the specified window.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyDown(key.rawValue, modifierFlags: modifierFlags, location: location, window: window)
    }

    /**
     Creates a key down event with the specified key in the specified view.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyDown(key.rawValue, modifierFlags: modifierFlags, location: view.convert(location, to: nil), view: view)
    }

    /**
     Creates a key down event with the specified key code in the specified window.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyDown(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: location, window: window)
    }

    /**
     Creates a key down event with the specified key code in the specified view.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyDown(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyDown(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: view.convert(location, to: nil), view: view)
    }

    /**
     Creates a key down event with the specified key in the specified window.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyDown(key.rawValue, modifierFlags: modifierFlags.cgEventFlags, location: location, window: window)
    }

    /**
     Creates a key down event with the specified key in the specified view.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyDown(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyDown(key.rawValue, modifierFlags: modifierFlags.cgEventFlags, location: view.convert(location, to: nil), view: view)
    }

    /**
     Creates a key up event with the specified key code in the specified window.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyUp(keyCode, modifierFlags: modifierFlags, location: window.convertPoint(toScreen: location))
    }

    /**
     Creates a key up event with the specified key code in the specified view.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, view: NSView) -> CGEvent? {
        guard let window = view.window else { return nil }
        return keyUp(keyCode, modifierFlags: modifierFlags, location: view.convert(location, to: nil), window: window)
    }

    /**
     Creates a key up event with the specified key in the specified window.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags, location: location, window: window)
    }

    /**
     Creates a key up event with the specified key in the specified view.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: CGEventFlags = [], location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags, location: view.convert(location, to: nil), view: view)
    }

    /**
     Creates a key up event with the specified key code in the specified window.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyUp(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: location, window: window)
    }

    /**
     Creates a key up event with the specified key code in the specified view.
     
     - Parameters:
        - keyCode: The key code of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyUp(_ keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyUp(keyCode, modifierFlags: modifierFlags.cgEventFlags, location: view.convert(location, to: nil), view: view)
    }

    /**
     Creates a key up event with the specified key in the specified window.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags.cgEventFlags, location: location, window: window)
    }

    /**
     Creates a key up event with the specified key in the specified view.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, view: NSView) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags.cgEventFlags, location: view.convert(location, to: nil), view: view)
    }
    
    /**
     Creates a key up event with the specified key.
     
     - Parameters:
        - key: The key of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func keyUp(_ key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero) -> CGEvent? {
        keyUp(key.rawValue, modifierFlags: modifierFlags.cgEventFlags, location: location)
    }
    
    /**
     Creates a mouse event with the specified type.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: CGEventFlags = [], location: CGPoint = .zero) -> CGEvent? {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type.type, mouseCursorPosition: location, mouseButton: type.button) else { return nil }
        event.flags = modifierFlags
        return event
    }

    /**
     Creates a mouse event with the specified type.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location on the screen of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero) -> CGEvent? {
        return mouse(type, modifierFlags: modifierFlags.cgEventFlags, location: location)
    }

    /**
     Creates a mouse event with the specified type in the specified window.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: CGEventFlags = [], location: CGPoint, window: NSWindow) -> CGEvent? {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type.type, mouseCursorPosition: window.convertPoint(toScreen: location), mouseButton: type.button) else { return nil }
        event.flags = modifierFlags
        return event
    }

    /**
     Creates a mouse event with the specified type in the specified window.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified window.
        - window: The window of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow) -> CGEvent? {
        return mouse(type, modifierFlags: modifierFlags.cgEventFlags, location: location, window: window)
    }

    /**
     Creates a mouse event with the specified type in the specified view.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: CGEventFlags = [], location: CGPoint, view: NSView) -> CGEvent? {
        guard let window = view.window else { return nil }
        return mouse(type, modifierFlags: modifierFlags, location: view.convert(location, to: nil), window: window)
    }

    /**
     Creates a mouse event with the specified type in the specified view.
     
     - Parameters:
        - type: The type of the event.
        - modifierFlags: The modifier flags of the event.
        - location: The location in the specified view.
        - view: The view of the event.
     */
    public static func mouse(_ type: MouseEventType, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, view: NSView) -> CGEvent? {
        return mouse(type, modifierFlags: modifierFlags.cgEventFlags, location: location, view: view)
    }
    
    /// Constants for the mouse event types.
    public enum MouseEventType {
        /// Left mouse down.
        case leftDown
        /// Left mouse up.
        case leftUp
        /// Left mouse dragged.
        case leftDragged
        /// Right mouse down.
        case rightDown
        /// Right mouse up.
        case rightUp
        /// Right mouse dragged.
        case rightDragged
        /// Other mouse down.
        case otherDown
        /// Other mouse up.
        case otherUp
        /// Other mouse dragged.
        case otherDragged
        
        var button: CGMouseButton {
            switch self {
            case .leftDown, .leftUp, .leftDragged:
                .left
            case .rightDown, .rightUp, .rightDragged:
                .right
            case .otherDown, .otherUp, .otherDragged:
                .center
            }
        }
        
        var type: CGEventType {
            switch self {
            case .leftDown: return .leftMouseDown
            case .leftUp: return .leftMouseUp
            case .leftDragged: return .leftMouseDragged
            case .rightDown: return .rightMouseDown
            case .rightUp: return .rightMouseUp
            case .rightDragged: return .rightMouseDragged
            case .otherDown: return .otherMouseDown
            case .otherUp: return .otherMouseUp
            case .otherDragged: return .otherMouseDragged
            }
        }
    }
    
    public static func scrollwheel(units: CGScrollEventUnit, wheelCount: UInt32, wheel1: Int32, wheel2: Int32, wheel3: Int32) -> CGEvent? {
        CGEvent(scrollWheelEvent2Source: nil, units: units, wheelCount: wheelCount, wheel1: wheel1, wheel2: wheel2, wheel3: wheel3)
    }
}

#endif
