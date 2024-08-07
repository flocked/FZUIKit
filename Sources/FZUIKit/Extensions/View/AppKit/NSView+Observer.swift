//
//  NSView+Observer.swift
//  
//
//  Created by Florian Zand on 26.02.24.
//

#if os(macOS)
import AppKit

class ObserverGestureRecognizer: NSGestureRecognizer {
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
        if let view = view {
            mouseDownLocation = event.location(in: view)
        }
        didCheckDragging = false
        view?.mouseHandlers.leftDown?(event)
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        view?.mouseHandlers.leftUp?(event)
        super.mouseUp(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        setupMenuProvider(for: event)
        view?.mouseHandlers.rightDown?(event)
        super.rightMouseDown(with: event)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        view?.mouseHandlers.rightUp?(event)
        super.rightMouseUp(with: event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        view?.mouseHandlers.otherDown?(event)
        super.otherMouseDown(with: event)
    }
    
    override func otherMouseUp(with event: NSEvent) {
        view?.mouseHandlers.otherUp?(event)
        super.otherMouseUp(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        setupDraggingSession(for: event)
        view?.mouseHandlers.leftDragged?(event)
        super.mouseDragged(with: event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        view?.mouseHandlers.rightDragged?(event)
        super.rightMouseDragged(with: event)
    }
    
    override func otherMouseDragged(with event: NSEvent) {
        view?.mouseHandlers.otherDragged?(event)
        super.otherMouseDragged(with: event)
    }
    
    override func magnify(with event: NSEvent) {
        view?.mouseHandlers.magnify?(event)
        super.magnify(with: event)
    }
    
    override func rotate(with event: NSEvent) {
        view?.mouseHandlers.rotate?(event)
        super.rotate(with: event)
    }
    
    func setupMenuProvider(for event: NSEvent) {
        guard let view = view, let menuProvider = view.menuProvider else { return }
        let location = event.location(in: view)
        if let menu = menuProvider(location) {
            menu.setupDelegateProxy(itemProviderView: view)
            view.menu = menu
        } else {
            view.menu = nil
        }
    }
    
    var didCheckDragging = false
    var mouseDownLocation: CGPoint = .zero
    static let minimumDragDistance: CGFloat = 4.0

    func setupDraggingSession(for event: NSEvent) {
        guard !didCheckDragging, let view = view, let canDrag = view.dragHandlers.canDrag else { return }
        let location = event.location(in: view)
        guard mouseDownLocation.distance(to: location) >= Self.minimumDragDistance else { return }
        didCheckDragging = true
        guard let items = canDrag(location), !items.isEmpty, let observerView = view.observerView else { return }
        observerView.fileDragOperation = .copy
        if view.dragHandlers.fileDragOperation == .move, items.count == items.fileURLs.count {
            observerView.fileDragOperation = .move
        }
        let draggingItems = items.compactMap({NSDraggingItem($0)})
        let component: NSDraggingImageComponent
        if let dragImage =  view.dragHandlers.dragImage?(location) {
            component = .init(image: dragImage.image, frame: dragImage.imageFrame)
        } else {
            component = .init(view: view)
        }
        draggingItems.first?.imageComponentsProvider = { [component] }
        draggingItems.forEach({
            $0.draggingFrame = CGRect(.zero, view.bounds.size)
            // $0.imageComponentsProvider = { [component] }
        })
       // NSPasteboard.general.writeObjects(items.compactMap({$0.pasteboardWriting}))
        view.beginDraggingSession(with: draggingItems, event: event, source: observerView)
    }
}

#endif
