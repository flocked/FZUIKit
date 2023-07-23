//
//  NSView+.swift
//  
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
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

    /**
     A Boolean value that determines whether subviews are confined to the bounds of the view.

     Setting this value to true causes subviews to be clipped to the bounds of the view. If set to false, subviews whose frames extend beyond the visible bounds of the view aren’t clipped.

     The default value is false.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var maskToBounds: Bool {
        get { layer?.masksToBounds ?? false }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.masksToBounds = newValue
        }
    }

    /**
     The view whose alpha channel is used to mask a view’s content.

     The view’s alpha channel determines how much of the view’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var mask: NSView? {
        get { return getAssociatedValue(key: "_viewMaskView", object: self) }
        set {
            wantsLayer = true
            layer?.mask = nil
            Self.swizzleAnimationForKey()
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
     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var center: CGPoint {
        get { frame.center }
        set {
            Self.swizzleAnimationForKey()
            frame.center = newValue }
    }

    /**
     Specifies the transform applied to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.) The default value of this property is CGAffineTransformIdentity.
     Transformations occur relative to the view's anchor point. By default, the anchor point is equal to the center point of the frame rectangle. To change the anchor point, modify the anchorPoint property of the view's underlying CALayer object.
     Changes to this property can be animated.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform: CGAffineTransform {
        get { wantsLayer = true
            return layer?.affineTransform() ?? .init()
        }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.setAffineTransform(newValue)
        }
    }

    /**
     The three-dimensional transform to apply to the view.

     The default value of this property is CATransform3DIdentity.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform3D: CATransform3D {
        get { wantsLayer = true
            return layer?.transform ?? CATransform3DIdentity
        }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.transform = newValue
        }
    }

    /**
     The anchor point of the view’s bounds rectangle.

     You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner. The default value of this property is (0.5, 0.5), which represents the center of the view’s bounds rectangle.

     All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var anchorPoint: CGPoint {
        get { layer?.anchorPoint ?? .zero }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            setAnchorPoint(newValue)
        }
    }
    
    /**
     The corner radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.cornerRadius = newValue
        }
    }

    /**
     The corner curve of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var cornerCurve: CALayerCornerCurve {
        get { layer?.cornerCurve ?? .circular }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.cornerCurve = newValue
        }
    }

    /**
     The rounded corners of the view.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var roundedCorners: CACornerMask {
        get { layer?.maskedCorners ?? CACornerMask() }
        set {
            wantsLayer = true
            layer?.maskedCorners = newValue
        }
    }

    /**
     The border width of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var borderWidth: CGFloat {
        get { layer?.borderWidth ?? 0.0 }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.borderWidth = newValue
        }
    }

    /**
     The border color of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var borderColor: NSColor? {
        get { if let cgColor = layer?.borderColor {
            return NSColor(cgColor: cgColor)
        } else { return nil } }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            layer?.borderColor = newValue?.cgColor
        }
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
     
     A convinient way of `needsDisplay = true`.
     */
    public func setNeedsDisplay() {
        needsDisplay = true
    }

    /**
     Invalidates the current layout of the receiver and triggers a layout update during the next update cycle.

     A convinient way of `needsLayout = true`.
     */
    public func setNeedsLayout() {
        needsLayout = true
    }

    /**
     Controls whether the view’s constraints need updating.

     A convinient way of `needsUpdateConstraints = true`.
     */
    public func setNeedsUpdateConstraints() {
        needsUpdateConstraints = true
    }

    /// The parent view controller managing the view.
    public var parentController: NSViewController? {
        if let responder = nextResponder as? NSViewController {
            return responder
        }
        return (nextResponder as? NSView)?.parentController
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
     */
    func scrollToVisible(_ rect: CGRect, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                self.scrollToVisible(rect)
            }
            
        } else {
            scrollToVisible(rect)
        }
    }
    
    // Sets the anchor point of the view’s bounds rectangle while retaining the position.
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
    
    internal var alpha: CGFloat {
        get { guard let cgValue = layer?.opacity else { return 1.0 }
            return CGFloat(cgValue)
        }
        set {
            wantsLayer = true
            layer?.opacity = Float(newValue)
        }
    }
}

public extension NSView.AutoresizingMask {
    static let none: NSView.AutoresizingMask = []
    static let flexibleSize: NSView.AutoresizingMask = [.height, .width]
    static let all: NSView.AutoresizingMask = [.height, .width, .minYMargin, .minXMargin, .maxXMargin, .maxYMargin]
}

internal extension CALayerContentsGravity {
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

internal extension NSView {
    @objc func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        switch key {
        case "center", "transform", "transform3D", "anchorPoint", "cornerRadius", "roundedCorners", "borderWidth", "borderColor", "masksToBounds", "mask":
            return CABasicAnimation()
        default:
            return self.swizzledAnimation(forKey: key)
        }
    }
    
    static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue(key: "NSView_didSwizzleAnimationForKey", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSView_didSwizzleAnimationForKey", object: self)
        }
    }
    
    static func swizzleAnimationForKey() {
        if didSwizzleAnimationForKey == false {
            didSwizzleAnimationForKey = true
            do {
                try Swizzle(NSView.self) {
                    #selector(animation(forKey:)) <-> #selector(swizzledAnimation(forKey:))
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}
#endif
