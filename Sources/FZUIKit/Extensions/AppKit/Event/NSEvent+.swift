//
//  NSEvent+.swift
//
//
//  Created by Florian Zand on 08.05.22.
//

#if os(macOS)

import AppKit
import Carbon
import Foundation
import FZSwiftUtils

public extension NSEvent {
    /**
     The location of the event inside the specified view.
     
     - Parameter view: The view for the location.
     */
    func location(in view: NSView) -> CGPoint {
        view.convert(locationInWindow, from: nil)
    }
    
    /// The screen location of the event.
    var screenLocation: CGPoint? {
        window?.convertPoint(toScreen: locationInWindow)
    }

    /// The last event that the app retrieved from the event queue.
    static var current: NSEvent? {
        NSApp.currentEvent
    }
    
    /**
     The change on the x- and y-coordinate for scroll wheel, mouse-move, mouse-drag, and swipe events.
     
     This property is only valid for scroll wheel, mouse-move, mouse-drag, and swipe events.
     
     For swipe events, a nonzero `x` value represents a horizontal swipe; `-1.0` corresponds to swipe right and `1.0` corresponds to swipe left. `y` represents a vertical swipe.
     
     For scroll wheel events, use ``scrollingDelta`` instead.
     */
    var delta: CGPoint {
        CGPoint(deltaX, deltaY)
    }
    
    /**
     The scroll wheel’s vertical and horizontal delta.
     
     This is the preferred property for accessing `NSScrollWheel` delta values. When [hasPreciseScrollingDeltas](https://developer.apple.com/documentation/appkit/nsevent/hasprecisescrollingdeltas) is `false`, your application may need to modify the raw value before using it.
     */
    var scrollingDelta: CGPoint {
        CGPoint(scrollingDeltaX, scrollingDeltaY)
    }
    
    /**
     Creates and returns a new key down event with the given key code in the specified window.

     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - window: The window of the event.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], in window: NSWindow, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key, modifierFlags: modifierFlags, location: .zero, keyDown: true, window: window, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key down event with the given key code in the specified view.
     
     - Note: The view must have a window.
     
     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - view: The view of the event.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], in view: NSView, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let window = view.window else { return nil }
        return keyEvent(keyCode: key, modifierFlags: modifierFlags, keyDown: true, window: window, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key down event with the specified key code.
     
     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - location: The cursor location on the screen.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key, modifierFlags: modifierFlags, keyDown: true, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key down event with the given key for the specified window.

     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - window: The window of the event.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: Key, modifierFlags: NSEvent.ModifierFlags = [], in window: NSWindow, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, location: .zero, keyDown: true, window: window, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key down event with the given key for the specified view.
     
     - Note: The view must have a window.
     
     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - view: The view of the event.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: Key, modifierFlags: NSEvent.ModifierFlags = [], in view: NSView, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let window = view.window else { return nil }
        return keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, keyDown: true, window: window, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key down event with the specified key.
     
     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - isARepeat: A Boolean value indicating whether the event is a repeat caused by the user holding the key down.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyDown(key: Key, modifierFlags: NSEvent.ModifierFlags = [], isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, keyDown: true, isARepeat: isARepeat, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the given key code in the specified window.

     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - window: The window of the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], in window: NSWindow, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key, modifierFlags: modifierFlags, keyDown: false, window: window, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the given key code in the specified view.
     
     - Note: The view must have a window.
     
     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - view: The view of the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], in view: NSView, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let window = view.window else { return nil }
        return keyEvent(keyCode: key, modifierFlags: modifierFlags, keyDown: false, window: window, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the specified key code.
     
     - Parameters:
        - key: The virtual code for the pressed key.
        - modifierFlags: The pressed modifier keys.
        - location: The cursor location on the screen.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: UInt16, modifierFlags: NSEvent.ModifierFlags = [], timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key, modifierFlags: modifierFlags, keyDown: false, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the given key in the specified window.
     
     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - window: The window of the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: Key, modifierFlags: NSEvent.ModifierFlags = [], in window: NSWindow, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, keyDown: false, window: window, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the given key in the specified window.
     
     - Note: The view must have a window.
     
     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - view: The view of the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: Key, modifierFlags: NSEvent.ModifierFlags = [], view: NSView, isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let window = view.window else { return nil }
        return keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, keyDown: false, window: window, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new key up event with the specified key.
     
     - Parameters:
        - key: The pressed key.
        - modifierFlags: The pressed modifier keys.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func keyUp(key: Key, modifierFlags: NSEvent.ModifierFlags = [], isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        keyEvent(keyCode: key.rawValue, modifierFlags: modifierFlags, keyDown: false, timestamp: timestamp)
    }
    
    private static func keyEvent(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = [], location: CGPoint = .zero, keyDown: Bool, window: NSWindow? = nil,  isARepeat: Bool = false, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: keyDown) else { return nil }
        cgEvent.flags = modifierFlags.cgEventFlags
        cgEvent.location = location
        guard let event = NSEvent(cgEvent: cgEvent) else { return nil }
        return NSEvent.keyEvent(with: event.type, location: location, modifierFlags: modifierFlags, timestamp: timestamp, windowNumber: window?.windowNumber ?? 0, context: nil, characters: event.characters ?? "", charactersIgnoringModifiers: event.charactersIgnoringModifiers ?? "", isARepeat: isARepeat, keyCode: keyCode) ?? event
    }
    
    /**
     Creates and returns a new mouse event in the specified window.
     
     - Parameters:
        - type: The mouse event type.
        - window: The window of the event.
        - location: The cursor location on the specified window.
        - modifierFlags: The modifier flags pressed.
        - clickCount: The number of mouse clicks associated with the mouse event.
        - pressure: The pressure (between `0.0` to `1.0`) applied to the input device (such as a graphics tablet).
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func mouse(_ type: MouseEventType, in window: NSWindow, at location: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], clickCount: Int = 1, pressure: Float = 1.0, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        NSEvent.mouseEvent(with: type.type, location: location, modifierFlags: modifierFlags, timestamp: timestamp, windowNumber: window.windowNumber, context: nil, eventNumber: Int.random(in: 0...Int.max), clickCount: clickCount, pressure: pressure.clamped(max: 1.0))
    }
    
    /**
     Creates and returns a new mouse event in the specified view.
     
     - Note: The view must have a window.
     
     - Parameters:
        - type: The mouse event type.
        - view: The view of the event.
        - location: The cursor location on the specified window.
        - modifierFlags: The modifier flags pressed.
        - clickCount: The number of mouse clicks associated with the mouse event.
        - pressure: The pressure (between `0.0` to `1.0`) applied to the input device (such as a graphics tablet).
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func mouse(_ type: MouseEventType, in view: NSView, at location: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], clickCount: Int = 1, pressure: Float = 1.0, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let window = view.window else { return nil }
        return mouse(type, in: window, at: view.convert(location, to: nil), modifierFlags: modifierFlags, clickCount: clickCount, pressure: pressure, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new mouse event.
     
     - Parameters:
        - type: The mouse event type.
        - location: The cursor location on the screen.
        - modifierFlags: The modifier flags pressed.
        - clickCount: The number of mouse clicks associated with the mouse event.
        - pressure: The pressure (between `0.0` to `1.0`) applied to the input device (such as a graphics tablet).
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func mouse(_ type: MouseEventType, at location: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], clickCount: Int = 1, pressure: Float = 1.0, timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        NSEvent.mouseEvent(with: type.type, location: location, modifierFlags: modifierFlags, timestamp: timestamp, windowNumber: 0, context: nil, eventNumber: Int.random(in: 0...Int.max), clickCount: clickCount, pressure: pressure.clamped(max: 1.0))
    }
    
    /**
     Creates and returns a new scroll wheel event with the specified scroll delta.

     - Parameters:
        - location: The location of the event in global screen coordinates.
        - delta: The scroll delta, in pixels.
        - modifierFlags: The modifier flags associated with the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func scrollWheel(at location: NSPoint, delta: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        guard let cgEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(delta.y), wheel2: Int32(delta.x), wheel3: .zero) else {
            return nil
        }
        cgEvent.location = location
        cgEvent.flags = modifierFlags.cgEventFlags
        cgEvent.timestamp = CGEventTimestamp(timestamp)
        return NSEvent(cgEvent: cgEvent)
    }
    
    /**
     Creates and returns a new scroll wheel event with the given scroll delta in the specified window.

     - Parameters:
        - window: The window of the event.
        - location: The location of the event in the window.
        - delta: The scroll delta, in pixels.
        - modifierFlags: The modifier flags associated with the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func scrollWheel(in window: NSWindow, at location: NSPoint, delta: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        scrollWheel(at: window.convertPoint(toScreen: location), delta: delta, modifierFlags: modifierFlags, timestamp: timestamp)
    }
    
    /**
     Creates and returns a new scroll wheel event with the given scroll delta in the specified view.

     - Parameters:
        - view: The view of the event.
        - location: The location of the event in the view.
        - delta: The scroll delta, in pixels.
        - modifierFlags: The modifier flags associated with the event.
        - timestamp: The event timestamp in seconds since system startup. The default value is `now`.
     */
    static func scrollWheel(in view: NSView, at location: NSPoint, delta: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], timestamp: TimeInterval = ProcessInfo.processInfo.systemUptime) -> NSEvent? {
        scrollWheel(at: view.frameOnScreen.origin, delta: delta, modifierFlags: modifierFlags, timestamp: timestamp)
    }
    
    /// Constants for mouse event types.
    enum MouseEventType {
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
        /// Mouse entered.
        case entered
        /// Mouse moved.
        case moved
        /// Mouse exited.
        case exited
        
        var type: NSEvent.EventType {
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
            case .entered: return .mouseEntered
            case .moved: return .mouseMoved
            case .exited: return .mouseExited
            }
        }
    }
    
    /// A Boolean value indicating whether no modifier key is pressed.
    var isNoModifierPressed: Bool {
        modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty
    }
    
    /**
     A Boolean value indicating whether the event type is a right mouse-down event.
     
     The value returns `true` for:
     - type is `rightMouseDown`
     - type is `leftMouseDown` and modifierFlags contains `control`.
     */
    var isRightMouseDown: Bool {
        type == .rightMouseDown || (modifierFlags.contains(.control) && type == .leftMouseDown)
    }
    
    /**
     A Boolean value indicating whether the event is a right mouse-up event.
     
     The value returns `true` for:
     - type is `rightMouseUp`
     - type is `leftMouseUp` and modifierFlags contains `control`.
     */
    var isRightMouseUp: Bool {
        type == .rightMouseUp || (modifierFlags.contains(.control) && type == .leftMouseUp)
    }
    
    /// A Boolean value indicating whether the event is a user interaction event.
    var isUserInteraction: Bool {
        type == .userInteraction
    }
    
    /// A Boolean value indicating whether the event is a keyboard event (`keyDown`, `keyUp` or `flagsChanged`).
    var isKeyboard: Bool {
        type == .keyboard
    }
    
    /// A Boolean value indicating whether the event is a mouse click event.
    var isMouse: Bool {
        type == .mouse
    }
    
    /// A Boolean value indicating whether the event is either a `.leftMouseDown`, `.leftMouseUp` or `.leftMouseDragged` event.
    var isLeftMouse: Bool {
        type == .leftMouse
    }
    
    /// A Boolean value indicating whether the event is either a `rightMouseDown`, `rightMouseUp` or `rightMouseDragged` event.
    var isRightMouse: Bool {
        type == .rightMouse
    }
    
    /// A Boolean value indicating whether the event is either a `.otherMouseDown`, `.otherMouseUp` or `.otherMouseDragged` event.
    var isOtherMouse: Bool {
        type == .otherMouse
    }
    
    /// A Boolean value indicating whether the event is a mouse movement event (`mouseEntered`, `mouseMoved` or `mouseExited`).
    var isMouseMovement: Bool {
        type == .mouseMovements
    }
    
    /// A Boolean value indicating whether the `command` key is pressed.
    var isCommandPressed: Bool {
        modifierFlags.contains(.command)
    }
    
    /// A Boolean value indicating whether the `option` key is pressed.
    var isOptionPressed: Bool {
        modifierFlags.contains(.option)
    }
    
    /// A Boolean value indicating whether the `control` key is pressed.
    var isControlPressed: Bool {
        modifierFlags.contains(.control)
    }
    
    /// A Boolean value indicating whether the `shift` key is pressed.
    var isShiftPressed: Bool {
        modifierFlags.contains(.shift)
    }
    
    /// A Boolean value indicating whether the `capslock` key is pressed.
    var isCapsLockPressed: Bool {
        modifierFlags.contains(.capsLock)
    }
    
    /// A Boolean value indicating whether the `function` key is pressed.
    var isFunctionPressed: Bool {
        modifierFlags.contains(.function)
    }
    
    /// The characters associated with a key-up or key-down event.
    var charactersSafely:  String? {
        isKeyboard ? try? ObjCRuntime.catchException { characters } : nil
    }
    
    /// The characters generated by a key event as if no modifier key (except for Shift) applies.
    var charactersIgnoringModifiersSafely:  String? {
        isKeyboard ? try? ObjCRuntime.catchException { charactersIgnoringModifiers } : nil
    }
    
    /// The mouse button for a mouse event.
    var mouseButton: MouseButton? {
        isMouse ? MouseButton(rawValue: buttonNumber) : nil
    }
    
    /// Represents a mouse button type.
    enum MouseButton: RawRepresentable, Hashable {
        /// Left mouse button (`primary`).
        case left
        /// Right mouse button  (`secondary`).
        case right
        /// Middle mouse button (typically a scroll wheel press).
        case middle
        /// Other mouse button.
        case other(Int)
        
        public var rawValue: Int {
            switch self {
            case .left: return 0
            case .right: return 1
            case .middle: return 2
            case .other(let index): return index
            }
        }
        
        public init(rawValue: Int) {
            switch rawValue {
            case 0: self = .left
            case 1: self = .right
            case 2: self = .middle
            default: self = .other(rawValue)
            }
        }
    }
}

extension NSEvent.EventType {
    public static func == (lhs: Self, rhs: NSEvent.EventTypeMask) -> Bool {
        rhs.intersects(lhs)
    }
}

extension NSEvent.EventSubtype: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .applicationActivated: return "applicationActivated"
        case .applicationDeactivated: return "applicationDeactivated"
        case .windowMoved: return "windowMoved"
        case .screenChanged: return "screenChanged"
        case .touch: return "touch"
        case .tabletPoint: return "tabletPoint"
        case .tabletProximity: return "tabletProximity"
        case .mouseEvent:  return "mouseEvent"
        default: return "other(\(rawValue))"
        }
    }
}

extension NSEvent.Phase: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .changed: return "changed"
        case .cancelled: return "cancelled"
        case .ended: return "ended"
        case .began: return "began"
        case .mayBegin: return "mayBegin"
        case .stationary: return "stationary"
        default: return "\(rawValue)"
        }
    }
}

extension NSEvent.EventType: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .leftMouseDown: return "leftMouseDown"
        case .leftMouseUp: return "leftMouseUp"
        case .rightMouseDown: return "rightMouseDown"
        case .rightMouseUp: return "rightMouseUp"
        case .mouseMoved: return "mouseMoved"
        case .leftMouseDragged: return "leftMouseDragged"
        case .rightMouseDragged: return "rightMouseDragged"
        case .mouseEntered: return "mouseEntered"
        case .mouseExited: return "mouseExited"
        case .keyDown: return "keyDown"
        case .keyUp: return "keyUp"
        case .flagsChanged: return "flagsChanged"
        case .appKitDefined: return "appKitDefined"
        case .systemDefined: return "systemDefined"
        case .applicationDefined: return "applicationDefined"
        case .periodic: return "periodic"
        case .cursorUpdate: return "cursorUpdate"
        case .scrollWheel: return "scrollWheel"
        case .tabletPoint: return "tabletPoint"
        case .tabletProximity: return "tabletProximity"
        case .otherMouseDown: return "otherMouseDown"
        case .otherMouseUp: return "otherMouseUp"
        case .otherMouseDragged: return "otherMouseDragged"
        case .gesture: return "gesture"
        case .magnify: return "magnify"
        case .swipe: return "swipe"
        case .rotate: return "rotate"
        case .beginGesture: return "beginGesture"
        case .endGesture: return "endGesture"
        case .smartMagnify: return "smartMagnify"
        case .quickLook: return "quickLook"
        case .pressure: return "pressure"
        case .directTouch: return "directTouch"
        case .changeMode: return "changeMode"
        default: return "other(\(rawValue))"
        }
    }
}

extension NSEvent.PressureBehavior: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .primaryDefault: return "primaryDefault"
        case .primaryClick: return "primaryClick"
        case .primaryGeneric: return "primaryGeneric"
        case .primaryAccelerator: return "primaryAccelerator"
        case .primaryDeepClick: return "primaryDeepClick"
        case .primaryDeepDrag: return "primaryDeepDrag"
        default: return "\(rawValue)"
        }
    }
}

extension NSEvent.PointingDeviceType: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .pen: return "pen"
        case .cursor: return "cursor"
        case .eraser: return "eraser"
        default: return "\(rawValue)"
        }
    }
}

extension NSEvent.SpecialKey: Swift.CustomStringConvertible, Swift.Encodable, Swift.Decodable {
    public var description: String {
        switch self {
        case .backTab: return "backTab"
        case .backspace: return "backspace"
        case .begin: return "begin"
        case .break: return "break"
        case .carriageReturn: return "carriageReturn"
        case .clearDisplay: return "clearDisplay"
        case .clearLine: return "clearLine"
        case .delete: return "delete"
        case .deleteCharacter: return "deleteCharacter"
        case .deleteForward: return "deleteForward"
        case .deleteLine: return "deleteLine"
        case .downArrow: return "downArrow"
        case .end: return "end"
        case .enter: return "enter"
        case .execute: return "execute"
        case .f1: return "f1"
        case .f2: return "f2"
        case .f3: return "f3"
        case .f4: return "f4"
        case .f5: return "f5"
        case .f6: return "f6"
        case .f7: return "f7"
        case .f8: return "f8"
        case .f9: return "f9"
        case .f10: return "f10"
        case .f11: return "f11"
        case .f12: return "f12"
        case .f13: return "f13"
        case .f14: return "f14"
        case .f15: return "f15"
        case .f16: return "f16"
        case .f17: return "f17"
        case .f18: return "f18"
        case .f19: return "f19"
        case .f20: return "f20"
        case .f21: return "f21"
        case .f22: return "f22"
        case .f23: return "f23"
        case .f24: return "f24"
        case .f25: return "f25"
        case .f26: return "f26"
        case .f27: return "f27"
        case .f28: return "f28"
        case .f29: return "f29"
        case .f30: return "f30"
        case .f31: return "f31"
        case .f32: return "f32"
        case .f33: return "f33"
        case .f34: return "f34"
        case .f35: return "f35"
        case .find: return "find"
        case .formFeed: return "formFeed"
        case .help: return "help"
        case .home: return "home"
        case .insert: return "insert"
        case .insertCharacter: return "insertCharacter"
        case .insertLine: return "insertLine"
        case .leftArrow: return "leftArrow"
        case .lineSeparator: return "lineSeparator"
        case .menu: return "menu"
        case .modeSwitch: return "modeSwitch"
        case .newline: return "newline"
        case .next: return "next"
        case .pageDown: return "pageDown"
        case .pageUp: return "pageUp"
        case .paragraphSeparator: return "paragraphSeparator"
        case .pause: return "pause"
        case .prev: return "prev"
        case .print: return "print"
        case .printScreen: return "printScreen"
        case .redo: return "redo"
        case .reset: return "reset"
        case .rightArrow: return "rightArrow"
        case .scrollLock: return "scrollLock"
        case .select: return "select"
        case .stop: return "stop"
        case .sysReq: return "sysReq"
        case .system: return "system"
        case .tab: return "tab"
        case .undo: return "undo"
        case .upArrow: return "upArrow"
        case .user: return "user"
        default: return "\(rawValue)"
        }
    }
}

extension NSEvent.EventTypeMask: Swift.CustomStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    /// A Boolean value indicating whether the specified event intersects with the mask.
    public func intersects(_ event: NSEvent?) -> Bool {
        guard let event = event else { return false }
        if event.type == .mouse {
            return !event.associatedEventsMask.intersection(self).isEmpty
        }
        return intersects(event.type)
    }
    
    /// A Boolean value indicating whether the specified event type intersects with the mask.
    public func intersects(_ type: NSEvent.EventType) -> Bool {
        contains(Self(type: type))
    }
    
    /// A mask for user interaction events  (`keyboard`, `mouse`, `mouseMovements`, `magnify`, `scrollWheel`, `swipe` or `rotate`).
    public static let userInteraction: NSEvent.EventTypeMask = keyboard + mouse + mouseMovements + [.magnify, .scrollWheel, .swipe, .rotate]
    
    /// A mask for keyboard events (`keyDown`, `keyUp` or `flagsChanged`).
    public static let keyboard: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]
    
    /// A mask for mouse click events (`left`, `right` or `other`).
    public static let mouse: NSEvent.EventTypeMask = leftMouse + rightMouse + otherMouse
    
    /// A mask for left mouse click events  (`leftMouseDown`, `leftMouseUp` or `leftMouseDragged`).
    public static let leftMouse: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
    
    /// A mask for right mouse click events  (`rightMouseDown`, `rightMouseUp` or `rightMouseDragged`).
    public static let rightMouse: NSEvent.EventTypeMask = [.rightMouseDown, .rightMouseUp, .rightMouseDragged]
    
    /// A mask for other mouse click events (`otherMouseDown`, `otherMouseUp` or `otherMouseDragged`).
    public static let otherMouse: NSEvent.EventTypeMask = [.otherMouseDown, .otherMouseUp, .otherMouseDragged]
    
    /// A mask for mouse movement events (`mouseEntered`, `mouseMoved` or `mouseExited`).
    public static let mouseMovements: NSEvent.EventTypeMask = [.mouseEntered, .mouseMoved, .mouseExited]
    
    public var description: String {
        var strings: [String] = []
        if self.contains(.leftMouseDown) { strings += ".leftMouseDown" }
        if self.contains(.leftMouseUp) { strings += ".leftMouseDown" }
        if self.contains(.leftMouseDragged) { strings += ".leftMouseDown" }
        if self.contains(.rightMouseDown) { strings += ".leftMouseDown" }
        if self.contains(.rightMouseUp) { strings += ".leftMouseDown" }
        if self.contains(.rightMouseDragged) { strings += ".leftMouseDown" }
        if self.contains(.otherMouseDown) { strings += ".leftMouseDown" }
        if self.contains(.otherMouseUp) { strings += ".leftMouseDown" }
        if self.contains(.otherMouseDragged) { strings += ".leftMouseDown" }
        if self.contains(.keyDown) { strings += ".keyDown" }
        if self.contains(.keyUp) { strings += ".keyUp" }
        if self.contains(.flagsChanged) { strings += ".flagsChanged" }
        if self.contains(.mouseEntered) { strings += ".mouseEntered" }
        if self.contains(.mouseMoved) { strings += ".mouseMoved" }
        if self.contains(.mouseExited) { strings += ".mouseExited" }
        if self.contains(.beginGesture) { strings += ".beginGesture" }
        if self.contains(.endGesture) { strings += ".endGesture" }
        if self.contains(.magnify) { strings += ".magnify" }
        if self.contains(.smartMagnify) { strings += ".smartMagnify" }
        if self.contains(.swipe) { strings += ".swipe" }
        if self.contains(.rotate) { strings += ".rotate" }
        if self.contains(.gesture) { strings += ".gesture" }
        if self.contains(.directTouch) { strings += ".directTouch" }
        if self.contains(.tabletPoint) { strings += ".tabletPoint" }
        if self.contains(.tabletProximity) { strings += ".tabletProximity" }
        if self.contains(.pressure) { strings += ".pressure" }
        if self.contains(.scrollWheel) { strings += ".scrollWheel" }
        if self.contains(.changeMode) { strings += ".changeMode" }
        if self.contains(.appKitDefined) { strings += ".appKitDefined" }
        if self.contains(.applicationDefined) { strings += ".applicationDefined" }
        if self.contains(.cursorUpdate) { strings += ".cursorUpdate" }
        if self.contains(.periodic) { strings += ".periodic" }
        if self.contains(.systemDefined) { strings += ".systemDefined" }
        return "[\(strings.joined(separator: ", "))]"
    }
}
#endif
