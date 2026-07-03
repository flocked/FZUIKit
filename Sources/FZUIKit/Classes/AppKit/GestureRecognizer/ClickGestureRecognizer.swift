//
//  ClickGestureRecognizer.swift
//
//
//  Created by Florian Zand on 01.06.25.
//

#if os(macOS)
import AppKit

/**
 A discrete gesture recognizer that tracks a specified number of mouse clicks.
  
 Compared to [NSClickGestureRecognizer](https://developer.apple.com/documentation/appkit/NSClickGestureRecognizer) this gesture recognizer always forwards mouse clicks to it's view.
 */
open class ClickGestureRecognizer: NSGestureRecognizer {
    private var clickEvent: NSEvent?
    
    /// The number of clicks required to match.
    open var numberOfClicksRequired = 1
    
    /// Sets the number of clicks required to match.
    @discardableResult
    open func numberOfClicksRequired(_ clicks: Int) -> Self {
        numberOfClicksRequired = clicks
        return self
    }

    /// The mouse button (or buttons) required to recognize this click.
    open var requiredButtons: ButtonMask = .left
    
    /// Sets the mouse button (or buttons) required to recognize this click.
    @discardableResult
    open func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
    
    open override func mouseDown(with event: NSEvent) {
        clickEvent = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.left) ? event : nil
        state = clickEvent != nil ? .recognized : .failed
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        clickEvent = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.right) ? event : nil
        state = clickEvent != nil ? .recognized : .failed
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        clickEvent = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.other) ? event : nil
        state = clickEvent != nil ? .recognized : .failed
    }
    
    open override func location(in view: NSView?) -> NSPoint {
        guard let view = view else { return super.location(in: view) }
        return clickEvent?.location(in: view) ?? super.location(in: view)
    }
}

#endif
