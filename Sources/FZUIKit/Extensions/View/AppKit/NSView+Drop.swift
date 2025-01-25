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
        public var canDrop: ((_ content: [PasteboardContent], _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ content: [PasteboardContent], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging enters the view’s bounds rectangle.
        public var dropEntered: ((_ content: [PasteboardContent], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging exits the view’s bounds rectangle.
        public var dropExited: (()->())?

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

fileprivate class DropView: NSView {
    var dropContent: [PasteboardContent] = []
    var acceptedDropContent: [PasteboardContent] = []
    var handlers = DropHandlers()
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard  handlers.isActive else { return [] }
        dropContent = sender.draggingPasteboard.content()
        handlers.dropEntered?(dropContent, sender.location(in: self))
        return canDrop(sender) ? .copy : []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard handlers.isActive else { return [] }
        return canDrop(sender) ? .copy : []
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
    
    override func hitTest(_: NSPoint) -> NSView? {
        nil
    }
    
    func canDrop(_ draggingInfo: NSDraggingInfo) -> Bool {
        acceptedDropContent = []
        let location = draggingInfo.location(in: self)
        var canDrop = false
        if let view = superview {
            canDrop = view.hitTest(location) === view
        }
        guard canDrop, !dropContent.isEmpty, handlers.isActive else { return false }
        if !handlers.allowedExtensions.isEmpty {
            let allowedExtensions = handlers.allowedExtensions.compactMap({$0.lowercased()}).uniqued()
            let conformingURLs = dropContent.fileURLs.filter({ allowedExtensions.contains($0.pathExtension.lowercased()) })
            if !conformingURLs.isEmpty {
                let allowsMultiple = handlers.allowsMultipleFiles
                if allowsMultiple || (!allowsMultiple && conformingURLs.count == 1) {
                    acceptedDropContent = conformingURLs
                    return true
                }
            }
        }
        if #available(macOS 11.0, *) {
            if !handlers.allowedContentTypes.isEmpty {
                let conformingURLs = dropContent.fileURLs.filter({ $0.contentType?.conforms(toAny: handlers.allowedContentTypes) == true })
                if !conformingURLs.isEmpty {
                    let allowsMultiple = handlers.allowsMultipleFiles
                    if allowsMultiple || (!allowsMultiple && conformingURLs.count == 1) {
                        acceptedDropContent = conformingURLs
                        return true
                    }
                }
            }
        }
        if handlers.canDrop?(dropContent, location) == true {
            acceptedDropContent = dropContent
            return true
        }
        return false
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

#endif
