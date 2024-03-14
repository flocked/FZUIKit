//
//  ActionGestureRecognizer.swift
//  
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit

/// A gesture recognizer that performs actions.
open class ActionGestureRecognizer: NSGestureRecognizer {
    
    /// The actions to perform.
    open var actions: [NSEvent.EventType: (NSEvent)->()] = [:]
    
    /// Initalizes the gesture recognizer.
    public init() {
        super.init(target: nil, action: nil)
    }
    
    /// Initalizes the gesture recognizer with the specified actions.
    public init(actions: [NSEvent.EventType : (NSEvent) -> Void]) {
        self.actions = actions
        super.init(target: nil, action: nil)
    }
        
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        actions[.leftMouseDown]?(event)
    }
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        actions[.leftMouseUp]?(event)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        actions[.leftMouseDragged]?(event)
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        actions[.rightMouseDown]?(event)
    }
    
    open override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        actions[.rightMouseUp]?(event)
    }
    
    open override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        actions[.rightMouseDragged]?(event)
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        super.otherMouseDown(with: event)
        actions[.otherMouseDown]?(event)
    }
    
    open override func otherMouseUp(with event: NSEvent) {
        super.otherMouseUp(with: event)
        actions[.otherMouseUp]?(event)
    }
    
    open override func otherMouseDragged(with event: NSEvent) {
        super.otherMouseDragged(with: event)
        actions[.otherMouseDragged]?(event)
    }
    
    open override func rotate(with event: NSEvent) {
        super.rotate(with: event)
        actions[.rotate]?(event)
    }
    
    open override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        actions[.magnify]?(event)
    }
    
    open override func pressureChange(with event: NSEvent) {
        super.pressureChange(with: event)
        actions[.pressure]?(event)
    }
    
    open override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        actions[.keyDown]?(event)
    }
    
    open override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        actions[.keyUp]?(event)
    }
    
    open override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        actions[.flagsChanged]?(event)
    }
    
    open override func tabletPoint(with event: NSEvent) {
        super.tabletPoint(with: event)
        actions[.tabletPoint]?(event)
    }
}

#endif
