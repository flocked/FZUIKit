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
        setupDraggingSession(for: event)
        state = .failed
        view?.mouseHandlers.leftDragged?(event)
    }

    override func rightMouseDown(with event: NSEvent) {
        state = .began
        setupMenuProvider(for: event)
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

    func setupDraggingSession(for event: NSEvent) {
        guard let mouseLocation = mouseLocation, let view = view, let canDrag = view.dragHandlers.canDrag else { return }
        let location = event.location(in: view)
        guard mouseLocation.distance(to: location) >= Self.minimumDragDistance else { return }
        self.mouseLocation = nil
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
