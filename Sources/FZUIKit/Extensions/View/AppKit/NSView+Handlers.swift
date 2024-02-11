//
//  ObserverView.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSObjectProtocol where Self: NSView {
    /**
     Handler that provides the menu for a right-click.

     The provided menu is displayed when the user right-clicks the view. If you don't want to display a menu, return `nil`.
     */
     public var menuProvider: ((Self)->(NSMenu?))? {
        get { getAssociatedValue(key: "menuProvider", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "menuProvider", object: self)
            setupRightDownMonitor()
        }
    }
    
    func setupRightDownMonitor() {
        if mouseHandlers.rightDown != nil || menuProvider != nil {
            let event = NSEvent.EventTypeMask.rightMouseDown
            eventMonitors[event.rawValue] = .local(for: event) { [weak self] event in
                guard let self = self else { return event }
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
    
    /// The handlers for dropping of content into the view.
    public var dropHandlers: DropHandlers {
        get { getAssociatedValue(key: "dropHandlers", object: self, initialValue: DropHandlers()) }
        set {
            set(associatedValue: newValue, key: "dropHandlers", object: self)
            setupObserverView()
        }
    }
    
    /// The handlers for dropping of content into the view.
    public var draggingHandlers: DraggingHandlers {
        get { getAssociatedValue(key: "draggingHandlers", object: self, initialValue: DraggingHandlers()) }
        set {
            set(associatedValue: newValue, key: "draggingHandlers", object: self)
            setupObserverView()
            setupMouseDownMonitor()
        }
    }
    
    func setupEventMonitors() {
        setupEventMonitor(for: .leftMouseUp, handler: mouseHandlers.up)
        setupEventMonitor(for: .rightMouseUp, handler: mouseHandlers.rightUp)
        setupMouseDownMonitor()
        setupRightDownMonitor()
    }
        
    func setupEventMonitor(for event: NSEvent.EventTypeMask, handler: ((NSEvent)->())?) {
        if let handler = handler {
            eventMonitors[event.rawValue] = .local(for: event) { [weak self] event in
                guard let self = self else { return event }
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
            eventMonitors[event.rawValue] = nil
        }
    }
    
    func setupMouseDownMonitor() {
        if mouseHandlers.down != nil || draggingHandlers.canDrag != nil {
            let event: NSEvent.EventTypeMask = .leftMouseDown
            eventMonitors[event.rawValue] = .local(for: event) { [weak self] event in
                guard let self = self else { return event }
                if let contentView = self.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self) {
                        let location = event.location(in: self)
                        if self.bounds.contains(location) {
                            self.mouseHandlers.down?(event)
                            if let draggingItems = self.draggingHandlers.canDragItems?(location), !draggingItems.isEmpty, let observerView = self.observerView {
                                self.beginDraggingSession(with: draggingItems, event: event, source: observerView)
                            } else if let items = self.draggingHandlers.canDrag?(location), !items.isEmpty, let observerView = self.observerView {
                                let draggingItems = items.compactMap({NSDraggingItem(pasteboardWriter: $0)})
                                draggingItems.forEach({$0.draggingFrame = self.frame})
                                self.beginDraggingSession(with: draggingItems, event: event, source: observerView)
                            }
                        }
                    }
                }
                return event
            }
        }
    }
        
    var eventMonitors: [UInt64: NSEvent.Monitor] {
        get { getAssociatedValue(key: "eventMonitors", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "eventMonitors", object: self) }
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
        if windowHandlers.needsObserving || mouseHandlers.needsObserving || dropHandlers.isActive || draggingHandlers.canDrag != nil {
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
        if items.images?.isEmpty == false || items.fileURLs?.isEmpty == false {
            return true
        } else {
            return false
        }
     }
     
     view.dropHandlers.didDrop = { items, location in
        if let images = items.images {
            // dropped images
        }
        if let fileURLs = items.fileURLs {
            // dropped file urls
        }
     }
     ```
     */
    public struct DropHandlers {
        /// The items on the current pasteboard.
        public struct PasteboardContent {
            /// The file urls on the pasteboard.
            public var fileURLs: [URL]?
            /// The urls on the pasteboard.
            public var urls: [URL]?
            /// The images on the pasteboard.
            public var images: [NSImage]?
            /// The strings on the pasteboard.
            public var strings: [String]?
            /// The colors on the pasteboard.
            public var colors: [NSColor]?
            /// The sounds on the pasteboard.
            public var sounds: [NSSound]?
            
            init(_ draggingInfo: NSDraggingInfo) {
                self.images = draggingInfo.images
                self.strings = draggingInfo.strings
                self.colors = draggingInfo.colors
                self.fileURLs = draggingInfo.fileURLs
                self.urls = draggingInfo.urls
                self.sounds = draggingInfo.sounds
            }
            
            var isValid: Bool {
                images?.isEmpty == false || strings?.isEmpty == false || fileURLs?.isEmpty == false || urls?.isEmpty == false || colors?.isEmpty == false || sounds?.isEmpty == false
            }
        }
        
        /// The handler that gets called when a pasteboard dragging enters the view’s bounds rectangle.
        public var draggingEntered: ((_ items: PasteboardContent, _ location: CGPoint) -> Void)?
        
        /**
         The handler that determines whether the user can drop the content from the pasteboard to your view.
         
         Implement the handler and return `true`, if the pasteboard contains content that your view accepts dropping.
         
         The handler gets called repeatedly on every mouse drag on the view’s bounds rectangle.
         */
        public var canDrop: ((_ items: PasteboardContent, _ location: CGPoint) -> (Bool))?

        /// The handler that gets called when the user did drop the content from the pasteboard to your view.
        public var didDrop: ((_ items: PasteboardContent, _ location: CGPoint) -> Void)?
        
        /// The handler that gets called when a pasteboard dragging exits the view’s bounds rectangle.
        public var draggingExited: (()->())?

        var isActive: Bool {
            canDrop != nil && didDrop != nil
        }
    }
    
    public struct DraggingHandlers {
        /// The items to write to the pasteboard.
        public struct PasteboardContent {
            /// The file urls.
            public var fileURLs: [URL]?
            /// The urls.
            public var urls: [URL]?
            /// The images.
            public var images: [NSImage]?
            /// The strings.
            public var strings: [String]?
            /// The colors.
            public var colors: [NSColor]?
            /// The sounds.
            public var sounds: [NSSound]?
            
            func draggingItems() -> [NSDraggingItem] {
                var items: [NSDraggingItem] = []
                
                if let content = fileURLs {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                if let content = urls {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                if let content = strings {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                if let content = images {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                if let content = colors {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                if let content = sounds {
                    items.append(contentsOf:  content.compactMap({NSDraggingItem(pasteboardWriter: ($0 as NSPasteboardWriting))}))
                }
                
               return items
            }
            
            var isValid: Bool {
                images?.isEmpty == false || strings?.isEmpty == false || fileURLs?.isEmpty == false || urls?.isEmpty == false || colors?.isEmpty == false || sounds?.isEmpty == false
            }
        }
        
        public var canDrag: ((_ location: CGPoint) -> ([NSPasteboardWriting]?))?
        public var canDragItems: ((_ location: CGPoint) -> ([NSDraggingItem]?))?
        public var didDrag: ((_ location: CGPoint, _ items: [NSPasteboardWriting]) -> ())?
        public var dragExited: (()->())?
    }
    
    class ObserverView: NSView, NSDraggingSource {
        
        func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
            Swift.print("sourceOperationMaskFor")
            switch context {
            case .outsideApplication:
                return .copy
            default:
                return .generic
            }
        }
        
        func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
            Swift.print("draggingSession willBeginAt", screenPoint)
        }
        func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
            Swift.print("draggingSession ended", screenPoint)
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
                        
        override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard  _dropHandlers.draggingEntered != nil || _dropHandlers.canDrop != nil else { return [] }
            let draggingOperation = DropHandlers.PasteboardContent(sender)
            guard draggingOperation.isValid else { return [] }
            _dropHandlers.draggingEntered?(draggingOperation, sender.draggingLocation)
            return _dropHandlers.canDrop?(draggingOperation, sender.draggingLocation) == true ? .copy : []
        }
        
        override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard let canDrop = _dropHandlers.canDrop else { return [] }
            let draggingOperation = DropHandlers.PasteboardContent(sender)
            guard draggingOperation.isValid else { return [] }
            return canDrop(draggingOperation, sender.draggingLocation) ? .copy : []
        }
        
        override public func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive, let canDrop = _dropHandlers.canDrop else { return false }
            let draggingOperation = DropHandlers.PasteboardContent(sender)
            guard draggingOperation.isValid else { return false }
            return canDrop(draggingOperation, sender.draggingLocation)
        }
        
        override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard _dropHandlers.isActive, let didDrop = _dropHandlers.didDrop else { return false }
            let draggingOperation = DropHandlers.PasteboardContent(sender)
            guard draggingOperation.isValid else { return false }
            didDrop(draggingOperation, sender.draggingLocation)
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

