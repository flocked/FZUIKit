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
     - Parameters view: The view for the location.
     - Returns: The location of the event.
     */
    func location(in view: NSView) -> CGPoint {
        return view.convert(locationInWindow, from: nil)
    }

    /// The last event that the app retrieved from the event queue.
    static var current: NSEvent? {
        NSApplication.shared.currentEvent
    }

    /// A boolean value that indicates whether the event is a user interaction event (`keyDown`, `scrollWheel`, `magnify` and any mouseDown event).
    var isUserInteraction: Bool {
        NSEvent.EventTypeMask.userInteractions.intersects(self)
    }

    /// A boolean value that indicates whether the event is a mouse moved event (`mouseEntered`, `mouseMoved` and `mouseExited`).
    var isMouseMovement: Bool {
        NSEvent.EventTypeMask.mouseMovements.intersects(self)
    }
    
    /// A boolean value that indicates whether the command key is pressed.
    var isCommandDown: Bool {
        return modifierFlags.contains(.command)
    }

    /// A boolean value that indicates whether the option key is pressed.
    var isOptionDown: Bool {
        return modifierFlags.contains(.option)
    }

    /// A boolean value that indicates whether the control key is pressed.
    var isControlDown: Bool {
        return modifierFlags.contains(.control)
    }

    /// A boolean value that indicates whether the shift key is pressed.
    var isShiftDown: Bool {
        return modifierFlags.contains(.shift)
    }

    /// A boolean value that indicates whether the capslock key is pressed.
    var isCapsLockDown: Bool {
        return modifierFlags.contains(.capsLock)
    }

    /// A boolean value that indicates whether no modifier key (command, option, control, shift and capslock) is pressed.
    var isNoModifierDown: Bool {
        return modifierFlags.intersection([.command, .option, .control, .shift, .capsLock]).isEmpty
    }

    /// A boolean value that indicates whether the event type is a right click.
    var isRightClick: Bool {
        return (type == .rightMouseDown) || modifierFlags.contains(.control)
    }
}

public extension NSEvent.EventTypeMask {
    /**
     A boolean value that indicates whether the specified event intersects with the event type mask.
     
     - Parameters event: The event for checking the intersection.
     - Returns: `true` if the event interesects with the mask, or `false` if not.
     */
    func intersects(_ event: NSEvent?) -> Bool {
        return event?.associatedEventsMask.intersection(self).isEmpty == false
    }
    
    /// All user interaction event types (excluding mouse up events).
    static let userInteractions: NSEvent.EventTypeMask = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .scrollWheel, .magnify, .keyDown]
    /// All user interaction event types (including mouse up events).
    static let extendedUserInteractions: NSEvent.EventTypeMask = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .scrollWheel, .magnify]
    /// All mouse movement event types.
    static let mouseMovements: NSEvent.EventTypeMask = [.mouseEntered, .mouseMoved, .mouseExited]
}
#endif
