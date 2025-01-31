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
            setupEventMonitors()
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
         
         You can return `String`, `URL`, `NSImage`, `NSColor` and `NSSound` values.
                  
         - Parameter location. The mouse location inside the view.
         - Returns: The content that can be dragged outside the view, or `nil` if the view doesn't provide any draggable content.
         */
        public var canDrag: ((_ location: CGPoint) -> ([PasteboardWriting]?))?
        /// An optional image used for dragging. If `nil`, a rendered image of the view is used.
        public var dragImage: ((_ location: CGPoint, _ content: PasteboardWriting) -> ((image: NSImage, imageFrame: CGRect?)))?
        /// The handler that gets called when the user did drag the content to a supported destination.
        public var didDrag: ((_ screenLocation: CGPoint, _ items: [PasteboardWriting]) -> ())?
        
        /// The operation for dragging files.
        public var fileDragOperation: FileDragOperation = .copy
        /// The visual format of multiple dragging items.
        public var draggingFormation: NSDraggingFormation = .default
        /// A Boolean value that determines whether the dragging image animates back to its starting point on a cancelled or failed drag.
        public var animatesToStartingPositionsOnCancelOrFail: Bool = true
        
        /// The operation for dragging files.
        public enum FileDragOperation: Int {
            /// Files are copied to the destination.
            case copy
            /// Files are moved to the destination.
            case move
            var operation: NSDragOperation {
                self == .copy ? .copy : .move
            }
        }
    }
    
    fileprivate var draggingGestureRecognizer: DraggingGestureRecognizer? {
        get { getAssociatedValue("draggingGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "draggingGestureRecognizer") }
    }
}

fileprivate class DraggingGestureRecognizer: NSGestureRecognizer, NSDraggingSource {
    var mouseDownLocation: CGPoint = .zero
    static let minimumDragDistance: CGFloat = 4.0
    
    var dragOperation: NSDragOperation = []
    var draggingItems: [DragItem] = []
    
    struct DragItem {
        let item: NSDraggingItem
        let content: PasteboardWriting
        var imageData: (image: NSImage, imageFrame: CGRect?)?
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
        dragOperation = view.dragHandlers.fileDragOperation.operation
        draggingItems = content.compactMap({ .init($0) })
        if let screenLocation = event.screenLocation, let handler = view.dragHandlers.dragImage {
            draggingItems.editEach({
                let dragImageData = handler(screenLocation, $0.content)
                $0.imageData = dragImageData
                $0.item.setDraggingFrame(dragImageData.imageFrame ?? CGRect(.zero, dragImageData.image.size), contents: dragImageData.image)
            })
        } else {
            let image = view.renderedImage
            draggingItems.forEach({ $0.item.setDraggingFrame(view.bounds, contents: image) })
        }
        let session = view.beginDraggingSession(with: draggingItems.compactMap({$0.item}), event: event, source: self)
        session.draggingFormation = view.dragHandlers.draggingFormation
        session.animatesToStartingPositionsOnCancelOrFail = view.dragHandlers.animatesToStartingPositionsOnCancelOrFail
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        dragOperation
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }
    
    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        guard !draggingItems.isEmpty else { return }
        view?.dragHandlers.didDrag?(screenPoint, draggingItems.compactMap({ $0.content }))
        draggingItems = []
    }
    
    func updateDraggingItems(for session: NSDraggingSession, screenPoint: NSPoint) {
        guard let handler = view?.dragHandlers.dragImage else { return }
        draggingItems.editEach({
            let dragImageData = handler(screenPoint, $0.content)
            if $0.imageData?.image != dragImageData.image || $0.imageData?.imageFrame != dragImageData.imageFrame {
                $0.imageData = dragImageData
                $0.item.setDraggingFrame(dragImageData.imageFrame ?? CGRect(.zero, dragImageData.image.size), contents: dragImageData.image)
            }
        })
    }
}

#endif
