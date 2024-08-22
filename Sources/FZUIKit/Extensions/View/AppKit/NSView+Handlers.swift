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
    /// Sets the menu.
    @discardableResult
    public func menu(_ menu: NSMenu?) -> Self {
        self.menu = menu
        return self
    }
    
    /// Sets the menu with the specified items.
    @discardableResult
    public func menu(@MenuBuilder _ items: @escaping () -> [NSMenuItem]) -> Self {
        self.menu = NSMenu(items)
        return self
    }
    
    /**
     Handler that provides the menu for a right-click.

     The provided menu is displayed when the user right-clicks the view. If you don't want to display a menu, return `nil`.
     */
    public var menuProvider: ((_ location: CGPoint)->(NSMenu?))? {
        get { getAssociatedValue("menuProvider", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "menuProvider")
            setupEventMonitors()
        }
    }
    
    /// The handlers for the window state.
    public var windowHandlers: WindowHandlers {
        get { getAssociatedValue("windowHandlers", initialValue: WindowHandlers()) }
        set {
            setAssociatedValue(newValue, key: "windowHandlers")
            setupObservation()
            setupObserverView()
        }
    }
    
    /// The handlers for mouse events.
    public var mouseHandlers: MouseHandlers {
        get { getAssociatedValue("mouseHandlers", initialValue: MouseHandlers()) }
        set {
            setAssociatedValue(newValue, key: "mouseHandlers")
            setupEventMonitors()
            setupObserverView()
        }
    }
    
    /// The handlers for mouse events.
    public var keyHandlers: KeyHandlers {
        get { getAssociatedValue("keyHandlers", initialValue: KeyHandlers()) }
        set {
            setAssociatedValue(newValue, key: "keyHandlers")
            setupEventMonitors()
        }
    }
    
    /// The handlers for the view state.
    public var viewHandlers: ViewHandlers {
        get { getAssociatedValue("viewHandlers", initialValue: ViewHandlers()) }
        set {
            setAssociatedValue(newValue, key: "viewHandlers")
            setupObservation()
            setupObserverView()
        }
    }
    
    /// The handlers for dragging content outside the view.
    public var dragHandlers: DragHandlers {
        get { getAssociatedValue("dragHandlers", initialValue: DragHandlers()) }
        set {
            setAssociatedValue(newValue, key: "dragHandlers")
            setupObserverView()
            setupEventMonitors()
        }
    }
    
    /// The handlers for dropping content into the view.
    public var dropHandlers: DropHandlers {
        get { getAssociatedValue("dropHandlers", initialValue: DropHandlers()) }
        set {
            setAssociatedValue(newValue, key: "dropHandlers")
            setupObserverView()
        }
    }
        
    var observerGestureRecognizer: ObserverGestureRecognizer? {
        get { getAssociatedValue("observerGestureRecognizer", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "observerGestureRecognizer") }
    }
    
    func setupEventMonitors() {
        if mouseHandlers.needsGestureObserving || keyHandlers.needsObserving || menuProvider != nil || dragHandlers.canDrag != nil {
            if let observerGestureRecognizer = observerGestureRecognizer, gestureRecognizers.contains(observerGestureRecognizer) == false {
                addGestureRecognizer(observerGestureRecognizer)
            } else if observerGestureRecognizer == nil {
                observerGestureRecognizer = ObserverGestureRecognizer(reattachesAutomatically: true)
                addGestureRecognizer(observerGestureRecognizer!)
            }
        } else {
            observerGestureRecognizer?.removeFromView()
            observerGestureRecognizer = nil
        }
    }

    func setupObservation() {
        func observe<Value: Equatable>(_ keyPath: KeyPath<NSView, Value>, handler: KeyPath<NSView, ((Value)->())?>) {
            if self[keyPath: handler] == nil {
                 viewObserver.remove(keyPath)
            } else if !viewObserver.isObserving(keyPath) {
                viewObserver.add(keyPath) { [weak self] old, new in
                   guard let self = self else { return }
                   self[keyPath: handler]?(new)
               }
            }
        }
        
        observe(\.window, handler: \.windowHandlers.window)
        observe(\.window?.screen, handler: \.windowHandlers.screen)
        observe(\.effectiveAppearance, handler: \.viewHandlers.effectiveAppearance)
        observe(\.alphaValue, handler: \.viewHandlers.alphaValue)
        observe(\.isHidden, handler: \.viewHandlers.isHidden)
        observe(\.bounds, handler: \.viewHandlers.bounds)
        observe(\.frame, handler: \.viewHandlers.frame)
        observe(\.superview, handler: \.viewHandlers.superview)
        
        if windowHandlers.frame == nil {
            viewObserver.remove(\.window?.frame)
        } else if !viewObserver.isObserving(\.window?.frame) {
            viewObserver.add(\.window?.frame) { [weak self] _, frame in
                guard let self = self, let frame = frame else { return }
                self.windowHandlers.frame?(frame)
            }
        }
                 
        if viewHandlers.isFirstResponder == nil {
            viewObserver.remove(\.window?.firstResponder)
        } else if !viewObserver.isObserving(\.window?.firstResponder) {
            viewObserver.add(\.window?.firstResponder) { [weak self] _, firstResponder in
               guard let self = self else { return }
                self._isFirstResponder = self.isFirstResponder
           }
        }
    }
    
    /// A Boolean value that indicates whether the property `inLiveResize` is KVO observable.
    public static var isLiveResizingObservable: Bool {
        get { isMethodReplaced(#selector(NSView.viewWillStartLiveResize)) }
        set {
            guard newValue != isLiveResizingObservable else { return }
            if newValue {
                do {
                   try replaceMethod(
                   #selector(NSView.viewWillStartLiveResize),
                   methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                   hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                       object in
                       if let view = object as? NSView {
                           view.willChangeValue(for: \.inLiveResize)
                           view._inLiveResize = true
                           view.didChangeValue(for: \.inLiveResize)
                           view._inLiveResize = nil
                       }
                       store.original(object, #selector(NSView.viewWillStartLiveResize))
                       }
                   }
                    try replaceMethod(
                    #selector(NSView.viewDidEndLiveResize),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        if let view = object as? NSView {
                            view._inLiveResize = true
                            view.willChangeValue(for: \.inLiveResize)
                            view._inLiveResize = nil
                            view.didChangeValue(for: \.inLiveResize)
                        }
                        store.original(object, #selector(NSView.viewDidEndLiveResize))
                        }
                    }
                    try replaceMethod(
                        #selector(getter: NSView.inLiveResize),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> (Bool)).self,
                    hookSignature: (@convention(block)  (AnyObject) -> (Bool)).self) { store in {
                        object in
                        (object as? NSView)?._inLiveResize ?? store.original(object,#selector(getter: NSView.inLiveResize))
                        }
                    }
                } catch {
                   debugPrint(error)
                }
            } else {
                resetMethod(#selector(NSView.viewWillStartLiveResize))
                resetMethod(#selector(NSView.viewDidEndLiveResize))
                resetMethod(#selector(getter: NSView.inLiveResize))
            }
        }
    }
    
    static func setupLiveResizingObservation() {
        guard !isMethodReplaced(#selector(NSView.viewWillStartLiveResize)) else { return  }
        do {
           try replaceMethod(
           #selector(NSView.viewWillStartLiveResize),
           methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
           hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
               object in
               (object as? NSView)?.willChangeValue(for: \.inLiveResize)
               (object as? NSView)?._inLiveResize = true
               (object as? NSView)?.didChangeValue(for: \.inLiveResize)
               (object as? NSView)?._inLiveResize = nil
               store.original(object, #selector(NSView.viewWillStartLiveResize))
               }
           }
            try replaceMethod(
            #selector(NSView.viewDidEndLiveResize),
            methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                object in
                (object as? NSView)?._inLiveResize = true
                (object as? NSView)?.willChangeValue(for: \.inLiveResize)
                (object as? NSView)?._inLiveResize = nil
                (object as? NSView)?.didChangeValue(for: \.inLiveResize)
                store.original(object, #selector(NSView.viewDidEndLiveResize))
                }
            }
            try replaceMethod(
                #selector(getter: NSView.inLiveResize),
            methodSignature: (@convention(c)  (AnyObject, Selector) -> (Bool)).self,
            hookSignature: (@convention(block)  (AnyObject) -> (Bool)).self) { store in {
                object in
                (object as? NSView)?._inLiveResize ?? store.original(object,#selector(getter: NSView.inLiveResize))
                }
            }
        } catch {
           // handle error
           debugPrint(error)
        }
    }
    
    var _inLiveResize: Bool? {
        get { getAssociatedValue("_inLiveResize", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "_inLiveResize") }
    }
    
    var _isFirstResponder: Bool {
        get { getAssociatedValue("_isFirstResponder", initialValue: isFirstResponder) }
        set { 
            guard newValue != _isFirstResponder else { return }
            setAssociatedValue(newValue, key: "_isFirstResponder")
            viewHandlers.isFirstResponder?(newValue)
        }
    }
    
    var viewObserver: KeyValueObserver<NSView> {
        get { getAssociatedValue("viewObserver", initialValue: KeyValueObserver(self)) }
    }
    
    var observerView: ObserverView? {
        get { getAssociatedValue("observerView", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "observerView") }
    }
        
    func setupObserverView() {
        if mouseHandlers.needsObserving || dropHandlers.isActive || dragHandlers.canDrag != nil || windowHandlers.needsObserverView || viewHandlers.needsObserverView {
            if observerView == nil {
                observerView = ObserverView(frame: .zero)
                addSubview(withConstraint: observerView!)
            }
            observerView?._mouseHandlers = mouseHandlers
            observerView?._dropHandlers = dropHandlers
            observerView?._windowHandlers = windowHandlers
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
        
        /// The handler that gets called when the screen changed.
        public var screen: ((NSScreen?)->())?
        
        /// The handler that gets called when the bounds rectangle changed.
        public var bounds: ((CGRect)->())?
        
        /// The handler that gets called when the frame rectangle changed.
        public var frame: ((CGRect)->())?
        
        var needsObserverView: Bool {
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
        /// The handler that gets called when the view is resized by the user.
        public var isLiveResizing: ((Bool)->())?
        /// The handler that gets called when the alpha value changed.
        public var alphaValue: ((CGFloat)->())?
        /// The handler that gets called when the effective appearance changed.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that gets called when the view is the first responder.
        public var isFirstResponder: ((Bool)->())?
        
        var needsObserverView: Bool {
            isLiveResizing != nil
        }
    }
    
    /// The handlers for keyboard events.
    public struct KeyHandlers {
        /// The handler that gets called when the user has pressed a key.
        public var keyDown: ((NSEvent) -> ())?
        /// The handler that gets called when the user has released a key.
        public var keyUp: ((NSEvent) -> ())?
        /// The handler that gets called when the user pressed or released a modifier key (Shift, Control, and so on).
        public var flagsChanged: ((NSEvent) -> ())?
        
        var needsObserving: Bool {
            keyDown != nil ||
            keyUp != nil ||
            flagsChanged != nil
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
        
        /// The handler that gets called when the mouse entered the view.
        public var entered: ((NSEvent) -> ())?
        
        /// The handler that gets called when the mouse inside the view moved.
        public var moved: ((NSEvent) -> ())?
        
        /// The handler that gets called when the mouse exited the view.
        public var exited: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user clicked the left mouse button.
        public var leftDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user released the left mouse button.
        public var leftUp: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user moved the mouse with the left button pressed.
        public var leftDragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user clicked the right mouse button.
        public var rightDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user released the right mouse button.
        public var rightUp: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user moved the mouse with the right button pressed.
        public var rightDragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user clicked a mouse button other than the left or right one.
        public var otherDown: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user released a mouse button other than the left or right one.
        public var otherUp: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user moved the mouse with a button other than the left or right one pressed.
        public var otherDragged: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user is performing a pinch gesture.
        public var magnify: ((NSEvent) -> ())?
        
        /// The handler that gets called when the user is performing a rotation gesture.
        public var rotate: ((NSEvent) -> ())?
        
        var needsObserving: Bool {
            moved != nil || entered != nil || exited != nil
        }
        
        var needsGestureObserving: Bool {
            leftDown != nil ||
            leftUp != nil ||
            leftDragged != nil ||
            rightDown != nil ||
            rightUp != nil ||
            rightDragged != nil ||
            otherDown != nil ||
            otherUp != nil ||
            otherDragged != nil ||
            rotate != nil ||
            magnify != nil
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
        /// The allowed file content types that can be dropped to the view.
        @available(macOS 11.0, *)
        public var allowedContentTypes: [UTType] {
            get { _allowedContentTypes as? [UTType] ?? [] }
            set { _allowedContentTypes = newValue }
        }
        var _allowedContentTypes: Any?
    
        /// A Boolean value that determines whether the user can drop multiple files with the specified content types  to the view.
        @available(macOS 11.0, *)
        public var allowsMultipleFiles: Bool {
            get { _allowsMultipleFiles }
            set { _allowsMultipleFiles = newValue }
        }
        var _allowsMultipleFiles: Bool = true
        
        /// The handler that gets called when a pasteboard dragging enters the view’s bounds rectangle.
        public var draggingEntered: ((_ items: [PasteboardContent], _ location: CGPoint) -> Void)?
        
        /**
         The handler that determines whether the user can drop the content from the pasteboard to your view.
         
         Implement the handler and return `true`, if the pasteboard contains content that your view accepts dropping.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ content: [PasteboardContent], _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ content: [PasteboardContent], _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging exits the view’s bounds rectangle.
        public var draggingExited: (()->())?

        var isActive: Bool {
            if #available(macOS 11.0, *) {
                (canDrop != nil || !allowedContentTypes.isEmpty) && didDrop != nil
            } else {
                canDrop != nil && didDrop != nil
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
        public var canDrag: ((_ location: CGPoint) -> ([PasteboardContent]?))?
        /// An optional image used for dragging. If `nil`, a rendered image of the view is used.
        public var dragImage: ((_ location: CGPoint) -> ((image: NSImage, imageFrame: CGRect)?))?
        /// The handler that gets called when the user did drag the content to a supported destination.
        public var didDrag: ((_ screenLocation: CGPoint, _ items: [PasteboardContent]) -> ())?
        
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
        var fileDragOperation: NSDragOperation = .copy
        lazy var trackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
        var _mouseHandlers = MouseHandlers() {
            didSet { trackingArea.options = _mouseHandlers.trackingAreaOptions }
        }
        var _windowHandlers = WindowHandlers() {
            didSet {
                setupWindowObservation()
            }
        }
                        
        var _dropHandlers = DropHandlers() {
            didSet { self.setupDragAndDrop() }
        }
        
        var keyWindowObservation: NotificationToken?
        var mainWindowObservation: NotificationToken?
        
        override func viewWillStartLiveResize() {
            super.viewWillStartLiveResize()
        }

        override func viewWillMove(toWindow newWindow: NSWindow?) {
            setupWindowObservation(for: newWindow)
            superview?.viewHandlers.isLiveResizing?(true)
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            superview?.viewHandlers.isLiveResizing?(false)
        }

        func setupWindowObservation(for newWindow: NSWindow? = nil) {
            if let window = newWindow ?? window {
                if let handler = _windowHandlers.isKey  {
                    keyWindowObservation = window.isKeyObservation(handler: handler)
                } else {
                    keyWindowObservation = nil
                }
                if let handler = _windowHandlers.isMain {
                    mainWindowObservation = window.isMainObservation(handler: handler)
                } else {
                    mainWindowObservation = nil
                }
            } else {
                keyWindowObservation = nil
                mainWindowObservation = nil
            }
        }
        
        func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
            switch context {
            case .outsideApplication:
                return fileDragOperation
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
            let contents = session.draggingPasteboard.content()
            guard !contents.isEmpty else { return }
            superview?.dragHandlers.didDrag?(screenPoint, contents)
        }
        
        override public func hitTest(_: NSPoint) -> NSView? {
            nil
        }
        
        override public var acceptsFirstResponder: Bool {
            false
        }
        
        func setupDragAndDrop() {
            if _dropHandlers.isActive {
                registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color, .sound, .URL, .textFinderOptions, .rtf])
            } else {
                unregisterDraggedTypes()
            }
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
                 
        func canDrop(_ pasteboard: NSPasteboard, location: CGPoint) -> Bool {
            let items = pasteboard.content()
            guard !items.isEmpty, _dropHandlers.isActive else { return false }
            if #available(macOS 11.0, *) {
                let contentTypes = _dropHandlers.allowedContentTypes
                if !contentTypes.isEmpty {
                    let conformingURLs = items.fileURLs.compactMap({$0.contentType}).filter({ $0.conforms(toAny: contentTypes) })
                    if !conformingURLs.isEmpty {
                        let allowsMultiple = _dropHandlers.allowsMultipleFiles
                        if allowsMultiple || (!allowsMultiple && conformingURLs.count == 1) {
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
            guard !items.isEmpty else { return false }
            didDrop(items, sender.draggingLocation)
            return true
        }
                
        override func draggingExited(_ sender: NSDraggingInfo?) {
            _dropHandlers.draggingExited?()
            super.draggingExited(sender)
        }
        
        /*
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            superview?.windowHandlers.window?(window)
            setupFirstResponderObservation()
        }
        
        func setupFirstResponderObservation() {
            if let window = window, superview?.viewHandlers.isFirstResponder != nil {
                firstResponderObservation = window.observeChanges(for: \.firstResponder) { [weak self] old, new in
                    guard let self = self, let superview = self.superview, superview.viewHandlers.isFirstResponder != nil else { return }
                    superview._isFirstResponder = superview.isFirstResponder
                }
            } else {
                firstResponderObservation = nil
            }
        }
        
        var firstResponderObservation: KeyValueObservation?
        */
    }
}
    
#endif

