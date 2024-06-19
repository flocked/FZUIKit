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
         - Returns: The location of the event.
         */
        func location(in view: NSView) -> CGPoint {
            view.convert(locationInWindow, from: nil)
        }

        /// The last event that the app retrieved from the event queue.
        static var current: NSEvent? {
            NSApplication.shared.currentEvent
        }

        /// A Boolean value that indicates whether the event is a user interaction event (`keyDown`, `scrollWheel`, `magnify` and any mouseDown event).
        var isUserInteraction: Bool {
            NSEvent.EventTypeMask.userInteractions.intersects(self)
        }

        /// A Boolean value that indicates whether the event is a mouse moved event (`mouseEntered`, `mouseMoved` and `mouseExited`).
        var isMouseMovement: Bool {
            NSEvent.EventTypeMask.mouseMovements.intersects(self)
        }

        /// A Boolean value that indicates whether the command key is pressed.
        var isCommandDown: Bool {
            modifierFlags.contains(.command)
        }

        /// A Boolean value that indicates whether the option key is pressed.
        var isOptionDown: Bool {
            modifierFlags.contains(.option)
        }

        /// A Boolean value that indicates whether the control key is pressed.
        var isControlDown: Bool {
            modifierFlags.contains(.control)
        }

        /// A Boolean value that indicates whether the shift key is pressed.
        var isShiftDown: Bool {
            modifierFlags.contains(.shift)
        }

        /// A Boolean value that indicates whether the capslock key is pressed.
        var isCapsLockDown: Bool {
            modifierFlags.contains(.capsLock)
        }

        /// A Boolean value that indicates whether no modifier key (command, option, control, shift and capslock) is pressed.
        var isNoModifierDown: Bool {
            modifierFlags.intersection([.command, .option, .control, .shift, .capsLock]).isEmpty
        }

        /// A Boolean value that indicates whether the event type is a right click.
        var isRightClick: Bool {
            (type == .rightMouseDown) || modifierFlags.contains(.control)
        }
    }

    public extension NSEvent.EventType {
        /// All user interaction event types (excluding mouse up events).
        static let userInteractions: [NSEvent.EventType] = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .scrollWheel, .magnify, .keyDown]

        /// All user interaction event types (including mouse up events).
        static let extendedUserInteractions: [NSEvent.EventType] = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .scrollWheel, .magnify]

        static let allUserInteractions: [NSEvent.EventType] = [.leftMouseDown, .leftMouseUp, .leftMouseDragged, .rightMouseDown, .rightMouseUp, .rightMouseDragged, .scrollWheel, .magnify, .keyDown, .keyUp, .flagsChanged, .mouseMoved, .mouseExited, .mouseEntered]

        /// All mouse movement event types.
        static let mouseMovements: [NSEvent.EventType] = [.mouseEntered, .mouseMoved, .mouseExited]

        /// All the mouse event types.
        static let mouse: [NSEvent.EventType] = [.mouseMoved, .mouseExited, .mouseEntered, .leftMouseUp, .otherMouseUp, .rightMouseUp, .leftMouseDown, .otherMouseDown, .rightMouseDown, .leftMouseDragged, .otherMouseDragged, .rightMouseDragged]
    }

extension NSEvent.EventTypeMask: Hashable {
}

    public extension NSEvent.EventTypeMask {
        /**
         A Boolean value that indicates whether the specified event intersects with the event type mask.

         - Parameter event: The event for checking the intersection.
         - Returns: `true` if the event interesects with the mask, or `false` if not.
         */
        func intersects(_ event: NSEvent?) -> Bool {
            event?.associatedEventsMask.intersection(self).isEmpty == false
        }

        /// All user interaction event types (excluding mouse up events).
        static let userInteractions: NSEvent.EventTypeMask = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .scrollWheel, .magnify, .keyDown]

        /// All user interaction event types (including mouse up events).
        static let extendedUserInteractions: NSEvent.EventTypeMask = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .scrollWheel, .magnify]

        static let allUserInteractions: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged, .rightMouseDown, .rightMouseUp, .rightMouseDragged, .scrollWheel, .magnify, .keyDown, .keyUp, .flagsChanged, .mouseMoved, .mouseExited, .mouseEntered]

        /// All mouse movement event types.
        static let mouseMovements: NSEvent.EventTypeMask = [.mouseEntered, .mouseMoved, .mouseExited]

        /// All the mouse event types.
        static let mouse: NSEvent.EventTypeMask = [.mouseMoved, .mouseExited, .mouseEntered, .leftMouseUp, .otherMouseUp, .rightMouseUp, .leftMouseDown, .otherMouseDown, .rightMouseDown, .leftMouseDragged, .otherMouseDragged, .rightMouseDragged]
    }

    public extension NSEvent.ModifierFlags {
        /// A Boolean value that indicates whether the Command key has been pressed.
        var isCommandPressed: Bool {
            contains(.command)
        }

        /// A Boolean value that indicates whether the Function key has been pressed.
        var isOptionPressed: Bool {
            contains(.option)
        }

        /// A Boolean value that indicates whether the Control key has been pressed.
        var isControlPressed: Bool {
            contains(.control)
        }

        /// A Boolean value that indicates whether the Command key has been pressed.
        var isFunctionPressed: Bool {
            contains(.function)
        }

        /// A Boolean value that indicates whether the Shift key has been pressed.
        var isShiftPressed: Bool {
            contains(.shift)
        }

        /// A Boolean value that indicates whether the Caps Lock key has been pressed.
        var isCapsLockPressed: Bool {
            contains(.capsLock)
        }

        /// A Boolean value that indicates whether the Help key has been pressed.
        var isHelpPressed: Bool {
            contains(.help)
        }

        /// A Boolean value that indicates whether a key in the numeric keypad or an arrow key has been pressed.
        var isNumericPadOrArrowPressed: Bool {
            contains(.numericPad)
        }

        /// A Boolean value that indicates whether device-independent modifier flags are masked.
        var deviceIndependentFlagsAreMasked: Bool {
            contains(.deviceIndependentFlagsMask)
        }
    }

extension CGEvent {
    /// The location of the mouse pointer.
    public static var mouseLocation: CGPoint? {
        CGEvent(source: nil)?.location
    }
}
#endif
