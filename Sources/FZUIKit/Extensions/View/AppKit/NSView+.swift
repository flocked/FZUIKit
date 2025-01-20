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
                return CGPoint(frame.x, frame.maxY - firstBaselineOffsetFromTop - 0.5)
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
            set { frame.origin = CGPoint(newValue.x, newValue.y - lastBaselineOffsetFromBottom - 0.5) }
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
        @objc public var mask: NSView? {
            get { (layer?.mask as? InverseMaskLayer)?.maskLayer?.parentView ?? layer?.mask?.parentView }
            set {
                NSView.swizzleAnimationForKey()
                newValue?.removeFromSuperview()
                optionalLayer?.mask = newValue?.optionalLayer
            }
        }

        /**
         The view whose inverse alpha channel is used to mask a view’s content.

         In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.

         Changes to this property turns the view into a layer-backed view. The property can be animated by changing it via `animator().inverseMask`.

         The default value is `nil`, which results in a view with no inverse mask.
         */
        @objc public var inverseMask: NSView? {
            get { mask }
            set {
                NSView.swizzleAnimationForKey()
                newValue?.removeFromSuperview()
                optionalLayer?.mask = newValue?.optionalLayer?.inverseMask
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
            set { optionalLayer?.isOpaque = newValue }
        }

        /**
         The center point of the view's frame rectangle.

         Setting this property updates the origin of the rectangle in the frame property appropriately.

         Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.

         Changes to this property can be animated via `animator().center`.
         */
        public var center: CGPoint {
            get { frame.center }
            set {
                NSView.swizzleAnimationForKey()
                frame.center = newValue
            }
        }
        
        /**
         The view’s position on the z axis.
         
         Changing the value of this property changes the front-to-back ordering of views onscreen. Higher values place the view visually closer to the viewer than views with lower values. This can affect the visibility of views whose frame rectangles overlap.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
         */
        @objc public var zPosition: CGFloat {
            get { layer?.zPosition ?? 0.0 }
            set {
                NSView.swizzleAnimationForKey()
                optionalLayer?.zPosition = newValue
            }
        }

        /**
         The transform to apply to the view, relative to the center of its bounds.

         Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.). Transformations occur relative to the view's ``anchorPoint``.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.

         The default value is `CGAffineTransformIdentity`, which results in a view with no transformation.
         */
        @objc public var transform: CGAffineTransform {
            get { layer?.affineTransform() ?? CGAffineTransformIdentity }
            set {
                NSView.swizzleAnimationForKey()
                optionalLayer?.setAffineTransform(newValue)
            }
        }

        /**
         The three-dimensional transform to apply to the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().transform3D`.

         The default value is `CATransform3DIdentity`, which results in a view with no transformation.
         */
        @objc public var transform3D: CATransform3D {
            get { layer?.transform ?? CATransform3DIdentity }
            set {
                NSView.swizzleAnimationForKey()
                optionalLayer?.transform = newValue
            }
        }

        /**
         The rotation of the view as euler angles in degrees.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().rotation`.

         The default value is `0.0`, which results in a view with no rotation.
         */
        public var rotation: Rotation {
            get { transform3D.eulerAnglesDegrees.rotation }
            set { transform3D.eulerAnglesDegrees = newValue.vector }
        }

        /**
         The rotation of the view as euler angles in radians.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().rotationInRadians`.

         The default value is `0.0`, which results in a view with no rotation.
         */
        public var rotationInRadians: Rotation {
            get { transform3D.eulerAngles.rotation }
            set { transform3D.eulerAngles = newValue.vector }
        }
        
        /**
         The scale transform of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().scale`.

         The default value is `none`, which results in a view displayed at it's original scale.
         */
        public var scale: Scale {
            get { layer?.scale ?? .none }
            set { transform3D.scale = newValue.vector }
        }

        /**
         The perspective of the view's transform.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().perspective`.

         The default value is `zero`, which results in a view with no transformed perspective.
         */
        public var perspective: Perspective {
            get { transform3D.perspective }
            set { transform3D.perspective = newValue }
        }
        
        
        /**
         The translation of the view's transform.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().translation`.

         The default value is `zero`, which results in a view with no transformed translation.
         */
        public var translation: Translation {
            get { transform3D.translation }
            set { transform3D.translation = newValue }
        }

        /**
         The shearing of the view's transform.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().skew`.

         The default value is `zero`, which results in a view with no transformed shearing.
         */
        public var skew: Skew {
            get { transform3D.skew }
            set { transform3D.skew = newValue }
        }

        /**
         The anchor point of the view’s bounds rectangle.

         You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner.

         All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().anchorPoint`.

         The default value is `zero`.
         */
        @objc public var anchorPoint: FractionalPoint {
            get { layer?.anchorPoint.fractional ?? .zero }
            set {
                NSView.swizzleAnimationForKey()
                setAnchorPoint(newValue.point)
            }
        }

        /**
         The corner radius of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().cornerRadius`.

         The default value is `0.0`, which results in a view with no rounded corners.
         
         Setting the corner radius to value other than `0.0`, sets the ``cornerShape`` to `normal`.
         */
        @objc public var cornerRadius: CGFloat {
            get { layer?.cornerRadius ?? 0.0 }
            set {
                let clipsToBounds = clipsToBounds
                NSView.swizzleAnimationForKey()
                relativeCornerRadius = nil
                optionalLayer?.cornerRadius = newValue
                if newValue != 0.0 {
                    // cornerShape = .normal
                }
                self.clipsToBounds = clipsToBounds
                layer?.masksToBounds = clipsToBounds
            }
        }

        /**
         The corner curve of the view.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().cornerCurve`.
         */
        @objc public var cornerCurve: CALayerCornerCurve {
            get { layer?.cornerCurve ?? .circular }
            set {
                NSView.swizzleAnimationForKey()
                optionalLayer?.cornerCurve = newValue
            }
        }

        /**
         The rounded corners of the view.
         
         Using this property turns the view into a layer-backed view.
         
         The default value is `[]`, which results in a view with all corners rounded when ``cornerRadius`` isn't `0`.
         */
        @objc public var roundedCorners: CACornerMask {
            get { layer?.maskedCorners ?? .none }
            set { 
                optionalLayer?.maskedCorners = newValue
                dashedBorderView?.update()
                visualEffectBackgroundView?.roundedCorners = newValue
            }
        }

        /**
         The border of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().border`.
         
         The default value is `none()`, which results in a view with no border.
         */
       public var border: BorderConfiguration {
            get { _border }
            set {
                NSView.swizzleAnimationForKey()
                _border = newValue
                if newValue.needsDashedBorder {
                    _borderColor = nil
                    _borderWidth = 0.0
                    if dashedBorderView == nil {
                        dashedBorderView = DashedBorderView()
                        addSubview(withConstraint: dashedBorderView!)
                        dashedBorderView?.sendToBack()
                    }
                    dashedBorderView?.configuration = newValue
                } else {
                    dashedBorderView?.removeFromSuperview()
                    dashedBorderView = nil
                    _borderColor = newValue.resolvedColor()
                    _borderWidth = newValue.width
                }
            }
        }
        
        var borderColorTransform: ColorTransformer? {
            get { getAssociatedValue("borderColorTransform") }
            set { setAssociatedValue(newValue, key: "borderColorTransform") }
        }
        
        var borderInsets: NSDirectionalEdgeInsets {
            get { getAssociatedValue("borderInsets") ?? .zero }
            set { setAssociatedValue(newValue, key: "borderInsets") }
        }
        
        var borderDash: BorderConfiguration.Dash {
            get { getAssociatedValue("borderDash") ?? .init() }
            set { setAssociatedValue(newValue, key: "borderDash") }
        }


        var _border: BorderConfiguration {
            get { getAssociatedValue("_border", initialValue: .init(color: realSelf._borderColor, width: realSelf._borderWidth)) }
            set { setAssociatedValue(newValue, key: "_border") }
        }
        
        /*
         /// The insets of the border.
         public var insets: NSDirectionalEdgeInsets = .init(0)
         
         /// The properties of the border dash.
         public var dash: Dash = Dash()
         */

        @objc var _borderWidth: CGFloat {
            get { (self as? NSBox)?.borderWidth ?? layer?.borderWidth ?? 0.0 }
            set {
                if let box = self as? NSBox {
                    box.borderWidth = newValue
                } else {
                    optionalLayer?.borderWidth = newValue
                }
            }
        }
        
        @objc var _borderColor: NSColor? {
            get { (self as? NSBox)?.borderColor ?? dynamicColors.border ?? layer?.borderColor?.nsUIColor }
            set {
                optionalLayer?.borderColor = newValue?.cgColor
                /*
                if let box = self as? NSBox {
                    box.borderColor = newValue ?? box.borderColor
                } else {
                    NSView.swizzleAnimationForKey()
                    realSelf.dynamicColors.background = newValue
                    var animatableColor = newValue?.resolvedColor(for: self)
                    if animatableColor == nil, isProxy() {
                        animatableColor = .clear
                    }
                    if optionalLayer?.borderColor?.isVisible == false || optionalLayer?.borderColor == nil {
                        optionalLayer?.borderColor = animatableColor?.withAlphaComponent(0.0).cgColor ?? .clear
                    }
                    optionalLayer?.borderColor = animatableColor?.cgColor
                }
                 */
            }
        }

        /**
         The outer shadow of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().outerShadow`.
         
         If the shadow is visible, `clipsToBounds` is set to `false`.
         
         The default value is `none()`, which results in a view with no outer shadow.
         */
        public var outerShadow: ShadowConfiguration {
            get {
                let view = realSelf
                return ShadowConfiguration(color: view.shadowColor, colorTransformer: view.shadowColorTransformer, opacity: view.shadowOpacity, radius: view.shadowRadius, offset: view.shadowOffset)
            }
            set {
                NSView.swizzleAnimationForKey()
                shadowColorTransformer = newValue.colorTransformer
                shadowOffset = newValue.offset
                shadowOpacity = newValue.opacity
                shadowRadius = newValue.radius
                shadowColor = newValue.resolvedColor()
                if !newValue.isInvisible {
                    clipsToBounds = false
                }
            }
        }
        
        var shadowColorTransformer: ColorTransformer? {
            get { getAssociatedValue("shadowColorTransformer") }
            set { setAssociatedValue(newValue, key: "shadowColorTransformer") }
        }

        @objc var shadowColor: NSColor? {
            get { dynamicColors.shadow ?? layer?.shadowColor?.nsUIColor }
            set {
                realSelf.dynamicColors.shadow = newValue
                var animatableColor = newValue?.resolvedColor(for: self)
                if animatableColor == nil, isProxy() {
                    animatableColor = .clear
                }
                if optionalLayer?.shadowColor?.isVisible == false || optionalLayer?.shadowColor == nil {
                    optionalLayer?.shadowColor = animatableColor?.withAlphaComponent(0.0).cgColor ?? .clear
                }
                optionalLayer?.shadowColor = animatableColor?.cgColor
            }
        }

        @objc var shadowOffset: CGPoint {
            get { (layer?.shadowOffset ?? .zero).point }
            set { optionalLayer?.shadowOffset = newValue.size }
        }

        @objc var shadowRadius: CGFloat {
            get { layer?.shadowRadius ?? .zero }
            set {  optionalLayer?.shadowRadius = newValue }
        }

        @objc var shadowOpacity: CGFloat {
            get { CGFloat(layer?.shadowOpacity ?? .zero) }
            set { optionalLayer?.shadowOpacity = Float(newValue) }
        }

        /**
         The shadow path of the view.
         
         Using this property turns the view into a layer-backed view. The value can be animated via `animator().shadowPath`.
         
         The default value is `nil`, which results in a view with no shadow path.
         */
        @objc public var shadowPath: NSBezierPath? {
            get { layer?.shadowPath?.bezierPath }
            set {
                NSView.swizzleAnimationForKey()
                optionalLayer?.shadowPath = newValue?.cgPath
            }
        }

        /**
         The inner shadow of the view.
         
         The default value is `none()`, which results in a view with no inner shadow.

         Using this property turns the view into a layer-backed view. The value can be animated via `animator().innerShadow`.
         */
      public var innerShadow: ShadowConfiguration {
            get { realSelf.innerShadowLayer?.configuration ?? .none() }
            set {
                NSView.swizzleAnimationForKey()
                if innerShadowLayer == nil {
                    let innerShadowLayer = InnerShadowLayer()
                    optionalLayer?.addSublayer(withConstraint: innerShadowLayer)
                    innerShadowLayer.sendToBack()
                }
                guard let innerShadowLayer = innerShadowLayer else { return }

                var newColor: NSUIColor? = newValue.resolvedColor()?.resolvedColor(for: self)
                if newColor == nil, isProxy() {
                    newColor = .clear
                }
                if innerShadowLayer.shadowColor?.isVisible == false || innerShadowLayer.shadowColor == nil {
                    innerShadowLayer.shadowColor = newColor?.withAlphaComponent(0.0).cgColor ?? .clear
                }
                innerShadowColor = newColor
                innerShadowOffset = newValue.offset
                innerShadowRadius = newValue.radius
                innerShadowOpacity = newValue.opacity
                innerShadowLayer.colorTransformer = newValue.colorTransformer
            }
        }

        @objc var innerShadowColor: NSColor? {
            get { innerShadowLayer?.shadowColor?.nsUIColor }
            set { innerShadowLayer?.shadowColor = newValue?.cgColor }
        }

        @objc var innerShadowOpacity: CGFloat {
            get { CGFloat(innerShadowLayer?.shadowOpacity ?? 0) }
            set { innerShadowLayer?.shadowOpacity = Float(newValue) }
        }

        @objc var innerShadowRadius: CGFloat {
            get { innerShadowLayer?.shadowRadius ?? 0 }
            set { innerShadowLayer?.shadowRadius = newValue }
        }

        @objc var innerShadowOffset: CGPoint {
            get { innerShadowLayer?.shadowOffset.point ?? .zero }
            set { innerShadowLayer?.shadowOffset = newValue.size }
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
            nextResponder as? NSViewController ?? (nextResponder as? NSView)?.parentController
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
        
        /**
         Sets the view’s tag that you use to identify the view within your app.
         
         - Parameter tag: The tag for the view, or `nil` to use the view's original tag.
         
         - Throws: An error if the tag couldn't be set.
         
         */
        public func setTag(_ tag: Int?) throws {
            if let tag = tag {
                do {
                    try replaceMethod(
                        #selector(getter: NSView.tag),
                        methodSignature: (@convention(c)  (AnyObject, Selector) -> (Int)).self,
                        hookSignature: (@convention(block)  (AnyObject) -> (Int)).self) { store in {
                            object in
                            return tag
                        }
                        }
                } catch {
                    throw error
                }
            } else {
                resetMethod(#selector(getter: NSView.tag))
            }
        }
        
        /**
         Inserts the subview at the specified index.

         - Parameters:
            - view: The view to insert.
            - index: The index of insertation.
         */
        @objc open func insertSubview(_ view: NSUIView, at index: Int) {
            guard index >= 0 else { return }
            guard index <= subviews.count else {
                addSubview(view)
                return
            }
            subviews.insert(view, at: index)
        }
        
        /// The current location of the mouse inside the view, regardless of the current event being handled or of any events pending.
        @objc open var mouseLocationOutsideOfEventStream: CGPoint {
            guard let mouseLocation = window?.mouseLocationOutsideOfEventStream else { return CGPoint(-1) }
            return convert(mouseLocation, from: nil)
        }
        
        static func swizzleAnimationForKey() {
            guard didSwizzleAnimationForKey == false else { return }
            didSwizzleAnimationForKey = true
            do {
                _ = try Swizzle(NSView.self) {
                  //  #selector(NSView.animation(forKey:)) <-> #selector(swizzled_Animation(forKey:))
                    #selector(NSView.defaultAnimation(forKey:)) <~> #selector(NSView.swizzledDefaultAnimation(forKey:))
                }
            } catch {
                Swift.debugPrint(error, (error as? LocalizedError)?.failureReason ?? "nil")
            }
        }
        
        @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
            if let animation = swizzledDefaultAnimation(forKey: key) {
                if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
                    return springAnimation
                }
                return animation
            } else if NSViewAnimationKeys.contains(key) {
                return swizzledDefaultAnimation(forKey: "frameOrigin")
            }
            return nil
        }

        static var didSwizzleAnimationForKey: Bool {
            get { getAssociatedValue("didSwizzleAnimationForKey", initialValue: false) }
            set { setAssociatedValue(newValue, key: "didSwizzleAnimationForKey") }
        }
        
        /*
        static var animatingViews: [Weak<NSView>] {
            get { getAssociatedValue("animatingViews", initialValue: []) }
            set { setAssociatedValue(newValue, key: "animatingViews") }
        }
        
        var currentAnimations: [NSAnimatablePropertyKey : Weak<CAAnimation>] {
            get { getAssociatedValue("currentAnimations", initialValue: [:]) }
            set { setAssociatedValue(newValue, key: "currentAnimations") }
        }
        
        public func stopAllAnimations(for context: NSAnimationContext) {
            let contextID = ObjectIdentifier(context)
            let animations = currentAnimations.filter({$0.value.object?.contextID == contextID})
            for animation in animations {
                animation.value.object
            }
        }
        
        @objc func swizzled_Animation(forKey key: NSAnimatablePropertyKey) -> Any? {
            if let animation = swizzled_Animation(forKey: key) as? CAAnimation {
                Swift.print("swizzled_Animation", animation)
                if !Self.animatingViews.contains(where: {$0.object == self }) {
                    Self.animatingViews.append(.init(self))
                }
                if NSAnimationContext.hasActiveGrouping {
                    animation.contextID = ObjectIdentifier(NSAnimationContext.current)
                }
                animation.onStop = { [weak self] in
                    guard let self = self else { return }
                    self.currentAnimations[key] = nil
                    if self.currentAnimations.isEmpty {
                        Self.animatingViews.removeFirst(where: {$0.object == self})
                    }
                }
                currentAnimations[key] = .init(animation)
                return animation
            }
            return nil
        }
         */
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
    private let NSViewAnimationKeys = ["transform", "transform3D", "anchorPoint", "cornerRadius", "roundedCorners", "_borderWidth", "_borderColor", "borderWidth", "borderColor", "mask", "inverseMask", "backgroundColorAnimatable", "center", "shadowColor", "shadowOffset", "shadowOpacity", "shadowRadius", "shadowPath", "innerShadowColor", "innerShadowOffset", "innerShadowOpacity", "innerShadowRadius", "fontSize", "gradientStartPoint", "gradientEndPoint", "gradientLocations", "gradientColors", "contentOffset", "contentOffsetFractional", "documentSize", "zPosition", "textColor", "selectionColor", "selectionTextColor", "placeholderTextColor"]

#endif
