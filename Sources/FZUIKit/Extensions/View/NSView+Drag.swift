//
//  NSView+Drag.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

extension NSView {
    /// The handlers for dragging content outside the view.
    public var dragHandlers: DragHandlers {
        get { getAssociatedValue("dragHandlers", initialValue: DragHandlers()) }
        set {
            setAssociatedValue(newValue, key: "dragHandlers")
            setupObserverView()
            if !newValue.canDrag {
                dragGestureRecognizer?.removeFromView()
                dragGestureRecognizer = nil
            } else if dragGestureRecognizer == nil {
                dragGestureRecognizer = .init()
                addGestureRecognizer(dragGestureRecognizer!)
            }
        }
    }
    
    /// The handlers for dragging content outside the view.
    public struct DragHandlers {
        /**
         The handler that provides the dragging items for a possible drag.
         
         You can either use this property or provide dragging content using ``draggingContent``.
         */
        public var draggingItems: ((_ viewLocation: CGPoint) -> ([NSDraggingItem]))?
        
        /**
         The handler that provides the dragging content for a possible drag.
         
         You can either use this property or provide dragging items using ``draggingItems``.
         */
        public var draggingContent: ((_ viewLocation: CGPoint) -> ([any NSPasteboardWriting]))?
        
        /// The handler that gets called whenever a drag will begin.
        public var dragWillBegin: ((_ session: NSDraggingSession) -> ())?
        
        /// The handler that gets called whenever a drag did move.
        public var dragMoved: ((_ session: NSDraggingSession, _ screenLocation: CGPoint) -> ())?
        
        /// The handler that gets called whenever a drag did end.
        public var dragEnded: ((_ session: NSDraggingSession, _ screenLocation: CGPoint, _ operation: NSDragOperation) -> ())?
        
        /// The handler that decides whether modifier keys are ignored for a drag.
        public var ignoreModifierKeys: ((_ session: NSDraggingSession) -> (Bool))?
        
        /**
         The operation types allowed to be performent by drag destionations outside the application.
         
         The default value is `.copy`.
         */
        public var allowedDragOperationsOutsideApp: NSDragOperation = .copy

        /**
         The visual format of multiple dragging items.
         
         The default value is `default`.
         
         You can update the property at the beginning of a drag, using the drag session provided by ``dragWillBegin``.
         */
        public var draggingFormation: NSDraggingFormation = .default
        
        /**
         A Boolean value that determines whether the dragging image animates back to its starting point on a cancelled or failed drag.
         
         The default value is `true`.
         
         You can update the property at the beginning of a drag, using the drag session provided by ``dragWillBegin``.
         */
        public var animatesToStartingPositionsOnCancelOrFail: Bool = true
        
        var canDrag: Bool {
            draggingItems != nil || draggingContent != nil
        }
        
        func allDraggingItems(for location: CGPoint) -> [NSDraggingItem] {
            (draggingItems?(location) ?? []) + (draggingContent?(location).map({ NSDraggingItem(pasteboardWriter: $0) }) ?? [])
        }
    }
    
    fileprivate var dragGestureRecognizer: DragGestureRecognizer? {
        get { getAssociatedValue("dragGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "dragGestureRecognizer") }
    }
}

fileprivate class DragGestureRecognizer: NSGestureRecognizer, NSDraggingSource {
    static let minimumDragDistance: CGFloat = 4.0
    var didCheck = false
    var mouseDownLocation: CGPoint = .zero
    var draggingItems: [NSDraggingItem] = []
    
    init() {
        super.init(target: nil, action: nil)
        delaysPrimaryMouseButtonEvents = true
        reattachesAutomatically = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        state = .began
        state = .failed
        if let view = view {
            mouseDownLocation = event.location(in: view)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        state = .began
        state = .failed
    }
    
    override func mouseDragged(with event: NSEvent) {
        state = .began
        defer { state = .failed }
        
        guard let view = view, view.dragHandlers.canDrag else { return }
        let location = event.location(in: view)
        guard mouseDownLocation.distance(to: event.location(in: view)) >= Self.minimumDragDistance else { return }
        didCheck = true
        draggingItems = view.dragHandlers.allDraggingItems(for: location)
        guard !draggingItems.isEmpty else { return }
        for draggingItem in draggingItems {
            if draggingItem.imageComponentsProvider == nil, draggingItem.view == nil {
                draggingItem.view = view
            } else if draggingItem.draggingFrame == .zero {
                draggingItem.draggingFrame =  view.bounds
            }
        }
        let session = view.beginDraggingSession(with: draggingItems, event: event, source: self)
        session.draggingFormation = view.dragHandlers.draggingFormation
        session.animatesToStartingPositionsOnCancelOrFail = view.dragHandlers.animatesToStartingPositionsOnCancelOrFail
    }
    
    override func responds(to selector: Selector!) -> Bool {
        guard selector == #selector(NSDraggingSource.ignoreModifierKeys(for:)) else { return true }
        return view?.dragHandlers.ignoreModifierKeys != nil
    }
    
    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool {
        view?.dragHandlers.ignoreModifierKeys?(session) ?? false
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        context == .withinApplication ? .every : view?.dragHandlers.allowedDragOperationsOutsideApp ?? []
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        guard !draggingItems.isEmpty else { return }
        view?.dragHandlers.dragWillBegin?(session)
    }
    
    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        guard !draggingItems.isEmpty else { return }
        guard let dragUpdated = view?.dragHandlers.dragMoved else { return }
        dragUpdated(session, screenPoint)
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        didCheck = false
        guard !draggingItems.isEmpty else { return }
        view?.dragHandlers.dragEnded?(session, screenPoint, operation)
        draggingItems = []
    }
}

/*
func renderImage(for view: NSView, visiblePath: NSBezierPath? = nil, shadowPath: NSBezierPath? = nil, backgroundColor: NSColor = .clear) -> NSImage {
    
    let size = view.bounds.size
    let image = NSImage(size: size)
    
    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    // Step 1: Draw background color
    backgroundColor.setFill()
    NSBezierPath(rect: view.bounds).fill()
    
    // Step 2: Clip to visiblePath if provided
    if let path = visiblePath {
        path.addClip()
    }

    // Step 3: Draw view’s image
    let viewImage = view.renderedImage
    viewImage.draw(in: view.bounds, from: .zero, operation: .sourceOver, fraction: 1.0)

    // Step 4: Add shadow if shadowPath is provided
    if let shadow = shadowPath {
        context.saveGState()
        let cgPath = shadow.cgPath
        context.setShadow(offset: CGSize(width: 0, height: -5), blur: 10, color: NSColor.black.withAlphaComponent(0.25).cgColor)
        context.addPath(cgPath)
        context.setFillColor(NSColor.clear.cgColor)
        context.fillPath()
        context.restoreGState()
    }

    image.unlockFocus()
    return image
}

func renderImage(for image: NSImage, visiblePath: NSBezierPath? = nil, shadowPath: NSBezierPath? = nil, backgroundColor: NSColor = .clear) -> NSImage {
    
    let size = image.size
    let outputImage = NSImage(size: size)
    
    outputImage.lockFocus()
    let context = NSGraphicsContext.current!.cgContext
    
    // Step 1: Draw background color
    backgroundColor.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
    
    // Step 2: Clip to visible path if provided
    if let clipPath = visiblePath {
        clipPath.addClip()
    }

    // Step 3: Draw original image
    image.draw(at: .zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)

    // Step 4: Apply shadowPath if provided
    if let shadowPath = shadowPath {
        context.saveGState()
        context.setShadow(.color(.black.withAlphaComponent(0.25), radius: 10, offset: CGPoint(0, -5)))
        context.addPath(shadowPath.cgPath)
        context.setFillColor(.clear)
        context.fillPath()
        context.restoreGState()
    }

    outputImage.unlockFocus()
    return outputImage
}

func renderImage(for cgImage: CGImage, visiblePath: NSBezierPath? = nil, shadowPath: NSBezierPath? = nil, backgroundColor: NSColor = .clear) -> NSImage {
    renderImage(for: cgImage.nsImage, visiblePath: visiblePath, shadowPath: shadowPath, backgroundColor: backgroundColor)
}
*/

#endif
