//
//  NSView+Extensions.swift
//  SelectableArray
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
    public typealias ContentMode = CALayerContentsGravity

    /**
     The frame rectangle, which describes the view’s location and size in its window’s coordinate system.

     This rectangle defines the size and position of the view in its window’s coordinate system. If the view isn't installed in a window, it will return zero.
     */
    public var frameInWindow: CGRect {
        convert(bounds, to: nil)
    }

    /**
     The frame rectangle, which describes the view’s location and size in its screen’s coordinate system.

     This rectangle defines the size and position of the view in its screen’s coordinate system.
     */
    public var frameOnScreen: CGRect? {
        return window?.convertToScreen(frameInWindow)
    }

    public var contentMode: ContentMode {
        get { layer?.contentsGravity ?? .center }
        set { wantsLayer = true
            layer?.contentsGravity = newValue
        }
    }

    /**
     A Boolean value that determines whether subviews are confined to the bounds of the view.

     Setting this value to true causes subviews to be clipped to the bounds of the view. If set to false, subviews whose frames extend beyond the visible bounds of the view aren’t clipped.

     The default value is false.

     Using this property turns the view into a layer-backed view.
     */
    public var maskToBounds: Bool {
        get { layer?.masksToBounds ?? false }
        set { wantsLayer = true
            layer?.masksToBounds = newValue
        }
    }

    /**
     An optional view whose alpha channel is used to mask a view’s content.

     The view’s alpha channel determines how much of the view’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.
     */
    public var mask: NSView? {
        get { return getAssociatedValue(key: "_viewMaskView", object: self) }
        set {
            layer?.mask = nil
            set(associatedValue: newValue, key: "_viewMaskView", object: self)
            if let maskView = newValue {
                wantsLayer = true
                maskView.wantsLayer = true
                layer?.mask = maskView.layer
            }
        }
    }

    /**
     A Boolean value that determines whether the view is opaque.

     This property provides a hint to the drawing system as to how it should treat the view. If set to true, the drawing system treats the view as fully opaque, which allows the drawing system to optimize some drawing operations and improve performance. If set to false, the drawing system composites the view normally with other content. The default value of this property is true.

     An opaque view is expected to fill its bounds with entirely opaque content—that is, the content should have an alpha value of 1.0. If the view is opaque and either does not fill its bounds or contains wholly or partially transparent content, the results are unpredictable. You should always set the value of this property to false if the view is fully or partially transparent.

     Using this property turns the view into a layer-backed view.
     */
    public var isOpaque: Bool {
        get { layer?.isOpaque ?? false }
        set { wantsLayer = true
            layer?.isOpaque = newValue
        }
    }

    /**
     The center point of the view's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform. Changes to this property can be animated.
     */
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }

    /**
     Specifies the transform applied to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.) The default value of this property is CGAffineTransformIdentity.
     Transformations occur relative to the view's anchor point. By default, the anchor point is equal to the center point of the frame rectangle. To change the anchor point, modify the anchorPoint property of the view's underlying CALayer object.
     Changes to this property can be animated.

     Using this property turns the view into a layer-backed view.
     */
    public var transform: CGAffineTransform {
        get { wantsLayer = true
            return layer?.affineTransform() ?? .init()
        }
        set { wantsLayer = true
            layer?.setAffineTransform(newValue)
        }
    }

    /**
     The three-dimensional transform to apply to the view.

     The default value of this property is CATransform3DIdentity.

     Using this property turns the view into a layer-backed view.
     */
    public var transform3D: CATransform3D {
        get { wantsLayer = true
            return layer?.transform ?? CATransform3DIdentity
        }
        set { wantsLayer = true
            layer?.transform = newValue
        }
    }

    /**
     The anchor point of the view’s bounds rectangle.

     You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner. The default value of this property is (0.5, 0.5), which represents the center of the view’s bounds rectangle.

     All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

     Using this property turns the view into a layer-backed view.
     */
    public var anchorPoint: CGPoint {
        get { layer?.anchorPoint ?? .zero }
        set { wantsLayer = true
            setAnchorPoint(newValue)
        }
    }

    internal var alpha: CGFloat {
        get { guard let cgValue = layer?.opacity else { return 1.0 }
            return CGFloat(cgValue)
        }
        set {
            wantsLayer = true
            layer?.opacity = Float(newValue)
        }
    }

    /**
     The view’s corner radius.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set { wantsLayer = true
            layer?.cornerRadius = newValue
        }
    }

    /**
     The view’s corner curve.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var cornerCurve: CALayerCornerCurve {
        get { layer?.cornerCurve ?? .circular }
        set { wantsLayer = true
            layer?.cornerCurve = newValue
        }
    }

    /**
     The view’s rounded corners.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var roundedCorners: CACornerMask {
        get { layer?.maskedCorners ?? CACornerMask() }
        set { wantsLayer = true
            layer?.maskedCorners = newValue
        }
    }

    /**
     The view’s border width.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var borderWidth: CGFloat {
        get { layer?.borderWidth ?? 0.0 }
        set { wantsLayer = true
            layer?.borderWidth = newValue
        }
    }

    /**
     The view’s border color.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var borderColor: NSColor? {
        get { if let cgColor = layer?.borderColor {
            return NSColor(cgColor: cgColor)
        } else { return nil } }
        set { wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }

    internal func setAnchorPoint(_ anchorPoint: CGPoint) {
        guard let layer = layer else { return }
        var newPoint = CGPoint(bounds.size.width * anchorPoint.x, bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(bounds.size.width * layer.anchorPoint.x, bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(layer.affineTransform())
        oldPoint = oldPoint.applying(layer.affineTransform())

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }

    /**
     Adds a tracking area to the view.

     - Parameters:
        - rect: A rectangle that defines a region of the view for tracking events related to mouse tracking and cursor updating. The specified rectangle should not exceed the view’s bounds rectangle.
        - options: One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area. See the description of NSTrackingArea.Options and related constants for details. You must specify one or more options for the initialized object for the type of tracking area and for when the tracking area is active; zero is not a valid value.
     */
    public func addTrackingArea(rect: NSRect? = nil, options: NSTrackingArea.Options = [
        .mouseMoved,
        .mouseEnteredAndExited,
        .activeInKeyWindow,
    ]) {
        addTrackingArea(NSTrackingArea(
            rect: rect ?? bounds,
            options: options,
            owner: self
        ))
    }

    /// Removes all tracking areas.
    public func removeAllTrackingAreas() {
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
    }
    
    /**
     Marks the receiver’s entire bounds rectangle as needing to be redrawn.
     
     You can use this method to notify the system that your view’s contents need to be redrawn. This method makes a note of the request and returns immediately. The view is not actually redrawn until the next drawing cycle, at which point all invalidated views are updated.
     
     */
    public func setNeedsDisplay() {
        needsDisplay = true
    }

    /**
     Invalidates the current layout of the receiver and triggers a layout update during the next update cycle.

     Calling this method lets the system know that the view’s layout needs to be updated before it is drawn. The system checks the value of this property prior to applying constraint-based layout rules for the view.
     
     This method makes a note of the request and returns immediately. Because this method does not force an immediate update, but instead waits for the next update cycle, you can use it to invalidate the layout of multiple views before any of those views are updated. This behavior allows you to consolidate all of your layout updates to one update cycle, which is usually better for performance.
     */
    public func setNeedsLayout() {
        needsLayout = true
    }

    /**
     Controls whether the view’s constraints need updating.

     When a property of your custom view changes in a way that would impact constraints, you can call this method to indicate that the constraints need to be updated at some point in the future. The system will then call `updateConstraints()` as part of its normal layout pass. Use this as an optimization tool to batch constraint changes. Updating constraints all at once just before they are needed ensures that you don’t needlessly recalculate constraints when multiple changes are made to your view in between layout passes.
     */
    public func setNeedsUpdateConstraints() {
        needsUpdateConstraints = true
    }

    // Returns the parent view controller managing the view.
    public var parentController: NSViewController? {
        if let responder = nextResponder as? NSViewController {
            return responder
        } else if let responder = nextResponder as? NSView {
            return responder.parentController
        } else {
            return nil
        }
    }

    /// A Boolean value that indicates whether the view is visible.
    public var isVisible: Bool {
        window != nil && alphaValue != 0.0 && visibleRect != .zero
    }
    
    /**
     Scrolls the view’s closest ancestor NSClipView object animated so a point in the view lies at the origin of the clip view's bounds rectangle.
     
     - Parameters point: The point in the view to scroll to.
     - Parameters animationDuration: The animation duration of the scolling.
     */
    func scroll(_ point: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                if let enclosingScrollView = self.enclosingScrollView {
                    enclosingScrollView.contentView.animator().setBoundsOrigin(point)
                    enclosingScrollView.reflectScrolledClipView(enclosingScrollView.contentView)
                }
            }
        } else {
            scroll(point)
        }
    }

    /**
     Scrolls the view’s closest ancestor NSClipView object  the minimum distance needed animated so a specified region of the view becomes visible in the clip view.
     
     - Parameters rect: The rectangle to be made visible in the clip view.
     - Parameters animationDuration: The animation duration of the scolling.
     - Returns: `true` if any scrolling is performed; otherwise returns `false`.
     */
    @discardableResult
    func scrollToVisible(_ rect: CGRect, animationDuration: CGFloat) -> Bool {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                return self.scrollToVisible(rect)
            }
        } else {
            return scrollToVisible(rect)
        }
    }
}

public extension NSView.AutoresizingMask {
    static let none: NSView.AutoresizingMask = []
    static let flexibleSize: NSView.AutoresizingMask = [.height, .width]
    static let all: NSView.AutoresizingMask = [.height, .width, .minYMargin, .minXMargin, .maxXMargin, .maxYMargin]
}

extension CALayerContentsGravity {
    var viewLayerContentsPlacement: NSView.LayerContentsPlacement {
        switch self {
        case .topLeft: return .topLeft
        case .top: return .top
        case .topRight: return .topRight
        case .center: return .center
        case .bottomLeft: return .bottomLeft
        case .bottom: return .bottom
        case .bottomRight: return .bottomRight
        case .resize: return .scaleAxesIndependently
        case .resizeAspectFill: return .scaleProportionallyToFill
        case .resizeAspect: return .scaleProportionallyToFit
        case .left: return .left
        case .right: return .right
        default: return .scaleProportionallyToFill
        }
    }
}
#endif
