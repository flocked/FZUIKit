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
            if newValue.canDrag == nil {
                draggingGestureRecognizer?.removeFromView()
                draggingGestureRecognizer = nil
            } else if draggingGestureRecognizer == nil {
                draggingGestureRecognizer = .init()
                addGestureRecognizer(draggingGestureRecognizer!)
            }
        }
    }
    
    /// The handlers for dragging content outside the view.
    public struct DragHandlers {
        /**
         The handler that determines whether the user can drag content outside the view.
         
         - Parameter location. The mouse location inside the view.
         - Returns: The content that can be dragged outside the view, or `nil` if the view doesn't provide any draggable content.
         
         You can return an array with any values of:
         
         - [String](https://developer.apple.com/documentation/swift/String)
         - [AttributedString](https://developer.apple.com/documentation/foundation/AttributedString) and [NSAttributedString](https://developer.apple.com/documentation/foundation/NSAttributedString)
         - [URL](https://developer.apple.com/documentation/foundation/URL)
         - [NSImage](https://developer.apple.com/documentation/appkit/NSImage)
         - [NSColor](https://developer.apple.com/documentation/appkit/NSColor)
         - [NSSound](https://developer.apple.com/documentation/appkit/NSSound)
         - [NSFilePromiseProvider](https://developer.apple.com/documentation/appkit/NSFilePromiseProvider)
         - [NSPasteboardItem](https://developer.apple.com/documentation/appkit/NSPasteboardItem)
         */
        public var canDrag: ((_ mouseLocation: CGPoint) -> ([PasteboardWriting]?))?
        /// An optional image used for dragging. If `nil`, a rendered image of the view is used.
        public var dragImage: ((_ location: CGPoint, _ content: PasteboardWriting) -> ((image: NSImage?, imageFrame: CGRect?)))?
        /// The handler that is called when the user did drag the content to a supported destination.
        public var didDrag: ((_ dragSession: NSDraggingSession, _ dragOperation: NSDragOperation) -> ())?
        
        public var dragUpdated: ((_ dragSession: NSDraggingSession) -> ())?
        
        /**
         The operation types allowed to be performent by drag destionations outside the application.
         
         The default value is `.copy`.
         */
        public var allowedDragOperationsOutsideApp: NSDragOperation = .copy

        /**
         The visual format of multiple dragging items.
         
         The default value is `default`.
         */
        public var draggingFormation: NSDraggingFormation = .default
        
        /**
         A Boolean value that determines whether the dragging image animates back to its starting point on a cancelled or failed drag.
         
         The default value is `true`.
         */
        public var animatesToStartingPositionsOnCancelOrFail: Bool = true
    }
    
    fileprivate var draggingGestureRecognizer: DraggingGestureRecognizer? {
        get { getAssociatedValue("draggingGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "draggingGestureRecognizer") }
    }
}

fileprivate class DraggingGestureRecognizer: NSGestureRecognizer, NSDraggingSource {
    var mouseDownLocation: CGPoint = .zero
    static let minimumDragDistance: CGFloat = 4.0
    
    var draggingItems: [DragItem] = []
    var draggingSession: NSDraggingSession?
    
    struct DragItem {
        let item: NSDraggingItem
        let content: PasteboardWriting
        var imageData: (image: NSImage?, imageFrame: CGRect?)?
        init(_ content: PasteboardWriting) {
            self.item = .init(content)
            self.content = content
        }
    }
    
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
        setupDraggingSession(for: event)
        state = .failed
    }
    
    func setupDraggingSession(for event: NSEvent) {
        guard let view = view, let canDrag = view.dragHandlers.canDrag else { return }
        let location = event.location(in: view)
        guard mouseDownLocation.distance(to: event.location(in: view)) >= Self.minimumDragDistance else { return }
        guard let content = canDrag(location), !content.isEmpty else { return }
        draggingItems = content.compactMap({ .init($0) })
        if let handler = view.dragHandlers.dragImage {
            draggingItems.editEach({
                let dragImageData = handler(location, $0.content)
                $0.imageData = dragImageData
                $0.item.setDraggingFrame(dragImageData.imageFrame ?? CGRect(.zero, dragImageData.image?.size ?? view.bounds.size), contents: dragImageData.image)
            })
        } else {
            draggingItems.forEach({ $0.item.setDraggingFrame(view.bounds, contents: nil) })
            draggingItems.first?.item.setDraggingFrame(view.bounds, contents: view.renderedImage)
        }
        let session = view.beginDraggingSession(with: draggingItems.compactMap({$0.item}), event: event, source: self)
        session.draggingFormation = view.dragHandlers.draggingFormation
        session.animatesToStartingPositionsOnCancelOrFail = view.dragHandlers.animatesToStartingPositionsOnCancelOrFail
        draggingSession = session
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        context == .withinApplication ? .every : view?.dragHandlers.allowedDragOperationsOutsideApp ?? []
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }
    
    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        guard !draggingItems.isEmpty else { return }
        guard let dragUpdated = view?.dragHandlers.dragUpdated else { return }
        draggingSession = draggingSession ?? session
        dragUpdated(draggingSession!)
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        guard !draggingItems.isEmpty, let didDrag = view?.dragHandlers.didDrag else { return }
        didDrag(draggingSession ?? session, operation)
        draggingItems = []
        draggingSession = nil
    }
    
    func updateDraggingItems(for session: NSDraggingSession, screenPoint: NSPoint) {
        guard let handler = view?.dragHandlers.dragImage else { return }
        draggingItems.editEach({
            let dragImageData = handler(screenPoint, $0.content)
            if $0.imageData?.image != dragImageData.image || $0.imageData?.imageFrame != dragImageData.imageFrame {
                $0.imageData = dragImageData
                $0.item.setDraggingFrame(dragImageData.imageFrame ?? CGRect(.zero, dragImageData.image?.size ?? view?.bounds.size ?? .zero), contents: dragImageData.image)
            }
        })
    }
}

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

#endif
