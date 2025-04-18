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
     The handlers for dropping content (e.g. file urls, strings, images, etc.) from the pasteboard to your view.
     
     To allow dropping content to your view, you have to provide ``canDrop`` and/or ``allowedFiles-swift.property`` and ``didDrop``.
          
     The system calls the ``canDrop`` handler to validate if your view accepts dropping the content on the pasteboard. If it returns `true`, the system calls the ``didDrop`` handler when the user drops the content to your view.
     
     In the following example the view accepts dropping of strings and file urls:
     
     ```swift
     view.dropHandlers.canDrop = { dropInfo in
        if !dropInfo.content.strings.isEmpty || !dropInfo.content.fileURLs.isEmpty {
            return .copy
        } else {
            return []
        }
     }
     
     view.dropHandlers.didDrop = { dropInfo in
        // dropped strings
        let strings = dropInfo.content.strings
        
        // dropped file urls
        let fileURLs = dropInfo.content.fileURLs
     }
     ```
     */
    public struct DropHandlers {
        /**
         The handler that determines whether the user can drop the content from the pasteboard to your view.
         
         Implement the handler and return `true`, if the pasteboard contains content that your view accepts dropping.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ info: DropInfo) -> NSDragOperation)?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ info: DropInfo) -> Void)?
        
        /// The handler that gets called when a mouse containing pasteboard content enters the view.
        public var dropEntered: ((_ info: DropInfo) -> Void)?
        
        /// The handler that gets called when a mouse containing pasteboard content moves inside the view.
        public var dropUpdated: ((_ info: DropInfo) -> NSDragOperation)?

        /// The handler that gets called when a mouse containing pasteboard content exits the view.
        public var dropExited: ((_ info: DropInfo)->())?
        
        /// The handler that gets called after a drop session ended.
        public var dropEnded: ((_ info: DropInfo) -> Void)?
        
        /// The handler that gets called when the dragging images should be changed.
        public var updateDropItemImages: ((_ info: DropInfo)->())?
        
        /// The files that can be dropped to the view.
        public struct AllowedFiles {
            /**
             The allowed file extensions that can be dropped to the view.
             
             Use `""` to specify directories.
             */
            public var extensions: [String] = [] {
                didSet { extensions = extensions.compactMap({$0.lowercased() }).uniqued() }
            }
            
            /**
             The allowed file extensions that can be dropped to the view.
             
             Use `""` to specify directories.
             */
            public var fileTypes: [FileType] = [] {
                didSet { fileTypes = fileTypes.uniqued() }
            }
            
            /// The allowed file content types that can be dropped to the view.
            @available(macOS 11.0, *)
            public var contentTypes: [UTType] {
                get { _contentTypes as? [UTType] ?? [] }
                set {
                    let contentTypes = newValue.uniqued()
                    _contentTypes = contentTypes.isEmpty ? nil : contentTypes
                }
            }
            var _contentTypes: Any?
            
            /// A Boolean value that determines whether the user can drop multiple files with the specified content types  to the view.
            public var allowsMultipleFiles: Bool = true
            
            init() { }
            
            var isValid: Bool {
                !extensions.isEmpty || !fileTypes.isEmpty || _contentTypes != nil
            }
        }
        
        /// The files that can be dropped to the view.
        public var allowedFiles = AllowedFiles()
                        
        public var springLoading = SpringLoading()
        
        public struct SpringLoading {
            /// The handler that determines the spring loading options for the content.
            public var options: ((_ info: DropInfo) -> (NSSpringLoadingOptions))?
            /// The handler that gets called when the spring loading activation state changed.
            public var activated: ((_ activated: Bool) -> ())?
            /// The handler that gets called when the spring loading highlight state changed.
            public var highlightChanged: ((_ highlight: NSSpringLoadingHighlight) -> ())?
        }

        var isActive: Bool {
            (canDrop != nil || allowedFiles.isValid) && didDrop != nil
        }
    }
    
    fileprivate var dropView: DropView? {
        get { getAssociatedValue("dropHandlerView") }
        set { setAssociatedValue(newValue, key: "dropHandlerView") }
    }
}

fileprivate class DropView: NSView, NSSpringLoadingDestination {
    var handlers = DropHandlers()
    var draggingInfo: NSDraggingInfo?
    var canDropFiles = false
    var dropOperation: NSDragOperation?
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard  handlers.isActive else { return [] }
        draggingInfo = sender
        if let operation = dropOperation(for: sender) {
            return operation
        } else if let operation = handlers.canDrop?(sender.dropInfo(for: self)) {
            canDropFiles = canDropFiles(for: sender)
            dropOperation = operation
            return dropOperation(for: sender)!
        }
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard handlers.isActive, let operation = dropOperation(for: sender) else { return [] }
        draggingInfo = sender
        return operation
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        guard let info = sender ?? draggingInfo else { return }
        handlers.dropExited?(info.dropInfo(for: self))
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        draggingInfo = nil
        handlers.dropEnded?(sender.dropInfo(for: self))
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard handlers.isActive, let didDrop = handlers.didDrop else { return false }
        didDrop(sender.dropInfo(for: self))
        return true
    }
    
    func springLoadingEntered(_ draggingInfo: NSDraggingInfo) -> NSSpringLoadingOptions {
        guard let dropOperation = dropOperation(for: draggingInfo), dropOperation != [] else { return .disabled }
        return handlers.springLoading.options?(draggingInfo.dropInfo(for: self)) ?? .disabled
    }
    
    func springLoadingUpdated(_ draggingInfo: NSDraggingInfo) -> NSSpringLoadingOptions {
        guard let dropOperation = dropOperation(for: draggingInfo), dropOperation != [] else { return .disabled }
        return handlers.springLoading.options?(draggingInfo.dropInfo(for: self)) ?? .disabled
    }
    
    func springLoadingActivated(_ activated: Bool, draggingInfo: NSDraggingInfo) {
        handlers.springLoading.activated?(activated)
    }
    
    func springLoadingHighlightChanged(_ draggingInfo: NSDraggingInfo) {
        handlers.springLoading.highlightChanged?(draggingInfo.springLoadingHighlight)
    }
    
    /*
    override func updateDraggingItemsForDrag(_ sender: NSDraggingInfo?) {
        guard let draggingInfo = sender, let updateDropItemImages = handlers.updateDropItemImages else {
            super.updateDraggingItemsForDrag(sender)
            return
        }
        updateDropItemImages(draggingInfo.dropInfo(for: self))
    }
     */
    
    func dropOperation(for info: NSDraggingInfo) -> NSDragOperation? {
        guard var operation = dropOperation else { return nil }
        if canDropFiles {
            operation.insert(.copy)
        }
        return operation
    }
    
    func canDropFiles(for info: NSDraggingInfo) -> Bool {
        guard handlers.allowedFiles.isValid else { return false }
        let fileURLs = info.pasteboardContent.fileURLs
        var filtered: [URL] = []
        if !handlers.allowedFiles.extensions.isEmpty {
            filtered = fileURLs.filter({ handlers.allowedFiles.extensions.contains($0.pathExtension.lowercased())  })
        }
        if !handlers.allowedFiles.fileTypes.isEmpty {
            filtered += fileURLs.filter({ if let fileType = $0.fileType { return handlers.allowedFiles.fileTypes.contains(fileType) } else { return false } })
        }
        if #available(macOS 11.0, *) {
            if !handlers.allowedFiles.contentTypes.isEmpty {
                filtered += fileURLs.filter({ $0.contentType?.conforms(toAny: handlers.allowedFiles.contentTypes) == true })
            }
        }
        filtered = filtered.uniqued()
        return handlers.allowedFiles.allowsMultipleFiles ? !filtered.isEmpty : filtered.count == 1
    }
    
    override func hitTest(_: NSPoint) -> NSView? {
        nil
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

    /*
extension NSDragOperation {
    var first: NSDragOperation {
        if self == [] { return [] }
        if contains(.copy) { return .copy }
        if contains(.move) { return .move }
        if contains(.link) { return .link }
        return []
    }
}
 */

#endif
