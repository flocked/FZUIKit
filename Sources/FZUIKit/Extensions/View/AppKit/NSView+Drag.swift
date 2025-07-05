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
        public var dragImage: ((_ screenLocation: CGPoint, _ content: PasteboardWriting) -> ((image: NSImage, imageFrame: CGRect?)))?
        /// The handler that gets called when the user did drag the content to a supported destination.
        public var didDrag: ((_ dragSession: DraggingSession, _ dragOperation: NSDragOperation) -> ())?
        
        public var dragUpdated: ((_ dragSession: DraggingSession) -> ())?
        
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
    var draggingSession: DraggingSession?
    
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
        draggingSession = DraggingSession(for: session)
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        context == .withinApplication ? .all : view?.dragHandlers.allowedDragOperationsOutsideApp ?? []
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }
    
    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        guard !draggingItems.isEmpty else { return }
        guard let dragUpdated = view?.dragHandlers.dragUpdated else { return }
        draggingSession = draggingSession ?? .init(for: session)
        view?.dragHandlers.dragUpdated?(draggingSession!)
        updateDraggingItems(for: session, screenPoint: screenPoint)
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        guard !draggingItems.isEmpty, let didDrag = view?.dragHandlers.didDrag else { return }
        didDrag((draggingSession ?? .init(for: session))!, operation)
        draggingItems = []
        draggingSession = nil
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

public class DraggingImages {
    private let session: NSDraggingSession
    var isActive: Bool = true
    
    func enumerateDraggingItems(types: [PasteboardWriting.Type], using block: (_ item: DraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        guard isActive else { return }
        
        var _shouldStop = false
        session.enumerateDraggingItems(for: nil, classes: types.map({$0.pasteboardWritingType})) { item, index, shouldStop in
            guard let _item = DraggingItem(item) else { return }
            let imageComponents = _item.imageComponents
            block(_item, index, &_shouldStop)
            if let provider = _item.imageComponentsProvider {
                item.imageComponentsProvider = {
                    provider().map({$0.component})
                }
            } else {
                item.imageComponentsProvider = nil
            }
            shouldStop.pointee = _shouldStop ? true : false
        }
    }
    
    init(session: NSDraggingSession) {
        self.session = session
    }
}

/// An active dragging session.
public class DraggingSession {
    private let session: NSDraggingSession
    
    /// Identifier that uniquely identifies the dragging session.
    public var identifier: Int {
        session.draggingSequenceNumber
    }
    
    /// The pasteboard object that contains the data being dragged.
    public var draggingPasteboard: NSPasteboard {
        session.draggingPasteboard
    }
    
    /**
     Controls the dragging formation when the drag is not over the source or a valid destination.
     
     Setting this value causes the dragging formation to change immediately, provided a valid destination has not overriden the behavior. If the dragging session hasn’t started yet, the dragging items will animate into formation immediately upon start.
     
     It is highly recommended to never change the formation when starting a drag.
     
     The default value is `default`.
     */
    public var draggingFormation: NSDraggingFormation {
        get { session.draggingFormation }
        set { session.draggingFormation = newValue }
    }
    
    /// The current cursor location of the drag in screen coordinates.
    public var draggingLocation: CGPoint {
        session.draggingLocation
    }
    
    /// The index of the dragging item under the cursor.
    public var draggingLeaderIndex: Int {
        get { session.draggingLeaderIndex }
        set { session.draggingLeaderIndex = newValue }
    }
    
    /// The current destination window of the dragging session.
    public var destinationWindow: NSWindow? {
        session.destinationWindow
    }
    
    /// The current destination view of the dragging session.
    public var destinationView: NSView? {
        session.destinationView
    }
    
    /// The destination of a dragging session.
    public enum Destination {
        /// Source view.
        case source
        /// Application.
        case application
        /// Outside application.
        case outsideApplication
    }
    
    /// The current destination of the dragging session.
    public var destination: Destination {
        guard destinationWindow != nil else { return .outsideApplication }
        if let view = destinationView, (session.source as? NSView) === view {
            return .source
        } else if let window = destinationWindow, (session.source as? NSWindow) === window {
            return .source
        }
        return .application
    }
    
    init(for session: NSDraggingSession) {
        self.session = session
    }
}

/**
 A single dragged item within a dragging session.
 
 ``DraggingItem`` objects have extremely limited lifetimes.
 When you call the NSDraggingSession method beginDraggingSession(with:event:source:), the system immediately consumes the dragging items that pass to the method, and doesn’t retain them. Any further changes to the dragging item associated with the returned NSDraggingSession must occur with the enumeration method enumerateDraggingItems(options:for:classes:searchOptions:using:). When enumerating, the system creates NSDraggingItem instances right before giving them to the enumeration block. After returning from the block, the dragging item is no longer valid.
 */
public class DraggingItem {
    private let item: NSDraggingItem
    
    /// The pasteboard content.
    public let content: PasteboardWriting
    
    /**
     The frame of the dragging item.
     
     The dragging frame provides the spatial relationship between `DraggingItem` instances when you set the dragging formation to `none`.
     
     The exact coordinate space of this rectangle depends on where you use it. Examples are the view that initiates the drag using beginDraggingSession(with:event:source:) or the view you pass to the `DraggingSession` implementation of enumerateDraggingItems(options:for:classes:searchOptions:using:).
     */
    public var draggingFrame: CGRect {
        get { item.draggingFrame }
        set { item.draggingFrame = newValue }
    }
    
    /**
     An array of dragging image components to use to create the drag image.
     
     The array contains copies of the components. The drag does not reflect changes you make to these copies. If needed, the system calls the ``imageComponentsProvider`` block to generate the image components.
     */
    public var imageComponents: [ImageComponent]? {
        get { imageComponentsProvider?() }
        set {
            if let newValue = newValue {
                imageComponentsProvider = {
                    newValue
                }
            } else {
                imageComponentsProvider = nil
            }
        }
    }
    
    /**
     An array of blocks that provide the dragging image components.
     
     The dragging image is the composite of an array of ``ImageComponent``.
     
     The dragging image components aren’t set directly. Instead, use a block to generate the components and the system calls the block if necessary.
     
     You can set the block to `nil`, meaning that the drag item has no image. Generally, only dragging destinations do this, and only if there’s at least one valid item in the drop, and the receiver isn’t that object.
     
     The system arranges the components in painting order. That is, the system paints each component in the array on top of the previous components in the array.
     */
    public var imageComponentsProvider: (() -> [ImageComponent])? = nil
    
    /// Keys that identify components of a dragging image.
    public struct ImageComponentKey: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        public let rawValue: String
        
        /// A key for a corresponding value that is a dragging item’s image.
        public static let icon = ImageComponentKey("icon")
        
        /// A key for a corresponding value that represents a textual label for a dragging item, for example, a file name.
        public static let label = ImageComponentKey("label")
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }
    
    public struct ImageComponent: Hashable {
        /**
         The name of this image component.
         
         The key must be unique for each component in an `DraggingItem` instance.
         
         When an `DraggingItem` instances `imageComponents` are changed by one of the enumerateDraggingItemsWithOptions:forView:classes:searchOptions:usingBlock: methods the image associated with this key is morphed into the new image component’s image associated with the same key.
         */
        public var key: ImageComponentKey
        
        /// The image of the component.
        public var image: NSImage?
        
        /**
         The coordinate space is the bounds of the parent dragging item.
         
         The frame is `[[0,0], [draggingFrame.size.width, draggingFrame.size.height]]`.
         
         The coordinate space is the `bounds` of the parent `DraggingItem` instance’s `draggingFrame`.
         */
        public var frame: CGRect
        
        var component: NSDraggingImageComponent {
            let component = NSDraggingImageComponent(key: .init(key.rawValue))
            component.frame = frame
            component.contents = image
            return component
        }
        
        /// Initializes and returns a dragging image component with the specified key, image and frame.
        public init(key: ImageComponentKey = .icon, image: NSImage? = nil, frame: CGRect? = nil) {
            self.key = key
            self.image = image
            self.frame = frame ?? CGRect(.zero, image?.size ?? .zero)
        }
        
        /// Initializes and returns a dragging image component with the specified key, image and frame.
        public init(key: ImageComponentKey = .icon, image: CGImage, frame: CGRect? = nil) {
            self.key = key
            self.image = image.nsImage
            self.frame = frame ?? CGRect(.zero, image.size)
        }
        
        /// Initializes and returns a dragging image component with the specified key, view and frame.
        public init(key: ImageComponentKey = .icon, view: NSView) {
            self.key = key
            image = view.renderedImage
            frame = CGRect(.zero, view.bounds.size)
        }
        
        /// Initializes and returns a dragging image component with the specified image and key.
        public static func image(_ image: NSImage, key: ImageComponentKey = .icon) -> Self {
            Self(key: key, image: image)
        }
        
        /// Initializes and returns a dragging image component with the specified image and key.
        public static func image(_ image: CGImage, key: ImageComponentKey = .icon) -> Self {
            Self(key: key, image: image)
        }
        
        /// Initializes and returns a dragging image component with the specified symbol image and key.
        @available(macOS 11.0, *)
        public static func symbolImage(_ symbolName: String, key: ImageComponentKey = .icon) -> Self {
            Self(key: key, image: .init(systemSymbolName: symbolName))
        }
        
        /// Initializes and returns a dragging image component with the specified view and key.
        public static func view(_ view: NSView, key: ImageComponentKey = .icon) -> Self {
            Self(key: key, view: view)
        }
    }
    
    init?(_ item: NSDraggingItem) {
        guard let content = item.item as? PasteboardWriting else { return nil }
        self.item = item
        self.content = content
        if let provider = item.imageComponentsProvider {
            imageComponentsProvider = {
                provider().map({$0.imageComponent})
            }
        }
    }
    
    init(content: PasteboardWriting) {
        self.item = .init(content)
        self.content = content
    }
    
    init(content: PasteboardWriting, image: NSImage) {
        self.item = .init(content)
        self.content = content
        self.imageComponents = [.image(image)]
    }
    
    init(content: PasteboardWriting, view: NSView) {
        self.item = .init(content)
        self.content = content
        self.imageComponents = [.view(view)]
    }
}

extension NSDraggingImageComponent {
    var imageComponent: DraggingItem.ImageComponent {
        .init(key: .init(key.rawValue), image: image, frame: frame)
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
