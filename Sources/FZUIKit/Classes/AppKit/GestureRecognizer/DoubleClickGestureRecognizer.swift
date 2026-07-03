//
//  DoubleClickGestureRecognizer.swift
//
//
//  Created by Florian Zand on 01.06.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A gesture recognizer that tracks double mouse clicks.
open class DoubleClickGestureRecognizer: NSGestureRecognizer {
    private var doubleClickEvent: NSEvent?
    
    open override func mouseDown(with event: NSEvent) {
        doubleClickEvent = event.clickCount >= 2 ? event : nil
        state = event.clickCount >= 2 ? .recognized : .failed
    }
    
    open override func location(in view: NSView?) -> NSPoint {
        guard let view = view else { return super.location(in: view) }
        return doubleClickEvent?.location(in: view) ?? super.location(in: view)
    }
}

#endif
