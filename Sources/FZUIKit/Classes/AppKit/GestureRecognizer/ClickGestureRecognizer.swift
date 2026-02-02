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
        state = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.left) ? .recognized : .failed
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        state = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.right) ? .recognized : .failed
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        state = event.clickCount >= numberOfClicksRequired && requiredButtons.contains(.other) ? .recognized : .failed
    }
}

#endif
