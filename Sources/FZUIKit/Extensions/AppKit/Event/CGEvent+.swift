//
//  CGEvent+.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit

extension CGEvent {
    /// The key code of the event.
    public var keyCode: Int {
        Int(getIntegerValueField(.keyboardEventKeycode))
    }
    
    /// The x-coordinate change for scroll wheel, mouse-move, mouse-drag, and swipe events.
    public var deltaX: Double {
        getDoubleValueField(.mouseEventDeltaX)
    }
    
    /// The y-coordinate change for scroll wheel, mouse-move, mouse-drag, and swipe events.
    public var deltaY: Double {
        getDoubleValueField(.mouseEventDeltaY)
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

extension CGEventFlags: Hashable {
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

#endif
