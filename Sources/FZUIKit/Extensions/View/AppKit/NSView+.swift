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
                
        /// Sets type of focus ring drawn around the view.
        @discardableResult
        @objc open func focusRingType(_ type: NSFocusRingType) -> Self {
            focusRingType = type
            return self
        }
        
        /**
         The frame rectangle, which describes the view’s location and size in its window’s coordinate system.

         This rectangle defines the size and position of the view in its window’s coordinate system. If the view isn't installed in a window, it will return zero.
         */
        @objc public var frameInWindow: CGRect {
            convert(bounds, to: nil)
        }

        /**
         The frame rectangle, which describes the view’s location and size in its screen’s coordinate system.

         This rectangle defines the size and position of the view in its screen’s coordinate system.
         */
        public var frameOnScreen: CGRect? {
            window?.convertToScreen(frameInWindow)
        }
        
        /**
         The coordinate of the baseline for the topmost line of text in the view.
         
         For views with multiple lines of text, this represents the baseline of the top row of text.
         */
        @objc open var firstBaselineOffset: CGPoint {
            get {
                guard firstBaselineOffsetFromTop != 0 else { return frame.origin }
                return CGPoint(frame.x, frame.y + frame.height - firstBaselineOffsetFromTop - 0.5)
            }
            set { frame.origin = CGPoint(newValue.x, newValue.y - firstBaselineOffsetFromBottom) }
        }
        
        var firstBaselineOffsetFromBottom: CGFloat {
            frame.height - firstBaselineOffsetFromTop - 0.5
        }

        /**
         The coordinate of the baseline for the bottommost line of text in the view.
         
         For views with multiple lines of text, this represents the baseline of the bottom row of text.
         */
        @objc open var lastBaselineOffset: CGPoint {
            get { CGPoint(frame.x, frame.y + lastBaselineOffsetFromBottom - 0.5) }
            set { frame.origin = CGPoint(newValue.x, newValue.y + lastBaselineOffsetFromBottom - 0.5) }
        }

        /**
         Embeds the view in a scroll view and returns that scroll view.
         
         If the view is already emedded in a scroll view, it will return that.

         The scroll view can be accessed via the view's `enclosingScrollView` property.
         
         - Parameters:
            - managed: A Boolean value that indicates whether the scroll view should automatically manage the view.
            - bordered: A Boolean value that indicates whether the scroll view is bordered.
            - drawsBackground: A Boolean value that indicates whether the scroll view draws it's background.
         - Returns: The scroll view.
         */
        @discardableResult
        @objc open func addEnclosingScrollView(managed: Bool = true, bordered: Bool = false, drawsBackground: Bool = false) -> NSScrollView {
            if let scrollView = enclosingScrollView {
                return scrollView.managesDocumentView(managed)
            }
            return NSScrollView()
                .size(bounds.size)
                .drawsBackground(drawsBackground)
                .backgroundColor(drawsBackground ? .controlBackgroundColor : .clear)
                .borderType(bordered ? .lineBorder : .noBorder)
                .documentView(self)
                .hasScroller(true)
                .managesDocumentView(managed)
        }

        /**
         The view whose alpha channel is used to mask a view’s content.

         The view’s alpha channel determines how much of the view’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.

         Changes to this property turns the view into a layer-backed view. The property can be animated by changing it via `animator().mask`.

         The default value is `nil`, which results in a view with no mask.
         */
        @objc open var mask: NSView? {
            get { (layer?.mask as? InverseMaskLayer)?.maskLayer?.parentView ?? layer?.mask?.parentView }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                newValue?.wantsLayer = true
                newValue?.removeFromSuperview()
                layer?.mask = newValue?.layer
            }
        }

        /**
         The view whose inverse alpha channel is used to mask a view’s content.

         In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.

         Changes to this property turns the view into a layer-backed view. The property can be animated by changing it via `animator().inverseMask`.

         The default value is `nil`, which results in a view with no inverse mask.
         */
        @objc open var inverseMask: NSView? {
            get { mask }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                newValue?.wantsLayer = true
                newValue?.removeFromSuperview()
                if let newMaskLayer = newValue?.layer {
                    layer?.mask = InverseMaskLayer(maskLayer: newMaskLayer)
                } else {
                    layer?.mask = nil
                }
            }
        }

        /**
         A Boolean value that determines whether the view is opaque.

         This property provides a hint to the drawing system as to how it should treat the view. If set to `true`, the drawing system treats the view as fully opaque, which allows the drawing system to optimize some drawing operations and improve performance. If set to `false`, the drawing system composites the view normally with other content.

         An opaque view is expected to fill its bounds with entirely opaque content—that is, the content should have an alpha value of `1.0`. If the view is opaque and either does not fill its bounds or contains wholly or partially transparent content, the results are unpredictable. You should always set the value of this property to false if the view is fully or partially transparent.

         You only need to set a value for the opaque property in subclasses of `NSView` that draw their own content using the `draw(_:)` method. The opaque property has no effect in system-provided classes such as `NSButton`, `NSTextField`, `NSTableRowView`, and so on.

         Changes to this property turns the view into a layer-backed view. The default value is `false`.
         */
        public var isOpaque: Bool {
            get { layer?.isOpaque ?? false }
            set { 
                wantsLayer = true
                layer?.isOpaque = newValue
            }
        }

        /**
         The center point of the view's frame rectangle.

         Setting this property updates the origin of the rectangle in the frame property appropriately.

         Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.

         Changes to this property can be animated via `animator().center`.
         */
        @objc open var center: CGPoint {
            get { frame.center }
            set {
                NSView.swizzleAnimationForKey()
                frame.center = newValue
            }
        }

        /**
         The transform to apply to the view, relative to the center of its bounds.

         Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.). Transformations occur relative to the view's ``anchorPoint``.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.

         The default value is `CGAffineTransformIdentity`, which results in a view with no transformation.
         */
        @objc open var transform: CGAffineTransform {
            get { wantsLayer = true
                return layer?.affineTransform() ?? CGAffineTransformIdentity
            }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.setAffineTransform(newValue)
            }
        }

        /**
         The three-dimensional transform to apply to the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().transform3D`.

         The default value is `CATransform3DIdentity`, which results in a view with no transformation.
         */
        @objc open var transform3D: CATransform3D {
            get {
                wantsLayer = true
                return layer?.transform ?? CATransform3DIdentity
            }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.transform = newValue
            }
        }

        /**
         The rotation of the view as euler angles in degrees.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().rotation`.

         The default value is `0.0`, which results in a view with no rotation.
         */
        @objc open var rotation: CGVector3 {
            get { transform3D.eulerAnglesDegrees }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.eulerAnglesDegrees = newValue
            }
        }

        /**
         The rotation of the view as euler angles in radians.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().rotationInRadians`.

         The default value is `0.0`, which results in a view with no rotation.
         */
        @objc open var rotationInRadians: CGVector3 {
            get { transform3D.eulerAngles }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.eulerAngles = newValue
            }
        }

        /**
         The scale transform of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().scale`.

         The default value is `CGPoint(x: 1.0, y: 1.0)`, which results in a view displayed at it's original scale.
         */
        @objc open var scale: CGPoint {
            get { layer?.scale ?? CGPoint(x: 1, y: 1) }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.scale = Scale(newValue.x, newValue.y, transform3D.scale.z)
            }
        }
        
        /**
         The scale transform of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().scale`.

         The default value is `Scale(1.0, 1.0, 1.0 )`, which results in a view displayed at it's original scale.
         */
        @objc open var scaleXYZ: Scale {
            get { layer?.scaleXYZ ?? .init(1, 1, 1) }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.scale = newValue
            }
        }

        /**
         The perspective of the view's transform

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().perspective`.

         The default value is `zero`, which results in a view with no transformed perspective.
         */
        @objc open var perspective: Perspective {
            get { transform3D.perspective }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.perspective = newValue
            }
        }

        /**
         The shearing of the view's transform.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().skew`.

         The default value is `zero`, which results in a view with no transformed shearing.
         */
        @objc open var skew: Skew {
            get { transform3D.skew }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                transform3D.skew = newValue
            }
        }

        /**
         The anchor point of the view’s bounds rectangle.

         You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner.

         All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().anchorPoint`.

         The default value is `zero`.
         */
        @objc open var anchorPoint: CGPoint {
            get { layer?.anchorPoint ?? .zero }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                setAnchorPoint(newValue)
            }
        }

        /**
         The corner radius of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().cornerRadius`.

         The default value is `0.0`, which results in a view with no rounded corners.
         
         Setting the corner radius to value other than `0.0`, sets the ``cornerShape`` to `normal`.
         */
        @objc open var cornerRadius: CGFloat {
            get { layer?.cornerRadius ?? 0.0 }
            set {
                let clipsToBounds = clipsToBounds
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.cornerRadius = newValue
                self.clipsToBounds = clipsToBounds
                layer?.masksToBounds = clipsToBounds
                if newValue != 0.0 {
                    cornerShape = .normal
                }
            }
        }

        /**
         The corner curve of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().cornerCurve`.
         */
        @objc open var cornerCurve: CALayerCornerCurve {
            get { layer?.cornerCurve ?? .circular }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.cornerCurve = newValue
            }
        }

        /**
         The rounded corners of the view.
         
         Using this property turns the view into a layer-backed view.
         
         The default value is `[]`, which results in a view with all corners rounded when ``cornerRadius`` isn't `0`.
         */
        @objc open var roundedCorners: CACornerMask {
            get { layer?.maskedCorners ?? CACornerMask() }
            set {
                wantsLayer = true
                optionalLayer?.maskedCorners = newValue
            }
        }

        /**
         The border of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().border`.
         
         The default value is `none()`, which results in a view with no border.
         */
       @objc open var border: BorderConfiguration {
            get {
                let view = realSelf
                return view.dashedBorderLayer?.configuration ?? .init(color: view.borderColor, width: view.borderWidth)
            }
            set {
                if newValue.needsDashedBordlerLayer {
                    configurate(using: newValue)
                } else {
                    borderColor = newValue._resolvedColor
                    borderWidth = newValue.width
                }
                shapeView?.border = border
            }
        }

        @objc var borderWidth: CGFloat {
            get { layer?.borderWidth ?? 0.0 }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.borderWidth = newValue
            }
        }

        var borderColor: NSColor? {
            get { layer?.borderColor?.nsColor }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                realSelf.dynamicColors.border = newValue
                var animatableColor = newValue?.resolvedColor(for: self)
                if animatableColor == nil, isProxy() {
                    animatableColor = .clear
                }
                if layer?.borderColor?.isVisible == false || layer?.borderColor == nil {
                    layer?.borderColor = animatableColor?.withAlphaComponent(0.0).cgColor ?? .clear
                }

                borderColorAnimatable = animatableColor
            }
        }

        @objc var borderColorAnimatable: NSColor? {
            get { layer?.borderColor?.nsColor }
            set { layer?.borderColor = newValue?.cgColor }
        }

        /**
         The outer shadow of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().outerShadow`.
         
         The default value is `none()`, which results in a view with no outer shadow.
         */
        @objc open var outerShadow: ShadowConfiguration {
            get {
                let view = realSelf
                return ShadowConfiguration(color: view.shadowColor, opacity: view.shadowOpacity, radius: view.shadowRadius, offset: view.shadowOffset)
            }
            set {
                shadowOffset = newValue.offset
                shadowOpacity = newValue.opacity
                shadowRadius = newValue.radius
                shadowColor = newValue._resolvedColor
                shapeView?.outerShadow = newValue
            }
        }

        var shadowColor: NSColor? {
            get { self.layer?.shadowColor?.nsColor }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                realSelf.dynamicColors.shadow = newValue
                var animatableColor = newValue?.resolvedColor(for: self)
                if animatableColor == nil, isProxy() {
                    animatableColor = .clear
                }
                if layer?.shadowColor?.isVisible == false || layer?.shadowColor == nil {
                    layer?.shadowColor = animatableColor?.withAlphaComponent(0.0).cgColor ?? .clear
                }
                shadowColorAnimatable = animatableColor
            }
        }

        @objc var shadowColorAnimatable: NSColor? {
            get { layer?.shadowColor?.nsColor }
            set { layer?.shadowColor = newValue?.cgColor }
        }

        @objc var shadowOffset: CGPoint {
            get { (layer?.shadowOffset ?? .zero).point }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.shadowOffset = newValue.size
            }
        }

        @objc var shadowRadius: CGFloat {
            get { layer?.shadowRadius ?? .zero }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.shadowRadius = newValue
            }
        }

        @objc var shadowOpacity: CGFloat {
            get { CGFloat(layer?.shadowOpacity ?? .zero) }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                layer?.shadowOpacity = Float(newValue)
            }
        }

        /**
         The shadow path of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().shadowPath`.
         
         The default value is `nil`, which results in a view with no shadow path.
         */
        @objc open var shadowPath: NSBezierPath? {
            get { shadowPathAnimatable?.bezierPath }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                shadowPathAnimatable = newValue?.cgPath
            }
        }

        @objc var shadowPathAnimatable: CGPath? {
            get { layer?.shadowPath }
            set { layer?.shadowPath = newValue }
        }

        /**
         The inner shadow of the view.
         
         The default value is `none()`, which results in a view with no inner shadow.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().innerShadow`.
         */
      @objc open var innerShadow: ShadowConfiguration {
            get { realSelf.layer?.innerShadowLayer?.configuration ?? .none() }
            set {
                wantsLayer = true
                NSView.swizzleAnimationForKey()
                realSelf.dynamicColors.innerShadow = newValue._resolvedColor
                if innerShadowLayer == nil {
                    let innerShadowLayer = InnerShadowLayer()
                    layer?.addSublayer(withConstraint: innerShadowLayer)
                    innerShadowLayer.sendToBack()
                    innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                    innerShadowLayer.shadowOpacity = 0.0
                    innerShadowLayer.shadowRadius = 0.0
                }
                var newColor = newValue._resolvedColor?.resolvedColor(for: self)
                if newColor == nil, isProxy() {
                    newColor = .clear
                }
                if layer?.innerShadowLayer?.shadowColor?.isVisible == false || layer?.innerShadowLayer?.shadowColor == nil {
                    layer?.innerShadowLayer?.shadowColor = newColor?.withAlphaComponent(0.0).cgColor ?? .clear
                }
                innerShadowColor = newColor
                layer?.innerShadowLayer?.color = newValue.color
                innerShadowColorTransformer = newValue.colorTransformer
                innerShadowOffset = newValue.offset
                innerShadowRadius = newValue.radius
                innerShadowOpacity = newValue.opacity
            }
        }
        
        var innerShadowColorTransformer: ColorTransformer? {
            get { layer?.innerShadowLayer?.colorTransformer }
            set { layer?.innerShadowLayer?.colorTransformer = newValue }
        }

        @objc var innerShadowColor: NSColor? {
            get { layer?.innerShadowLayer?.resolvedColor }
            set { layer?.innerShadowLayer?.resolvedColor = newValue }
        }

        @objc var innerShadowOpacity: CGFloat {
            get { CGFloat(layer?.innerShadowLayer?.shadowOpacity ?? 0) }
            set { layer?.innerShadowLayer?.shadowOpacity = Float(newValue) }
        }

        @objc var innerShadowRadius: CGFloat {
            get { layer?.innerShadowLayer?.configuration.radius ?? 0 }
            set { layer?.innerShadowLayer?.configuration.radius = newValue }
        }

        @objc var innerShadowOffset: CGPoint {
            get { layer?.innerShadowLayer?.configuration.offset ?? .zero }
            set { layer?.innerShadowLayer?.configuration.offset = newValue }
        }

        /// Removes all tracking areas.
        @objc open func removeAllTrackingAreas() {
            trackingAreas.forEach({ removeTrackingArea($0) })
        }

        /**
         Marks the receiver’s entire bounds rectangle as needing to be redrawn.

         It's a convinient way of setting `needsDisplay` to `true`.
         */
        @discardableResult
        @objc open func setNeedsDisplay() -> Self {
            needsDisplay = true
            return self
        }
        
        /// Sets the Boolean value indicating whether the view’s autoresizing mask is translated into constraints for the constraint-based layout system.
        @discardableResult
        @objc open func translatesAutoresizingMaskIntoConstraints(_ translates: Bool) -> Self {
            translatesAutoresizingMaskIntoConstraints = translates
            return self
        }
        
        /// Sets the options that determine how the view is resized relative to its superview.
        @discardableResult
        @objc open func autoresizingMask(_ mask: AutoresizingMask) -> Self {
            autoresizingMask = mask
            return self
        }

        /**
         Invalidates the current layout of the receiver and triggers a layout update during the next update cycle.

         It's a convinient way of setting `needsLayout` to `true`.
         */
        @discardableResult
        @objc open func setNeedsLayout() -> Self {
            needsLayout = true
            return self
        }

        /**
         Controls whether the view’s constraints need updating.

         It's a convinient way of setting `needsUpdateConstraints` to `true`.
         */
        @discardableResult
        @objc open func setNeedsUpdateConstraints() -> Self {
            needsUpdateConstraints = true
            return self
        }

        /**
         Turns the view into a layer-backed view

         It's a convinient way of setting `wantsLayer` to `true`.
         */
        @discardableResult
        @objc open func setWantsLayer() -> Self {
            wantsLayer = true
            return self
        }

        /// The parent view controller managing the view.
        @objc open var parentController: NSViewController? {
            return nextResponder as? NSViewController ?? (nextResponder as? NSView)?.parentController
        }

        /**
         A Boolean value that indicates whether the view is visible.

         Returns `true` if :
            - `window` isn't `nil`,
            - `isHidden` is `false`
            - `alphaValue` isn't `0.0`
            - `visibleRect` isn't `zero`.
         */
        @objc open var isVisible: Bool {
            window != nil && alphaValue != 0.0 && visibleRect != .zero && isHidden == false
        }

        /**
         Resizes and repositions the view to it's superview using the specified scale.

         - Parameter option: The option for resizing and repositioning the view.
         */
        @objc open func resizeAndRepositionInSuperview(using option: CALayerContentsGravity) {
            guard let superview = superview else { return }
            switch option {
            case .resize:
                frame.size = superview.bounds.size
            case .resizeAspect:
                frame.size = frame.size.scaled(toFit: superview.bounds.size)
            case .resizeAspectFill:
                frame.size = frame.size.scaled(toFill: superview.bounds.size)
            default:
                break
            }
            switch option {
            case .bottom:
                frame.bottom = superview.bounds.bottom
            case .bottomLeft:
                frame.origin = .zero
            case .bottomRight:
                frame.bottomRight = superview.bounds.bottomRight
            case .left:
                frame.left = superview.bounds.left
            case .right:
                frame.right = superview.bounds.right
            case .topLeft:
                frame.topLeft = superview.bounds.topLeft
            case .top:
                frame.top = superview.bounds.top
            case .topRight:
                frame.topRight = superview.bounds.topRight
            default:
                center = superview.bounds.center
            }
        }

        /**
         Scrolls the view’s closest ancestor `NSClipView` object animated so a point in the view lies at the origin of the clip view's bounds rectangle.

         - Parameters:
            - point: The point in the view to scroll to.
            - animationDuration: The animation duration of the scolling.
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
         Scrolls the view’s closest ancestor `NSClipView` object  the minimum distance needed animated so a specified region of the view becomes visible in the clip view.

         - Parameters:
            - rect: The rectangle to be made visible in the clip view.
            - animationDuration: The animation duration of the scolling.
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
        
        /// Sets the text for the view’s tooltip.
        @discardableResult
        @objc open func toolTip(_ toolTip: String?) -> Self {
            self.toolTip = toolTip
            return self
        }
        
        static func swizzleAnimationForKey() {
            guard didSwizzleAnimationForKey == false else { return }
            didSwizzleAnimationForKey = true
            do {
                _ = try Swizzle(NSView.self) {
                    #selector(NSView.animation(forKey:)) <-> #selector(swizzled_Animation(forKey:))
                }
            } catch {
                Swift.debugPrint(error)
            }
        }
        
        @objc func swizzled_Animation(forKey key: NSAnimatablePropertyKey) -> Any? {
            if let animation = swizzled_Animation(forKey: key) {
                return animation
            } else if NSViewAnimationKeys.contains(key) {
                let animation = CABasicAnimation()
                animation.timingFunction = .default
                return animation
            }
            return nil
        }

        static var didSwizzleAnimationForKey: Bool {
            get { getAssociatedValue("NdidSwizzleAnimationForKey", initialValue: false) }
            set { setAssociatedValue(newValue, key: "NdidSwizzleAnimationForKey") }
        }
    }

    public extension NSView.AutoresizingMask {
        /// An empy autoresizing mask.
        static let none: NSView.AutoresizingMask = []
        /// An autoresizing mask with flexible size.
        static let flexibleSize: NSView.AutoresizingMask = [.height, .width]
        /// An autoresizing mask with flexible size and fixed margins.
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

    /// The `NSView` properties keys that can be animated.
    private let NSViewAnimationKeys = ["transform", "transform3D", "anchorPoint", "cornerRadius", "roundedCorners", "borderWidth", "borderColorAnimatable", "mask", "inverseMask", "backgroundColorAnimatable", "left", "right", "top", "bottom", "topLeft", "topCenter", "topRight", "centerLeft", "center", "centerRight", "bottomLeft", "bottomCenter", "bottomRight", "shadowColorAnimatable", "shadowOffset", "shadowOpacity", "shadowRadius", "shadowPathAnimatable", "innerShadowColor", "innerShadowOffset", "innerShadowOpacity", "innerShadowRadius", "fontSize", "gradientStartPoint", "gradientEndPoint", "gradientLocations", "gradientColors", "contentOffset", "contentOffsetFractional", "documentSize"]

#endif
