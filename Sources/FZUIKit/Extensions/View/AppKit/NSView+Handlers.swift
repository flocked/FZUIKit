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

extension NSObjectProtocol where Self: NSView {
    /**
     Handler that provides the menu for a right-click.

     The provided menu is displayed when the user right-clicks the view. If you don't want to display a menu, return `nil`.
     */
     public var menuProvider: ((Self)->(NSMenu?))? {
        get { getAssociatedValue(key: "menuProvider", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "menuProvider", object: self)
            // setupRightDownMonitor()
            setupRightDownMonitorNew()
        }
    }
    
    func setupRightDownMonitorNew() {
        do {
            if (mouseHandlers.rightDown != nil || menuProvider != nil) && eventMonitorsNew[.rightMouseDown] == nil {
                eventMonitorsNew[.rightMouseDown] = try replaceMethod(#selector(NSView.rightMouseDown(with:)),
                methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                    object, event in
                    if let view = object as? NSView {
                        view.mouseHandlers.rightDown?(event)
                        if let menuProvider = view.menuProvider {
                            view.menu = menuProvider(view)
                        }
                    }
                    store.original(object, #selector(NSView.rightMouseDown(with:)), event)
                    }
                }
            } else if mouseHandlers.rightDown == nil && menuProvider == nil {
                if let token = eventMonitorsNew[.rightMouseDown] {
                    resetMethod(token)
                }
                eventMonitorsNew[.rightMouseDown] = nil
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    func setupRightDownMonitor() {
        if mouseHandlers.rightDown != nil || menuProvider != nil {
            eventMonitors[.rightMouseDown] = .local(for: .rightMouseDown) { [weak self] event in
                guard let self = self, self.isVisible else { return event }
                if let contentView = self.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self) {
                        let location = event.location(in: self)
                        if self.bounds.contains(location) {
                            self.mouseHandlers.rightDown?(event)
                            if let menuProvider = menuProvider {
                                self.menu = menuProvider(self)
                            }
                        }
                    }
                }
                return event
            }
        } else {
            eventMonitors[.rightMouseDown] = nil
        }
    }
}

extension NSView {
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
    
    /// The handlers for dropping content into the view.
    public var dropHandlers: DropHandlers {
        get { getAssociatedValue(key: "dropHandlers", object: self, initialValue: DropHandlers()) }
        set {
            set(associatedValue: newValue, key: "dropHandlers", object: self)
            setupObserverView()
        }
    }
    
    /// The handlers for dragging content outside the view.
    public var dragHandlers: DragHandlers {
        get { getAssociatedValue(key: "dragHandlers", object: self, initialValue: DragHandlers()) }
        set {
            set(associatedValue: newValue, key: "dragHandlers", object: self)
            setupObserverView()
            // setupMouseDownMonitor()
            setupMouseDownMonitorNew()
        }
    }
    
    func setupEventMonitors() {
        /*
        setupEventMonitor(for: .leftMouseUp, handler: mouseHandlers.up)
        setupEventMonitor(for: .rightMouseUp, handler: mouseHandlers.rightUp)
        setupMouseDownMonitor()
        setupRightDownMonitor()
         */
        setupEventMonitor(for: .leftMouseUp, #selector(NSView.mouseUp(with:)), \.up)
        setupEventMonitor(for: .rightMouseUp, #selector(NSView.rightMouseUp(with:)), \.rightUp)
        setupMouseDownMonitorNew()
        setupRightDownMonitorNew()
    }
        
    func setupEventMonitor(for event: NSEvent.EventTypeMask, handler: ((NSEvent)->())?) {
        if let handler = handler {
            eventMonitors[event] = .local(for: event) { [weak self] event in
                guard let self = self, self.isVisible else { return event }
                if let contentView = self.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self) {
                        let location = event.location(in: self)
                        if self.bounds.contains(location) {
                            handler(event)
                        }
                    }
                }
                return event
            }
        } else {
            eventMonitors[event] = nil
        }
    }
    
    func setupMouseDownMonitor() {
        if mouseHandlers.down != nil || dragHandlers.canDrag != nil {
            eventMonitors[.leftMouseDown] = .local(for: .leftMouseDown) { [weak self] event in
                guard let self = self, self.isVisible else { return event }
                if let contentView = self.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self) {
                        let location = event.location(in: self)
                        if self.bounds.contains(location) {
                            self.mouseHandlers.down?(event)
                            if let items = self.dragHandlers.canDrag?(location), !items.isEmpty, let observerView = self.observerView {
                                self.fileDragOperation = .copy
                                if self.dragHandlers.fileDragOperation == .move {
                                    if items.count == (items as? [URL] ?? []).filter({$0.absoluteString.contains("file:/")}).count {
                                        self.fileDragOperation = .move
                                    }
                                }
                                let component: NSDraggingImageComponent
                                if let dragImage =  view.dragHandlers.dragImage?(event.location(in: view)) {
                                    component = .init(image: dragImage.image, frame: dragImage.imageFrame)
                                } else {
                                    component = .init(view: view)
                                }
                                let draggingItems = items.compactMap({NSDraggingItem($0)})
                                draggingItems.forEach({
                                    $0.draggingFrame = CGRect(.zero, self.bounds.size)
                                    $0.imageComponentsProvider = { [component] }
                                })
                                self.beginDraggingSession(with: draggingItems, event: event, source: observerView)
                            }
                        }
                    }
                }
                return event
            }
        } else {
            eventMonitors[.leftMouseDown] = nil
        }
    }
    
    func setupEventMonitor(for event: NSEvent.EventTypeMask, _ selector: Selector, _ keyPath: KeyPath<NSView.MouseHandlers, ((NSEvent) -> ())?>) {
        do {
            if mouseHandlers[keyPath: keyPath] != nil,  eventMonitorsNew[event] == nil  {
                eventMonitorsNew[event] =  try replaceMethod(selector,
                methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                    object, event in
                    (object as? NSView)?.mouseHandlers[keyPath: keyPath]?(event)
                    store.original(object, selector, event)
                    }
                }
            } else if mouseHandlers[keyPath: keyPath] == nil {
                if let token = eventMonitorsNew[event] {
                    resetMethod(token)
                }
                eventMonitorsNew[event] = nil
            }
        } catch {
           Swift.debugPrint(error)
        }
    }
    
    func setupMouseDownMonitorNew() {
        do {
            if (mouseHandlers.down != nil || dragHandlers.canDrag != nil) && eventMonitorsNew[.leftMouseDown] == nil {
                eventMonitorsNew[.leftMouseDown] = try replaceMethod(#selector(NSView.mouseDown(with:)),
                methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                    object, event in
                    if let view = object as? NSView {
                        view.mouseHandlers.down?(event)
                        if let items = view.dragHandlers.canDrag?(event.location(in: view)), !items.isEmpty, let observerView = view.observerView {
                            view.fileDragOperation = .copy
                            if view.dragHandlers.fileDragOperation == .move {
                                if items.count == (items as? [URL] ?? []).filter({$0.absoluteString.contains("file:/")}).count {
                                    view.fileDragOperation = .move
                                }
                            }
                            let draggingItems = items.compactMap({NSDraggingItem($0)})
                            let component: NSDraggingImageComponent
                            if let dragImage =  view.dragHandlers.dragImage?(event.location(in: view)) {
                                component = .init(image: dragImage.image, frame: dragImage.imageFrame)
                            } else {
                                component = .init(view: view)
                            }
                            draggingItems.forEach({
                                $0.draggingFrame = CGRect(.zero, view.bounds.size)
                                $0.imageComponentsProvider = { [component] }
                            })
                            view.beginDraggingSession(with: draggingItems, event: event, source: observerView)
                        }
                    }
                    store.original(object, #selector(NSView.mouseDown(with:)), event)
                    }
                }
            } else if mouseHandlers.down == nil && dragHandlers.canDrag == nil {
                if let token = eventMonitorsNew[.leftMouseDown] {
                    resetMethod(token)
                }
                eventMonitorsNew[.leftMouseDown] = nil
            }
        } catch {
           Swift.debugPrint(error)
        }
    }
        
    var eventMonitors: [NSEvent.EventTypeMask: NSEvent.Monitor] {
        get { getAssociatedValue(key: "eventMonitors", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "eventMonitors", object: self) }
    }
    
    var eventMonitorsNew: [NSEvent.EventTypeMask: ReplacedMethodToken] {
        get { getAssociatedValue(key: "eventMonitorsNew", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "eventMonitorsNew", object: self) }
    }
        
    func setupViewObservation() {
        if viewHandlers.needsObserving || windowHandlers.window != nil {
            if viewObserver == nil {
                viewObserver = .init(self)
            }
            observe(\.window, handler: windowHandlers.window)
            observe(\.effectiveAppearance, handler: viewHandlers.effectiveAppearance)
            observe(\.alphaValue, handler: viewHandlers.alphaValue)
            observe(\.isHidden, handler: viewHandlers.isHidden)
            observe(\.bounds, handler: viewHandlers.bounds)
            observe(\.frame, handler: viewHandlers.frame)
            observe(\.superview, handler: viewHandlers.superview)
            if let isFirstResponderHandler = viewHandlers.isFirstResponder {
                viewObserver?.add(\.window?.firstResponder) { _, firstResponder in
                    isFirstResponderHandler(self == firstResponder)
                }
            } else {
                viewObserver?.remove(\.window?.firstResponder)
            }
        } else {
            viewObserver = nil
        }
    }
    
    var viewObserver: KeyValueObserver<NSView>? {
        get { getAssociatedValue(key: "viewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "viewObserver", object: self) }
    }
    
    func observe<Value: Equatable>(_ keyPath: KeyPath<NSView, Value>, handler: ((Value)->())?) {
        if let handler = handler {
            viewObserver?.add(keyPath) { old, new in
                handler(new)
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
                self.observerView = ObserverView()
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
        /// Options when the mouse handlers are active.
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
        
        /// Option when the mouse handlers are active. The default value is `inKeyWindow`.
        public var active: ActiveOption = .inKeyWindow
        
        /// The handler that gets called when when the mouse inside the view moved.
        public var moved: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse inside the view dragged.
        public var dragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse entered the view.
        public var entered: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse exited the view.
        public var exited: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse did left-click the view.
        public var down: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse did right-click the view.
        public var rightDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse did left-click up the view.
        public var up: ((NSEvent) -> ())?
        
        /// The handler that gets called when when the mouse did right-click up the view.
        public var rightUp: ((NSEvent) -> ())?
        
        var needsObserving: Bool {
            moved != nil || dragged != nil || entered != nil || exited != nil
        }
        
        var trackingAreaOptions: NSTrackingArea.Options {
            var options: NSTrackingArea.Options = [.inVisibleRect, .mouseEnteredAndExited]
            options.insert(active.option)
            if dragged != nil {
                options.insert(.enabledDuringMouseDrag)
            }
            if moved != nil {
                options.insert(NSTrackingArea.Options.mouseMoved)
            }
            return options
        }
    }
    
    /**
     The handlers dropping content (file urls, images, colors or strings) from the pasteboard to your view.
     
     Provide ``canDrop`` and ``didDrop`` to support dropping of content to your view.
     
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
        public var canDrop: ((_ items: [PasteboardContent], _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ items: [PasteboardContent], _ location: CGPoint) -> Void)?
        
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
                registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color, .sound, .URL])
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
                 
        func canDrop(_ items: [PasteboardContent], location: CGPoint) -> Bool {
            guard _dropHandlers.isActive, items.isEmpty == false else { return false }
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
            return _dropHandlers.canDrop?(items, location) == true
        }
        
        override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard  _dropHandlers.draggingEntered != nil || _dropHandlers.isActive else { return [] }
            let items = sender.draggingPasteboard.content()
            _dropHandlers.draggingEntered?(items, sender.draggingLocation)
            return canDrop(items, location: sender.draggingLocation) ? .copy : []
        }
        
        override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard _dropHandlers.isActive else { return [] }
            let items = sender.draggingPasteboard.content()
            guard items.isEmpty == false else { return [] }
            return canDrop(items, location: sender.draggingLocation) ? .copy : []
        }
        
        override public func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive else { return false }
            let items = sender.draggingPasteboard.content()
            guard items.isEmpty == false else { return false }
            return canDrop(items, location: sender.draggingLocation)
        }
        
        override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive, let didDrop = _dropHandlers.didDrop else { return false }
            let items = sender.draggingPasteboard.content()
            guard items.isEmpty == false else { return false }
            didDrop(items, sender.draggingLocation)
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

