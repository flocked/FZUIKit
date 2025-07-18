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
    
    /**
     An object that observes events for a specific event type of a ``ActionGestureRecognizer``.
     
     When the object is deinited or invalidated, it will stop observing.
     */
    open class GestureRecognizerEventObservation {
        /// The type of the  observered action.
        public let type: NSEvent.EventType
        
        ///  A Boolean value indicating whether the observation is active.
        open var isObserving: Bool {
            get { gestureRecognizer?.actionObservations[type, default: []].contains(where: {$0.id == id}) == true }
            set {
                guard newValue != isObserving else { return }
                if newValue {
                    gestureRecognizer?.actionObservations[type, default: []].append((id, handler))
                } else {
                    gestureRecognizer?.actionObservations[type, default: []].removeFirst(where: {$0.id == id})
                }
            }
        }
        
        /// Invalidates the observation.
        open func invalidate() {
            isObserving = false
        }
        
        private let id = UUID()
        private let handler: (NSEvent)->()
        private weak var gestureRecognizer: ActionGestureRecognizer?
        
        init(type: NSEvent.EventType, gestureRecognizer: ActionGestureRecognizer, handler: @escaping (NSEvent)->()) {
            self.type = type
            self.gestureRecognizer = gestureRecognizer
            self.handler = handler
            self.isObserving = true
        }
        
        deinit {
            invalidate()
        }
    }
    
    /**
     Observes events for the specified event type.
     
     When the returned ``GestureRecognizerEventObservation`` is deinited or invalidated, it will stop observing.

     Example usage:
     
     ```swift
     let gestureRecognizer = ActionGestureRecognizer()
     let leftMouseDownObservation = gestureRecognizer.observe(.leftMouseDown) {
        event in
        // handle the left mouse down event
     }
     ```
     
     - Parameters:
        - type: The event type to observe.
        - handler: The handler that is called for events of the specified type.
     
     - Returns: A ``GestureRecognizerEventObservation`` object representing the observation.
     */
    open func observe(_ type: NSEvent.EventType, handler: @escaping (_ event: NSEvent)->()) -> GestureRecognizerEventObservation {
        .init(type: type, gestureRecognizer: self, handler: handler)
    }
    
    var actionObservations: [NSEvent.EventType: [(id: UUID, handler: (NSEvent)->())]] = [:]
    
    private func callHandlers(for type: NSEvent.EventType, event: NSEvent) {
        actionObservations[type, default: []].forEach({ $0.handler(event) })
    }
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        callHandlers(for: .leftMouseDown, event: event)
    }
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        callHandlers(for: .leftMouseUp, event: event)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        callHandlers(for: .leftMouseDragged, event: event)
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        callHandlers(for: .rightMouseDown, event: event)
    }
    
    open override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        callHandlers(for: .rightMouseUp, event: event)
    }
    
    open override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        callHandlers(for: .rightMouseDragged, event: event)
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        super.otherMouseDown(with: event)
        callHandlers(for: .otherMouseDown, event: event)
    }
    
    open override func otherMouseUp(with event: NSEvent) {
        super.otherMouseUp(with: event)
        callHandlers(for: .otherMouseUp, event: event)
    }
    
    open override func otherMouseDragged(with event: NSEvent) {
        super.otherMouseDragged(with: event)
        callHandlers(for: .otherMouseDragged, event: event)
    }
    
    open override func rotate(with event: NSEvent) {
        super.rotate(with: event)
        callHandlers(for: .rotate, event: event)
    }
    
    open override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        callHandlers(for: .pressure, event: event)
    }
    
    open override func pressureChange(with event: NSEvent) {
        super.pressureChange(with: event)
        callHandlers(for: .pressure, event: event)
    }
    
    open override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        callHandlers(for: .keyDown, event: event)
    }
    
    open override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        callHandlers(for: .keyUp, event: event)
    }
    
    open override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        callHandlers(for: .flagsChanged, event: event)
    }
    
    open override func tabletPoint(with event: NSEvent) {
        super.tabletPoint(with: event)
        callHandlers(for: .tabletPoint, event: event)
    }
}

#endif
