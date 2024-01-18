//
//  ObserverView.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

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
            setupObserverView()
        }
    }
    
    /// The handlers for the view state.
    public var viewHandlers: ViewHandlers {
        get { getAssociatedValue(key: "viewHandlers", object: self, initialValue: ViewHandlers()) }
        set {
            set(associatedValue: newValue, key: "viewHandlers", object: self)
            setupObserverView()
        }
    }
    
    /// The handlers for the view state.
    public var dragAndDropHandlers: DragAndDropHandlers {
        get { getAssociatedValue(key: "dragAndDropHandlers", object: self, initialValue: DragAndDropHandlers()) }
        set {
            set(associatedValue: newValue, key: "dragAndDropHandlers", object: self)
            setupObserverView()
        }
    }
    
    var observerView: ObserverView? {
        get { getAssociatedValue(key: "observerView", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "observerView", object: self) }
    }
    
    var subviewObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "subviewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "subviewObserver", object: self) }
    }
    func setupObserverView() {
        if windowHandlers.needsObserving || mouseHandlers.needsObserving || viewHandlers.needsObserving || dragAndDropHandlers.isActive {
            if observerView == nil {
                let observerView = ObserverView()
                self.observerView = observerView
                addSubview(withConstraint: observerView)
                subviewObserver = observeChanges(for: \.subviews) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    Swift.print("subviews", old.count, new.count)
                    
                }
            }
            observerView?._viewHandlers = viewHandlers
            observerView?._mouseHandlers = mouseHandlers
            observerView?._windowHandlers = windowHandlers
            observerView?._dragAndDropHandlers = dragAndDropHandlers

        } else {
            observerView?.removeFromSuperview()
            observerView = nil
            subviewObserver = nil
        }
    }
    
    /// The handlers for the window state.
    public struct WindowHandlers {
        /// The view will move to a window.
        public var willMoveToWindow: ((NSWindow?) -> Void)?
        
        /// The view did move to a window.
        public var didMoveToWindow: ((NSWindow) -> Void)?
        
        /// The window is key.
        public var isKey: ((Bool) -> Void)?
        
        /// The window is main.
        public var isMain: ((Bool) -> Void)?
        
        var needsObserving: Bool {
            willMoveToWindow != nil || didMoveToWindow != nil || isKey != nil || isMain != nil
        }
    }
    
    /// The handlers for the view.
    public struct ViewHandlers {
        /// The superview changed.
        public var superviewChanged: ((NSView?) -> Void)?
        
        var needsObserving: Bool {
            superviewChanged != nil
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
        
        /// The mouse moved.
        public var moved: ((NSEvent) -> (Bool))?
        
        /// The mouse dragged.
        public var dragged: ((NSEvent) -> (Bool))?
        
        /// The mouse entered.
        public var entered: ((NSEvent) -> (Bool))?
        
        /// The mouse entered.
        public var exited: ((NSEvent) -> (Bool))?
        
        /// The mouse did left click.
        public var down: ((NSEvent) -> (Bool))?
        
        /// The mouse did right click.
        public var rightDown: ((NSEvent) -> (Bool))?
        
        /// The mouse did left click up.
        public var up: ((NSEvent) -> (Bool))?
        
        /// The mouse did right click up.
        public var rightUp: ((NSEvent) -> (Bool))?
        
        var needsObserving: Bool {
            moved != nil || dragged != nil || entered != nil || exited != nil || down != nil || rightDown != nil || up != nil || rightUp != nil
        }
        
        /// Option when the mouse handlers are active. The default value is `inKeyWindow`.
        public var active: ActiveOption = .inKeyWindow
        
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
     The handlers dropping items (either file urls, images, colors or strings) from the pasteboard to your view.
     
     Provide drag and drop handlers to support the dropping of pasteboard items to your view.
     
     The system calls the ``canDrop`` handler to validate if your view accepts dropping the items on the current pasteboard. If `true`, the system calls the ``didDrop`` handler when the user dropped items to your view.
     
     ```swift
     view.dragAndDropHandlers.canDrag = { [weak self] items, location in
        guard let self = self else { return }
        // Accepts dropping of images and file urls.
        if items.images.isEmpty == false || items.fileURLs.isEmpty == false {
            return true
        } else {
            return false
        }
     }
     
     view.dragAndDropHandlers.didDrop = { [weak self] items, location in
        guard let self = self else { return }
        if let images = items.images {
            // dropped images
        }
        if let fileURLs = items.fileURLs {
            // dropped file urls
        }
     }
  }
     ```
     */
    public struct DragAndDropHandlers {
        /// The items on the current pasteboard.
        public struct PasteboardItems {
            /// The file urls on the pasteboard.
            public var fileURLs: [URL]?
            /// The images on the pasteboard.
            public var images: [NSImage]?
            /// The string on the pasteboard.
            public var string: String?
            /// The color on the pasteboard.
            public var color: NSColor?
            
            init(_ draggingInfo: NSDraggingInfo) {
                self.images = draggingInfo.images
                self.string = draggingInfo.string
                self.color = draggingInfo.color
                self.fileURLs = draggingInfo.fileURLs
            }
            
            var isValid: Bool {
                images?.count ?? 0 >= 1 || fileURLs?.count ?? 0 >= 1 || color != nil || string != nil
            }
        }
        
        /**
         The handler that determines whether the user can drop items from the pasteboard to your view.
         
         Provide the handler and return `true`, if the pasteboard contains items that your view accepts dropping.
         */
        public var canDrop: ((_ items: PasteboardItems, _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when items did drop items from the pasteboard to your view.
        public var didDrop: ((_ items: PasteboardItems, _ location: CGPoint) -> Void)?

        var isActive: Bool {
            canDrop != nil && didDrop != nil
        }
    }
    
    class ObserverView: NSView {
        /// The handlers for the window state.
        public var _windowHandlers = WindowHandlers() {
            didSet {
                updateWindowObserver()
            }
        }
        
        /// The handlers for the view state.
        public var _viewHandlers = ViewHandlers() {
            didSet {
                setupObservation(needsSetup: _viewHandlers.needsObserving)
            }
        }
        
        /// The handlers for mouse events.
        public var _mouseHandlers = MouseHandlers() {
            didSet {
                _trackingArea.options = _mouseHandlers.trackingAreaOptions
            }
        }
        
        /// The handlers for drag and drop of files (either images or urls, strings).
        public var _dragAndDropHandlers = DragAndDropHandlers() {
            didSet {
                self.setupDragAndDrop(needsSetup: _dragAndDropHandlers.isActive)
            }
        }
        
        override public func hitTest(_: NSPoint) -> NSView? {
            nil
        }
        
        override public var acceptsFirstResponder: Bool {
            false
        }
        
        func setupDragAndDrop(needsSetup: Bool) {
            if needsSetup {
                registerForDraggedTypes([.fileURL, .png, .string, .tiff, .color])
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
            _trackingArea.options = _mouseHandlers.trackingAreaOptions
            _trackingArea.update()
        }
        
        override public func updateTrackingAreas() {
            super.updateTrackingAreas()
            _trackingArea.update()
        }
        
        override public func mouseEntered(with event: NSEvent) {
            if _mouseHandlers.entered?(event) ?? true {
                super.mouseEntered(with: event)
            }
        }
        
        override public func mouseExited(with event: NSEvent) {
            if _mouseHandlers.exited?(event) ?? true {
                super.mouseExited(with: event)
            }
        }
        
        override public func mouseDown(with event: NSEvent) {
            if _mouseHandlers.down?(event) ?? true {
                super.mouseDown(with: event)
            }
        }
        
        override public func rightMouseDown(with event: NSEvent) {
            if _mouseHandlers.rightDown?(event) ?? true {
                super.rightMouseDown(with: event)
            }
        }
        
        override public func mouseUp(with event: NSEvent) {
            if _mouseHandlers.up?(event) ?? true {
                super.mouseUp(with: event)
            }
        }
        
        override public func rightMouseUp(with event: NSEvent) {
            if _mouseHandlers.rightUp?(event) ?? true {
                super.rightMouseUp(with: event)
            }
        }
        
        override public func mouseMoved(with event: NSEvent) {
            if _mouseHandlers.moved?(event) ?? true {
                super.mouseMoved(with: event)
            }
        }
        
        override public func mouseDragged(with event: NSEvent) {
            if _mouseHandlers.dragged?(event) ?? true {
                super.mouseDragged(with: event)
            }
        }
        
        
        
        var keyValueObserver: KeyValueObserver<NSView>?
        
        func setupObservation(needsSetup: Bool) {
            if needsSetup {
                if keyValueObserver == nil {
                    keyValueObserver = KeyValueObserver(self)
                    keyValueObserver?.add(\.superview?.superview, sendInitalValue: true, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self._viewHandlers.superviewChanged?(new)
                    })
                }
            } else {
                keyValueObserver = nil
            }
        }
        
        override public func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dragAndDropHandlers.isActive, let canDrop = _dragAndDropHandlers.canDrop else { return false }
            let draggingOperation = DragAndDropHandlers.PasteboardItems(sender)
            guard draggingOperation.isValid else { return false }
            return canDrop(draggingOperation, sender.draggingLocation)
        }
        
        /*
        override public func draggingExited(_ sender: NSDraggingInfo?) {
            if let dropOutside = _dragAndDropHandlers.dropOutside?() {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                if let string = dropOutside.compactMap({ $0 as? String }).first {
                    pasteboard.setString(string, forType: .string)
                }
                var items: [NSPasteboardWriting] = []
                let inages = dropOutside.compactMap { $0 as? NSImage }
                items.append(contentsOf: inages)
                let urls = dropOutside.compactMap { $0 as? NSURL }
                items.append(contentsOf: urls)
                if items.isEmpty == false {
                    pasteboard.writeObjects(items)
                }
            }
            super.draggingExited(sender)
        }
         */
        
        var acceptsDrop: Bool = false
        override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard let canDrop = _dragAndDropHandlers.canDrop else { return [] }
            let draggingOperation = DragAndDropHandlers.PasteboardItems(sender)
            guard draggingOperation.isValid else { return [] }
            acceptsDrop = canDrop(draggingOperation, sender.draggingLocation)
            return acceptsDrop ? .copy : []
        }
        
        override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard let canDrop = _dragAndDropHandlers.canDrop else { return [] }
            let draggingOperation = DragAndDropHandlers.PasteboardItems(sender)
            guard draggingOperation.isValid else { return [] }
            acceptsDrop = canDrop(draggingOperation, sender.draggingLocation)
            return acceptsDrop ? .copy : []
        }
        
        override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dragAndDropHandlers.isActive, let didDrop = _dragAndDropHandlers.didDrop else { return false }
            let draggingOperation = DragAndDropHandlers.PasteboardItems(sender)
            guard draggingOperation.isValid else { return false }
            didDrop(draggingOperation, sender.draggingLocation)
            return true
        }
        
        override public func viewDidMoveToWindow() {
            if let window = window {
                _windowHandlers.didMoveToWindow?(window)
            }
            super.viewDidMoveToWindow()
        }
        
        override public func viewWillMove(toWindow newWindow: NSWindow?) {
            if newWindow != window {
                removeWindowKeyObserver()
                removeWindowMainObserver()
                if let newWindow = newWindow {
                    observeWindowState(for: newWindow)
                }
            }
            _windowHandlers.willMoveToWindow?(newWindow)
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
        
        lazy var _trackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
        
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
        
        var windowDidBecomeKeyObserver: NotificationToken?
        var windowDidResignKeyObserver: NotificationToken?
        var windowDidBecomeMainObserver: NotificationToken?
        var windowDidResignMainObserver: NotificationToken?
        
        lazy var _superviewObserver: NSKeyValueObservation? = self.observeChanges(for: \.superview) { [weak self] _, new in
            guard let self = self else { return }
            self._viewHandlers.superviewChanged?(new)
        }
        
        deinit {
            self.removeWindowKeyObserver()
            self.removeWindowMainObserver()
            self._superviewObserver?.invalidate()
        }
    }
}
    
#endif

