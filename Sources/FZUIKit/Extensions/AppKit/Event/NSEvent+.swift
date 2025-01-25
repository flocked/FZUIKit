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
        window?.convertToScreen(CGRect(locationInWindow, .zero)).origin
    }
    
    /// The last event that the app retrieved from the event queue.
    static var current: NSEvent? {
        NSApplication.shared.currentEvent
    }
    
    /**
     Creates and returns a new key down event.
     
     - Parameters:
        - keyCode: The virtual code for the key.
        - modifierFlags: The pressed modifier keys.
        - location: The location of the event.
     */
    static func keyDown(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = [], location: CGPoint = .zero) -> NSEvent? {
        keyEvent(keyCode: keyCode, modifierFlags: modifierFlags, location: location, keyDown: true)
    }
    
    /**
     Creates and returns a new key up event.
     
     - Parameters:
        - keyCode: The virtual code for the key.
        - modifierFlags: The pressed modifier keys.
        - location: The location of the event.
     */
    static func keyUp(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = [], location: CGPoint = .zero) -> NSEvent? {
        keyEvent(keyCode: keyCode, modifierFlags: modifierFlags, location: location, keyDown: false)
    }
    
    private static func keyEvent(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = [], location: CGPoint = .zero, keyDown: Bool) -> NSEvent? {
        guard let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: keyDown) else { return nil }
        cgEvent.flags = modifierFlags.cgEventFlags
        cgEvent.location = location
        return NSEvent(cgEvent: cgEvent)
    }
    
    /**
     Creates and returns a new mouse event.
     
     - Parameters:
        - type: The mouse event type.
        - location: The cursor location in the base coordinate system of the window specified by windowNum.
        - modifierFlags: The position of the mouse cursor in global coordinates.
        - clickCount: The number of mouse clicks associated with the mouse event.
        - pressure: A value from `0.0` to `1.0` indicating the pressure applied to the input device on a mouse event, used for an appropriate device such as a graphics tablet. For devices that aren’t pressure-sensitive, the value should be either `0.0` or `1.0`.
     */
    static func mouse(_ type: NSEvent.EventType, location: CGPoint, modifierFlags: NSEvent.ModifierFlags = [], clickCount: Int = 1, pressure: Float = 1.0, window: NSWindow? = nil) -> NSEvent? {
        NSEvent.mouseEvent(with: type, location: location, modifierFlags: modifierFlags, timestamp: .nan, windowNumber: window?.windowNumber ?? 0, context: nil, eventNumber: Int.random(in: 0...Int.max), clickCount: clickCount, pressure: pressure)
    }
    
    /// A Boolean value that indicates whether no modifier key is pressed.
    var isNoModifierPressed: Bool {
        modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty
    }
    
    /// A Boolean value that indicates whether the event type is a right mouse-down event.
    var isRightMouseDown: Bool {
        type == .rightMouseDown || (modifierFlags.contains(.control) && type == .leftMouseDown)
    }
    
    /// A Boolean value that indicates whether the event is a right mouse-up event.
    var isRightMouseUp: Bool {
        type == .rightMouseUp || (modifierFlags.contains(.control) && type == .leftMouseUp)
    }
    
    /// A Boolean value that indicates whether the event is a user interaction event.
    var isUserInteraction: Bool {
        type == .userInteraction
    }
    
    /// A Boolean value that indicates whether the event is a keyboard event (`keyDown`, `keyUp` or `flagsChanged`).
    var isKeyboard: Bool {
        type == .keyboard
    }
    
    /// A Boolean value that indicates whether the event is a mouse click event.
    var isMouse: Bool {
        type == .mouse
    }
    
    /// A Boolean value that indicates whether the event is a left mouse click event.
    var isLeftMouse: Bool {
        type == .leftMouse
    }
    
    /// A Boolean value that indicates whether the event is a right mouse click event.
    var isRightMouse: Bool {
        type == .rightMouse
    }
    
    /// A Boolean value that indicates whether the event is an other mouse click event.
    var isOtherMouse: Bool {
        type == .otherMouse
    }
    
    /// A Boolean value that indicates whether the event is a mouse movement event (`mouseEntered`, `mouseMoved` or `mouseExited`).
    var isMouseMovement: Bool {
        type == .mouseMovements
    }
    
    /// A Boolean value that indicates whether the command key is pressed.
    var isCommandPressed: Bool {
        modifierFlags.contains(.command)
    }
    
    /// A Boolean value that indicates whether the option key is pressed.
    var isOptionPressed: Bool {
        modifierFlags.contains(.option)
    }
    
    /// A Boolean value that indicates whether the control key is pressed.
    var isControlPressed: Bool {
        modifierFlags.contains(.control)
    }
    
    /// A Boolean value that indicates whether the shift key is pressed.
    var isShiftPressed: Bool {
        modifierFlags.contains(.shift)
    }
    
    /// A Boolean value that indicates whether the capslock key is pressed.
    var isCapsLockPressed: Bool {
        modifierFlags.contains(.capsLock)
    }
}

extension NSEvent.EventType: Hashable, Codable { }
extension NSEvent.EventTypeMask: Hashable, Codable { }
extension NSEvent.ModifierFlags: Hashable, Codable { }

extension NSEvent.EventType {
    static func == (lhs: Self, rhs: NSEvent.EventTypeMask) -> Bool {
        rhs.intersects(lhs)
    }
}

public extension NSEvent.EventTypeMask {
    /**
     A Boolean value that indicates whether the specified event intersects with the event type mask.
     
     - Parameter event: The event for checking the intersection.
     - Returns: `true` if the event interesects with the mask, otherwise `false`.
     */
    func intersects(_ event: NSEvent?) -> Bool {
        guard let event = event else { return false }
        if event.type == .mouse {
            return event.associatedEventsMask.intersection(self).isEmpty == false
        }
        return self.intersects(event.type)
    }
    
    /**
     A Boolean value that indicates whether the specified event type intersects with the mask.
     
     - Parameter type: The event type.
     - Returns: `true` if the event type interesects with the mask, otherwise `false`.
     */
    func intersects(_ type: NSEvent.EventType) -> Bool {
        switch type {
        case .leftMouseDown: return contains(.leftMouseDown)
        case .leftMouseUp: return contains(.leftMouseUp)
        case .rightMouseDown: return contains(.rightMouseDown)
        case .rightMouseUp: return contains(.rightMouseUp)
        case .mouseMoved: return contains(.mouseMoved)
        case .leftMouseDragged: return contains(.leftMouseDragged)
        case .rightMouseDragged: return contains(.rightMouseDragged)
        case .mouseEntered: return contains(.mouseEntered)
        case .mouseExited: return contains(.mouseExited)
        case .keyDown: return contains(.keyDown)
        case .keyUp: return contains(.keyUp)
        case .flagsChanged: return contains(.flagsChanged)
        case .appKitDefined: return contains(.appKitDefined)
        case .systemDefined: return contains(.systemDefined)
        case .applicationDefined: return contains(.applicationDefined)
        case .periodic: return contains(.periodic)
        case .cursorUpdate: return contains(.cursorUpdate)
        case .scrollWheel: return contains(.scrollWheel)
        case .tabletPoint: return contains(.tabletPoint)
        case .tabletProximity: return contains(.tabletProximity)
        case .otherMouseDown: return contains(.otherMouseDown)
        case .otherMouseUp: return contains(.otherMouseUp)
        case .otherMouseDragged: return contains(.otherMouseDragged)
        case .gesture: return contains(.gesture)
        case .magnify: return contains(.magnify)
        case .swipe: return contains(.swipe)
        case .rotate: return contains(.rotate)
        case .beginGesture: return contains(.beginGesture)
        case .endGesture: return contains(.endGesture)
        case .smartMagnify: return contains(.smartMagnify)
        case .pressure: return contains(.pressure)
        case .directTouch: return contains(.directTouch)
        case .changeMode: return contains(.changeMode)
        //  case .quickLook: return contains(.quick)
        default: return false
        }
    }
    
    /// A mask all user interaction events.
    static let userInteraction: NSEvent.EventTypeMask = keyboard + mouse + mouseMoved + [.magnify, .scrollWheel, .swipe, .rotate]
    
    /// A mask for keyboard events.
    static let keyboard: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]
    
    /// A mask for mouse click events.
    static let mouse: NSEvent.EventTypeMask = leftMouse + rightMouse + otherMouse
    
    /// A mask for left mouse click events.
    static let leftMouse: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
    
    /// A mask for right mouse click events.
    static let rightMouse: NSEvent.EventTypeMask = [.rightMouseDown, .rightMouseUp, .rightMouseDragged]
    
    /// A mask for other mouse click events.
    static let otherMouse: NSEvent.EventTypeMask = [.otherMouseDown, .otherMouseUp, .otherMouseDragged]
    
    /// A mask for mouse movement events.
    static let mouseMovements: NSEvent.EventTypeMask = [.mouseEntered, .mouseMoved, .mouseExited]
    
    static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs.insert(rhs)
    }
}

public extension NSEvent.ModifierFlags {
    /// A Boolean value that indicates whether no modifier key is pressed.
    var hasNoKeyPressed: Bool {
        intersection(.deviceIndependentFlagsMask).isEmpty
    }
    
    /// A Boolean value that indicates whether the Command key is pressed.
    var isCommandPressed: Bool {
        contains(.command)
    }
    
    /// A Boolean value that indicates whether the Function key is pressed.
    var isOptionPressed: Bool {
        contains(.option)
    }
    
    /// A Boolean value that indicates whether the Control key is pressed.
    var isControlPressed: Bool {
        contains(.control)
    }
    
    /// A Boolean value that indicates whether the Command key is pressed.
    var isFunctionPressed: Bool {
        contains(.function)
    }
    
    /// A Boolean value that indicates whether the Shift key is pressed.
    var isShiftPressed: Bool {
        contains(.shift)
    }
    
    /// A Boolean value that indicates whether the Caps Lock key is pressed.
    var isCapsLockPressed: Bool {
        contains(.capsLock)
    }
    
    /// A Boolean value that indicates whether the Help key is pressed.
    var isHelpPressed: Bool {
        contains(.help)
    }
    
    /// A Boolean value that indicates whether a numeric keypad or arrow key is pressed.
    var isNumericPadOrArrowPressed: Bool {
        contains(.numericPad)
    }
    
    /// The modifier flags as `CGEventFlags`.
    var cgEventFlags: CGEventFlags {
        var flags: CGEventFlags = []
        if contains(.shift) { flags.insert(.maskShift) }
        if contains(.control) { flags.insert(.maskControl) }
        if contains(.command) { flags.insert(.maskCommand) }
        if contains(.numericPad) { flags.insert(.maskNumericPad) }
        if contains(.help) { flags.insert(.maskHelp) }
        if contains(.option) { flags.insert(.maskAlternate) }
        if contains(.function) { flags.insert(.maskSecondaryFn) }
        if contains(.capsLock) { flags.insert(.maskAlphaShift) }
        return flags
    }
}

extension CGEvent {
    /// The location of the mouse pointer.
    public static var mouseLocation: CGPoint? {
        CGEvent(source: nil)?.location
    }
}
#endif
