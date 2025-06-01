//
//  DoubleClickGestureRecognizer.swift
//
//
//  Created by Florian Zand on 01.06.25.
//

#if os(macOS)
import AppKit

/// A gesture recognizer that tracks double mouse clicks.
open class DoubleClickGestureRecognizer: NSGestureRecognizer {
    open override func mouseDown(with event: NSEvent) {
        state = event.clickCount == 2 ? .recognized : .failed
    }
}

#endif
