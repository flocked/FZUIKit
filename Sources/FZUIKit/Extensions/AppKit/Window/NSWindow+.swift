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
    /// A Boolean value that indicates whether the window is fullscreen.
    public var isFullscreen: Bool {
        get { styleMask.contains(.fullScreen) }
        set { 
            guard newValue != isFullscreen else { return }
            self.toggleFullScreen(nil)
        }
    }
    
    /// the index of the window tab or nil if the window isn't a tab.
    public var tabIndex: Int? {
        tabbedWindows?.firstIndex(of: self)
    }

    /**
     Positions the bottom-left corner of the window’s frame rectangle at a given point on the screen.

     - Parameters:
        - point: The new position of the window’s bottom-left corner in screen coordinates.
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
     
     The window is placed exactly in the center horizontally and somewhat above center vertically. Such a placement carries a certain visual immediacy and importance. This method doesn’t put the window onscreen, however; use makeKeyAndOrderFront(_:) to do that.
     You typically use this method to place a window—most likely an alert dialog—where the user can’t miss it. This method is invoked automatically when a panel is placed on the screen by the runModal(for:) method of the NSApplication class.
     
     - Parameters screen: The screen for centering the window.
     */
    public func center(on screen: NSScreen) {
        var frame = self.frame
        frame.center = screen.frame.center
        setFrame(frame, display: true)
    }
    
    /**
     The center point of the window's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a window.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var centerPoint: CGPoint {
        get { self.frame.center }
        set {
            Self.swizzleAnimationForKey()
            var frame = self.frame
            frame.center = newValue
            setFrame(frame, display: true)
        }
    }
    
    /**
     Make the receiver a sensible size, given the current screen
     
     This method attempts to size the window to match the current screen aspect ratio and dimensions. It will not exceed 1024 x 900.
     */
    public func resizeToScreenAspectRatio() {
        guard let screen = NSScreen.main else {
            return
        }
        let aspectRatio = screen.visibleFrame.size.aspectRatio
        var newSize = frame.size
        newSize.width = frame.height * aspectRatio
        if newSize.width < minSize.width {
            newSize.width = minSize.width
        }
    }
    
    /**
     Returns the total titlebar height
     
     Takes into account the tab bar, as well as transparent title bars and full size content.
     */
    public var titleBarHeight: CGFloat {
        let frameHeight = contentView?.frame.height ?? frame.height
        let contentLayoutRectHeight = contentLayoutRect.height

        return frameHeight - contentLayoutRectHeight
    }

    /// A Boolean value that indicates whether the tab bar is visible.
    public var isTabBarVisible: Bool {
        get {
            if #available(OSX 10.13, *) {
                // be extremely careful here. Just *accessing* the tabGroup property can
                // affect NSWindow's tabbing behavior
                if tabbedWindows == nil {
                    return false
                }
                
                return tabGroup?.isTabBarVisible ?? false
            } else {
                return false
            }
        }
        set {
            guard let tabbedWindows = tabbedWindows, tabbedWindows.count > 1, let tabGroup = tabGroup, tabGroup.isTabBarVisible != newValue else { return }
            self.toggleTabBar(nil)
        }
    }
    
    /**
     Returns the tab bar height.
     
     This value will be zero if the tab bar isn't visible.
     */
    public var tabBarHeight: CGFloat {
        // hard-coding this isn't excellent, but I don't know
        // of another way to determine it without messing around
        // with hidden windows.
        return isTabBarVisible ? 28.0 : 0.0
    }

    /**
     Runs the specified handler without animating the window.
     - Parameters block: The handler to be used.
     */
    public func withAnimationDisabled(block: () -> Void) {
        let currentBehavior = animationBehavior

        animationBehavior = .none

        block()

        OperationQueue.main.addOperation {
            self.animationBehavior = currentBehavior
        }
    }
}

extension NSWindow {
    /**
     The window’s visual effect background.
     
     The property adds a NSVisualEffectView as background to the window’s `contentView`. The default value is `nil.
      */
    public var visualEffect: ContentConfiguration.VisualEffect? {
        get { return contentView?.visualEffect }
        set {
            var newValue = newValue
            newValue?.blendingMode = .behindWindow
            contentView?.visualEffect = newValue
            appearance = visualEffect?.appearance ?? appearance
        }
    }

    /*
    /**
     The window’s corner radius.

     Using this property turns the window’s content view into a layer-backed view.
     */
    @objc open dynamic var cornerRadius: CGFloat {
        get { getAssociatedValue(key: "_windowCornerRadius", object: self, initialValue: -1) }
        set {
            Self.swizzleAnimationForKey()
            set(associatedValue: newValue, key: "_windowCornerRadius", object: self)
            updateCornerRadius()
        }
    }
    */

    /**
     The window’s corner curve.

     Using this property turns the window’s content view into a layer-backed view.
     */
    @objc open dynamic var cornerCurve: CALayerCornerCurve {
        get { contentView?.layer?.cornerCurve ?? .circular }
        set {
            Self.swizzleAnimationForKey()
            contentView?.wantsLayer = true
            contentView?.layer?.cornerCurve = newValue
        }
    }

    /**
     The window’s border width.

     Using this property turns the window’s content view into a layer-backed view.
     */
    @objc open dynamic var borderWidth: CGFloat {
        get { contentView?.layer?.borderWidth ?? 0.0 }
        set {
            Self.swizzleAnimationForKey()
            contentView?.wantsLayer = true
            contentView?.layer?.borderWidth = newValue
        }
    }

    /**
     The window’s border width.

     Using this property turns the window’s content view into a layer-backed view.
     */
    @objc open dynamic var borderColor: NSColor? {
        get {
            if let cgColor = contentView?.layer?.borderColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            Self.swizzleAnimationForKey()
            contentView?.wantsLayer = true
            contentView?.layer?.borderColor = newValue?.cgColor
        }
    }

    /*
    internal func updateCornerRadius() {
        if cornerRadius >= 0 {
            backgroundColor = .clear
            isOpaque = false
            styleMask.insert(.borderless)
            styleMask.insert(.fullSizeContentView)
            styleMask.remove(.titled)
            
            contentView?.wantsLayer = true
            contentView?.layer?.cornerRadius = cornerRadius
            contentView?.layer?.masksToBounds = true
        } else {
            isOpaque = true
            backgroundColor = .windowBackgroundColor
            contentView?.layer?.cornerRadius = 0.0
            contentView?.layer?.cornerCurve = .circular
        }
    }
    */
}

internal extension NSWindow {
    @objc func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if NSWindowAnimationKeys.contains(key) {
            let animation = CABasicAnimation()
            animation.timingFunction = .default
            return animation
        }
        return self.swizzledAnimation(forKey: key)
    }
    
    /// A Boolean value that indicates whether windows are swizzled to support additional properties for animating.
    static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue(key: "NSWindow_didSwizzleAnimationForKey", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSWindow_didSwizzleAnimationForKey", object: self)
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
}

/// The additional `NSWindow` keys of properties that can be animated.
private let NSWindowAnimationKeys = ["cornerRadius", "roundedCorners", "borderWidth", "borderColor", "centerPoint"]
#endif
