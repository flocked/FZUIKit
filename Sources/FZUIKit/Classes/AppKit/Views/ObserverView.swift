//
//  File.swift
//  
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public protocol DraggingType { }
extension String: DraggingType { }
extension NSImage: DraggingType { }
extension URL: DraggingType { }



/**
 A NSView that adds various handlers (e.g. for mouse events and changes to the window and superview).
 */
public class ObservingView: NSView {
    public var contentView: NSView? = nil {
        willSet {
            if (newValue != self.contentView) {
                self.contentView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let contentView = self.contentView {
                self.addSubview(withConstraint: contentView)
            }
        }
    }
    
    public var windowHandlers = WindowHandlers() {
        didSet { self.updateWindowObserver() }
    }
    
    public var viewHandlers = ViewHandlers() {
        didSet {  }
    }
    
    public var keyHandlers = KeyHandlers() {
        didSet { self.updateWindowObserver() }
    }

    public var mouseHandlers = MouseHandlers() {
        didSet { self.trackingArea.options = mouseHandlers.trackingAreaOptions }
    }
    
    public var dragAndDropHandlers = DragAndDropHandlers() {
        didSet {
            if dragAndDropHandlers.isSetup {
            self.setupDragAndDrop() } }
    }
    
    internal func setupDragAndDrop() {
        self.registerForDraggedTypes([.fileURL])
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
        self.trackingArea.update()
        _ = self.superviewObserver
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
        trackingArea.update()
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
    
    public override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let canDrop = self.dragAndDropHandlers.canDrop else { return false }
        guard let files = filesOnPasteboard(for: sender) else { return false }
        return (canDrop(files).count > 0)
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let canDrop = self.dragAndDropHandlers.canDrop else { return [] }
        guard let files = filesOnPasteboard(for: sender) else { return [] }
        
        guard (canDrop(files).count > 0) else { return [] }
        return .copy
    }


    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard var files = filesOnPasteboard(for: sender) else { return false }
        
        files = dragAndDropHandlers.canDrop?(files) ?? files
        guard files.count > 0 else { return false }
        dragAndDropHandlers.didDrop?(files)
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
    
    internal lazy var trackingArea: TrackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
    
    internal func removeWindowKeyObserver() {
        windowDidBecomeKeyObserver = nil
        windowDidResignKeyObserver = nil
    }
    
    internal func removeWindowMainObserver() {
        windowDidBecomeMainObserver = nil
        windowDidResignMainObserver = nil
    }
    
    internal func observeWindowState(for window: NSWindow) {
        Swift.print(observeWindowState)
        if windowDidBecomeKeyObserver == nil, windowHandlers.isKey != nil {
            windowDidBecomeKeyObserver = NotificationCenter.default.observe(name: NSWindow.didBecomeKeyNotification, object: window) { notification in
                self.windowIsKey = true
            }
            
            windowDidResignKeyObserver = NotificationCenter.default.observe(name: NSWindow.didResignKeyNotification, object: window) { notification in
                self.windowIsKey = false
            }
        }
        
        if windowDidBecomeMainObserver == nil, windowHandlers.isMain != nil {
            windowDidBecomeMainObserver = NotificationCenter.default.observe(name: NSWindow.didBecomeMainNotification, object: window) { notification in
                self.windowIsMain = true
            }
            
            windowDidResignMainObserver = NotificationCenter.default.observe(name: NSWindow.didResignMainNotification, object: window) { notification in
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
    
    internal lazy var superviewObserver: NSKeyValueObservation? = self.observeChange(\.superview) { [weak self] _, _, new in
        guard let self = self else { return }
        self.viewHandlers.didMoveToSuperview?(new)
    }

    deinit {
        self.removeWindowKeyObserver()
        self.removeWindowMainObserver()
        self.superviewObserver?.invalidate()
    }
}

public extension ObservingView {
    struct WindowHandlers {
        public var willMoveToWindow: ((NSWindow?)->())? = nil
        public var didMoveToWindow: ((NSWindow)->())? = nil
        public var isKey: ((Bool)->())? = nil
        public var isMain: ((Bool)->())? = nil
    }
    
    struct DragAndDropHandlers {
        public var canDrop: (([URL]) -> ([URL]))? = nil
        public var didDrop: (([URL]) -> ())? = nil
        
        public var canDropOutside: (() -> ([URL]))? = nil
        public var didDropOutside: (([URL]) -> ())? = nil
        
        internal var isSetup: Bool {
            self.canDrop != nil && self.didDrop != nil
        }
    }
        
    struct ViewHandlers {
        public var willMoveToSuperview: ((NSView?)->())? = nil
        public var didMoveToSuperview: ((NSView?)->())? = nil
    }
    
    struct KeyHandlers {
        public var keyDown: ((NSEvent)->(Bool))? = nil
        public var keyUp: ((NSEvent)->(Bool))? = nil
        public var flagsChanged: ((NSEvent)->(Bool))? = nil
    }
    
    struct MouseHandlers {
        public var moved: ((NSEvent)->(Bool))? = nil
        public var dragged: ((NSEvent)->(Bool))? = nil
        public var entered: ((NSEvent)->(Bool))? = nil
        public var exited: ((NSEvent)->(Bool))? = nil
        public var down: ((NSEvent)->(Bool))? = nil
        public var rightDown: ((NSEvent)->(Bool))? = nil
        public var up: ((NSEvent)->(Bool))? = nil
        public var rightUp: ((NSEvent)->(Bool))? = nil
        
        internal var trackingAreaOptions: NSTrackingArea.Options {
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
