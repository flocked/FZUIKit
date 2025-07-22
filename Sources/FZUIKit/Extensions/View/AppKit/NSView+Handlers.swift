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
     A handler that provides the menu for a right-click.
     
     If you ptovide this property, [menu](https://developer.apple.com/documentation/appkit/nsresponder/menu) will be ignored.
          
     - Parameter locationInView: The location of the right click inside the view.
     - Returns: A menu for the location or `nil`, if there shouldn't be a menu displayed.
     */
    public var menuProvider: ((_ locationInView: CGPoint)->(NSMenu?))? {
        get { _menuProvider }
        set {
            _menuProvider = newValue
            if newValue != nil, menuProviderHook == nil {
                do {
                    menuProviderHook = try hook(#selector(NSView.menu(for:)), closure: {
                        original, view, selector, event in
                        let location = event.location(in: view)
                        var _location = location
                        if let superview = view.superview {
                            _location = event.location(in: superview)
                        }
                        if let hitView = view.hitTest(_location), hitView !== view {
                            if let textProvider = hitView as? TextLocationProvider {
                                if textProvider.isLocationInsideText(view.convert(location, to: hitView)) {
                                    return nil
                                }
                            } else {
                                return nil
                            }
                        }
                        return view._menuProvider?(location) ?? nil
                    } as @convention(block) ( (NSView, Selector, NSEvent) -> NSMenu?, NSView, Selector, NSEvent) -> NSMenu?)
                } catch {
                    _menuProvider = nil
                    Swift.print(error)
                }
            } else if newValue == nil {
                try? menuProviderHook?.revert()
                menuProviderHook = nil
            }
        }
    }
    
    fileprivate var _menuProvider: ((_ locationInView: CGPoint)->(NSMenu?))? {
        get { getAssociatedValue("_menuProvider") }
        set { setAssociatedValue(newValue, key: "_menuProvider") }
    }
    
    fileprivate var menuProviderHook: Hook? {
        get { getAssociatedValue("menuProviderHook") }
        set { setAssociatedValue(newValue, key: "menuProviderHook") }
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
            setupObserverView()
            
            keyHooks.values.forEach({ try? $0.revert() })
            keyHooks = [:]
            setupHandler(#selector(NSView.mouseDown(with:)), newValue.leftDown)
            setupHandler(#selector(NSView.mouseUp(with:)), newValue.leftUp)
            setupHandler(#selector(NSView.mouseDragged(with:)), newValue.leftDragged)
            setupHandler(#selector(NSView.rightMouseDown(with:)), newValue.rightDown)
            setupHandler(#selector(NSView.rightMouseUp(with:)), newValue.rightUp)
            setupHandler(#selector(NSView.rightMouseDragged(with:)), newValue.rightDragged)
            setupHandler(#selector(NSView.otherMouseDown(with:)), newValue.otherDown)
            setupHandler(#selector(NSView.otherMouseUp(with:)), newValue.otherUp)
            setupHandler(#selector(NSView.otherMouseDragged(with:)), newValue.otherDragged)
            setupHandler(#selector(NSView.magnify(with:)), newValue.magnify)
            setupHandler(#selector(NSView.rotate(with:)), newValue.rotate)
            setupHandler(#selector(NSView.mouseDown(with:)), newValue.shouldLeftDown)
            setupHandler(#selector(NSView.mouseUp(with:)), newValue.shouldLeftUp)
            setupHandler(#selector(NSView.mouseDragged(with:)), newValue.shouldLeftDragged)
            setupHandler(#selector(NSView.rightMouseDown(with:)), newValue.shouldRightDown)
            setupHandler(#selector(NSView.rightMouseUp(with:)), newValue.shouldRightUp)
            setupHandler(#selector(NSView.rightMouseDragged(with:)), newValue.shouldRightDragged)
            setupHandler(#selector(NSView.otherMouseDown(with:)), newValue.shouldOtherDown)
            setupHandler(#selector(NSView.otherMouseUp(with:)), newValue.shouldOtherUp)
            setupHandler(#selector(NSView.otherMouseDragged(with:)), newValue.shouldOtherDragged)
            setupHandler(#selector(NSView.magnify(with:)), newValue.shouldMagnify)
            setupHandler(#selector(NSView.rotate(with:)), newValue.shouldRotate)
        }
    }
    
    fileprivate func setupHandler(_ selector: Selector, _ handler: ((NSEvent) -> ())?, _ keyPath: ReferenceWritableKeyPath<NSView, [String: Hook]> = \.mouseHooks) {
        guard let handler = handler else { return }
        do {
            self[keyPath: keyPath][NSStringFromSelector(selector)] = try hookAfter(selector, closure: { view, selector, event in
                handler(event)
            } as @convention(block) (NSView, Selector, NSEvent) -> Void)
        } catch {
            Swift.print(error)
        }
    }
    
    fileprivate func setupHandler(_ selector: Selector, _ handler: ((NSEvent) -> (Bool))?, _ keyPath: ReferenceWritableKeyPath<NSView, [String: Hook]> = \.mouseHooks) {
        guard let handler = handler else { return }
        do {
            mouseHooks[NSStringFromSelector(selector) + "_should"] = try hook(selector, closure: { original, view, selector, event in
                guard handler(event) else { return }
                original(view, selector, event)
            } as @convention(block) ((NSView, Selector, NSEvent) -> Void, NSView, Selector, NSEvent) -> Void)
        } catch {
            Swift.print(error)
        }
    }
    
    fileprivate var mouseHooks: [String: Hook] {
        get { getAssociatedValue("mouseHooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "mouseHooks") }
    }
    
    /// The handlers for mouse events.
    public var keyHandlers: KeyHandlers {
        get { getAssociatedValue("keyHandlers", initialValue: KeyHandlers()) }
        set {
            setAssociatedValue(newValue, key: "keyHandlers")
            keyHooks.values.forEach({ try? $0.revert() })
            keyHooks = [:]
            setupHandler(#selector(NSView.keyDown(with:)), newValue.keyDown, \.keyHooks)
            setupHandler(#selector(NSView.keyUp(with:)), newValue.keyUp, \.keyHooks)
            setupHandler(#selector(NSView.flagsChanged(with:)), newValue.flagsChanged, \.keyHooks)
            setupHandler(#selector(NSView.keyDown(with:)), newValue.shouldKeyDown, \.keyHooks)
            setupHandler(#selector(NSView.keyUp(with:)), newValue.shouldKeyUp, \.keyHooks)
            setupHandler(#selector(NSView.flagsChanged(with:)), newValue.shouldFlagsChanged, \.keyHooks)
        }
    }
    
    fileprivate var keyHooks: [String: Hook] {
        get { getAssociatedValue("keyHooks") ?? [:] }
        set { setAssociatedValue(newValue, key: "keyHooks") }
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
            setupSubviewObservation()
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
    
    private var touchRecognizerView: TouchRecognizerView? {
        get { getAssociatedValue("touchRecognizerView") }
        set { setAssociatedValue(newValue, key: "touchRecognizerView") }
    }
    
    /*
    func setupEventMonitors() {
        if mouseHandlers.needsGestureObserving {
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
    */
    
    fileprivate var windowObservation: [String: [NotificationToken]] {
        get { getAssociatedValue("windowObservation") ?? [:] }
        set { setAssociatedValue(newValue, key: "windowObservation") }
    }
    
    fileprivate var backgroundStyleObserverView: BackgroundStyleObserverView? {
        get { getAssociatedValue("backgroundStyleObserverView") }
        set { setAssociatedValue(newValue, key: "backgroundStyleObserverView") }
    }
    
    fileprivate func setupObservation() {
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
            if let backgroundStyle = (self as? NSControl)?.backgroundStyle {
                backgroundStyleObserverView?.backgroundStyle = backgroundStyle
            }
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
    
    fileprivate func setupWindowObservation() {
        windowObservation["key"] = window?.observeIsKey(windowHandlers.isKey) ?? nil
        windowObservation["main"] = window?.observeIsMain(windowHandlers.isMain) ?? nil
        windowObservation["miniaturize"] = window?.observeMiniaturize(windowHandlers.isMiniaturize) ?? nil
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
    
    fileprivate var willMoveToWindowHook: Hook? {
        get { getAssociatedValue("willMoveToWindowHook") }
        set { setAssociatedValue(newValue, key: "willMoveToWindowHook") }
    }
    
    fileprivate func setupWillMoveToSuperview() {
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
    
    fileprivate var willMoveToSuperviewHook: Hook? {
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
    
    fileprivate static func setupLiveResizingObservation() {
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
    
    fileprivate var __backgroundStyle: NSView.BackgroundStyle {
        get { getAssociatedValue("__backgroundStyle") ?? .normal }
        set { setAssociatedValue(newValue, key: "__backgroundStyle") }
    }
    
    fileprivate var _inLiveResize: Bool? {
        get { getAssociatedValue("_inLiveResize") }
        set { setAssociatedValue(newValue, key: "_inLiveResize") }
    }
    
    fileprivate var _isFirstResponder: Bool {
        get { getAssociatedValue("_isFirstResponder", initialValue: isFirstResponder) }
        set { 
            guard newValue != _isFirstResponder else { return }
            setAssociatedValue(newValue, key: "_isFirstResponder")
            viewHandlers.isFirstResponder?(newValue)
        }
    }
    
    fileprivate var viewObserver: KeyValueObserver<NSView> {
        get { getAssociatedValue("viewObserver", initialValue: KeyValueObserver(self)) }
    }
    
    fileprivate var observerView: ObserverView? {
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
        
        /// The handler that gets called when `isMain` changed.
        public var isMiniaturize: ((Bool) -> Void)?
        
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
        /// The handler that gets called when the subviews changed.
        public var subviews: ((_ subviews: [NSView])->())?
        
        var needsObserverView: Bool {
            isLiveResizing != nil
        }
    }
    
    /// The handlers for keyboard events.
    public struct KeyHandlers {
        /// The handler that gets called when the user has pressed a key.
        public var keyDown: ((_ event: NSEvent) -> ())?
        /// The handler that gets called when the user has released a key.
        public var keyUp: ((_ event: NSEvent) -> ())?
        /// The handler that gets called when the user pressed or released a modifier key (Shift, Control, and so on).
        public var flagsChanged: ((_ event: NSEvent) -> ())?
        /// The handler that determinates if the view should handle the key down event.
        public var shouldKeyDown: ((_ event: NSEvent) -> (Bool))?
        /// The handler that determinates if the view should handle the key up event.
        public var shouldKeyUp: ((_ event: NSEvent) -> (Bool))?
        /// The handler that determinates if the view should handle the flags modified event.
        public var shouldFlagsChanged: ((_ event: NSEvent) -> (Bool))?
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
        
        /// The handler that determinates if the view should handle the mouse down event.
        public var shouldLeftDown: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the mouse up event.
        public var shouldLeftUp: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the mouse dragged event.
        public var shouldLeftDragged: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the right mouse down event.
        public var shouldRightDown: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the right mouse up event.
        public var shouldRightUp: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the right mouse dragged event.
        public var shouldRightDragged: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the other mouse down event.
        public var shouldOtherDown: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the other mouse up event.
        public var shouldOtherUp: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the other mouse dragged event.
        public var shouldOtherDragged: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the magnify event.
        public var shouldMagnify: ((NSEvent) -> (Bool))?
        
        /// The handler that determinates if the view should handle the rotate event.
        public var shouldRotate: ((NSEvent) -> (Bool))?
        
        var needsObserving: Bool {
            moved != nil || entered != nil || exited != nil || isHovering != nil
        }
        
        var trackingAreaOptions: NSTrackingArea.Options {
            var options: NSTrackingArea.Options = [.inVisibleRect]
            options.insert(active.option)
            if entered != nil || exited != nil {
                options += .mouseEnteredAndExited
            }
            if moved != nil {
                options += .mouseMoved
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
    
    fileprivate class TouchRecognizerView: NSView {
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
    
    fileprivate var subviewIDs: [ObjectIdentifier] {
        get { getAssociatedValue("subviewIDs") ?? [] }
        set { setAssociatedValue(newValue, key: "subviewIDs") }
    }
    
    fileprivate func setSubviewIDs(_ ids: [ObjectIdentifier]) {
        guard subviewIDs != ids else { return }
        subviewIDs = ids
        viewHandlers.subviews?(subviews)
    }
    
    fileprivate var subviewHooks: [Hook] {
        get { getAssociatedValue("subviewHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "subviewHooks") }
    }
    
    fileprivate func setupSubviewObservation() {
        if viewHandlers.subviews == nil {
            subviewHooks.forEach({ try? $0.revert() })
            subviewHooks = []
        } else if subviewHooks.isEmpty {
            do {
                subviewHooks += try hookAfter(#selector(setter: NSView.subviews)) { view, _ in
                    view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }))
                }
                subviewHooks += try hookAfter(#selector(NSView.didAddSubview(_:))) { view, _ in
                    view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }))
                }
                subviewHooks += try hookAfter(#selector(NSView.willRemoveSubview(_:)), closure: { view, _, removed in
                    view.setSubviewIDs(view.subviews.filter({ $0 !== removed }).map({ ObjectIdentifier($0) }))
                } as @convention(block) (NSView, Selector, NSView) -> Void )
                subviewHooks += try hookAfter(#selector(NSView.addSubview(_:positioned:relativeTo:))) { view, _ in
                    view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }))
                }
                subviewIDs = subviews.map({ ObjectIdentifier($0) })
            } catch {
                Swift.print(error)
            }
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

fileprivate extension NSView {
    func subview(at location: CGPoint) -> NSView? {
        for subview in subviews {
            guard let subview = subview.subview(at: convert(location, to: subview)) else { continue }
            return subview
        }
        return bounds.contains(location) ? self : nil
    }
}
    
#endif

