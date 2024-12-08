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
    /// Observes the main state of the window.
    @objc open func observeIsMain(handler: @escaping (_ isMain: Bool)->()) -> NotificationToken {
        [NotificationCenter.default.observe(NSWindow.didBecomeMainNotification, object: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didResignMainNotification, object: self) { _ in handler(false) }].combinedNotificationToken!
    }
    
    /// Observes the key state of the window.
    @objc open func observeIsKey(handler: @escaping (_ isKey: Bool)->()) -> NotificationToken {
        [NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: self) { _ in handler(false) }].combinedNotificationToken!
    }
    
    /// Observes the resizing of the window by the user.
    @objc open func observeLiveResize(handler: @escaping (_ isKey: Bool)->()) -> NotificationToken {
        [NotificationCenter.default.observe(NSWindow.willStartLiveResizeNotification, object: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didEndLiveResizeNotification, object: self) { _ in handler(false) }].combinedNotificationToken!
    }
    
    /**
     Resizes and positions the window’s origin with an offset from the specified frame.
     
     - Parameter frame: The frame.
     */
    @objc open func cascade(from frame: CGRect) {
        let spacing = 10.0
        setFrame(frame, display: false)
        guard let screen = screen, frame.width <= screen.visibleFrame.width, frame.height <= screen.visibleFrame.height else { return }
        var offsetFrame = frame.offsetBy(dx: 30, dy: -30)
        if offsetFrame.maxX + spacing > screen.visibleFrame.maxX {
            offsetFrame.origin.x = screen.visibleFrame.x + spacing
        }
        if offsetFrame.y - spacing < screen.visibleFrame.y {
            offsetFrame.origin.y = screen.visibleFrame.maxY-frame.height -  spacing
        }
        setFrame(offsetFrame, display: false)
    }
    
    /**
     A Boolean value that indicates whether the window is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.
     */
    @objc open var isFirstResponder: Bool {
        firstResponder == self
    }
    
    /// A Boolean value that indicates whether the window displays a title bar.
    @objc open var isTitled: Bool {
        get { styleMask.contains(.titled) }
        set { styleMask[.titled] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window displays a title bar.
    @discardableResult
    @objc open func isTitled(_ isTitled: Bool) -> Self {
        self.isTitled = isTitled
        return self
    }
    
    /// A Boolean value that indicates whether the window’s contentView consumes the full size of the window.
    @objc open var hasFullSizeContentView: Bool {
        get { styleMask.contains(.fullSizeContentView) }
        set { styleMask[.fullSizeContentView] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window’s contentView consumes the full size of the window.
    @discardableResult
    @objc open func hasFullSizeContentView(_ hasFullSizeContentView: Bool) -> Self {
        self.hasFullSizeContentView = hasFullSizeContentView
        return self
    }
    
    /// A Boolean value that indicates whether the window displays a close button.
    @objc open var displaysCloseButton: Bool {
        get { styleMask.contains(.closable) }
        set { styleMask[.closable] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window displays a close button.
    @discardableResult
    @objc open func displaysCloseButton(_ displays: Bool) -> Self {
        self.displaysCloseButton = displays
        return self
    }
    
    /// A Boolean value that indicates whether the window can be resized by the user.
    @objc open var isResizable: Bool {
        get { styleMask.contains(.resizable) }
        set { styleMask[.resizable] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window can be resized by the user.
    @discardableResult
    @objc open func isResizable(_ isResizable: Bool) -> Self {
        self.isResizable = isResizable
        return self
    }
    
    /// A Boolean value that indicates whether the window displays a minimize button.
    @objc open var displaysMinimizeButton: Bool {
        get { styleMask.contains(.miniaturizable) }
        set { styleMask[.miniaturizable] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window displays a minimize button.
    @discardableResult
    @objc open func displaysMinimizeButton(_ displays: Bool) -> Self {
        self.displaysMinimizeButton = displays
        return self
    }
    
    /// A Boolean value that indicates whether the window displays none of the usual peripheral elements.
    @objc open var isBorderless: Bool {
        get { styleMask.contains(.borderless) }
        set { styleMask[.borderless] = newValue }
    }
    
    /// Sets the Boolean value that indicates whether the window displays none of the usual peripheral elements.
    @discardableResult
    @objc open func isBorderless(_ isBorderless: Bool) -> Self {
        self.isBorderless = isBorderless
        return self
    }
    
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
        /// The handler that gets called when the appearance changes.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that gets called when the window’s fullscreen state changes.
        public var isFullScreen: ((Bool)->())?
        /// The handler that gets called when the style mask changes.
        public var styleMask: ((StyleMask)->())?
        /// The handler that gets called when the window’s active space state changes.
        public var isOnActiveSpace: ((Bool)->())?
        
        /// The tab handlers for the window.
        public var tab: TabHandlers = TabHandlers()
        
        /// Tab handlers for the window.
        public struct TabHandlers {
            /// The handler that gets called when the tab windows changes.
            public var windows: (([NSWindow]?)->())?
            /// The handler that gets called when the selected tab changes.
            public var selected: ((NSWindow?)->())?
            /// The handler that gets called when the tab selection state changes.
            public var isSelected: ((Bool)->())?
            /// The handler that gets called when the tab bar visibilty changes.
            public var isTabBarVisible: ((Bool)->())?
            /// The handler that gets called when the tab overview visibilty changes.
            public var isOverviewVisible: ((Bool)->())?
        }
    }
    
    /// The handlers for the window.
    public var handlers: Handlers {
        get { getAssociatedValue("windowHandlers", initialValue: Handlers()) }
        set {
            let needsSpaceUpdate = (handlers.isOnActiveSpace == nil && newValue.isOnActiveSpace != nil) || (handlers.isOnActiveSpace != nil && newValue.isOnActiveSpace == nil)
            setAssociatedValue(newValue, key: "windowHandlers")
            setupLiveResizeObservation()
            
            if needsSpaceUpdate {
                _isOnActiveSpace = isOnActiveSpace
                NSWindow.updateSpaceObservation(shouldObserve: newValue.isOnActiveSpace != nil)
            }
            
            func observe<Value: Equatable>(_ keyPath: KeyPath<NSWindow, Value>, handler: KeyPath<NSWindow, ((Value)->())?>) {
                if self[keyPath: handler] == nil {
                    windowObserver.remove(keyPath)
                } else if !windowObserver.isObserving(keyPath) {
                    windowObserver.add(keyPath) { [weak self] old, new in
                       guard let self = self else { return }
                       self[keyPath: handler]?(new)
                   }
                }
            }
            
            func observe<Value: Equatable>(_ keyPath: KeyPath<NSWindow, Value?>, handler: KeyPath<NSWindow, ((Value)->())?>) {
                if self[keyPath: handler] == nil {
                    windowObserver.remove(keyPath)
                } else if !windowObserver.isObserving(keyPath) {
                    windowObserver.add(keyPath) { [weak self] old, new in
                       guard let self = self, let new = new else { return }
                       self[keyPath: handler]?(new)
                   }
                }
            }
                        
            observe(\.firstResponder, handler: \.handlers.firstResponder)
            observe(\.effectiveAppearance, handler: \.handlers.effectiveAppearance)
            observe(\.frame, handler: \.handlers.frame)
            
            observe(\.tabGroup?.isTabBarVisible, handler: \.handlers.tab.isTabBarVisible)
            observe(\.tabGroup?.isOverviewVisible, handler: \.handlers.tab.isOverviewVisible)
            observe(\.tabGroup?.windows, handler: \.handlers.tab.windows)
            
            if newValue.styleMask == nil && newValue.isFullScreen == nil {
                windowObserver.remove(\.styleMask)
            } else if !windowObserver.isObserving(\.styleMask) {
                windowObserver.add(\.styleMask) { [weak self] old, new in
                    guard let self = self else { return }
                    self.handlers.styleMask?(new)
                    let fullscreen = new.contains(.fullScreen)
                    guard old.contains(.fullScreen) != fullscreen else { return }
                    self.handlers.isFullScreen?(fullscreen)
                }
            }
            
            if newValue.tab.isSelected == nil && newValue.tab.selected == nil {
                windowObserver.remove(\.tabGroup?.selectedWindow)
            } else if !windowObserver.isObserving(\.tabGroup?.selectedWindow) {
                windowObserver.add(\.tabGroup?.selectedWindow) { [weak self] old, new in
                    guard let self = self else { return }
                    self.handlers.tab.selected?(new)
                    if old == self, new != self {
                        self.handlers.tab.isSelected?(false)
                    } else if old != self, new == self {
                        self.handlers.tab.isSelected?(false)
                    }
                }
            }
            
            if let handler = newValue.isKey {
                isKeyObservation = observeIsKey(handler: handler)
            } else {
                isKeyObservation = nil
            }
            
            if let handler = newValue.isMain {
                isMainObservation = observeIsMain(handler: handler)
            } else {
                isMainObservation = nil
            }
        }
    }
    
    var _isOnActiveSpace: Bool {
        get { getAssociatedValue("isOnActiveSpace", initialValue: isOnActiveSpace) }
        set { setAssociatedValue(newValue, key: "isOnActiveSpace") }
    }
    
    func sendOnActiveSpace() {
        guard let handler = handlers.isOnActiveSpace, _isOnActiveSpace != isOnActiveSpace else { return  }
        _isOnActiveSpace = !_isOnActiveSpace
        handler(_isOnActiveSpace)
    }
    
    static func updateSpaceObservation(shouldObserve: Bool) {
        if !shouldObserve && !NSApp.windows.contains(where: { $0.handlers.isOnActiveSpace != nil }) {
            activeSpaceObservation = nil
        } else if activeSpaceObservation == nil {
            activeSpaceObservation = NotificationCenter.default.observe(NSWorkspace.activeSpaceDidChangeNotification) { _ in
                NSApp.windows.forEach({ $0.sendOnActiveSpace() })
            }
        }
        Swift.print("CHECK", activeSpaceObservation != nil)
    }
    
   static var activeSpaceObservation: NotificationToken? {
        get { getAssociatedValue("activeSpaceObservation") }
        set { setAssociatedValue(newValue, key: "activeSpaceObservation") }
    }
    
    /// Sets the minimum size to which the window’s frame (including its title bar) can be sized.
    @discardableResult
    @objc open func minSize(_ size: CGSize) -> Self {
        self.minSize = size
        return self
    }
    
    /// Sets the maximum size to which the window’s frame (including its title bar) can be sized.
    @discardableResult
    @objc open func maxSize(_ size: CGSize) -> Self {
        self.maxSize = size
        return self
    }
    
    /// Sets the size of the window.
    @discardableResult
    @objc open func size(_ size: CGSize) -> Self {
        self.setContentSize(size)
        return self
    }
    
    /// Sets the origin of the window.
    @discardableResult
    @objc open func origin(_ origin: CGPoint) -> Self {
        self.setFrameOrigin(origin)
        return self
    }
    
    /// Sets the flags that describe the window’s current style, such as if it’s resizable or in full-screen mode.
    @discardableResult
    @objc open func styleMask(_ styleMask: StyleMask) -> Self {
        self.styleMask = styleMask
        return self
    }
    
    /// Sets the window’s alpha value.
    @discardableResult
    @objc open func alphaValue(_ alphaValue: CGFloat) -> Self {
        self.alphaValue = alphaValue
        return self
    }
    
    /// Sets the color of the window’s background.
    @discardableResult
    @objc open func backgroundColor(_ color: NSColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    /// Sets the Boolean value that indicates whether the window can hide when its application becomes hidden.
    @discardableResult
    @objc open func canHide(_ canHide: Bool) -> Self {
        self.canHide = canHide
        return self
    }
    
    /// Sets the Boolean value that indicates whether the window is removed from the screen when its application becomes inactive.
    @discardableResult
    @objc open func hidesOnDeactivate(_ hides: Bool) -> Self {
        self.hidesOnDeactivate = hides
        return self
    }
    
    /// Sets the Boolean value that indicates whether the window is opaque.
    @discardableResult
    @objc open func isOpaque(_ isOpaque: Bool) -> Self {
        self.isOpaque = isOpaque
        return self
    }
    
    /// Sets the Boolean value that indicates whether the window has a shadow.
    @discardableResult
    @objc open func hasShadow(_ hasShadow: Bool) -> Self {
        self.hasShadow = hasShadow
        return self
    }
    
    /// Sets the value that identifies the window’s behavior in window collections.
    @discardableResult
    @objc open func collectionBehavior(_ behavior: CollectionBehavior) -> Self {
        self.collectionBehavior = behavior
        return self
    }
    
    /// Sets the window’s content view, the highest accessible view object in the window’s view hierarchy.
    @discardableResult
    @objc open func contentView(_ view: NSView?) -> Self {
        self.contentView = view
        return self
    }
    
    /// Sets the main content view controller for the window.
    @discardableResult
    @objc open func contentViewController(_ viewController: NSViewController?) -> Self {
        self.contentViewController = viewController
        return self
    }
    
    /// Sets the window’s color space.
    @discardableResult
    @objc open func colorSpace(_ colorSpace: NSColorSpace?) -> Self {
        self.colorSpace = colorSpace
        return self
    }
    
    /**
     Sets the size of the window’s frame rectangle according to a given size.
     
     - Parameters:
     - size: The frame rectangle size for the window, including the title bar.
     - expandToBottom:A Boolean value that indicates whether the window should expand it's size to the bottom.
     - display: Specifies whether the window redraws the views that need to be displayed. When `true` the window sends a `displayIfNeeded()` message down its view hierarchy, thus redrawing all views.
     */
    @objc open func setSize(_ size: CGSize, expandToBottom: Bool, display: Bool) {
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
    @objc open func setSize(_ size: CGSize, expandToBottom: Bool, display: Bool, animate: Bool) {
        var frame = frame
        frame.size = size
        if expandToBottom {
            frame.origin.y -= (frame.height - self.frame.height)
        }
        setFrame(frame, display: display)
        
        setFrame(frame, display: display, animate: animate)
    }
    
    var windowObserver: KeyValueObserver<NSWindow> {
        get { getAssociatedValue("windowObserver", initialValue: KeyValueObserver(self)) }
    }
    
    var isKeyObservation: NotificationToken? {
        get { getAssociatedValue("isKeyObservation") }
        set { setAssociatedValue(newValue, key: "isKeyObservation") }
    }
    
    var isMainObservation: NotificationToken? {
        get { getAssociatedValue("isMainObservation") }
        set { setAssociatedValue(newValue, key: "isMainObservation") }
    }
    
    /// A Boolean value that indicates whether the window is fullscreen.
    @objc open var isFullscreen: Bool {
        get { styleMask.contains(.fullScreen) }
        set {
            guard newValue != isFullscreen else { return }
            toggleFullScreen(nil)
        }
    }
    
    /// Sets the Boolean value that indicates whether the window is fullscreen.
    @discardableResult
    @objc open func isFullscreen(_ isFullscreen: Bool) -> Self {
        self.isFullscreen = isFullscreen
        return self
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
    @objc open func setFrameOrigin(_ point: CGPoint, on screen: NSScreen) {
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
    @objc open func center(on screen: NSScreen) {
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
    
    /// Sets the center point of the window's frame rectangle.
    @discardableResult
    @objc open func centerPoint(_ centerPoint: CGPoint) -> Self {
        self.centerPoint = centerPoint
        return self
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
    @objc open func resizeToScreenAspectRatio() {
        guard let aspectRatio = self.screen?.visibleFrame.size.aspectRatio else { return }
        let frame = frame.scaled(byFactor: aspectRatio).size(frame.size.clamped(to: minSize...maxSize))
        setFrame(frame, display: false)
    }
    
    /**
     Returns the total titlebar height.
     
     The value takes into account the tab bar, as well as transparent title bars and full size content.
     */
    @objc open var titlebarHeight: CGFloat {
        if styleMask.contains(.fullSizeContentView), let windowFrameHeight = contentView?.frame.height {
            let contentLayoutRectHeight = contentLayoutRect.height
            return windowFrameHeight - contentLayoutRectHeight
        }
        return frame.height - contentRect(forFrameRect: frame).height
    }
    
    /// A Boolean value that indicates whether window currently displays a tab bar.
    @objc open var isTabBarVisible: Bool {
        get { tabGroup?.isTabBarVisible ?? false }
        set {
            guard let tabGroup = tabGroup, tabGroup.isTabBarVisible != newValue else { return }
            toggleTabBar(nil)
        }
    }
    
    /// Sets the Boolean value that indicates whether window currently displays a tab bar.
    @discardableResult
    @objc open func isTabBarVisible(_ isVisible: Bool) -> Self {
        self.isTabBarVisible = isVisible
        return self
    }
    
    /// A Boolean value indicating if the tab overview is currently displayed.
    @objc open var isTabOverviewVisible: Bool {
        get { tabGroup?.isOverviewVisible ?? false }
        set { tabGroup?.isOverviewVisible = newValue }
    }
    
    /// Sets the Boolean value indicating if the tab overview is currently displayed.
    @discardableResult
    @objc open func isTabOverviewVisible(_ isVisible: Bool) -> Self {
        self.isTabOverviewVisible = isVisible
        return self
    }
    
    /**
     Inserts the provided window as tab.
     
     - Parameters:
     - window: The window to insert.
     - position: The position to insert the window.
     - select: A Boolean value that indicates whether to select the inserted tab.
     */
    public func insertTabWindow(_ window: NSWindow, position: NSWindowTabGroup.TabPosition = .afterSelected, select: Bool = true) {
        tabGroup?.insertWindow(window, position: position, select: select)
    }
    
    /// Returns the tab bar height, or `0`, if the tab bar isn't visible.
    @objc open var tabBarHeight: CGFloat {
        isTabBarVisible ? 28.0 : 0.0
    }
    
    /**
     Runs the specified block without animating the window.
     
     - Parameter block: The handler to be used.
     */
    @objc open func runNonAnimated(block: () -> Void) {
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
    @objc open var visualEffect: VisualEffectConfiguration? {
        get { contentView?.visualEffect }
        set {
            var newValue = newValue
            newValue?.blendingMode = .behindWindow
            contentView?.visualEffect = newValue
            appearance = visualEffect?.appearance ?? appearance
        }
    }
    
    /// Sets the window’s visual effect background.
    @discardableResult
    @objc open func visualEffect(_ visualEffect: VisualEffectConfiguration?) -> Self {
        self.visualEffect = visualEffect
        return self
    }
    
    /// The close button.
    @objc open var closeButton: NSButton? {
        standardWindowButton(.closeButton)
    }
    
    /// The minimize button.
    @objc open var miniaturizeButton: NSButton? {
        standardWindowButton(.miniaturizeButton)
    }
    
    /// The zoom button.
    @objc open var zoomButton: NSButton? {
        standardWindowButton(.zoomButton)
    }
    
    /// The toolbar button.
    @objc open var toolbarButton: NSButton? {
        standardWindowButton(.toolbarButton)
    }
    
    /// The document icon button.
    @objc open var documentIconButton: NSButton? {
        standardWindowButton(.documentIconButton)
    }
    
    /// The document versions button.
    @objc open var documentVersionsButton: NSButton? {
        standardWindowButton(.documentVersionsButton)
    }
    
    /**
     A Boolean value that indicates whether the sidebar is visible.
     
     If the window's content view controller isn't a split view controller or the split view doesn't contain a sidebar, it returns `false`.
     */
    @objc open var isSidebarVisible: Bool {
        get { (contentViewController as? NSSplitViewController)?.isSidebarVisible ?? false }
        set { (contentViewController as? NSSplitViewController)?.isSidebarVisible = newValue }
    }
    
    /**
     Collapses or expands the sidebar.
          
     If the window's content view controller isn't a split view controller or the split view doesn't contain a sidebar, calling this method does nothing.
     
     - Parameters:
        - isVisible: A Boolean value that indicates whether the sidebar is visible.
        - animated: A Boolean value that indicates whether the collapsing/expanding of the sidebar should be animated.
     */
    @discardableResult
    @objc open func isSidebarVisible(_ isVisible: Bool, animated: Bool = true) -> Self {
        (contentViewController as? NSSplitViewController)?.isSidebarVisible(isVisible, animated: animated)
        return self
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
        get { isMethodReplaced(#selector(getter: NSWindow.isKeyWindow)) }
        set {
            guard newValue != isKeyWindowObservable else { return }
            if newValue {
                do {
                    try replaceMethod(
                        #selector(getter: NSWindow.isKeyWindow),
                        methodSignature: (@convention(c)  (AnyObject, Selector) -> (Bool)).self,
                        hookSignature: (@convention(block)  (AnyObject) -> (Bool)).self) { store in {
                            object in
                            return (object as? NSWindow)?._isKeyWindow ?? store.original(object, #selector(getter: NSWindow.isKeyWindow))
                        }
                        }
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
                    }
                    }
                    try replaceMethod(#selector(NSWindow.resignKey),
                                      methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                                      hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        store.original(object, #selector(NSWindow.resignKey))
                        guard let window = object as? NSWindow else { return }
                        window._isKeyWindow = true
                    }
                    }
                } catch {
                    Swift.debugPrint(error)
                }
            } else {
                resetMethod(#selector(NSWindow.becomeKey))
                resetMethod(#selector(NSWindow.resignKey))
                resetMethod(#selector(getter: NSWindow.isKeyWindow))
            }
        }
    }
    
    var mainWindowObservation: KeyValueObservation? {
        get { getAssociatedValue("mainWindowObservation") }
        set { setAssociatedValue(newValue, key: "mainWindowObservation") }
    }
    
    var keyWindowObservation: KeyValueObservation? {
        get { getAssociatedValue("keyWindowObservation") }
        set { setAssociatedValue(newValue, key: "keyWindowObservation") }
    }
    
    /// A Boolean value that indicates whether the property `isMainWindow` is KVO observable.
    public static var isMainWindowObservable: Bool {
        get { isMethodReplaced(#selector(getter: NSWindow.isMainWindow)) }
        set {
            guard newValue != isMainWindowObservable else { return }
            if newValue {
                do {
                    try replaceMethod(
                        #selector(getter: NSWindow.isMainWindow),
                        methodSignature: (@convention(c)  (AnyObject, Selector) -> (Bool)).self,
                        hookSignature: (@convention(block)  (AnyObject) -> (Bool)).self) { store in {
                            object in
                            return (object as? NSWindow)?._isMainWindow ?? store.original(object, #selector(getter: NSWindow.isMainWindow))
                        }
                        }
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
                    }
                    }
                    try replaceMethod(#selector(NSWindow.resignMain),
                                      methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                                      hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        store.original(object, #selector(NSWindow.resignMain))
                        guard let window = object as? NSWindow else { return }
                        window._isMainWindow = true
                    }
                    }
                } catch {
                    Swift.debugPrint(error)
                }
            } else {
                resetMethod(#selector(NSWindow.becomeMain))
                resetMethod(#selector(NSWindow.resignMain))
                resetMethod(#selector(getter: NSWindow.isMainWindow))
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
        get { getAssociatedValue("_inLiveResize") }
        set { 
            setAssociatedValue(newValue, key: "_inLiveResize")
            set(\.inLiveResize, \._inLiveResize, to: newValue)
        }
    }
    
    var _isMainWindow: Bool? {
        get { getAssociatedValue("_isMainWindow") }
        set {
            setAssociatedValue(newValue, key: "_isMainWindow")
            set(\.isMainWindow, \._isMainWindow, to: newValue)
        }
    }
    
    var _isKeyWindow: Bool? {
        get { getAssociatedValue("_isKeyWindow") }
        set {
            setAssociatedValue(newValue, key: "_isKeyWindow")
            set(\.isKeyWindow, \._isKeyWindow, to: newValue)
        }
    }
    
    func set(_ keyPath: KeyPath<NSWindow, Bool>, _ writable: ReferenceWritableKeyPath<NSWindow, Bool?>, to value: Bool?) {
        guard value != nil else { return }
        willChangeValue(for: keyPath)
        self[keyPath: writable] = nil
        didChangeValue(for: keyPath)
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
            })
            liveResizeTokens.append(NotificationCenter.default.observe(NSWindow.didEndLiveResizeNotification, object: self) { [weak self] _ in
                guard let self = self else { return }
                guard self.needsLiveResizeObservation else {
                    self.liveResizeTokens.removeAll()
                    return
                }
                self.handlers.isLiveResizing?(false)
                self._inLiveResize = true
            })
        } else {
            liveResizeTokens.removeAll()
        }
    }
}

private let NSWindowAnimationKeys = ["frameAnimatable", "centerPoint"]
#endif
