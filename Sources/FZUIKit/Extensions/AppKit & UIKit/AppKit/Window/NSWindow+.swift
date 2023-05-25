//
//  NSWindow+.swift
//  FZExtensions
//
//  Created by Florian Zand on 12.08.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSWindow {
    var isFullscreen: Bool {
        styleMask.contains(.fullScreen)
    }

    var tabIndex: Int? {
        tabbedWindows?.firstIndex(of: self)
    }

    /**
     Positions the bottom-left corner of the window’s frame rectangle at a given point on the screen.

     - Parameters:
        - point: The new position of the window’s bottom-left corner in screen coordinates.
        - screen: The screen on which the window’s frame gets moved.
     */
    func setFrameOrigin(_ point: CGPoint, on screen: NSScreen) {
        let screenFrame = screen.frame
        var origin = point
        origin.x = screenFrame.origin.x + point.x
        origin.y = screenFrame.origin.y + point.y
        setFrameOrigin(origin)
    }

    func center(on screen: NSScreen) {
        var frame = self.frame
        frame.center = screen.frame.center
        setFrame(frame, display: true)
    }

    /// Make the receiver a sensible size, given the current screen
    ///
    /// This method attempts to size the window to match the current screen
    /// aspect ratio and dimensions. It will not exceed 1024 x 900.
    func resizeToScreenAspectRatio() {
        guard let screen = NSScreen.main else {
            return
        }
        let aspectRatio = screen.visibleFrame.size.aspectRatio
        var newSize = frame.size
        newSize.width = frame.height * aspectRatio
        if newSize.width < minSize.width {
            newSize.width = minSize.width
            //    newSize.height =
        }

        /*
         let minWindowSize = NSSize(width: 800, height: 600)
         let maxWindowSize = NSSize(width: 1024, height: 900)
         let fraction: CGFloat = 0.6

         let screenSize = NSScreen.main?.visibleFrame.size ?? minWindowSize

         screenSize.aspectRatio

         let width = min(screenSize.width * fraction, maxWindowSize.width)
         let height = min(screenSize.height * fraction, maxWindowSize.height)

         setContentSize(NSSize(width: ceil(width), height: ceil(height)))
          */
    }

    /// Returns the total titlebar height
    ///
    /// Takes into account the tab bar, as well as transparent title bars and
    /// full size content.
    var titleBarHeight: CGFloat {
        let frameHeight = contentView?.frame.height ?? frame.height
        let contentLayoutRectHeight = contentLayoutRect.height

        return frameHeight - contentLayoutRectHeight
    }

    /// Indicates the state of the window's tab bar
    var isTabBarVisible: Bool {
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

    /// Returns the tab bar height
    ///
    /// This value will be zero if the tab bar is not visible
    var tabBarHeight: CGFloat {
        // hard-coding this isn't excellent, but I don't know
        // of another way to determine it without messing around
        // with hidden windows.
        return isTabBarVisible ? 28.0 : 0.0
    }

    func withAnimationDisabled(block: () -> Void) {
        let currentBehavior = animationBehavior

        animationBehavior = .none

        block()

        OperationQueue.main.addOperation {
            self.animationBehavior = currentBehavior
        }
    }
}

public extension NSWindow {
    /**
      The window’s visual effect background.

     The property adds a NSVisualEffectView as background to the window’s contentView. The default value is nil.
      */
    var visualEffect: ContentConfiguration.VisualEffect? {
        get { return contentView?.visualEffect }
        set { contentView?.visualEffect = newValue
            appearance = visualEffect?.appearance ?? appearance
        }
    }

    /**
     The window’s corner radius.

     Using this property turns the window’s content view into a layer-backed view.
     */
    var cornerRadius: CGFloat? {
        get { getAssociatedValue(key: "_windowCornerRadius", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_windowCornerRadius", object: self)
            updateCornerRadius()
        }
    }

    /**
     The window’s corner curve.

     Using this property turns the window’s content view into a layer-backed view.
     */
    var cornerCurve: CALayerCornerCurve {
        get { contentView?.layer?.cornerCurve ?? .circular }
        set {
            contentView?.wantsLayer = true
            contentView?.layer?.cornerCurve = newValue
        }
    }

    /**
     The window’s border width.

     Using this property turns the window’s content view into a layer-backed view.
     */
    var borderWidth: CGFloat {
        get { contentView?.layer?.borderWidth ?? 0.0 }
        set {
            contentView?.wantsLayer = true
            contentView?.layer?.borderWidth = newValue
        }
    }

    /**
     The window’s border width.

     Using this property turns the window’s content view into a layer-backed view.
     */
    var borderColor: NSColor? {
        get {
            if let cgColor = contentView?.layer?.borderColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            contentView?.wantsLayer = true
            contentView?.layer?.borderColor = newValue?.cgColor
        }
    }

    internal func updateCornerRadius() {
        if let cornerRadius = cornerRadius {
            backgroundColor = .clear
            isOpaque = false
            styleMask.insert(.borderless)
            styleMask.insert(.fullSizeContentView)

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
}
#endif
