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
    /**
     Observes the view by adding a hidden ``ObserverView`` as subview to the receiver and returning it.
     
     You can observe the window state, keyboard and mouse events and drag and drop of files for the view by using the correspoinding handlers of the `ObserverView`.
     
     If there is already observed and already includes a `ObserverView` as subview it will return that subview.
     */
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
        didSet { 
            self.updateWindowObserver()
        }
    }
    
    /// The handlers for the view state.
    public var viewHandlers = ViewHandlers() {
        didSet { 
            self.setupObservation(needsSetup: viewHandlers.needsSetup)
        }
    }
    
    /// The handlers for mouse events.
    public var mouseHandlers = MouseHandlers() {
        didSet {
            self._trackingArea.options = mouseHandlers.trackingAreaOptions
        }
    }
    
    ///The handlers for drag and drop of files (either images or urls, strings).
    public var dragAndDropHandlers = DragAndDropHandlers() {
        didSet {
            self.setupDragAndDrop(needsSetup: dragAndDropHandlers.needsSetup)
        }
    }
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
    
    public override var acceptsFirstResponder: Bool {
        false
    }
    
    func setupDragAndDrop(needsSetup: Bool) {
        if needsSetup {
            self.registerForDraggedTypes([.fileURL, .png, .string, .tiff])
        } else {
            self.unregisterDraggedTypes()
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initalSetup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initalSetup()
    }
    
    func initalSetup() {
        trackingArea
        _trackingArea.options = mouseHandlers.trackingAreaOptions
        _trackingArea.update()
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
    
    var keyValueObserver: KeyValueObserver<NSView>? = nil
    
    func setupObservation(needsSetup: Bool) {
        if needsSetup {
            if keyValueObserver == nil {
                keyValueObserver = KeyValueObserver(self)
                keyValueObserver?.add(\.superview?.superview, sendInitalValue: true, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.viewHandlers.superviewChanged?(new)
                    
                })
            }
        } else {
            keyValueObserver = nil
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
    
    func updateWindowObserver() {
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
    
    var windowIsKey = false {
        didSet {
            if (oldValue != self.windowIsKey) {
                windowHandlers.isKey?(self.windowIsKey)
            }
        }
    }
    
    var windowIsMain = false {
        didSet {
            if (oldValue != self.windowIsMain) {
                windowHandlers.isMain?(self.windowIsMain)
            }
        }
    }
        
    var windowDidBecomeKeyObserver: NotificationToken? = nil
    var windowDidResignKeyObserver: NotificationToken? = nil
    var windowDidBecomeMainObserver: NotificationToken? = nil
    var windowDidResignMainObserver: NotificationToken? = nil
    
    lazy var _superviewObserver: NSKeyValueObservation? = self.observeChanges(for: \.superview) { [weak self]  _, new in
        guard let self = self else { return }
        self.viewHandlers.superviewChanged?(new)
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
        
        var needsSetup: Bool {
            self.canDrop != nil && self.didDrop != nil
        }
    }
    
    /// The handlers for the view.
    public struct ViewHandlers {
        /// The superview changed.
        public var superviewChanged: ((NSView?)->())? = nil
        
        var needsSetup: Bool {
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
        
        /// Option when the mouse handlers are active. The default value is `inKeyWindow`.
        public var active: ActiveOption = .inKeyWindow
        
        var trackingAreaOptions: NSTrackingArea.Options {
            var options: NSTrackingArea.Options = [.inVisibleRect, .mouseEnteredAndExited]
            options.insert(active.option)
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
