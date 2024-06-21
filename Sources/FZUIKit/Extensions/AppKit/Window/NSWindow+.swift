//
//  NSWindow+.swift
//
//
//  Created by Florian Zand on 12.08.22.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    extension NSWindow {
        
        /// Handlers for the window.
        public struct Handlers {
            /// The handler that gets called when the window’s key state changes.
            public var isKey: ((Bool)->())?
            /// The handler that gets called when the window’s main state changes.
            public var isMain: ((Bool)->())?
            /// The handler that gets called when the window’s first responder changes.
            public var firstResponder: ((NSResponder?)->())?
            /// The handler that gets called when the window’s frame changes.
            public var frame: ((CGRect)->())?
            /// The handler that gets called when the user is resizing the window.
            public var isLiveResizing: ((Bool)->())?
            
            var needsObserver: Bool {
                frame != nil || firstResponder != nil
            }
        }
        
        /// The handlers for the window.
        public var handlers: Handlers {
            get { getAssociatedValue("windowHandlers", initialValue: Handlers()) }
            set {
                setAssociatedValue(newValue, key: "windowHandlers")
                setupLiveResizeObservation()
                if handlers.needsObserver, windowObserver == nil {
                    windowObserver = KeyValueObserver(self)
                } else if !handlers.needsObserver {
                    windowObserver = nil
                }
                
                if handlers.firstResponder != nil {
                    windowObserver?.add(\.firstResponder) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.handlers.firstResponder?(new)
                    }
                }
                
                if handlers.frame != nil {
                    windowObserver?.add(\.frame) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.handlers.frame?(new)
                    }
                }
                
                if handlers.isKey != nil, isKeyWindowTokens.isEmpty {
                    _isKeyWindow = isKeyWindow
                    isKeyWindowTokens.append(NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: self) { [weak self] _ in
                        guard let self = self else { return }
                        self._isKeyWindow = true
                    })
                    isKeyWindowTokens.append(NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: self) { [weak self] _ in
                        guard let self = self else { return }
                        self._isKeyWindow = false
                    })
                } else if handlers.isKey == nil {
                    isKeyWindowTokens.removeAll()
                }
                
                if handlers.isMain != nil, isMainWindowTokens.isEmpty {
                    _isMainWindow = isMainWindow
                    isMainWindowTokens.append(NotificationCenter.default.observe(NSWindow.didBecomeMainNotification, object: self) { [weak self] _ in
                        guard let self = self else { return }
                        self._isMainWindow = true
                    })
                    isMainWindowTokens.append(NotificationCenter.default.observe(NSWindow.didResignMainNotification, object: self) { [weak self] _ in
                        guard let self = self else { return }
                        self._isMainWindow = false
                    })
                } else if handlers.isMain == nil {
                    isMainWindowTokens.removeAll()
                }
            }
        }
        
        /**
         Sets the size of the window’s frame rectangle according to a given size.

         - Parameters:
            - size: The frame rectangle size for the window, including the title bar.
            - expandToBottom:A Boolean value that indicates whether the window should expand it's size to the bottom.
            - display: Specifies whether the window redraws the views that need to be displayed. When `true` the window sends a `displayIfNeeded()` message down its view hierarchy, thus redrawing all views.
         */
        public func setSize(_ size: CGSize, expandToBottom: Bool, display: Bool) {
            setSize(size, expandToBottom: expandToBottom, display: display, animate: false)
        }
        
        /**
         Sets the size of the window’s frame rectangle, with optional animation, according to a given size.
         
         - Parameters:
            - size: The frame rectangle size for the window, including the title bar.
            - expandToBottom:A Boolean value that indicates whether the window should expand it's size to the bottom.
            - display: Specifies whether the window redraws the views that need to be displayed. When `true` the window sends a `displayIfNeeded()` message down its view hierarchy, thus redrawing all views.
            - animate: Specifies whether the window performs a smooth resize. `true` to perform the animation, whose duration is specified by `animationResizeTime(_:)`.
         */
        public func setSize(_ size: CGSize, expandToBottom: Bool, display: Bool, animate: Bool) {
            var frame = frame
            frame.size = size
            if expandToBottom {
                frame.origin.y -= (frame.height - self.frame.height)
            }
            setFrame(frame, display: display)

            setFrame(frame, display: display, animate: animate)
        }
        
        /**
         A Boolean value that indicates whether the window is the key window for the application.
         
         It provides the same value as `isKeyWindow`, but can be KVO observed by enabling `isKeyWindowObservable`.
         */
        @objc public dynamic internal(set) var isKey: Bool {
            get { NSWindow.isKeyWindowObservable ? getAssociatedValue("isKey", initialValue: isKeyWindow) :  isKeyWindow }
            set { setAssociatedValue(newValue, key: "isKey") }
        }
        
        /**
         A Boolean value that indicates whether the window is the application’s main window.
         
         It provides the same value as `isMainWindow`, but can be KVO observed by enabling `isMainWindowObservable`.
         */
        @objc public dynamic internal(set) var isMain: Bool {
            get { NSWindow.isKeyWindowObservable ? getAssociatedValue("isMain", initialValue: isMainWindow) :  isMainWindow }
            set { setAssociatedValue(newValue, key: "isMain") }
        }
        
        var windowObserver: KeyValueObserver<NSWindow>? {
            get { getAssociatedValue("windowObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "windowObserver") }
        }
        
        var isKeyWindowTokens: [NotificationToken] {
            get { getAssociatedValue("isKeyWindowTokens", initialValue: []) }
            set { setAssociatedValue(newValue, key: "isKeyWindowTokens") }
        }
        
        var isMainWindowTokens: [NotificationToken] {
            get { getAssociatedValue("isMainWindowTokens", initialValue: []) }
            set { setAssociatedValue(newValue, key: "isMainWindowTokens") }
        }
        
        var _isKeyWindow: Bool {
            get { getAssociatedValue("_isKeyWindow", initialValue: isKeyWindow) }
            set { 
                guard _isKeyWindow != newValue else { return }
                setAssociatedValue(newValue, key: "_isKeyWindow")
                handlers.isKey?(newValue)
            }
        }
        
        var _isMainWindow: Bool {
            get { getAssociatedValue("_isMainWindow", initialValue: isMainWindow) }
            set { 
                guard _isMainWindow != newValue else { return }
                setAssociatedValue(newValue, key: "_isMainWindow")
                handlers.isMain?(newValue)
            }
        }
                
        /// A Boolean value that indicates whether the window is fullscreen.
        public var isFullscreen: Bool {
            get { styleMask.contains(.fullScreen) }
            set {
                guard newValue != isFullscreen else { return }
                toggleFullScreen(nil)
            }
        }

        /// The index of the window tab, or `nil` if the window isn't a tab.
        public var tabIndex: Int? {
            tabbedWindows?.firstIndex(of: self)
        }

        /**
         Positions the window’s frame rectangle at a given point on the screen.

         - Parameters:
            - point: The new position of the window’s frame in screen coordinates.
            - screen: The screen on which the window’s frame gets moved.
         */
        public func setFrameOrigin(_ point: CGPoint, on screen: NSScreen) {
            let screenFrame = screen.frame
            var origin = point
            origin.x = screenFrame.origin.x + point.x
            origin.y = screenFrame.origin.y + point.y
            setFrameOrigin(origin)
        }

        /**
         Sets the window’s location to the center of the specified screen.

         - Parameter screen: The screen for centering the window.
         */
        public func center(on screen: NSScreen) {
            var frame = frame
            frame.center = screen.frame.center
            setFrame(frame, display: true)
        }

        /**
         The center point of the window's frame rectangle.

         Setting this property updates the origin of the rectangle in the frame property appropriately.
         Use this property, instead of the frame property, when you want to change the position of a window.

         The value can be animated via `animator()`.
         */
        @objc open var centerPoint: CGPoint {
            get { frameAnimatable.center }
            set { frameAnimatable.center = newValue }
        }
        
        /**
         The animatable window’s frame rectangle in screen coordinates.
         
         The value can be animated via `animator()`.
         */
        @objc open var frameAnimatable: CGRect {
            get { frame }
            set {
                NSWindow.swizzleAnimationForKey()
                setFrame(newValue, display: false)
            }
        }

        /// Resizes the window to match it's screen aspect ratio and dimensions.
        public func resizeToScreenAspectRatio() {
            guard let screen = self.screen else {
                return
            }
            let aspectRatio = screen.visibleFrame.size.aspectRatio
            var newSize = frame.size
            newSize.width = frame.height * aspectRatio
            if newSize.width < minSize.width {
                newSize.width = minSize.width
            }
            setFrame(CGRect(frame.origin, newSize), display: false)
        }

        /**
         Returns the total titlebar height.

         The value takes into account the tab bar, as well as transparent title bars and full size content.
         */
        public var titleBarHeight: CGFloat {
            let frameHeight = contentView?.frame.height ?? frame.height
            let contentLayoutRectHeight = contentLayoutRect.height
            return frameHeight - contentLayoutRectHeight
        }

        /// A Boolean value that indicates whether window currently displays a tab bar.
        public var isTabBarVisible: Bool {
            get {
                if tabbedWindows == nil {
                    return false
                }
                return tabGroup?.isTabBarVisible ?? false
            }
            set {
                guard let tabbedWindows = tabbedWindows, tabbedWindows.count > 1, let tabGroup = tabGroup, tabGroup.isTabBarVisible != newValue else { return }
                toggleTabBar(nil)
            }
        }

        /// Returns the tab bar height, or `0`, if the tab bar isn't visible.
        public var tabBarHeight: CGFloat {
            isTabBarVisible ? 28.0 : 0.0
        }

        /**
         Runs the specified block without animating the window.
         
         - Parameter block: The handler to be used.
         */
        public func runNonAnimated(block: () -> Void) {
            let currentBehavior = animationBehavior
            animationBehavior = .none
            block()
            OperationQueue.main.addOperation {
                self.animationBehavior = currentBehavior
            }
        }
        
        /**
         The window’s visual effect background.

         The property adds a `NSVisualEffectView` as background to the window’s `contentView`. The default value is `nil.
          */
        public var visualEffect: VisualEffectConfiguration? {
            get { contentView?.visualEffect }
            set {
                var newValue = newValue
                newValue?.blendingMode = .behindWindow
                contentView?.visualEffect = newValue
                appearance = visualEffect?.appearance ?? appearance
            }
        }
        
        /// The close button.
        public var closeButton: NSButton? {
            standardWindowButton(.closeButton)
        }
        
        /// The minimize button.
        public var miniaturizeButton: NSButton? {
            standardWindowButton(.miniaturizeButton)
        }
        
        /// The zoom button.
        public var zoomButton: NSButton? {
            standardWindowButton(.zoomButton)
        }
        
        /// The toolbar button.
        public var toolbarButton: NSButton? {
            standardWindowButton(.toolbarButton)
        }
        
        /// The document icon button.
        public var documentIconButton: NSButton? {
            standardWindowButton(.documentIconButton)
        }
        
        /// The document versions button.
        public var documentVersionsButton: NSButton? {
            standardWindowButton(.documentVersionsButton)
        }
        
        /**
         A Boolean value that indicates whether the sidebar is visible.
              
         If the window's content view controller isn't a split view controller or the split view doesn't contain a sidebar, it returns `false`.
         */
        public var isSidebarVisible: Bool {
            get { (contentViewController as? NSSplitViewController)?.isSidebarVisible ?? false }
            set { (contentViewController as? NSSplitViewController)?.isSidebarVisible = newValue }
        }

        @objc func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
            if let animation = swizzledAnimation(forKey: key) {
                return animation
            } else if NSWindowAnimationKeys.contains(key) {
                let animation = CABasicAnimation()
                animation.timingFunction = .default
                return animation
            }
            return nil
        }

        /// A Boolean value that indicates whether windows are swizzled to support additional properties for animating.
        static var didSwizzleAnimationForKey: Bool {
            get { getAssociatedValue("didSwizzleAnimationForKey", initialValue: false) }
            set {
                setAssociatedValue(newValue, key: "didSwizzleAnimationForKey")
            }
        }

        /// Swizzles windows to support additional properties for animating.
        static func swizzleAnimationForKey() {
            if didSwizzleAnimationForKey == false {
                didSwizzleAnimationForKey = true
                do {
                    try Swizzle(NSWindow.self) {
                        #selector(animation(forKey:)) <-> #selector(swizzledAnimation(forKey:))
                    }
                } catch {
                    Swift.debugPrint(error)
                }
            }
        }

    /// A Boolean value that indicates whether the property `isKeyWindow` is KVO observable.
    public static var isKeyWindowObservable: Bool {
        get { isMethodReplaced(#selector(NSWindow.becomeKey)) }
        set {
            guard newValue != isKeyWindowObservable else { return }
            if newValue {
                do {
                   try replaceMethod(#selector(NSWindow.becomeKey),
                   methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                   hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                       object in
                       guard let window = object as? NSWindow else {
                           store.original(object, #selector(NSWindow.becomeKey))
                           return
                       }
                       window.willChangeValue(for: \.isKeyWindow)
                       store.original(object, #selector(NSWindow.becomeKey))
                       window.didChangeValue(for: \.isKeyWindow)
                       window.isKey = true
                       window.willChangeValue(for: \.isKeyWindow)
                       }
                   }
                    try replaceMethod(#selector(NSWindow.resignKey),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        store.original(object, #selector(NSWindow.resignKey))
                        guard let window = object as? NSWindow else { return }
                        window.didChangeValue(for: \.isKeyWindow)
                        window.isKey = false
                        }
                    }
                } catch {
                   Swift.debugPrint(error)
                }
            } else {
                resetMethod(#selector(NSWindow.becomeKey))
                resetMethod(#selector(NSWindow.resignKey))
            }
        }
    }
    
    /// A Boolean value that indicates whether the property `isMainWindow` is KVO observable.
    public static var isMainWindowObservable: Bool {
        get { isMethodReplaced(#selector(NSWindow.becomeMain)) }
        set {
            guard newValue != isMainWindowObservable else { return }
            if newValue {
                do {
                   try replaceMethod(#selector(NSWindow.becomeMain),
                   methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                   hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                       object in
                       guard let window = object as? NSWindow else {
                           store.original(object, #selector(NSWindow.becomeMain))
                           return
                       }
                       window.willChangeValue(for: \.isMainWindow)
                       store.original(object, #selector(NSWindow.becomeMain))
                       window.didChangeValue(for: \.isMainWindow)
                       window.isMain = true
                       window.willChangeValue(for: \.isMainWindow)
                       }
                   }
                    try replaceMethod(#selector(NSWindow.resignMain),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        store.original(object, #selector(NSWindow.resignMain))
                        guard let window = object as? NSWindow else { return }
                        window.didChangeValue(for: \.isMainWindow)
                        window.isMain = false
                        }
                    }
                } catch {
                   Swift.debugPrint(error)
                }
            } else {
                resetMethod(#selector(NSWindow.becomeMain))
                resetMethod(#selector(NSWindow.resignMain))
            }
        }
    }
        
        /// A Boolean value that indicates whether the property `inLiveResize` is KVO observable.
        public static var isLiveResizeObservable: Bool {
            get { isMethodReplaced(#selector(getter: NSWindow.inLiveResize)) }
            set {
                guard newValue != isLiveResizeObservable else { return }
                if newValue {
                    guard !isMethodReplaced(#selector(getter: NSWindow.inLiveResize)) else { return }
                    do {
                       try replaceMethod(
                        #selector(getter: NSWindow.inLiveResize),
                       methodSignature: (@convention(c)  (AnyObject, Selector) -> (Bool)).self,
                       hookSignature: (@convention(block)  (AnyObject) -> (Bool)).self) { store in {
                           object in
                           (object as? NSWindow)?.setupLiveResizeObservation()
                           return (object as? NSWindow)?._inLiveResize ?? store.original(object, #selector(getter: NSWindow.inLiveResize))
                           }
                       }
                    } catch {
                       debugPrint(error)
                    }
                } else {
                    resetMethod(#selector(getter: NSWindow.inLiveResize))
                }
            }
        }
        
        var _inLiveResize: Bool? {
            get { getAssociatedValue("_inLiveResize", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "_inLiveResize") }
        }
        
        var liveResizeTokens: [NotificationToken] {
            get { getAssociatedValue("liveResizeTokens", initialValue: []) }
            set { setAssociatedValue(newValue, key: "liveResizeTokens") }
        }
        
        var needsLiveResizeObservation: Bool {
            NSWindow.isLiveResizeObservable || handlers.isLiveResizing != nil
        }
        
        func setupLiveResizeObservation() {
            if needsLiveResizeObservation {
                guard liveResizeTokens.isEmpty else { return }
                liveResizeTokens.append(NotificationCenter.default.observe(NSWindow.willStartLiveResizeNotification, object: self) { [weak self] _ in
                    guard let self = self else { return }
                    guard self.needsLiveResizeObservation else {
                        self.liveResizeTokens.removeAll()
                        return
                    }
                    self.handlers.isLiveResizing?(true)
                    self._inLiveResize = false
                    willChangeValue(for: \.inLiveResize)
                    self._inLiveResize = nil
                    didChangeValue(for: \.inLiveResize)
                })
                liveResizeTokens.append(NotificationCenter.default.observe(NSWindow.didEndLiveResizeNotification, object: self) { [weak self] _ in
                    guard let self = self else { return }
                    guard self.needsLiveResizeObservation else {
                        self.liveResizeTokens.removeAll()
                        return
                    }
                    self.handlers.isLiveResizing?(false)
                    self._inLiveResize = true
                    willChangeValue(for: \.inLiveResize)
                    self._inLiveResize = nil
                    didChangeValue(for: \.inLiveResize)
                })
            } else {
                liveResizeTokens.removeAll()
            }
        }
}

    private let NSWindowAnimationKeys = ["frameAnimatable", "centerPoint"]
#endif

