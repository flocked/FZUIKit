//
//  File.swift
//  
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A NSView that adds various handlers (e.g. for mouse events and changes to the window and superview).
 */
public class ObserverView: NSView {
    public var windowHandlers = WindowHandlers() {
        didSet { self.updateWindowObserver() }
    }
    
    public var viewHandlers = ViewHandlers() {
        didSet {  }
    }

    public var mouseHandlers = MouseHandlers() {
        didSet { self.trackingArea.options = mouseHandlers.trackingAreaOptions }
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
        self.mouseHandlers.entered?(event)
        super.mouseEntered(with: event)
    }
    
    public override func mouseExited(with event: NSEvent) {
        self.mouseHandlers.exited?(event)
        super.mouseExited(with: event)
    }
    
    public override func mouseDown(with event: NSEvent) {
        self.mouseHandlers.down?(event)
        super.mouseDown(with: event)
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        self.mouseHandlers.rightDown?(event)
        super.rightMouseDown(with: event)
    }
    
    public override func mouseUp(with event: NSEvent) {
        self.mouseHandlers.up?(event)
        super.mouseUp(with: event)
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        self.mouseHandlers.rightUp?(event)
        super.rightMouseUp(with: event)
    }
    
    public override func mouseMoved(with event: NSEvent) {
      //  mouseMoveHandler?(event)
        self.mouseHandlers.moved?(event)
        super.mouseMoved(with: event)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        self.mouseHandlers.dragged?(event)
        super.mouseDragged(with: event)
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

public extension ObserverView {
    struct WindowHandlers {
        public var willMoveToWindow: ((NSWindow?)->())? = nil
        public var didMoveToWindow: ((NSWindow)->())? = nil
        public var isKey: ((Bool)->())? = nil
        public var isMain: ((Bool)->())? = nil
    }
    
    struct ViewHandlers {
        public var willMoveToSuperview: ((NSView?)->())? = nil
        public var didMoveToSuperview: ((NSView?)->())? = nil
    }
    
    struct MouseHandlers {
        public var moved: ((NSEvent)->())? = nil
        public var dragged: ((NSEvent)->())? = nil
        public var entered: ((NSEvent)->())? = nil
        public var exited: ((NSEvent)->())? = nil
        public var down: ((NSEvent)->())? = nil
        public var rightDown: ((NSEvent)->())? = nil
        public var up: ((NSEvent)->())? = nil
        public var rightUp: ((NSEvent)->())? = nil
        
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
