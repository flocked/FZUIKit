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
                  
         Implement the handler and return a valid drag operation, if the pasteboard contains content that your view accepts dropping.
         
         To check the content of a drag, use the ``AppKit/NSDraggingInfo/content`` property of the dragging info.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ info: NSDraggingInfo) -> NSDragOperation)?
        
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
        public var didDrop: ((_ info: NSDraggingInfo) -> ())?
        
        /// The handler that is called when a mouse drag containing pasteboard content enters the view.
        public var dropEntered: ((_ info: NSDraggingInfo) -> ())?
        
        /**
         The handler that is called when a mouse drag containing pasteboard content moves within the view's `bounds`.
         
         Similar to ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` the handler determines whether the user can drop the content from the pasteboard to your view.
         
         It's useful for dynamically updating the allowed operation based on the mouse location.
         
         - Note: ``AppKit/NSView/DropHandlers-swift.struct/canDrop`` is still required for supporting droping pastebard content.
         */
        public var dropUpdated: ((_ info: NSDraggingInfo) -> NSDragOperation)?

        /// The handler that is called when a mouse drag containing pasteboard content exits the view.
        public var dropExited: ((_ info: NSDraggingInfo)->())?
        
        /// The handler that is called after a drop session ended.
        public var dropEnded: ((_ info: NSDraggingInfo) -> ())?
        
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
        public var updateDraggingItems: ((_ info: NSDraggingInfo)->())?
        
        /// Indicates whether the view is currently an active drop target and whether the dragged item can be accepted.
        public enum DropState {
            /// No drag operation is currently over the view.
            case inactive
            /// A drag operation is over the view, but the dragged item cannot be dropped.
            case invalid
            /// A drag operation is over the view and the dragged item can be dropped.
            case valid
        }
        
        /// The handler that is called whenever the drop state changes.
        public var stateChanged: ((_ state: DropState)->())?
               
        /*
        public var springLoading = SpringLoading()
        
        public struct SpringLoading {
            /// The handler that determines the spring loading options for the content.
            public var options: ((_ info: DropInfo) -> (NSSpringLoadingOptions))?
            /// The handler that is called when the spring loading activation state changed.
            public var activated: ((_ activated: Bool) -> ())?
            /// The handler that is called when the spring loading highlight state changed.
            public var highlightChanged: ((_ highlight: NSSpringLoadingHighlight) -> ())?
        }
         */

        var isActive: Bool {
            canDrop != nil && didDrop != nil
        }
    }
    
    fileprivate var dropView: DropView? {
        get { getAssociatedValue("dropHandlerView") }
        set { setAssociatedValue(newValue, key: "dropHandlerView") }
    }
}

class DropView: NSView {
    var handlers = DropHandlers()
    private var draggingInfo: NSDraggingInfo?
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
        sender.view = view
        return dropOperation(for: sender)
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        sender.view = view
        return dropOperation(for: sender, isUpdate: true)
    }
    
    override func wantsPeriodicDraggingUpdates() -> Bool {
        handlers.updatesPeriodic && handlers.dropUpdated != nil
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        sender?.view = view
        guard let info = sender ?? draggingInfo else { return }
        hasValidDrop = false
        handlers.dropExited?(info)
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        sender.view = view
        draggingInfo = nil
        handlers.dropEnded?(sender)
        hasValidDrop = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        sender.view = view
        guard handlers.isActive, let didDrop = handlers.didDrop else { return false }
        didDrop(sender)
        return true
    }
    
    override func updateDraggingItemsForDrag(_ sender: NSDraggingInfo?) {
        sender?.view = view
        guard let sender = sender else { return }
        handlers.updateDraggingItems?(sender)
    }
    
    func dropOperation(for info: NSDraggingInfo, isUpdate: Bool = false) -> NSDragOperation {
        guard handlers.isActive else { return [] }
        let dropInfo = info
        if dropOperation == nil {
            dropOperation = handlers.canDrop?(dropInfo) ?? []
            handlers.dropEntered?(dropInfo)
        }
        if isUpdate, let operation = handlers.dropUpdated?(dropInfo) {
            dropOperation = operation
        }
        let operation = dropOperation ?? []
        draggingInfo = info
        hasValidDrop = operation != []
        return operation
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
    
    override func hitTest(_: NSPoint) -> NSView? {
        nil
    }
    
    override func removeFromSuperview() {
        guard let superview = superview, !superview.dropHandlers.isActive else { return }
        superviewObservation = nil
        super.removeFromSuperview()
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
    
    /*
    override func shouldDelayWindowOrdering(for event: NSEvent) -> Bool {
        return super.shouldDelayWindowOrdering(for: event)
    }
     */
}

/*
extension NSView.DropHandlers {
    mutating func setAllowedFiles(extensions: Set<String>, contentTypes: Set<UTType>, fileTypes: Set<FileType>, allowsMultiple: Bool = true) {
        guard !extensions.isEmpty || !fileTypes.isEmpty || !contentTypes.isEmpty else { return }
        canDrop = { info in
            let fileURLs = info.content.fileURLs
            var filtered = fileURLs.filter(extensions: extensions)
            if !filtered.isEmpty, allowsMultiple || filtered.count == 1 {
                return .copy
            }
            filtered = fileURLs.filter(types: fileTypes)
            if !filtered.isEmpty, allowsMultiple || filtered.count == 1 {
                return .copy
            }
            filtered = fileURLs.filter(contentTypes: contentTypes)
            if !filtered.isEmpty, allowsMultiple || filtered.count == 1 {
                return .copy
            }
            return []
        }
    }
}

fileprivate extension Sequence where Element == URL {
    func filter<S: Sequence<UTType>>(contentTypes: S) -> [URL] {
        filter({
            guard let type = $0.resources.contentType else { return false }
            return contentTypes.contains(where: { type.conforms(to: $0) })
        })
    }
    
    func filter<S: Sequence<String>>(extensions: S) -> [URL] {
        filter({ extensions.contains($0.pathExtension.lowercased()) })
    }
    
    func filter<S: Sequence<FileType>>(types: S) -> [URL] {
        filter({
            guard let type = $0.fileType else { return false }
            return types.contains(type)
        })
    }
}
 */

#endif
