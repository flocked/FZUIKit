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
     
     The handler provides the location of the right click inside the view. Return the menu to the handler, or `nil`, if you don't want to display a menu.
     */
    public var menuProvider: ((_ location: CGPoint)->(NSMenu?))? {
        get { (menu as? ViewMenuProviderMenu)?.handler }
        set {
            if let newValue = newValue {
                menu = menu as? ViewMenuProviderMenu ?? ViewMenuProviderMenu(for: self)
                (menu as? ViewMenuProviderMenu)?.handler = newValue
            } else if menu is ViewMenuProviderMenu {
                menu = nil
            }
        }
    }
    
    class ViewMenuProviderMenu: NSMenu {
        weak var view: NSView?
        var handler: ((_ location: CGPoint)->(NSMenu?)) = { _ in return nil }
        
        init(for view: NSView) {
            self.view = view
            super.init(title: "")
            self.setupDelegateProxy()
        }
        
        func getMenu() -> NSMenu? {
            guard let view = view, let location = NSApp.currentEvent?.location(in: view) else { return nil }
            return handler(location)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    /// The handlers for the window state.
    public var windowHandlers: WindowHandlers {
        get { getAssociatedValue("windowHandlers", initialValue: WindowHandlers()) }
        set {
            setAssociatedValue(newValue, key: "windowHandlers")
            setupObservation()
            setupWindowObservation()
            setupWillMoveToWindow()
        }
    }
    
    /// The handlers for mouse events.
    public var mouseHandlers: MouseHandlers {
        get { getAssociatedValue("mouseHandlers", initialValue: MouseHandlers()) }
        set {
            setAssociatedValue(newValue, key: "mouseHandlers")
            guard !(self is ObserverView) else { return }
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
            guard !(self is ObserverView) else { return }
            setupObservation()
            setupObserverView()
            setupWillMoveToSuperview()
        }
    }
    
    /// A touch event.
    public struct TouchEvent: Hashable, CustomStringConvertible {
        /// Phase of the event.
        public enum Phase: Int, Hashable, CustomStringConvertible {
            /// A new set of touches has been recognized.
            case began
            /// One or more touches have moved.
            case moved
            /// The touches have been removed.
            case ended
            /// The tracking of the touches has been cancelled for any reason (e.g. if the window associated with the touches resigns key or is deactivated).
            case cancelled
            
            public var description: String {
                switch self {
                case .began: return "began"
                case .moved: return "moved"
                case .ended: return "ended"
                case .cancelled: return "cancelled"
                }
            }
        }
        
        /// The touches.
        public let touches: Set<NSTouch>
        
        /// The phase of the event.
        public let phase: Phase
        
        /// The touch event.
        public let event: NSEvent
        
        public var description: String {
            "TouchEvent(\(phase.description), touches: \(touches.count))"
        }
        
        init(event: NSEvent, view: NSView, phase: Phase) {
            self.touches = event.touches(matching: .any, in: view)
            self.phase = phase
            self.event = event
        }
    }
    
    /// The handler for touch events.
    public var touchHandler: ((_ event: TouchEvent)->())? {
        get { getAssociatedValue("touchHandler") }
        set {
            setAssociatedValue(newValue, key: "touchHandler")
            guard !(self is TouchRecognizerView) else { return }
            if let newValue = newValue {
                if touchRecognizerView == nil {
                    touchRecognizerView = TouchRecognizerView(for: self)
                }
                touchRecognizerView?.touchHandler = newValue
            } else {
                touchRecognizerView?.removeFromSuperview()
                touchRecognizerView = nil
            }
        }
    }
    
    var touchRecognizerView: TouchRecognizerView? {
        get { getAssociatedValue("touchRecognizerView") }
        set { setAssociatedValue(newValue, key: "touchRecognizerView") }
    }
        
    var observerGestureRecognizer: ObserverGestureRecognizer? {
        get { getAssociatedValue("observerGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "observerGestureRecognizer") }
    }
    
    func setupEventMonitors() {
        if mouseHandlers.needsGestureObserving || keyHandlers.needsObserving {
            if let observerGestureRecognizer = observerGestureRecognizer, gestureRecognizers.contains(observerGestureRecognizer) == false {
                addGestureRecognizer(observerGestureRecognizer)
            } else if observerGestureRecognizer == nil {
                observerGestureRecognizer = ObserverGestureRecognizer()
                addGestureRecognizer(observerGestureRecognizer!)
            }
        } else {
            observerGestureRecognizer?.removeFromView()
            observerGestureRecognizer = nil
        }
    }
    
    var keyWindowObservation: NotificationToken? {
        get { getAssociatedValue("keyWindowObservation") }
        set { setAssociatedValue(newValue, key: "keyWindowObservation") }
    }
    var mainWindowObservation: NotificationToken? {
        get { getAssociatedValue("mainWindowObservation") }
        set { setAssociatedValue(newValue, key: "mainWindowObservation") }
    }
    
    fileprivate var backgroundStyleObserverView: BackgroundStyleObserverView? {
        get { getAssociatedValue("backgroundStyleObserverView") }
        set { setAssociatedValue(newValue, key: "backgroundStyleObserverView") }
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
        
        observe(\.window?.screen, handler: \.windowHandlers.screen)
        observe(\.effectiveAppearance, handler: \.viewHandlers.effectiveAppearance)
        observe(\.alphaValue, handler: \.viewHandlers.alphaValue)
        observe(\.isHidden, handler: \.viewHandlers.isHidden)
        observe(\.bounds, handler: \.viewHandlers.bounds)
        observe(\.frame, handler: \.viewHandlers.frame)
        observe(\.superview, handler: \.viewHandlers.superview)
        if viewHandlers.backgroundStyle == nil {
            backgroundStyleObserverView?.removeFromSuperview()
            backgroundStyleObserverView = nil
        } else if backgroundStyleObserverView == nil {
            backgroundStyleObserverView = .init(frame: .zero)
            addSubview(backgroundStyleObserverView!)
            backgroundStyleObserverView?.sendToBack()
            backgroundStyleObserverView?.zPosition = -4000
        }
        
        if windowHandlers.frame == nil {
            viewObserver.remove(\.window?.frame)
        } else if !viewObserver.isObserving(\.window?.frame) {
            viewObserver.add(\.window?.frame) { [weak self] _, frame in
                guard let self = self, let frame = frame else { return }
                self.windowHandlers.frame?(frame)
            }
        }
        
        if !windowHandlers.needsObservation {
            viewObserver.remove(\.window)
        } else if !viewObserver.isObserving(\.window) {
            viewObserver.add(\.window) { [weak self] _, window in
                guard let self = self else { return }
                self.setupWindowObservation()
                self.windowHandlers.window?(window)
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
    
    func setupWindowObservation() {
        if let window = window {
            if let handler = windowHandlers.isKey {
                keyWindowObservation = window.observeIsKey(handler: handler)
            } else {
                keyWindowObservation = nil
            }
            if let handler = windowHandlers.isMain {
                mainWindowObservation = window.observeIsMain(handler: handler)
            } else {
                mainWindowObservation = nil
            }
        } else {
            keyWindowObservation = nil
            mainWindowObservation = nil
        }
    }
    
    func setupWillMoveToWindow() {
        willMoveToWindowHook = nil
        if let handler = windowHandlers.willMoveToWindow {
            do {
                willMoveToWindowHook = try hookBefore(#selector(NSView.viewWillMove(toWindow:)), closure: { object, selector, newWindow in
                    handler(newWindow)
                } as @convention(block) (AnyObject, Selector, NSWindow?) -> ())
            } catch {
                Swift.print(error)
            }
        }
    }
    
    var willMoveToWindowHook: Hook? {
        get { getAssociatedValue("willMoveToWindowHook") }
        set { setAssociatedValue(newValue, key: "willMoveToWindowHook") }
    }
    
    func setupWillMoveToSuperview() {
        willMoveToSuperviewHook = nil
        if let handler = viewHandlers.willMoveToSuperview {
            do {
                willMoveToSuperviewHook = try hookBefore(#selector(NSView.viewWillMove(toSuperview:)), closure: { object, selector, superview in
                    handler(superview)
                } as @convention(block) (AnyObject, Selector, NSView?) -> ())
            } catch {
                Swift.print(error)
            }
        }
    }
    
    var willMoveToSuperviewHook: Hook? {
        get { getAssociatedValue("willMoveToSuperviewHook") }
        set { setAssociatedValue(newValue, key: "willMoveToSuperviewHook") }
    }
    
    /// A Boolean value that indicates whether the property `inLiveResize` is KVO observable.
    public static var isLiveResizingObservable: Bool {
        get { isMethodHooked(#selector(NSView.viewWillStartLiveResize)) }
        set {
            guard newValue != isLiveResizingObservable else { return }
            if newValue {
                do {
                    try hook(#selector(NSView.viewWillStartLiveResize), closure: { original, object, sel in
                        if let view = object as? NSView {
                            view.willChangeValue(for: \.inLiveResize)
                            view._inLiveResize = true
                            view.didChangeValue(for: \.inLiveResize)
                            view._inLiveResize = nil
                        }
                        original(object, sel)
                    } as @convention(block) (
                        (AnyObject, Selector) -> Void,
                        AnyObject, Selector) -> Void)
                    
                    try hook(#selector(NSView.viewDidEndLiveResize), closure: { original, object, sel in
                        if let view = object as? NSView {
                            view._inLiveResize = true
                            view.willChangeValue(for: \.inLiveResize)
                            view._inLiveResize = nil
                            view.didChangeValue(for: \.inLiveResize)
                        }
                        original(object, sel)
                    } as @convention(block) (
                        (AnyObject, Selector) -> Void,
                        AnyObject, Selector) -> Void)
                    
                    try hook(#selector(getter: NSView.inLiveResize), closure: { original, object, sel in
                        (object as? NSView)?._inLiveResize ?? original(object, sel)
                    } as @convention(block) (
                        (AnyObject, Selector) -> Bool,
                        AnyObject, Selector) -> Bool)
                } catch {
                   debugPrint(error)
                }
            } else {
                revertHooks(for: #selector(NSView.viewWillStartLiveResize))
                revertHooks(for: #selector(NSView.viewDidEndLiveResize))
                revertHooks(for: #selector(getter: NSView.inLiveResize))
            }
        }
    }
    
    static func setupLiveResizingObservation() {
        guard !isMethodHooked(#selector(NSView.viewWillStartLiveResize)) else { return  }
        do {
            try hook(#selector(NSView.viewWillStartLiveResize), closure: { original, object, sel in
                (object as? NSView)?.willChangeValue(for: \.inLiveResize)
                (object as? NSView)?._inLiveResize = true
                (object as? NSView)?.didChangeValue(for: \.inLiveResize)
                (object as? NSView)?._inLiveResize = nil
                original(object, sel)
            } as @convention(block) (
                (AnyObject, Selector) -> Void,
                AnyObject, Selector) -> Void)
            
            try hook(#selector(NSView.viewDidEndLiveResize), closure: { original, object, sel in
                (object as? NSView)?._inLiveResize = true
                (object as? NSView)?.willChangeValue(for: \.inLiveResize)
                (object as? NSView)?._inLiveResize = nil
                (object as? NSView)?.didChangeValue(for: \.inLiveResize)
                original(object, sel)
            } as @convention(block) (
                (AnyObject, Selector) -> Void,
                AnyObject, Selector) -> Void)
            
            try hook(#selector(getter: NSView.inLiveResize), closure: { original, object, sel in
                (object as? NSView)?._inLiveResize ?? original(object, sel)
            } as @convention(block) (
                (AnyObject, Selector) -> Bool,
                AnyObject, Selector) -> Bool)
        } catch {
           // handle error
           debugPrint(error)
        }
    }
    
    var __backgroundStyle: NSView.BackgroundStyle {
        get { getAssociatedValue("__backgroundStyle") ?? .normal }
        set { setAssociatedValue(newValue, key: "__backgroundStyle") }
    }
    
    var _inLiveResize: Bool? {
        get { getAssociatedValue("_inLiveResize") }
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
        get { getAssociatedValue("observerView") }
        set { setAssociatedValue(newValue, key: "observerView") }
    }
        
    func setupObserverView() {
        if mouseHandlers.needsObserving || viewHandlers.needsObserverView {
            if observerView == nil {
                observerView = ObserverView(for: self)
            }
            observerView?.setupMouseHandlers(mouseHandlers)
        } else {
            observerView?.removeFromSuperview()
            observerView = nil
        }
    }
    
    /// The handlers for the window state.
    public struct WindowHandlers {
        /// The handler that gets called before the window of the view changes.
        public var willMoveToWindow: ((NSWindow?) -> Void)?
        
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
        
        var needsObservation: Bool {
            isKey != nil || isMain != nil || window != nil
        }
    }
    
    /// The handlers for the view.
    public struct ViewHandlers {
        /// The handler that gets called before the superview changed.
        public var willMoveToSuperview: ((NSView?) -> Void)?
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
        /// The handler that gets called when the background style changed.
        public var backgroundStyle: ((BackgroundStyle)->())?
        
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
        
        /// The handler that gets called when the mouse is hovering (is inside) the view.
        public var isHovering: ((Bool) -> ())?
        
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
            moved != nil || entered != nil || exited != nil || isHovering != nil
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
    
    class ObserverView: NSView {
        lazy var trackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited])
        func setupMouseHandlers(_ handlers: MouseHandlers) {
            mouseHandlers = handlers
            trackingArea.options = handlers.trackingAreaOptions
        }
        
        override func viewWillStartLiveResize() {
            super.viewWillStartLiveResize()
            superview?.viewHandlers.isLiveResizing?(true)
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            superview?.viewHandlers.isLiveResizing?(true)
        }
        
        override public func hitTest(_: NSPoint) -> NSView? {
            nil
        }
        
        override public var acceptsFirstResponder: Bool {
            false
        }
        
        override public func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override public func mouseEntered(with event: NSEvent) {
            mouseHandlers.entered?(event)
            mouseHandlers.isHovering?(true)
            super.mouseEntered(with: event)
        }
        
        override public func mouseExited(with event: NSEvent) {
            mouseHandlers.exited?(event)
            mouseHandlers.isHovering?(false)
            super.mouseExited(with: event)
        }
        
        override public func mouseMoved(with event: NSEvent) {
            mouseHandlers.moved?(event)
            super.mouseMoved(with: event)
        }
        
        init(for view: NSView) {
            super.init(frame: .zero)
            zPosition = -2001
            view.addSubview(withConstraint: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func removeFromSuperview() {
            if let superview = superview, !superview.mouseHandlers.needsObserving && !superview.viewHandlers.needsObserverView {
                super.removeFromSuperview()
            }
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
    
    class TouchRecognizerView: NSView {
        var observation: KeyValueObservation!
        
        init(for view: NSView) {
            super.init(frame: .zero)
            allowedTouchTypes = .indirect
            wantsRestingTouches = view.wantsRestingTouches
            zPosition = .greatestFiniteMagnitude-1000
            view.addSubview(withConstraint: self)
            observation = view.observeChanges(for: \.wantsRestingTouches) { [weak self] old, new in
                guard let self = self else { return }
                self.wantsRestingTouches = new
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func touchesBegan(with event: NSEvent) {
            touchHandler?(.init(event: event, view: self, phase: .began))
        }

        override func touchesMoved(with event: NSEvent) {
            touchHandler?(.init(event: event, view: self, phase: .moved))
        }

        override func touchesEnded(with event: NSEvent) {
            touchHandler?(.init(event: event, view: self, phase: .ended))
        }
        
        override func touchesCancelled(with event: NSEvent) {
            touchHandler?(.init(event: event, view: self, phase: .cancelled))
        }
        
        override var acceptsFirstResponder: Bool {
            false
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            guard let event = NSEvent.current else { return nil }
            if event.type == .beginGesture || event.type == .gesture || event.type == .endGesture {
                return super.hitTest(point)
            }
            return nil
        }
        
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
            return false
        }
    }
}

fileprivate class BackgroundStyleObserverView: NSControl {
    override class var cellClass: AnyClass? {
        get { Cell.self }
        set { }
    }
    
    class Cell: NSCell {
        override var backgroundStyle: NSView.BackgroundStyle {
            get { super.backgroundStyle }
            set {
                let backgroundStyleChanged = backgroundStyle != newValue
                super.backgroundStyle = newValue
                guard backgroundStyleChanged else { return }
                controlView?.superview?.viewHandlers.backgroundStyle?(newValue)
            }
        }
    }
}
    
#endif

