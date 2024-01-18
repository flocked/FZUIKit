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
    
    var _observerView: ObserverView? {
        get { getAssociatedValue(key: "_observerView", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_observerView", object: self) }
    }
    
    func setupObserverView() {
        if windowHandlers.needsObserving || mouseHandlers.needsObserving || viewHandlers.needsObserving {
            if _observerView == nil {
                _observerView = ObserverView()
                self.insertSubview(withConstraint: _observerView!, at: 0)
            }
            _observerView?._viewHandlers = viewHandlers
            _observerView?._mouseHandlers = mouseHandlers
            _observerView?._windowHandlers = windowHandlers
        } else {
            _observerView?.removeFromSuperview()
            _observerView = nil
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
        public var dragAndDropHandlers = DragAndDropHandlers() {
            didSet {
                self.setupDragAndDrop(needsSetup: dragAndDropHandlers.needsSetup)
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
                registerForDraggedTypes([.fileURL, .png, .string, .tiff])
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
            guard let canDrop = dragAndDropHandlers.canDrop else { return false }
            
            let items = sender.pasteboardReadWritings()
            guard items.count > 0 else { return false }
            return canDrop(items).count > 0
        }
        
        override public func draggingExited(_ sender: NSDraggingInfo?) {
            if let dropOutside = dragAndDropHandlers.dropOutside?() {
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
        
        override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard let canDrop = dragAndDropHandlers.canDrop else { return [] }
            let items = sender.pasteboardReadWritings()
            guard items.count > 0 else { return [] }
            guard canDrop(items).count > 0 else { return [] }
            
            return .copy
        }
        
        override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            var items = sender.pasteboardReadWritings()
            items = dragAndDropHandlers.canDrop?(items) ?? items
            guard items.count > 0 else { return false }
            dragAndDropHandlers.didDrop?(items)
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
        
        /// The handlers for file drag and drop.
        struct DragAndDropHandlers {
            public var canDrop: (([PasteboardReadWriting]) -> ([PasteboardReadWriting]))?

            public var didDrop: (([PasteboardReadWriting]) -> Void)?

            public var dropOutside: (() -> ([PasteboardReadWriting]))?

            var needsSetup: Bool {
                canDrop != nil && didDrop != nil
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

