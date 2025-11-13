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
        
        /**
         The handler that is called when a drop is valid.
         
         A handler that notifies your view about the validity of a potential drop operation.
         
         This handler is called when the validity of a drop changes. If `isValid` is `true`, it means your ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` handler doesn't return `[]`. If it isn't,  it indicates that the drag operation has either finished, been cancelled, or is no longer valid.
         
         Use this handler to provide visual feedback to the user, such as highlighting the view's background when a valid drop is possible.
                  
         In the following example the view's background color is updated based on if the drop has file urls: After dropping the urls or cancelling the drop, the view's background is set back to `nil`.
         
         ```swift
         view.dropHandlers.canDrop = { dropInfo in
             !dropInfo.content.fileURLs.isEmpty ? .copy : []
         }

         view.dropHandlers.hasValidDrop = { isValid in
             view.backgroundColor = isValid ? .systemBlue : nil
         }

         view.dropHandlers.didDrop = { dropInfo in
             let fileURLs = dropInfo.content.fileURLs
             // Handle the dropped file URLs…
         }
         */
        public var hasValidDrop: (( _ isValid: Bool) -> ())?
        
        /// The handler that is called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ info: DropInfo) -> ())?
        
        /// The handler that is called when a mouse drag containing pasteboard content enters the view.
        public var dropEntered: ((_ info: DropInfo) -> ())?
        
        /**
         The handler that is called when a mouse drag containing pasteboard content moves within the view's `bounds`.
         
         Similar to ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` the handler determines whether the user can drop the content from the pasteboard to your view.
         
         It's useful for dynamically updating the allowed operation based on the mouse location.
         
         - Note: ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` is still required for supporting droping pastebard content.
         */
        public var dropUpdated: ((_ info: DropInfo) -> NSDragOperation)?

        /// The handler that is called when a mouse drag containing pasteboard content exits the view.
        public var dropExited: ((_ info: DropInfo)->())?
        
        /// The handler that is called after a drop session ended.
        public var dropEnded: ((_ info: DropInfo) -> ())?
        
        /**
         A Boolean value indicating whether the ``AppKit/NSView/DropHandlers-swift.struct/dropUpdated`` handler is called periodicallly, even if the mouse isn't moving.
         
         If set to `false`, the handler is only called when the mouse moves or a modifier flag changes. The default value is `true` and calls the handler periodically even if nothing changed.
         */
        public var updatesPeriodic = true
        
        /**
         The handler that is called when the dragging images should be changed.
         
         While you may update the dragging images of ``DropInfo`` at any time, it is recommended to wait until this method is called before updating the dragging images.
         
         This allows the system to delay changing the dragging images until it is likely that the user will drop on this destination. Otherwise, the dragging images will change too often during the drag which would be distracting to the user.
         
         During ``DropInfo/enumerateDropItems(for:using:)`` you may set non-acceptable drag items images to `nil` to hide them or use the enumeration option of clearNonenumeratedImages If there are items that you hide, then after enumeration, you need to set the ``DropInfo/numberOfValidItemsForDrop`` to the number of non-hidden drag items. However, if the valid item count is `0`, then it is better to return `[]` from your implementation of ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` and, or ``AppKit/NSView/DropHandlers-swift.struct/dropUpdated`` instead of hiding all drag items during enumeration.
         */
        public var updateDraggingItems: ((_ info: DropInfo)->())?
        
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
            
            var filters: [(URL)->Bool] {
                var filters: [(URL)->Bool] = []
                if !extensions.isEmpty {
                    filters += { extensions.contains($0.pathExtension.lowercased())  }
                }
                if !fileTypes.isEmpty {
                    filters += { if let fileType = $0.fileType { return fileTypes.contains(fileType) } else { return false } }
                }
                if #available(macOS 11.0, *), !contentTypes.isEmpty {
                    filters += { $0.contentType?.conforms(toAny: contentTypes) == true }
                }
                return filters
            }
        }
        
        /// The files that can be dropped to the view.
        public var allowedFiles = AllowedFiles()
                        
        public var springLoading = SpringLoading()
        
        public struct SpringLoading {
            /// The handler that determines the spring loading options for the content.
            public var options: ((_ info: DropInfo) -> (NSSpringLoadingOptions))?
            /// The handler that is called when the spring loading activation state changed.
            public var activated: ((_ activated: Bool) -> ())?
            /// The handler that is called when the spring loading highlight state changed.
            public var highlightChanged: ((_ highlight: NSSpringLoadingHighlight) -> ())?
        }

        var isActive: Bool {
            (allowedFiles.isValid || canDrop != nil) && didDrop != nil
        }
    }
    
    fileprivate var dropView: DropView? {
        get { getAssociatedValue("dropHandlerView") }
        set { setAssociatedValue(newValue, key: "dropHandlerView") }
    }
}

// NSSpringLoadingDestination
class DropView: NSView {
    var handlers = DropHandlers()
    private var draggingInfo: NSDraggingInfo?
    private var canDropFiles = false
    private var dropOperation: NSDragOperation?
    private var superviewObservation: KeyValueObservation?
    private weak var view: NSView?
    private var hasValidDrop = false {
        didSet {
            guard oldValue != hasValidDrop, handlers.isActive else { return }
            handlers.hasValidDrop?(hasValidDrop)
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return dropOperation(for: sender)
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        dropOperation(for: sender, isUpdate: true)
    }
    
    override func wantsPeriodicDraggingUpdates() -> Bool {
        handlers.updatesPeriodic && handlers.dropUpdated != nil
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        guard let info = sender ?? draggingInfo else { return }
        hasValidDrop = false
        handlers.dropExited?(info.dropInfo(for: self))
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        draggingInfo = nil
        handlers.dropEnded?(sender.dropInfo(for: self))
        hasValidDrop = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard handlers.isActive, let didDrop = handlers.didDrop else { return false }
        didDrop(sender.dropInfo(for: self))
        return true
    }
    
    override func updateDraggingItemsForDrag(_ sender: NSDraggingInfo?) {
        guard let sender = sender else { return }
        handlers.updateDraggingItems?(sender.dropInfo(for: self))
    }
    
    /*
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
    */
    
    func dropOperation(for info: NSDraggingInfo, isUpdate: Bool = false) -> NSDragOperation {
        guard handlers.isActive else { return [] }
        let dropInfo = info.dropInfo(for: self)
        if dropOperation == nil {
            dropOperation = handlers.canDrop?(dropInfo) ?? []
            canDropFiles = canDropFiles(for: info)
            handlers.dropEntered?(dropInfo)
        }
        if isUpdate, let operation = handlers.dropUpdated?(dropInfo) {
            dropOperation = operation
        }
        var operation = dropOperation ?? []
        if canDropFiles {
            operation += .copy
        }
        hasValidDrop = operation != []
        draggingInfo = info
        return operation
    }
    
    override func shouldDelayWindowOrdering(for event: NSEvent) -> Bool {
        // Swift.print("shouldDelayWindowOrdering", event)
        return super.shouldDelayWindowOrdering(for: event)
    }
    
    func canDropFiles(for info: NSDraggingInfo) -> Bool {
        guard handlers.allowedFiles.isValid else { return false }
        var fileURLs = info.pasteboardContent.fileURLs
        var filtered: [URL] = []
        if !handlers.allowedFiles.extensions.isEmpty {
            filtered = fileURLs.removeAll(where: { handlers.allowedFiles.extensions.contains($0.pathExtension.lowercased())  })
        }
        if !handlers.allowedFiles.fileTypes.isEmpty {
            filtered += fileURLs.removeAll(where: { if let fileType = $0.fileType { return handlers.allowedFiles.fileTypes.contains(fileType) } else { return false } })
        }
        if #available(macOS 11.0, *) {
            if !handlers.allowedFiles.contentTypes.isEmpty {
                filtered += fileURLs.removeAll(where:  { $0.contentType?.conforms(toAny: handlers.allowedFiles.contentTypes) == true })
            }
        }
        return handlers.allowedFiles.allowsMultipleFiles ? !filtered.isEmpty : filtered.count == 1
    }
    
    override func hitTest(_: NSPoint) -> NSView? {
        nil
    }
    
    override func removeFromSuperview() {
        if let superview = superview, !superview.dropHandlers.isActive {
            superviewObservation = nil
            super.removeFromSuperview()
        }
    }
    
    init(for view: NSView) {
        super.init(frame: .zero)
        registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color, .sound, .URL, .textFinderOptions, .rtf])
        zPosition = -20000
        view.addSubview(withConstraint: self)
        sendToBack()
        self.view = view
        superviewObservation = observeChanges(for: \.superview) { [weak self] old, new in
            guard let self = self, let view = self.view, old !== view else { return }
            view.addSubview(self)
            self.sendToBack()
        }
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
