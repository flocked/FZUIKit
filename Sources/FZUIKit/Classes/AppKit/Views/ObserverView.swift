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
    public func observe() -> ObserverView {
        if let observingView = self.subviews(type: ObserverView.self).first {
            return observingView
        }
        let observingView = ObserverView(frame: .zero)
        self.addSubview(withAutoresizing: observingView)
        observingView.sendToBack()
        return observingView
    }
}

/**
 A view that provides various handlers for mouse, key, view, window and drag & drop events.
 
 You can insert this
 */
public class ObserverView: NSView {
    /// The handlers for the window state.
    public var windowHandlers = WindowHandlers() {
        didSet { self.updateWindowObserver() }
    }
    
    /// The handlers for the view state.
    public var viewHandlers = ViewHandlers() {
        didSet {  }
    }
    
    /// The handlers for keyboard events.
    public var keyHandlers = KeyHandlers() {
        didSet { self.updateWindowObserver() }
    }

    /// The handlers for mouse events.
    public var mouseHandlers = MouseHandlers() {
        didSet { self._trackingArea.options = mouseHandlers.trackingAreaOptions }
    }
    
    ///The handlers for file drag and drop.
    public var dragAndDropHandlers = DragAndDropHandlers() {
        didSet {
            if dragAndDropHandlers.isSetup {
            self.setupDragAndDrop() } }
    }
    
    public var contentView: NSView? = nil {
        didSet {
            if oldValue != self.contentView {
                oldValue?.removeFromSuperview()
            }
            if let contentView = self.contentView {
                self.addSubview(withConstraint: contentView)
            }
        }
    }
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    public override var acceptsFirstResponder: Bool {
        return false
    }
    
    internal func setupDragAndDrop() {
        self.registerForDraggedTypes([.fileURL, .png, .string, .tiff])
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initalSetup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initalSetup()
    }
    
    internal func initalSetup() {
        self._trackingArea.update()
        _ = self._superviewObserver
    }
    
    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        self.viewHandlers.willMoveToSuperview?(newSuperview)
        super.viewWillMove(toSuperview: newSuperview)
    }
    
    public override func viewDidMoveToSuperview() {
        if let superview = self.superview {
            self.viewHandlers.didMoveToSuperview?(superview)
        }
        super.viewDidMoveToSuperview()
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        _trackingArea.update()
    }
    
    public override func mouseEntered(with event: NSEvent) {
        if (self.mouseHandlers.entered?(event) ?? true) {
            super.mouseEntered(with: event)
        }
    }
    
    public override func mouseExited(with event: NSEvent) {
        if (self.mouseHandlers.exited?(event) ?? true) {
            super.mouseExited(with: event)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        if (self.mouseHandlers.down?(event) ?? true) {
            super.mouseDown(with: event)
        }
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        if (self.mouseHandlers.rightDown?(event) ?? true) {
            super.rightMouseDown(with: event)
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        if (self.mouseHandlers.up?(event) ?? true) {
            super.mouseUp(with: event)
        }
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        if (self.mouseHandlers.rightUp?(event) ?? true) {
            super.rightMouseUp(with: event)
        }
    }
    
    public override func mouseMoved(with event: NSEvent) {
        if (self.mouseHandlers.moved?(event) ?? true) {
            super.mouseMoved(with: event)
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        if (self.mouseHandlers.dragged?(event) ?? true) {
            super.mouseDragged(with: event)
        }
    }
    
    /*
    public override func keyDown(with event: NSEvent) {
        if (self.keyHandlers.keyDown?(event) ?? true) {
            super.keyDown(with: event)
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        if (self.keyHandlers.keyUp?(event) ?? true) {
            super.keyUp(with: event)
        }
    }
    
    public override func flagsChanged(with event: NSEvent) {
        let performSuper = self.keyHandlers.flagsChanged?(event) ?? true
        if (performSuper) {
            super.flagsChanged(with: event)
        }
    }
    */
    
    var keyDownMonitor: NSEvent.Monitor? = nil
    var keyUpMonitor: NSEvent.Monitor? = nil
    var flagsChangedMonitor: NSEvent.Monitor? = nil

    func setupKeyObserver() {
        if let keyDown = keyHandlers.keyDown {
            if keyDownMonitor == nil {
                keyDownMonitor = .local(for: .keyDown, handler: { event in
                    if keyDown(event) {
                        return nil
                    }
                    return event
                })
            }
        } else {
            keyDownMonitor = nil
        }
        
        if let keyUp = keyHandlers.keyUp {
            if keyUpMonitor == nil {
                keyUpMonitor = .local(for: .keyUp, handler: { event in
                    if keyUp(event) {
                        return nil
                    }
                    return event
                })
            }
        } else {
            keyUpMonitor = nil
        }
        
        if let flagsChanged = keyHandlers.flagsChanged {
            if flagsChangedMonitor == nil {
                flagsChangedMonitor = .local(for: .flagsChanged, handler: { event in
                    if flagsChanged(event) {
                        return nil
                    }
                    return event
                })
            }
        } else {
            flagsChangedMonitor = nil
        }
    }
    
    public override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let canDrop = self.dragAndDropHandlers.canDrop else { return false }
        
        let items = sender.pasteboardReadWritings()
        guard items.count > 0 else { return false }
        return (canDrop(items).count > 0)
    }
    
    public override func draggingExited(_ sender: NSDraggingInfo?) {
        if let dropOutside = self.dragAndDropHandlers.dropOutside?() {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            if let string = dropOutside.compactMap({$0 as? String}).first {
                pasteboard.setString(string, forType: .string)
            }
            var items: [NSPasteboardWriting] = []
            let inages = dropOutside.compactMap({$0 as? NSImage})
            items.append(contentsOf: inages)
            let urls = dropOutside.compactMap({$0 as? NSURL})
            items.append(contentsOf: urls)
            if items.isEmpty == false {
                pasteboard.writeObjects(items)
            }
        }
        super.draggingExited(sender)
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let canDrop = self.dragAndDropHandlers.canDrop else { return [] }
        let items = sender.pasteboardReadWritings()
        guard items.count > 0 else { return [] }
        guard (canDrop(items).count > 0) else { return [] }
        
        return .copy
    }


    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        var items = sender.pasteboardReadWritings()
        items = dragAndDropHandlers.canDrop?(items) ?? items
        guard items.count > 0 else { return false }
        dragAndDropHandlers.didDrop?(items)
        return true
    }
    
    public override func viewDidMoveToWindow() {
        if let window = self.window {
            self.windowHandlers.didMoveToWindow?(window)
        }
        super.viewDidMoveToWindow()
    }
        
    public override func viewWillMove(toWindow newWindow: NSWindow?) {
        if (newWindow != self.window) {
            self.removeWindowKeyObserver()
            self.removeWindowMainObserver()
            if let newWindow = newWindow {
                self.observeWindowState(for: newWindow)
            }
        }
        self.windowHandlers.willMoveToWindow?(newWindow)
        super.viewWillMove(toWindow: newWindow)
    }
    
    internal func updateWindowObserver() {
        if windowHandlers.isKey == nil {
            self.removeWindowKeyObserver()
        }
        
        if windowHandlers.isMain == nil {
            self.removeWindowMainObserver()
        }
        
        if let window = self.window {
            self.observeWindowState(for: window)
        }
    }
    
    internal lazy var _trackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
    
    internal func removeWindowKeyObserver() {
        windowDidBecomeKeyObserver = nil
        windowDidResignKeyObserver = nil
    }
    
    internal func removeWindowMainObserver() {
        windowDidBecomeMainObserver = nil
        windowDidResignMainObserver = nil
    }
    
    internal func observeWindowState(for window: NSWindow) {
        if windowDidBecomeKeyObserver == nil, windowHandlers.isKey != nil {
            windowDidBecomeKeyObserver = NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: window) { notification in
                self.windowIsKey = true
            }
            
            windowDidResignKeyObserver = NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: window) { notification in
                self.windowIsKey = false
            }
        }
        
        if windowDidBecomeMainObserver == nil, windowHandlers.isMain != nil {
            windowDidBecomeMainObserver = NotificationCenter.default.observe(NSWindow.didBecomeMainNotification, object: window) { notification in
                self.windowIsMain = true
            }
            
            windowDidResignMainObserver = NotificationCenter.default.observe(NSWindow.didResignMainNotification, object: window) { notification in
                self.windowIsMain = false
            }
        }
    }
    
    internal var windowIsKey = false {
        didSet {
            if (oldValue != self.windowIsKey) {
                windowHandlers.isKey?(self.windowIsKey)
            }
        }
    }
    
    internal var windowIsMain = false {
        didSet {
            if (oldValue != self.windowIsMain) {
                windowHandlers.isMain?(self.windowIsMain)
            }
        }
    }
        
    internal var windowDidBecomeKeyObserver: NotificationToken? = nil
    internal var windowDidResignKeyObserver: NotificationToken? = nil
    internal var windowDidBecomeMainObserver: NotificationToken? = nil
    internal var windowDidResignMainObserver: NotificationToken? = nil
    
    internal lazy var _superviewObserver: NSKeyValueObservation? = self.observeChanges(for: \.superview) { [weak self]  _, new in
        guard let self = self else { return }
        self.viewHandlers.didMoveToSuperview?(new)
    }

    deinit {
        self.removeWindowKeyObserver()
        self.removeWindowMainObserver()
        self._superviewObserver?.invalidate()
    }
}

extension ObserverView {
    ///The handlers for the window state.
    public struct WindowHandlers {
        /// The view will move to a window.
        public var willMoveToWindow: ((NSWindow?)->())? = nil
        /// The view did move to a window.
        public var didMoveToWindow: ((NSWindow)->())? = nil
        /// The window is key.
        public var isKey: ((Bool)->())? = nil
        /// The window is main.
        public var isMain: ((Bool)->())? = nil
    }
    
    ///The handlers for file drag and drop.
    public struct DragAndDropHandlers {
        public var canDrop: (([PasteboardReadWriting]) -> ([PasteboardReadWriting]))? = nil
        public var didDrop: (([PasteboardReadWriting]) -> ())? = nil
        public var dropOutside: (() -> ([PasteboardReadWriting]))? = nil
        
        internal var isSetup: Bool {
            self.canDrop != nil && self.didDrop != nil
        }
    }
    
    /// The handlers for the view.
    public struct ViewHandlers {
        /// The view will move to a superview.
        public var willMoveToSuperview: ((NSView?)->())? = nil
        /// The view did move to a superview.
        public var didMoveToSuperview: ((NSView?)->())? = nil
    }
    
    /// The handlers for keyboard events.
    public struct KeyHandlers {
        /// The keyDown event.
        public var keyDown: ((NSEvent)->(Bool))? = nil
        /// The keyUp event.
        public var keyUp: ((NSEvent)->(Bool))? = nil
        /// The flagsChanged event.
        public var flagsChanged: ((NSEvent)->(Bool))? = nil
        
        var shouldObserve: Bool {
            keyDown != nil || keyUp != nil || flagsChanged != nil
        }
    }
    
    /// The handlers for mouse events.
    public struct MouseHandlers {
        enum Event {
            case moved
            case dragged
            case entered
            case exited
            case down
            case rightDown
            case up
            case rightUp
        }
        
        /// The mouse moved.
        public var moved: ((NSEvent)->(Bool))? = nil
        /// The mouse dragged.
        public var dragged: ((NSEvent)->(Bool))? = nil
        /// The mouse entered.
        public var entered: ((NSEvent)->(Bool))? = nil
        /// The mouse entered.
        public var exited: ((NSEvent)->(Bool))? = nil
        /// The mouse did left click.
        public var down: ((NSEvent)->(Bool))? = nil
        /// The mouse did right click.
        public var rightDown: ((NSEvent)->(Bool))? = nil
        /// The mouse did left click up.
        public var up: ((NSEvent)->(Bool))? = nil
        /// The mouse did right click up.
        public var rightUp: ((NSEvent)->(Bool))? = nil
        
        mutating func setup(_ events: [Event], handler: @escaping ((NSEvent)->(Bool))) {
            if events.contains(.moved) {
                self.moved = handler
            }
            if events.contains(.dragged) {
                self.dragged = handler
            }
            if events.contains(.entered) {
                self.entered = handler
            }
            if events.contains(.exited) {
                self.exited = handler
            }
            if events.contains(.down) {
                self.down = handler
            }
            if events.contains(.rightDown) {
                self.rightDown = handler
            }
            if events.contains(.up) {
                self.up = handler
            }
            if events.contains(.rightUp) {
                self.rightUp = handler
            }
        }
        
        var trackingAreaOptions: NSTrackingArea.Options {
            var options: NSTrackingArea.Options = [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited]
            if (dragged != nil) {
                options.insert(.enabledDuringMouseDrag)
            }
            if (moved != nil) {
                options.insert(NSTrackingArea.Options.mouseMoved)
            }
            return options
        }
    }
}
#endif
