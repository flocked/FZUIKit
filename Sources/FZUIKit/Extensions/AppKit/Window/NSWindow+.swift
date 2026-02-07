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
    /// Repositions the window below the other specified window.
    @objc open func order(below window: NSWindow) {
        order(.below, relativeTo: window.windowNumber)
    }
    
    /// Repositions the window above the other specified window.
    @objc open func order(above window: NSWindow) {
        order(.above, relativeTo: window.windowNumber)
    }
    
    /// Repositions the window’s origin with an offset from the specified frame.
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
    
    /// Repositions the window’s origin with an offset from the specified window.
    func cascade(from window: NSWindow) {
        cascade(from: window.frame)
    }
    
    /**
     A Boolean value indicating whether the window is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.
     */
    @objc open var isFirstResponder: Bool {
        firstResponder == self
    }
    
    /// A Boolean value indicating whether the window displays a title bar.
    @objc open var isTitled: Bool {
        get { styleMask.contains(.titled) }
        set { styleMask[.titled] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window displays a title bar.
    @discardableResult
    @objc open func isTitled(_ isTitled: Bool) -> Self {
        self.isTitled = isTitled
        return self
    }
    
    /// A Boolean value indicating whether the [contentView](https://developer.apple.com/documentation/appkit/nswindow/contentview) consumes the full size of the window.
    @objc open var hasFullSizeContentView: Bool {
        get { styleMask.contains(.fullSizeContentView) }
        set { styleMask[.fullSizeContentView] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the [contentView](https://developer.apple.com/documentation/appkit/nswindow/contentview) consumes the full size of the window.
    @discardableResult
    @objc open func hasFullSizeContentView(_ hasFullSizeContentView: Bool) -> Self {
        self.hasFullSizeContentView = hasFullSizeContentView
        return self
    }
    
    /// A Boolean value indicating whether the window displays a close button.
    @objc open var displaysCloseButton: Bool {
        get { styleMask.contains(.closable) }
        set { styleMask[.closable] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window displays a close button.
    @discardableResult
    @objc open func displaysCloseButton(_ displays: Bool) -> Self {
        self.displaysCloseButton = displays
        return self
    }
    
    /// A Boolean value indicating whether the window can be resized by the user.
    @objc open var isResizable: Bool {
        get { styleMask.contains(.resizable) }
        set { styleMask[.resizable] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window can be resized by the user.
    @discardableResult
    @objc open func isResizable(_ isResizable: Bool) -> Self {
        self.isResizable = isResizable
        return self
    }
    
    /// A Boolean value indicating whether the window displays a minimize button.
    @objc open var displaysMinimizeButton: Bool {
        get { styleMask.contains(.miniaturizable) }
        set { styleMask[.miniaturizable] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window displays a minimize button.
    @discardableResult
    @objc open func displaysMinimizeButton(_ displays: Bool) -> Self {
        self.displaysMinimizeButton = displays
        return self
    }
    
    /// A Boolean value indicating whether the window displays none of the usual peripheral elements.
    @objc open var isBorderless: Bool {
        get { styleMask.contains(.borderless) }
        set { styleMask[.borderless] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window displays none of the usual peripheral elements.
    @discardableResult
    @objc open func isBorderless(_ isBorderless: Bool) -> Self {
        self.isBorderless = isBorderless
        return self
    }
    
    /// A Boolean value indicating whether the window is a document-modal panel.
    @objc open var isDocumentModal: Bool {
        get { styleMask.contains(.docModalWindow) }
        set { styleMask[.docModalWindow] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the window is a document-modal panel.
    @discardableResult
    @objc open func isDocumentModal(_ isDocumentModal: Bool) -> Self {
        self.isDocumentModal = isDocumentModal
        return self
    }
    
    public enum FullscreenTilingBehaviour {
        /**
         The system determines whether the window can participate in full-screen tiling.
         
         This is the default behavior. Most resizable windows that are not panels or sheets will automatically support tiling.
         */
        case `default`
        
        /**
         Explicitly allows the window to participate in full-screen tiling (Split View).
         
         Use this for custom or nonstandard windows that would not otherwise qualify for tiling.
         */
        case allows
        
        /**
         Explicitly disallows the window from participating in full-screen tiling.
         
         Use this for utility panels, inspectors, or other windows that should not appear in Split View or allow other windows to tile alongside them.
         */
        case disallows
    }
    
    var fullscreenTilingBehaviour: FullscreenTilingBehaviour {
        get { collectionBehavior.contains(.fullScreenAllowsTiling) ? .allows : collectionBehavior.contains(.fullScreenDisallowsTiling) ? .disallows : .default }
        set {
            switch newValue {
            case .allows:
                collectionBehavior.insert(.fullScreenAllowsTiling)
                collectionBehavior.remove(.fullScreenDisallowsTiling)
            case .disallows:
                collectionBehavior.remove(.fullScreenAllowsTiling)
                collectionBehavior.insert(.fullScreenDisallowsTiling)
            case .default:
                collectionBehavior.remove([.fullScreenAllowsTiling, .fullScreenDisallowsTiling])
            }
        }
    }
    
    public enum FullscreenSupport {
        /// The window can enter full-screen mode.
        case regular
        /// The window displays on the same space as the full screen window.
        case auxiliary
        /// The window doesn’t support full-screen mode.
        case none
    }
    
    public var fullscreenSupport: FullscreenSupport {
        get { collectionBehavior.contains(.fullScreenPrimary) ? .regular : collectionBehavior.contains(.fullScreenAuxiliary) ? .auxiliary : .none }
        set {
            collectionBehavior[.fullScreenNone] = newValue == .none
            collectionBehavior[.fullScreenPrimary] = newValue == .regular
            collectionBehavior[.fullScreenAuxiliary] = newValue == .auxiliary
        }
    }
    
    @objc open var participatesInCycle: Bool {
        get { !collectionBehavior.contains(.ignoresCycle) }
        set {
            collectionBehavior[.ignoresCycle] = !newValue
            collectionBehavior[.participatesInCycle] = newValue
        }
    }
    
    /// Handlers for the window.
    public struct Handlers {
        /// The handler that is called when the window’s key state changes.
        public var isKey: ((Bool)->())?
        /// The handler that is called when the window’s main state changes.
        public var isMain: ((Bool)->())?
        /// The handler that is called when the window’s first responder changes.
        public var firstResponder: ((NSResponder?)->())?
        /// The handler that is called when the window’s frame changes.
        public var frame: ((CGRect)->())?
        /// The handler that is called when the user is resizing the window.
        public var isLiveResizing: ((Bool)->())?
        /// The handler that is called when the appearance changes.
        public var effectiveAppearance: ((NSAppearance)->())?
        /// The handler that is called when the window’s fullscreen state changes.
        public var isFullScreen: ((Bool)->())?
        /// The handler that is called when the style mask changes.
        public var styleMask: ((StyleMask)->())?
        /// The handler that is called when the window’s active space state changes.
        public var isOnActiveSpace: ((Bool)->())?
        /// The handler that is called when the screen changes.
        public var screen: ((NSScreen?)->())?
        /// The handler that is called when the is visibility state changes.
        public var isVisible: ((Bool)->())?
        /// The handler that is called when the is visibility state changes.
        public var isMiniaturized: ((Bool)->())?
        
        /// The tab handlers for the window.
        public var tab: TabHandlers = TabHandlers()
        
        /// Tab handlers for the window.
        public struct TabHandlers {
            /// The handler that is called when the tab windows changes.
            public var windows: (([NSWindow]?)->())?
            /// The handler that is called when the selected tab changes.
            public var selected: ((NSWindow?)->())?
            /// The handler that is called when the tab selection state changes.
            public var isSelected: ((Bool)->())?
            /// The handler that is called when the tab bar visibilty changes.
            public var isTabBarVisible: ((Bool)->())?
            /// The handler that is called when the tab overview visibilty changes.
            public var isOverviewVisible: ((Bool)->())?
        }
    }
    
    /// The handlers for the window.
    public var handlers: Handlers {
        get { getAssociatedValue("windowHandlers", initialValue: Handlers()) }
        set {
            let needsSpaceUpdate = (handlers.isOnActiveSpace == nil && newValue.isOnActiveSpace != nil) || (handlers.isOnActiveSpace != nil && newValue.isOnActiveSpace == nil)
            setAssociatedValue(newValue, key: "windowHandlers")
            
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
            observe(\.screen, handler: \.handlers.screen)
            observe(\.isVisible, handler: \.handlers.isVisible)
            
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
            observations["key"] = observeIsKey(newValue.isKey)
            observations["main"] = observeIsMain(newValue.isMain)
            observations["resize"] = observeIsLiveResizing(newValue.isLiveResizing)
            observations["miniaturize"] = observeMiniaturize(newValue.isMiniaturized)
        }
    }
    
    func observeIsKey(_ handler: ((Bool)->())?) -> [NotificationToken] {
        guard let handler = handler else { return [] }
        return [NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, postedBy: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, postedBy: self) { _ in handler(false) }]
    }
    
    func observeIsMain(_ handler: ((Bool)->())?) -> [NotificationToken] {
        guard let handler = handler else { return [] }
        return [NotificationCenter.default.observe(NSWindow.didBecomeMainNotification, postedBy: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didResignMainNotification, postedBy: self) { _ in handler(false) }]
    }
    
    func observeIsLiveResizing(_ handler: ((Bool)->())?) -> [NotificationToken] {
        guard let handler = handler else { return [] }
        return [NotificationCenter.default.observe(NSWindow.willStartLiveResizeNotification, postedBy: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didEndLiveResizeNotification, postedBy: self) { _ in handler(false) }]
    }
    
    func observeMiniaturize(_ handler: ((Bool)->())?) -> [NotificationToken] {
        guard let handler = handler else { return [] }
        return [NotificationCenter.default.observe(NSWindow.didMiniaturizeNotification, postedBy: self) { _ in handler(true) }, NotificationCenter.default.observe(NSWindow.didDeminiaturizeNotification, postedBy: self) { _ in handler(false) }]
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
    
    /**
     The window’s frame size, including the title bar.
          
     The value can be animated via `animator().size`.
     */
    @objc open var size: CGSize {
        get { frame.size }
        set { frameAnimatable.size = newValue }
    }
    
    /**
     Sets the window’s frame size, including the title bar.
     
     - Parameters:
        - size: The window’s frame size, including the title bar.
        - expandToBottom:A Boolean value indicating whether the window should expand it's size to the bottom.
     */
    @discardableResult
    @objc open func size(_ size: CGSize, expandToBottom: Bool = false) -> Self {
        frameAnimatable = expandToBottom ? frame.size(size).offsetBy(dy: size.height - self.frame.height) : frame.size(size)
        return self
    }
    
    /*
    /**
     The size of the window’s content view.
     
     The value can be animated via `animator().contentSize`.
     */
    @objc open var contentSize: CGSize {
        get { contentLayoutRect.size }
        set { setContentSize(newValue) }
    }
    
    /// Sets the size of the window.
    @discardableResult
    @objc open func contentSize(_ size: CGSize) -> Self {
        self.contentSize = size
        return self
    }
    */
    
    /// Sets the origin of the window’s frame rectangle in screen coordinates.
    @discardableResult
    @objc open func origin(_ origin: CGPoint) -> Self {
        self.frameAnimatable.origin = origin
        return self
    }
    
    /// Sets the window style, such as if it’s resizable or in full-screen mode.
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
    
    /// Sets the Boolean value indicating whether the window can hide when its application becomes hidden.
    @discardableResult
    @objc open func canHide(_ canHide: Bool) -> Self {
        self.canHide = canHide
        return self
    }
    
    /// Sets the Boolean value indicating whether the window is removed from the screen when its application becomes inactive.
    @discardableResult
    @objc open func hidesOnDeactivate(_ hides: Bool) -> Self {
        self.hidesOnDeactivate = hides
        return self
    }
    
    /// Sets the Boolean value indicating whether the window is opaque.
    @discardableResult
    @objc open func isOpaque(_ isOpaque: Bool) -> Self {
        self.isOpaque = isOpaque
        return self
    }
    
    /// Sets the Boolean value indicating whether the window has a shadow.
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
    
    fileprivate var windowObserver: KeyValueObserver<NSWindow> {
        get { getAssociatedValue("windowObserver", initialValue: KeyValueObserver(self)) }
    }
    
    fileprivate var observations: [String: [NotificationToken]] {
        get { getAssociatedValue("observations") ?? [:] }
        set { setAssociatedValue(newValue, key: "observations") }
    }
    
    /// A Boolean value indicating whether the window is fullscreen.
    @objc open var isFullscreen: Bool {
        get {
            setupFullscreenObservation()
            return styleMask.contains(.fullScreen)
        }
        set {
            guard newValue != isFullscreen else { return }
            toggleFullScreen(nil)
        }
    }
    
    /// Sets the Boolean value indicating whether the window is fullscreen.
    @discardableResult
    @objc open func isFullscreen(_ isFullscreen: Bool) -> Self {
        self.isFullscreen = isFullscreen
        return self
    }
    
    private func setupFullscreenObservation() {
        guard fullscreenTokens.isEmpty else { return }
        fullscreenTokens = [NotificationToken(NSWindow.willEnterFullScreenNotification, object: self, block: { [weak self] _ in
            self?.willChangeValue(for: \.isFullscreen)
        }), NotificationToken(NSWindow.willExitFullScreenNotification, object: self, block: { [weak self] _ in
            self?.willChangeValue(for: \.isFullscreen)
        }), NotificationToken(NSWindow.didExitFullScreenNotification, object: self, block: { [weak self] _ in
            self?.didChangeValue(for: \.isFullscreen)
        }), NotificationToken(NSWindow.didEnterFullScreenNotification, object: self, block: { [weak self] _ in
            self?.didChangeValue(for: \.isFullscreen)
        })]
    }
    
    private var fullscreenTokens: [NotificationToken] {
        get { getAssociatedValue("fullscreenTokens") ?? [] }
        set { setAssociatedValue(newValue, key: "fullscreenTokens") }
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
     
     The value can be animated via `animator().frameAnimatable`.
     */
    @objc open var frameAnimatable: CGRect {
        get { frame }
        set { setFrame(newValue, display: false) }
    }
    
    /// Resizes the window to match it's screen aspect ratio and dimensions.
    @objc open func resizeToScreenAspectRatio() {
        guard let aspectRatio = screen?.visibleFrame.size.aspectRatio else { return }
        let frame = frame.scaled(byFactor: aspectRatio).size(frame.size.clamped(to: minSize...maxSize))
        setFrame(frame, display: false)
    }
    
    /**
     Returns the total titlebar height.
     
     The value takes into account the tab bar, as well as transparent title bars and full size content.
     */
    public var titlebarHeight: CGFloat {
        if hasFullSizeContentView, let windowFrameHeight = contentView?.frame.height {
            return windowFrameHeight - contentLayoutRect.height
        }
        return frame.height - contentRect(forFrameRect: frame).height
    }
    
    /// A Boolean value indicating whether window currently displays a tab bar.
    @objc open var isTabBarVisible: Bool {
        get { tabGroup?.isTabBarVisible ?? false }
        set {
            guard let tabGroup = tabGroup, tabGroup.isTabBarVisible != newValue else { return }
            toggleTabBar(nil)
        }
    }
    
    /// Sets the Boolean value indicating whether window currently displays a tab bar.
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
        - select: A Boolean value indicating whether to select the inserted tab.
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
     A Boolean value indicating whether the sidebar is visible.
     
     If the window's content view controller isn't a split view controlller with a sidebar item, it returns `false`.
     
     Changing the property is animatable by using `window.animator().isSidebarVisible`.
     */
    public var isSidebarVisible: Bool {
        get { (contentViewController as? NSSplitViewController)?.isSidebarVisible ?? false }
        set { (contentViewController as? NSSplitViewController)?.animator(isProxy()).isSidebarVisible = newValue }
    }
    
    /**
     A Boolean value indicating whether the inspector split view item is visible.
     
     If the window's content view controller isn't a split view controlller with a inspector item, it returns `false`.

     Changing the property is animatable by using `window.animator().isInspectorVisible`.
     */
    @available(macOS 11.0, *)
    public var isInspectorVisible: Bool {
        get { (contentViewController as? NSSplitViewController)?.isInspectorVisible ?? false }
        set { (contentViewController as? NSSplitViewController)?.animator(isProxy()).isInspectorVisible = newValue }
    }
    
    var mainWindowObservation: KeyValueObservation? {
        get { getAssociatedValue("mainWindowObservation") }
        set { setAssociatedValue(newValue, key: "mainWindowObservation") }
    }
    
    var keyWindowObservation: KeyValueObservation? {
        get { getAssociatedValue("keyWindowObservation") }
        set { setAssociatedValue(newValue, key: "keyWindowObservation") }
    }
    
    func set(_ keyPath: KeyPath<NSWindow, Bool>, _ writable: ReferenceWritableKeyPath<NSWindow, Bool?>, to value: Bool?) {
        guard value != nil else { return }
        willChangeValue(for: keyPath)
        self[keyPath: writable] = nil
        didChangeValue(for: keyPath)
    }
}

extension NSWindow.Level {
    /// Creates a window level for the specified key.
    public init(_ windowLevelKey: CGWindowLevelKey) {
        self.init(rawValue: Int(CGWindowLevelForKey(windowLevelKey)))
    }
    
    /// The level for the desktop.
    public static let desktop = Self(.desktopWindow)
    /// The level for desktop icons.
    public static let desktopIcons = Self(.desktopIconWindow)
    /// The level for the cursor.
    public static let cursor = Self(.cursorWindow)
}

extension Collection where Element == NSWindow {
    /// Repositions the windows in the order of the collection.
    public func order(firstIsFront: Bool = true) {
        guard count > 1 else { return }
        var current = first!
        for window in dropFirst() {
            if firstIsFront {
                window.order(below: current)
            } else {
                window.order(above: current)
            }
            current = window
        }
    }
}
#endif
