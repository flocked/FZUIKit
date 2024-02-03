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
            get { frame.center }
            set {
                Self.swizzleAnimationForKey()
                var frame = frame
                frame.center = newValue
                setFrame(frame, display: true)
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
        
        /**
         A Boolean value that indicates whether the sidebar is visible.
              
         If the window's content view controller isn't a split view controller or the split view doesn't contain a sidebar, it returns `false`.
         */
        public var isSidebarVisible: Bool {
            get { (contentViewController as? NSSplitViewController)?.isSidebarVisible ?? false }
            set { (contentViewController as? NSSplitViewController)?.isSidebarVisible = newValue }
        }

        @objc func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
            if NSWindowAnimationKeys.contains(key) {
                let animation = CABasicAnimation()
                animation.timingFunction = .default
                return animation
            }
            return swizzledAnimation(forKey: key)
        }

        /// A Boolean value that indicates whether windows are swizzled to support additional properties for animating.
        static var didSwizzleAnimationForKey: Bool {
            get { getAssociatedValue(key: "didSwizzleAnimationForKey", object: self, initialValue: false) }
            set {
                set(associatedValue: newValue, key: "didSwizzleAnimationForKey", object: self)
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

    private let NSWindowAnimationKeys = ["centerPoint"]
#endif

/*
 /**
  The window’s corner radius.

  Using this property turns the window’s content view into a layer-backed view.
  */
 @objc open var cornerRadius: CGFloat {
     get { getAssociatedValue(key: "_windowCornerRadius", object: self, initialValue: -1) }
     set {
         Self.swizzleAnimationForKey()
         set(associatedValue: newValue, key: "_windowCornerRadius", object: self)
         updateCornerRadius()
     }
 }

 /**
  The window’s corner curve.

  Using this property turns the window’s content view into a layer-backed view.
  */
 @objc open var cornerCurve: CALayerCornerCurve {
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
 @objc open var borderWidth: CGFloat {
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
 @objc open var borderColor: NSColor? {
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
