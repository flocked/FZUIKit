//
//  NSEvent+.swift
//  FZCollection
//
//  Created by Florian Zand on 08.05.22.
//

#if os(macOS)

import AppKit
import Carbon
import Foundation

public extension NSEvent {
    func location(in view: NSView) -> CGPoint {
        return view.convert(locationInWindow, from: nil)
    }

    static var current: NSEvent? {
        NSApplication.shared.currentEvent
    }
}

public extension NSEvent {
    var isCommandDown: Bool {
        return modifierFlags.contains(.command)
    }

    var isOptionDown: Bool {
        return modifierFlags.contains(.option)
    }

    var isControlDown: Bool {
        return modifierFlags.contains(.control)
    }

    var isShiftDown: Bool {
        return modifierFlags.contains(.shift)
    }

    var isCapsLockDown: Bool {
        return modifierFlags.contains(.capsLock)
    }

    var isNoModifierDown: Bool {
        return modifierFlags.intersection([.command, .option, .control, .shift, .capsLock]).isEmpty
    }

    var isRightClick: Bool {
        return (type == .rightMouseDown) || modifierFlags.contains(.control)
    }
}

public extension NSEvent.EventTypeMask {
    func intersects(_ event: NSEvent?) -> Bool {
        return event?.associatedEventsMask.intersection(self).isEmpty == false
    }
}

public extension NSEvent.EventType {
    var isUserInteraction: Bool {
        Self.userInteractions.contains(self)
    }

    var isExtendedUserInteraction: Bool {
        Self.extendedUserInteractions.contains(self)
    }

    var isMouseMovement: Bool {
        Self.mouseMovements.contains(self)
    }

    static let userInteractions: [NSEvent.EventType] = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .scrollWheel, .magnify, .keyDown]
    static let extendedUserInteractions: [NSEvent.EventType] = [.leftMouseDragged, .leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .scrollWheel, .magnify]
    static let mouseMovements: [NSEvent.EventType] = [.mouseEntered, .mouseMoved, .mouseExited]
}

#endif
