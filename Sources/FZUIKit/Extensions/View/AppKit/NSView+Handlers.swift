//
//  ObserverView.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

extension NSView {
    /**
     Handler that provides the menu for a right-click.

     The provided menu is displayed when the user right-clicks the view. If you don't want to display a menu, return `nil`.
     */
    public var menuProvider: ((_ location: CGPoint)->(NSMenu?))? {
        get { getAssociatedValue(key: "menuProvider", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "menuProvider", object: self)
            setupEventMonitors()
        }
    }
    
    /// The handlers for the window state.
    public var windowHandlers: WindowHandlers {
        get { getAssociatedValue(key: "windowHandlers", object: self, initialValue: WindowHandlers()) }
        set {
            set(associatedValue: newValue, key: "windowHandlers", object: self)
            setupObserverView()
        }
    }
    
    /// The handlers for mouse events.
    public var mouseHandlers: MouseHandlers {
        get { getAssociatedValue(key: "mouseHandlers", object: self, initialValue: MouseHandlers()) }
        set {
            set(associatedValue: newValue, key: "mouseHandlers", object: self)
            setupEventMonitors()
            setupObserverView()
        }
    }
    
    /// The handlers for the view state.
    public var viewHandlers: ViewHandlers {
        get { getAssociatedValue(key: "viewHandlers", object: self, initialValue: ViewHandlers()) }
        set {
            set(associatedValue: newValue, key: "viewHandlers", object: self)
            setupViewObservation()
        }
    }
    
    /// The handlers for dragging content outside the view.
    public var dragHandlers: DragHandlers {
        get { getAssociatedValue(key: "dragHandlers", object: self, initialValue: DragHandlers()) }
        set {
            set(associatedValue: newValue, key: "dragHandlers", object: self)
            setupObserverView()
            setupEventMonitors()
        }
    }
    
    /// The handlers for dropping content into the view.
    public var dropHandlers: DropHandlers {
        get { getAssociatedValue(key: "dropHandlers", object: self, initialValue: DropHandlers()) }
        set {
            set(associatedValue: newValue, key: "dropHandlers", object: self)
            setupObserverView()
        }
    }
    
    func setupEventMonitors() {
        setupEventMonitor(for: .leftMouseUp, #selector(NSView.mouseUp(with:)), \.leftUp)
        setupEventMonitor(for: .rightMouseUp, #selector(NSView.rightMouseUp(with:)), \.rightUp)
        setupEventMonitor(for: .rightMouseDragged, #selector(NSView.rightMouseDragged(with:)), \.rightDragged)
        setupEventMonitor(for: .otherMouseDown, #selector(NSView.otherMouseDown(with:)), \.otherDown)
        setupEventMonitor(for: .otherMouseUp, #selector(NSView.otherMouseUp(with:)), \.otherUp)
        setupEventMonitor(for: .leftMouseDown, #selector(NSView.mouseDown(with:)), \.leftDown, { dragHandlers.canDrag != nil }) { event, view in
            view.didStartDragging = false
            view.mouseDownLocation = event.location(in: view)
        }
        setupEventMonitor(for: .rightMouseDown, #selector(NSView.rightMouseDown(with:)), \.rightDown, { menuProvider != nil }) { event, view in
            view.setupMenuProvider(for: event)
        }
        setupEventMonitor(for: .leftMouseDragged, #selector(NSView.mouseDragged(with:)), \.dragged, { dragHandlers.canDrag != nil }) { event, view in
            view.setupDraggingSession(for: event)
        }
    }
    
    func setupEventMonitor(for event: NSEvent.EventTypeMask, _ selector: Selector, _ keyPath: KeyPath<NSView.MouseHandlers, ((NSEvent) -> ())?>, _ condition: ()->(Bool) = { return true }, _ additional: ((NSEvent, NSView)->())? = nil) {
        do {
            if mouseHandlers[keyPath: keyPath] != nil || condition() {
                if eventMonitors[event] == nil {
                    eventMonitors[event] =  try replaceMethod(selector,
                                                              methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                                                              hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                        object, event in
                        if let view = object as? NSView {
                            view.mouseHandlers[keyPath: keyPath]?(event)
                            additional?(event, view)
                        }
                        store.original(object, selector, event)
                    }
                    }
                }
            } else {
                if let token = eventMonitors[event] {
                    resetMethod(token)
                }
                eventMonitors[event] = nil
            }
        } catch {
           Swift.debugPrint(error)
        }
    }
    
    var mouseDownLocation: CGPoint {
        get { getAssociatedValue(key: "leftMouseDownLocation", object: self, initialValue: .zero) }
        set { set(associatedValue: newValue, key: "leftMouseDownLocation", object: self) }
    }
    
    var didStartDragging: Bool {
        get { getAssociatedValue(key: "didStartDragging", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didStartDragging", object: self) }
    }
    
    func setupMenuProvider(for event: NSEvent) {
        guard let menuProvider = self.menuProvider else { return }
        let location = event.location(in: self)
        if let menu = menuProvider(location) {
            menu.handlers.didClose = {
                if self.menu == menu {
                    self.menu = nil
                }
            }
            self.menu = menu
        } else {
            self.menu = nil
        }
    }
    
    static let minimumDragDistance: CGFloat = 4.0
    
    func setupDraggingSession(for event: NSEvent) {
        guard let canDrag = dragHandlers.canDrag, !didStartDragging else { return }
        let location = event.location(in: self)
        guard mouseDownLocation.distance(to: location) >= NSView.minimumDragDistance else { return }
        didStartDragging = true
        guard let items = canDrag(location), !items.isEmpty, let observerView = self.observerView else { return }
        fileDragOperation = .copy
        if dragHandlers.fileDragOperation == .move {
            if items.count == (items as? [URL] ?? []).filter({$0.absoluteString.contains("file:/")}).count {
                fileDragOperation = .move
            }
        }
        let draggingItems = items.compactMap({NSDraggingItem($0)})
        let component: NSDraggingImageComponent
        if let dragImage =  dragHandlers.dragImage?(location) {
            component = .init(image: dragImage.image, frame: dragImage.imageFrame)
        } else {
            component = .init(view: self)
        }
        draggingItems.first?.imageComponentsProvider = { [component] }
        draggingItems.forEach({
           $0.draggingFrame = CGRect(.zero, self.bounds.size)
            // $0.imageComponentsProvider = { [component] }
        })
        NSPasteboard.general.writeObjects(items.compactMap({$0.pasteboardWriting}))
        beginDraggingSession(with: draggingItems, event: event, source: observerView)
    }
                
    var eventMonitors: [NSEvent.EventTypeMask: ReplacedMethodToken] {
        get { getAssociatedValue(key: "eventMonitors", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "eventMonitors", object: self) }
    }
        
    func setupViewObservation() {
        if viewHandlers.needsObserving || windowHandlers.window != nil {
            if viewObserver == nil {
                viewObserver = .init(self)
            }
            observe(\.window, handler: \.windowHandlers.window)
            observe(\.effectiveAppearance, handler: \.viewHandlers.effectiveAppearance)
            observe(\.alphaValue, handler: \.viewHandlers.alphaValue)
            observe(\.isHidden, handler: \.viewHandlers.isHidden)
            observe(\.bounds, handler: \.viewHandlers.bounds)
            observe(\.frame, handler: \.viewHandlers.frame)
            observe(\.superview, handler: \.viewHandlers.superview)
            
            if viewHandlers.isFirstResponder != nil && viewObserver?.isObserving(\.window?.firstResponder) == false {
                viewObserver?.add(\.window?.firstResponder) { [weak self] _, firstResponder in
                    guard let self = self else { return }
                    self._isFirstResponder = self.isFirstResponder
                }
            } else if viewHandlers.isFirstResponder == nil {
                viewObserver?.remove(\.window?.firstResponder)
            }
        } else {
            viewObserver = nil
        }
    }
    
    var _isFirstResponder: Bool {
        get { getAssociatedValue(key: "_isFirstResponder", object: self, initialValue: isFirstResponder) }
        set { 
            guard newValue != _isFirstResponder else { return }
            set(associatedValue: newValue, key: "_isFirstResponder", object: self)
            viewHandlers.isFirstResponder?(newValue)
        }
    }
    
    var viewObserver: KeyValueObserver<NSView>? {
        get { getAssociatedValue(key: "viewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "viewObserver", object: self) }
    }
    
    func observe<Value: Equatable>(_ keyPath: KeyPath<NSView, Value>, handler: KeyPath<NSView, ((Value)->())?>) {
        if self[keyPath: handler] != nil {
            if  viewObserver?.isObserving(keyPath) == false {
                viewObserver?.add(keyPath) { [weak self] old, new in
                    guard let self = self else { return }
                    self[keyPath: handler]?(new)
                }
            }
        } else {
            viewObserver?.remove(keyPath)
        }
    }
            
    var observerView: ObserverView? {
        get { getAssociatedValue(key: "observerView", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "observerView", object: self) }
    }
        
    func setupObserverView() {
        if windowHandlers.needsObserving || mouseHandlers.needsObserving || dropHandlers.isActive || dragHandlers.canDrag != nil {
            if observerView == nil {
                observerView = ObserverView()
                addSubview(withConstraint: observerView!)
            }
            observerView?._mouseHandlers = mouseHandlers
            observerView?._windowHandlers = windowHandlers
            observerView?._dropHandlers = dropHandlers
        } else if observerView != nil {
            observerView?.removeFromSuperview()
            observerView = nil
        }
    }
    
    /// The handlers for the window state.
    public struct WindowHandlers {
        /// The handler that gets called when the window of the view changes.
        public var window: ((NSWindow?) -> Void)?
        
        /// The handler that gets called when `isKey` changed.
        public var isKey: ((Bool) -> Void)?
        
        /// The handler that gets called when `isMain` changed.
        public var isMain: ((Bool) -> Void)?
        
        var needsObserving: Bool {
            isKey != nil || isMain != nil
        }
    }
    
    /// The handlers for the view.
    public struct ViewHandlers {
        /// The handler that gets called when the superview changed.
        public var superview: ((NSView?) -> Void)?
        /// The handler that gets called when the bounds rectangle changed.
        public var bounds: ((CGRect)->())?
        /// The handler that gets called when the frame rectangle changed.
        public var frame: ((CGRect)->())?
        /// The handler that gets called when `isHidden` changed.
        public var isHidden: ((Bool)->())?
        /// The handler that gets called when the alpha value changed.
        public var alphaValue: ((CGFloat)->())?
        /// The handler that gets called when the effective appearance changed.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that gets called when the view is the first responder.
        public var isFirstResponder: ((Bool)->())?

        var needsObserving: Bool {
            superview != nil ||
            isHidden != nil ||
            alphaValue != nil ||
            bounds != nil ||
            frame != nil ||
            effectiveAppearance != nil ||
            isFirstResponder != nil
        }
    }
    
    /// The handlers for mouse events.
    public struct MouseHandlers {
        /// Options when the `entered`, `exited` and `moved` mouse handlers are active.
        public enum ActiveOption: Int, Hashable {
            /// The mouse handlers are always active.
            case always
            
            /// The mouse handlers is active when the window is key.
            case inKeyWindow
            
            /// The mouse handlers is active when the application is active.
            case inActiveApp
            
            var option: NSTrackingArea.Options {
                switch self {
                case .always: return [.activeAlways]
                case .inKeyWindow: return [.activeInKeyWindow]
                case .inActiveApp: return [.activeInActiveApp]
                }
            }
        }
        
        /// Option when the `entered`, `exited` and `moved` mouse handlers are active. The default value is `inKeyWindow`.
        public var active: ActiveOption = .inKeyWindow
        
        /// The handler that gets called when when the mouse inside the view moved.
        public var moved: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse dragged inside the view.
        public var dragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse entered the view.
        public var entered: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse exited the view.
        public var exited: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user clicked the left mouse button.
        public var leftDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user released the left mouse button.
        public var leftUp: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user clicked the right mouse button.
        public var rightDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user released the right mouse button.
        public var rightUp: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse dragged inside the view while the right button clicked,
        public var rightDragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user clicked a mouse button other than the left or right one.
        public var otherDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the user released a mouse button other than the left or right one.
        public var otherUp: ((NSEvent) -> ())?
        
        var needsObserving: Bool {
            moved != nil || entered != nil || exited != nil
        }
        
        var trackingAreaOptions: NSTrackingArea.Options {
            var options: NSTrackingArea.Options = [.inVisibleRect, .mouseEnteredAndExited]
            options.insert(active.option)
            if moved != nil {
                options.insert(NSTrackingArea.Options.mouseMoved)
            }
            return options
        }
    }
    
    /**
     The handlers dropping content (file urls, images, colors or strings) from the pasteboard to your view.
     
     Provide ``canDrop`` and/or ``allowedContentTypes`` to specify the items that can be dropped to the view.
     
     
     
     ``didDrop`` gets the
     
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
        /// The allowed file content types that can be dropped to the view, or `nil` if no file is allowed to drop to the file.
        @available(macOS 11.0, *)
        public var allowedContentTypes: [UTType] {
            get { _allowedContentTypes as? [UTType] ?? [] }
            set { _allowedContentTypes = newValue }
        }
        var _allowedContentTypes: Any?
    
        /// A Boolean value that determines whether the user can drop multiple files with the specified content types  to the view.
        public var allowsMultipleFiles: Bool = true
        
        
        /**
         The file content types that can be dropped to the view.
         */
        @available(macOS 11.0, *)
        public struct FileDropping {
            /// The allowed file content types that can be dropped to the view, or `nil` if no file is allowed to drop to the file.
            public var contentTypes: [UTType]? = nil
            /// A Boolean value that determines whether the user can drop multiple files with the specified content types  to the view.
            public var allowsMultiple: Bool = true
        }
        
        /**
         The file content types that can be dropped to the view.
         
         Provides the allowed content types of the files that can be dropped to the view.
         ```swift
         view.dropHandlers.fileDropping.contentTypes = [.image, .video]
         ```
         
         Alternatively you can determine the allowed files for dropping to the view more precisely by using `canDrop`:
         
         ```swift
         view.dropHandlers.canDrop = { items, _ in
             let fileURLs = items.fileURLs
         
             /// Checks if the files have the prefix `vid_` and allows dropping.
             let hasPrefix = fileURLs.contains(where: { $0.lastPathComponent.hasPrefix("vid_") })
         
             return hasPrefix
         }
         ```
         */
        @available(macOS 11.0, *)
        public var fileDropping: FileDropping {
            get { (_fileDropping as? FileDropping) ?? FileDropping() }
            set { _fileDropping = newValue }
        }
        
        var _fileDropping: Any?
        
        /// The handler that gets called when a pasteboard dragging enters the view’s bounds rectangle.
        public var draggingEntered: ((_ items: [PasteboardContent], _ location: CGPoint) -> Void)?
        
        /**
         The handler that determines whether the user can drop the content from the pasteboard to your view.
         
         Implement the handler and return `true`, if the pasteboard contains content that your view accepts dropping.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ content: [PasteboardContent], _ items: [NSPasteboardItem], _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ items: [PasteboardContent], _ items: [NSPasteboardItem], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging exits the view’s bounds rectangle.
        public var draggingExited: (()->())?

        var isActive: Bool {
            if #available(macOS 11.0, *) {
                (canDrop != nil || fileDropping.contentTypes != nil) && didDrop != nil
            } else {
                canDrop != nil && didDrop != nil
            }
        }
    }
    
    var fileDragOperation: NSDragOperation {
        get { getAssociatedValue(key: "fileDragOperation", object: self, initialValue: .copy) }
        set { set(associatedValue: newValue, key: "fileDragOperation", object: self) }
    }
    
    /// The handlers for dragging content outside the view.
    public struct DragHandlers {
        /**
         The handler that determines whether the user can drag content outside the view.
         
         You can return `String`, `URL`, `NSImage`, `NSColor` and `NSSound` values.
                  
         - Parameter location. The mouse location inside the view.
         - Returns: The content that can be dragged outside the view, or `nil` if the view doesn't provide any draggable content.
         */
        public var canDrag: ((_ location: CGPoint) -> ([PasteboardContent]?))?
        /// An optional image used for dragging. If `nil`, a rendered image of the view is used.
        public var dragImage: ((_ location: CGPoint) -> ((image: NSImage, imageFrame: CGRect)?))?
        /// The handler that gets called when the user did drag the content to a supported destination.
        public var didDrag: ((_ screenLocation: CGPoint, _ items: [PasteboardContent]) -> ())?
        /// The handler that gets called when the dragging ended without dragging the content to a supported destination.
        public var dragEnded: ((_ screenLocation: CGPoint)->())?
        
        
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
    
    class ObserverView: NSView, NSDraggingSource {
        func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
            switch context {
            case .outsideApplication:
                return superview?.fileDragOperation ?? .copy
            default:
                return .generic
            }
        }
        
        func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
            if let dragHandlers = superview?.dragHandlers {
                session.draggingFormation = dragHandlers.draggingFormation
                session.animatesToStartingPositionsOnCancelOrFail = dragHandlers.animatesToStartingPositionsOnCancelOrFail
            }
            // Swift.print("draggingSession willBeginAt", screenPoint)
        }
        
        func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
            guard superview?.dragHandlers.canDrag != nil else { return }
            if operation != .none {
                superview?.dragHandlers.didDrag?(screenPoint, session.draggingPasteboard.content())
            } else {
                superview?.dragHandlers.dragEnded?(screenPoint)
            }
        }
        
        lazy var trackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
        var windowDidBecomeKeyObserver: NotificationToken?
        var windowDidResignKeyObserver: NotificationToken?
        var windowDidBecomeMainObserver: NotificationToken?
        var windowDidResignMainObserver: NotificationToken?
        
        var _windowHandlers = WindowHandlers() {
            didSet { updateWindowObserver() }
        }
        
        var _mouseHandlers = MouseHandlers() {
            didSet {  trackingArea.options = _mouseHandlers.trackingAreaOptions }
        }
                        
        var _dropHandlers = DropHandlers() {
            didSet { self.setupDragAndDrop(needsSetup: _dropHandlers.isActive) }
        }
        
        override public func hitTest(_: NSPoint) -> NSView? {
            nil
        }
        
        override public var acceptsFirstResponder: Bool {
            false
        }
        
        func setupDragAndDrop(needsSetup: Bool) {
            if needsSetup {
                registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color, .sound, .URL, .codable, .textFinderOptions])
            } else {
                unregisterDraggedTypes()
            }
        }
        
        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            initalSetup()
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            initalSetup()
        }
        
        func initalSetup() {
            trackingArea.options = _mouseHandlers.trackingAreaOptions
            trackingArea.update()
        }
        
        override public func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override public func mouseEntered(with event: NSEvent) {
            _mouseHandlers.entered?(event)
            super.mouseEntered(with: event)
        }
        
        override public func mouseExited(with event: NSEvent) {
            _mouseHandlers.exited?(event)
            super.mouseExited(with: event)
        }
        
        override public func mouseMoved(with event: NSEvent) {
            _mouseHandlers.moved?(event)
            super.mouseMoved(with: event)
        }
        
        override public func mouseDragged(with event: NSEvent) {
            _mouseHandlers.dragged?(event)
            super.mouseDragged(with: event)
        }
                 
        func canDrop(_ pasteboard: NSPasteboard, location: CGPoint) -> Bool {
            let items = pasteboard.content()
            guard items.isEmpty == false, _dropHandlers.isActive else { return false }
            let pasteboardItems = pasteboard.pasteboardItems ?? []
            if #available(macOS 11.0, *) {
                if let contentTypes = _dropHandlers.fileDropping.contentTypes, !contentTypes.isEmpty {
                    let conformingURLs =  items.urls.compactMap({$0.contentType}).filter({ $0.conforms(toAny: contentTypes) })
                    if conformingURLs.isEmpty == false {
                        let allowsMultiple = _dropHandlers.fileDropping.allowsMultiple
                        if allowsMultiple || (allowsMultiple == false && conformingURLs.count == 1) {
                            return true
                        }
                    }
                }
            }
            return _dropHandlers.canDrop?(items, pasteboardItems, location) == true
        }
        
        override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard  _dropHandlers.draggingEntered != nil || _dropHandlers.isActive else { return [] }
            let items = sender.draggingPasteboard.content()
            _dropHandlers.draggingEntered?(items, sender.draggingLocation)
            return canDrop(sender.draggingPasteboard, location: sender.draggingLocation) ? .copy : []
        }
        
        override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard _dropHandlers.isActive else { return [] }
            return canDrop(sender.draggingPasteboard, location: sender.draggingLocation) ? .copy : []
        }
        
        override public func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive else { return false }
            return canDrop(sender.draggingPasteboard, location: sender.draggingLocation)
        }
        
        override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive, let didDrop = _dropHandlers.didDrop else { return false }
            let items = sender.draggingPasteboard.content()
            guard items.isEmpty == false else { return false }
            didDrop(items, sender.draggingPasteboard.pasteboardItems ?? [],  sender.draggingLocation)
            return true
        }
        
        override func draggingExited(_ sender: NSDraggingInfo?) {
            dropHandlers.draggingExited?()
            super.draggingExited(sender)
        }
        
        override public func viewWillMove(toWindow newWindow: NSWindow?) {
            if newWindow != window {
                removeWindowKeyObserver()
                removeWindowMainObserver()
                if let newWindow = newWindow {
                    observeWindowState(for: newWindow)
                }
            }
            super.viewWillMove(toWindow: newWindow)
        }
        
        func updateWindowObserver() {
            if _windowHandlers.isKey == nil {
                removeWindowKeyObserver()
            }
            
            if _windowHandlers.isMain == nil {
                removeWindowMainObserver()
            }
            
            if let window = window {
                observeWindowState(for: window)
            }
        }
                
        func removeWindowKeyObserver() {
            windowDidBecomeKeyObserver = nil
            windowDidResignKeyObserver = nil
        }
        
        func removeWindowMainObserver() {
            windowDidBecomeMainObserver = nil
            windowDidResignMainObserver = nil
        }
        
        func observeWindowState(for window: NSWindow) {
            windowIsKey = window.isKeyWindow
            windowIsMain = window.isMainWindow
            if windowDidBecomeKeyObserver == nil, _windowHandlers.isKey != nil {
                windowDidBecomeKeyObserver = NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: window) { _ in
                    self.windowIsKey = true
                }
                
                windowDidResignKeyObserver = NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: window) { _ in
                    self.windowIsKey = false
                }
            }
            
            if windowDidBecomeMainObserver == nil, _windowHandlers.isMain != nil {
                windowDidBecomeMainObserver = NotificationCenter.default.observe(NSWindow.didBecomeMainNotification, object: window) { _ in
                    self.windowIsMain = true
                }
                
                windowDidResignMainObserver = NotificationCenter.default.observe(NSWindow.didResignMainNotification, object: window) { _ in
                    self.windowIsMain = false
                }
            }
        }
        
        var windowIsKey = false {
            didSet {
                if oldValue != windowIsKey {
                    _windowHandlers.isKey?(windowIsKey)
                }
            }
        }
        
        var windowIsMain = false {
            didSet {
                if oldValue != windowIsMain {
                    _windowHandlers.isMain?(windowIsMain)
                }
            }
        }
        
        deinit {
            self.removeWindowKeyObserver()
            self.removeWindowMainObserver()
        }
    }
}
    
#endif

