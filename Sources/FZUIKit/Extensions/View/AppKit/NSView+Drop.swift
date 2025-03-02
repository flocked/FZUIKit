//
//  NSView+Drop.swift
//  
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

extension NSView {
    /// The handlers for dropping content into the view.
    public var dropHandlers: DropHandlers {
        get { getAssociatedValue("dropHandlers", initialValue: DropHandlers()) }
        set {
            setAssociatedValue(newValue, key: "dropHandlers")
            if !newValue.isActive {
                dropView?.removeFromSuperview()
                dropView = nil
            } else {
                if dropView == nil {
                    dropView = DropView(for: self)
                }
                dropView?.handlers = newValue
            }
        }
    }
    
    /**
     The handlers dropping content (file urls, images, colors or strings) from the pasteboard to your view.
     
     Provide ``canDrop``, ``allowedExtensions``,  and/or ``allowedContentTypes`` to specify the items that can be dropped to the view.
     
     The system calls the ``canDrop`` handler to validate if your view accepts dropping the content on the pasteboard. If it returns `true`, the system calls the ``didDrop`` handler when the user drops the content to your view.
     
     In the following example the view accepts dropping of images and file urls:
     
     ```swift
     view.dropHandlers.canDrop = { items, location in
        if !items.images.isEmpty || !items.fileURLs.isEmpty {
            return true
        } else {
            return false
        }
     }
     
     view.dropHandlers.didDrop = { items, location in
        // dropped images
        let images = items.images
        
        // dropped file urls
        let fileURLs = items.fileURLs
     }
     ```
     */
    public struct DropHandlers {
        /// The allowed file content types that can be dropped to the view.
        @available(macOS 11.0, *)
        public var allowedContentTypes: [UTType] {
            get { _allowedContentTypes as? [UTType] ?? [] }
            set { _allowedContentTypes = newValue }
        }
        var _allowedContentTypes: Any?
        
        /**
         The allowed file extensions that can be dropped to the view.
         
         Use `""` to specify directories.
         */
        public var allowedExtensions: [String] = []
    
        /// A Boolean value that determines whether the user can drop multiple files with the specified content types  to the view.
        public var allowsMultipleFiles: Bool = true
        
        /**
         The handler that determines whether the user can drop the content from the pasteboard to your view.
         
         Implement the handler and return `true`, if the pasteboard contains content that your view accepts dropping.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ content: [PasteboardReading], _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ content: [PasteboardReading], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging enters the view’s bounds rectangle.
        public var dropEntered: ((_ content: [PasteboardReading], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging exits the view’s bounds rectangle.
        public var dropExited: (()->())?
        
        public var dropImage: ((_ item: NSPasteboardItem) -> (DragPreview?))?
        
        public var springLoading = SpringLoading()
        
        public struct SpringLoading {
            /// The handler that determines the spring loading options for the content.
            public var options: ((_ content: [PasteboardReading]) -> (NSSpringLoadingOptions))?
            /// The handler that gets called when the spring loading activation state changed.
            public var activated: ((_ activated: Bool) -> ())?
            /// The handler that gets called when the spring loading highlight state changed.
            public var highlightChanged: ((_ highlight: NSSpringLoadingHighlight) -> ())?
        }

        var isActive: Bool {
            if #available(macOS 11.0, *) {
                (canDrop != nil || !allowedContentTypes.isEmpty || !allowedExtensions.isEmpty) && didDrop != nil
            } else {
                (canDrop != nil || !allowedExtensions.isEmpty) && didDrop != nil
            }
        }
    }
    
    fileprivate var dropView: DropView? {
        get { getAssociatedValue("dropHandlerView") }
        set { setAssociatedValue(newValue, key: "dropHandlerView") }
    }
}

fileprivate class DropView: NSView, NSSpringLoadingDestination {
    var dropContent: [PasteboardReading] = []
    var acceptedDropContent: [PasteboardReading] = []
    var handlers = DropHandlers()
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard  handlers.isActive else { return [] }
        dropContent = sender.draggingPasteboard.content
        handlers.dropEntered?(dropContent, sender.location(in: self))
        return canDrop(sender, updateDraggingImage: true) ? .copy : []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard handlers.isActive else { return [] }
        let canDrop = self.canDrop(sender)
        return canDrop ? .copy : []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        handlers.dropExited?()
    }
    
    override func draggingEnded(_ sender: any NSDraggingInfo) {
        dropContent = []
        acceptedDropContent = []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard handlers.isActive, let didDrop = handlers.didDrop else { return false }
        if !acceptedDropContent.isEmpty {
            didDrop(acceptedDropContent, sender.location(in: self))
        }
        return !acceptedDropContent.isEmpty
    }
    
    func springLoadingEntered(_ draggingInfo: any NSDraggingInfo) -> NSSpringLoadingOptions {
        acceptedDropContent.isEmpty ? .disabled : handlers.springLoading.options?(acceptedDropContent) ?? .disabled
    }
    
    func springLoadingUpdated(_ draggingInfo: any NSDraggingInfo) -> NSSpringLoadingOptions {
        acceptedDropContent.isEmpty ? .disabled : handlers.springLoading.options?(acceptedDropContent) ?? .disabled
    }
    
    func springLoadingActivated(_ activated: Bool, draggingInfo: any NSDraggingInfo) {
        handlers.springLoading.activated?(activated)
    }
    
    func springLoadingHighlightChanged(_ draggingInfo: any NSDraggingInfo) {
        handlers.springLoading.highlightChanged?(draggingInfo.springLoadingHighlight)
    }
    
    override func hitTest(_: NSPoint) -> NSView? {
        nil
    }
    
    var renderItemsCount = -1
    weak var draggingInfo: NSDraggingInfo?
    var draggingItemImageComponents: [NSPasteboardItem: [NSDraggingImageComponent]] = [:] {
        didSet { updateDraggingItemImages() }
    }
    
    func updateDraggingItemImages() {
        guard renderItemsCount == draggingItemImageComponents.count, let draggingInfo = draggingInfo else { return }
        draggingInfo.enumerateDraggingItems(for: self, classes: [NSPasteboardItem.self]) { [weak self] draggingItem, index, shouldStop in
            guard let item = draggingItem.item as? NSPasteboardItem, let imageComponents = self?.draggingItemImageComponents[item] else { return }
            draggingItem.imageComponentsProvider = { imageComponents }
        }
    }
    
    override func updateDraggingItemsForDrag(_ sender: NSDraggingInfo?) {
        guard let draggingInfo = sender, let dropImageHandler = handlers.dropImage else { 
            super.updateDraggingItemsForDrag(sender)
            return
        }
        draggingItemImageComponents = [:]
        renderItemsCount = -1
        self.draggingInfo = draggingInfo
        let renderItems = (draggingInfo.draggingPasteboard.pasteboardItems ?? []).filter({ item in
            item.content.contains(where: { reading in self.acceptedDropContent.contains(where: { $0.pasteboardReading === reading.pasteboardReading }) })
        })
        renderItemsCount = renderItems.count
        renderItems.forEach({ item in
            (dropImageHandler(item) ?? .init()).render { [weak self] images in
                self?.draggingItemImageComponents[item] = images
            }
        })
    }
    
    func canDrop(_ draggingInfo: NSDraggingInfo, updateDraggingImage: Bool = false) -> Bool {
        acceptedDropContent = []
        let location = draggingInfo.location(in: self)
        var canDrop = false
        if let view = superview {
            canDrop = view.hitTest(location) === view
        }
        guard canDrop, !dropContent.isEmpty, handlers.isActive else { return false }
        if handlers.canDrop?(dropContent, location) == true {
            acceptedDropContent = dropContent
        } else {
            if !handlers.allowedExtensions.isEmpty {
                let allowedExtensions = handlers.allowedExtensions.compactMap({$0.lowercased()}).uniqued()
                acceptedDropContent += dropContent.fileURLs.filter({ allowedExtensions.contains($0.pathExtension.lowercased()) })
            }
            if #available(macOS 11.0, *) {
                if !handlers.allowedContentTypes.isEmpty {
                    acceptedDropContent += dropContent.fileURLs.filter({ $0.contentType?.conforms(toAny: handlers.allowedContentTypes) == true })
                }
            }
        }
        if acceptedDropContent.isEmpty || (!handlers.allowsMultipleFiles && acceptedDropContent.count > 1) {
            acceptedDropContent = []
            return false
        }
        
        return true
    }
    
    override func removeFromSuperview() {
        if let superview = superview, !superview.dropHandlers.isActive {
            super.removeFromSuperview()
        }
    }
    
    init(for view: NSView) {
        super.init(frame: .zero)
        registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color, .sound, .URL, .textFinderOptions, .rtf])
        zPosition = -20000
        view.addSubview(withConstraint: self)
        sendToBack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSShadow {
    func renderAsImage(path shadowPath: NSBezierPath, size: CGSize) -> NSImage {
        NSImage(shadowPath: shadowPath, size: size, color: shadowColor ?? .clear, radius: shadowBlurRadius, offset: shadowOffset.point)
    }
}

extension NSImage {
   convenience init(shadowPath: NSBezierPath, size: CGSize, configuration: ShadowConfiguration) {
        self.init(size: size)
        self.lockFocus()
        NSShadow(configuration: configuration).set()
        shadowPath.fill()
        self.unlockFocus()
    }
    
    convenience init(shadowPath: NSBezierPath, size: CGSize, color: NSColor = .shadowColor, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) {
        self.init(shadowPath: shadowPath, size: size, configuration: .color(color, opacity: 1.0, radius: radius, offset: offset))
    }
}

extension NSDraggingItem.ImageComponentKey {
    /// A key for a corresponding value that is a dragging item’s background color.
    public static let backgroundColor = NSDraggingItem.ImageComponentKey("backgroundColor")
    
    /// A key for a corresponding value that is a dragging item’s shadow.
    public static let shadow = NSDraggingItem.ImageComponentKey("shadow")
}

#endif
