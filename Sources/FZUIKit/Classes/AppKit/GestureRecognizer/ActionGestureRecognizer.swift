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
    
    /// An object that observes a specific action of a gesture recognizer.
    open class GestureActionObservation {
        /// The type of the  observered action.
        public let type: NSEvent.EventType
        
        ///  A Boolean value indicating whether the observation is active.
        public var isObserving: Bool {
            get { gestureRecognizer?.actionObservations[id] != nil }
            set { gestureRecognizer?.actionObservations[id] = newValue ? self : nil }
        }
        
        /// Invalidates the observation.
        public func invalidate() {
            gestureRecognizer?.actionObservations[id] = nil
        }
        
        let id = UUID()
        let handler: (NSEvent)->()
        weak var gestureRecognizer: ActionGestureRecognizer?
        
        init(type: NSEvent.EventType, gestureRecognizer: ActionGestureRecognizer, handler: @escaping (NSEvent)->()) {
            self.type = type
            self.gestureRecognizer = gestureRecognizer
            self.handler = handler
            gestureRecognizer.actionObservations[id] = self
        }
        
        deinit {
            invalidate()
        }
    }
    
    /**
     Observes calls for the specified event type and calls a handler.
     
     Example usage:
     
     ```swift
     
     let leftMouseDownObservation = gestureRecognizer.observe(.leftMouseDown) { event in
        // handle the left mouse down event
     }
     ```
     
     - Parameters:
        - type: The type of the event to observe.
        - handler: A closure that will be called when the event of the specified type is called.
     
     - Returns: An `GestureActionObservation` object representing the observation.
     */
    public func observe(_ type: NSEvent.EventType, handler: @escaping (NSEvent)->()) -> GestureActionObservation {
        GestureActionObservation(type: type, gestureRecognizer: self, handler: handler)
    }
    
    var actionObservations: [UUID: GestureActionObservation] = [:]
    
    func handlers(for type: NSEvent.EventType) -> [(NSEvent)->()] {
        actionObservations.values.filter({$0.type == type}).compactMap({$0.handler})
    }
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        handlers(for: .leftMouseDown).forEach({ $0(event)})
    }
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        handlers(for: .leftMouseUp).forEach({ $0(event)})
    }
    
    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        handlers(for: .leftMouseDragged).forEach({ $0(event)})
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        handlers(for: .rightMouseDown).forEach({ $0(event)})
    }
    
    open override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        handlers(for: .rightMouseUp).forEach({ $0(event)})
    }
    
    open override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        handlers(for: .rightMouseDragged).forEach({ $0(event)})
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        super.otherMouseDown(with: event)
        handlers(for: .otherMouseDown).forEach({ $0(event)})
    }
    
    open override func otherMouseUp(with event: NSEvent) {
        super.otherMouseUp(with: event)
        handlers(for: .otherMouseUp).forEach({ $0(event)})
    }
    
    open override func otherMouseDragged(with event: NSEvent) {
        super.otherMouseDragged(with: event)
        handlers(for: .otherMouseDragged).forEach({ $0(event)})
    }
    
    open override func rotate(with event: NSEvent) {
        super.rotate(with: event)
        handlers(for: .rotate).forEach({ $0(event)})
    }
    
    open override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        handlers(for: .magnify).forEach({ $0(event)})
    }
    
    open override func pressureChange(with event: NSEvent) {
        super.pressureChange(with: event)
        handlers(for: .pressure).forEach({ $0(event)})
    }
    
    open override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        handlers(for: .keyDown).forEach({ $0(event)})
    }
    
    open override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        handlers(for: .keyUp).forEach({ $0(event)})
    }
    
    open override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        handlers(for: .flagsChanged).forEach({ $0(event)})
    }
    
    open override func tabletPoint(with event: NSEvent) {
        super.tabletPoint(with: event)
        handlers(for: .tabletPoint).forEach({ $0(event)})
    }
}

#endif
