//
//  NSView+Observer.swift
//  
//
//  Created by Florian Zand on 26.02.24.
//

#if os(macOS)
import AppKit

class ObserverGestureRecognizer: NSGestureRecognizer {
    var mouseLocation: CGPoint? = nil
    static let minimumDragDistance: CGFloat = 4.0
    
    init() {
        super.init(target: nil, action: nil)
        delaysPrimaryMouseButtonEvents = true
        delaysSecondaryMouseButtonEvents = true
        reattachesAutomatically = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func keyDown(with event: NSEvent) {
        view?.keyHandlers.keyDown?(event)
        super.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        view?.keyHandlers.keyUp?(event)
        super.keyUp(with: event)
    }
    
    override func flagsChanged(with event: NSEvent) {
        view?.keyHandlers.flagsChanged?(event)
        super.flagsChanged(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        state = .began
        state = .failed
        if let view = view {
            mouseLocation = event.location(in: view)
        }
        view?.mouseHandlers.leftDown?(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        state = .began
        state = .failed
        view?.mouseHandlers.leftUp?(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        state = .began
        state = .failed
        view?.mouseHandlers.leftDragged?(event)
    }

    override func rightMouseDown(with event: NSEvent) {
        state = .began
        state = .failed
        view?.mouseHandlers.rightDown?(event)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        state = .began
        state = .failed
        view?.mouseHandlers.rightUp?(event)
    }
    
    
    override func rightMouseDragged(with event: NSEvent) {
        state = .began
        state = .failed
        view?.mouseHandlers.rightDragged?(event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        view?.mouseHandlers.otherDown?(event)
    }
    
    override func otherMouseUp(with event: NSEvent) {
        view?.mouseHandlers.otherUp?(event)
    }
    
    override func otherMouseDragged(with event: NSEvent) {
        view?.mouseHandlers.otherDragged?(event)
    }
    
    override func magnify(with event: NSEvent) {
        view?.mouseHandlers.magnify?(event)
    }
    
    override func rotate(with event: NSEvent) {
        view?.mouseHandlers.rotate?(event)
    }
}

#endif
