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
    public var mask: NSView? {
        get { _mask }
        set {
            NSView.swizzleAnimationForKey()
            _mask = newValue
        }
    }

    @objc var _mask: NSView? {
        get { (layer?.mask as? InverseMaskLayer)?.maskLayer?.parentView ?? layer?.mask?.parentView }
        set {
            newValue?.removeFromSuperview()
            optionalLayer?.mask = newValue?.optionalLayer
        }
    }

    /// The shape that is used for masking the view.
    public var maskShape: PathShape? {
        get { layer?.maskShape }
        set { optionalLayer?.maskShape = newValue }
    }

    /**
     The view whose inverse alpha channel is used to mask a view’s content.

     In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.

     Changes to this property turns the view into a layer-backed view. The property can be animated by changing it via `animator().inverseMask`.

     The default value is `nil`, which results in a view with no inverse mask.
     */
    @objc public var inverseMask: NSView? {
        get { _inverseMask }
        set {
            NSView.swizzleAnimationForKey()
            _inverseMask = newValue
        }
    }

    @objc var _inverseMask: NSView? {
        get { mask }
        set {
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
        get { _center }
        set {
            NSView.swizzleAnimationForKey()
            _center = newValue
        }
    }

    @objc var _center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }

    /**
     The view’s position on the z axis.

     Changing the value of this property changes the front-to-back ordering of views onscreen. Higher values place the view visually closer to the viewer than views with lower values. This can affect the visibility of views whose frame rectangles overlap.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public var zPosition: CGFloat {
        get { _zPosition }
        set {
            NSView.swizzleAnimationForKey()
            _zPosition = newValue
        }
    }

    @objc var _zPosition: CGFloat {
        get { layer?.zPosition ?? 0.0 }
        set { optionalLayer?.zPosition = newValue.clamped(to: -CGFloat(Int.max)...CGFloat(Int.max)) }
    }

    /**
     The transform to apply to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.). Transformations occur relative to the view's ``anchorPoint``.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.

     The default value is `CGAffineTransformIdentity`, which results in a view with no transformation.
     */
    public var transform: CGAffineTransform {
        get { _transform }
        set {
            NSView.swizzleAnimationForKey()
            _transform = newValue
        }
    }

    @objc var _transform: CGAffineTransform {
        get { layer?.affineTransform() ?? CGAffineTransformIdentity }
        set { optionalLayer?.setAffineTransform(newValue) }
    }

    /**
     The three-dimensional transform to apply to the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().transform3D`.

     The default value is `CATransform3DIdentity`, which results in a view with no transformation.
     */
    public var transform3D: CATransform3D {
        get { _transform3D }
        set {
            NSView.swizzleAnimationForKey()
            _transform3D = newValue
        }
    }

    @objc var _transform3D: CATransform3D {
        get { layer?.transform ?? CATransform3DIdentity }
        set { optionalLayer?.transform = newValue }
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
     The anchor point for the view’s position along the z axis.



     You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner.

     All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().anchorPoint`.

     The default value is `zero`.
     */
    public var anchorPoint: FractionalPoint {
        get { _anchorPoint }
        set {
            NSView.swizzleAnimationForKey()
            _anchorPoint = newValue
        }
    }

    @objc var _anchorPoint: FractionalPoint {
        get {
            let anchorPoint = layer?.anchorPoint ?? .zero
            return FractionalPoint(anchorPoint.x, anchorPoint.y)
        }
        set { setAnchorPoint(CGPoint(newValue.x, newValue.y)) }
    }

    /**
     The anchor point for the view’s position along the z axis.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().anchorPointZ`.

     The default value is `0.0`.
     */
    public var anchorPointZ: CGFloat {
        get { _anchorPointZ }
        set {
            NSView.swizzleAnimationForKey()
            _anchorPointZ = newValue
        }
    }

    @objc var _anchorPointZ: CGFloat {
        get { layer?.anchorPointZ ?? .zero }
        set { optionalLayer?.anchorPointZ = newValue }
    }



    /**
     The corner radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().cornerRadius`.

     The default value is `0.0`, which results in a view with no rounded corners.

     Setting the corner radius to value other than `0.0`, sets the ``cornerShape`` to `normal`.
     */
    public var cornerRadius: CGFloat {
        get { __cornerRadius }
        set {
            NSView.swizzleAnimationForKey()
            __cornerRadius = newValue
        }
    }

    @objc var __cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set {
            let clipsToBounds = clipsToBounds
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
    public var cornerCurve: CALayerCornerCurve {
        get { _cornerCurve }
        set {
            NSView.swizzleAnimationForKey()
            _cornerCurve = newValue
        }
    }

    @objc var _cornerCurve: CALayerCornerCurve {
        get { layer?.cornerCurve ?? .circular }
        set { optionalLayer?.cornerCurve = newValue }
    }

    /**
     The rounded corners of the view.

     Using this property turns the view into a layer-backed view.

     The default value is `all`, which results in a view with all corners rounded to the value specified at ``cornerRadius``.
     */
    @objc public var roundedCorners: CACornerMask {
        get { layer?.maskedCorners.toAll ?? .all }
        set {
            optionalLayer?.maskedCorners = newValue
            dashedBorderView?.update()
            visualEffectBackgroundView?.roundedCorners = newValue
        }
    }

    /**
     The border of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().border`.

     The default value is `none`, which results in a view with no border.
     */
    public var border: BorderConfiguration {
        get { layer?.configurations.border ?? .none }
        set {
            NSView.swizzleAnimationForKey()
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.border.color, \.configurations.border.isVisible)
            optionalLayer?.configurations.border.colorTransformer = newValue.colorTransformer
            optionalLayer?.configurations.border.dash.lineCap = newValue.dash.lineCap
            optionalLayer?.configurations.border.dash.lineJoin = newValue.dash.lineJoin
            borderValues = newValue.values
        }
    }
    
    @objc fileprivate var borderValues: [Any] {
        get { layer?.configurations.border.values ?? [] }
        set { optionalLayer?.configurations.border.values = newValue }
    }
    
    /**
     The outer shadow of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().outerShadow`.

     If the shadow is visible, `clipsToBounds` is set to `false`.

     The default value is `none`, which results in a view with no outer shadow.
     */
    public var outerShadow: ShadowConfiguration {
        get {
            let view = realSelf
            return view.layer?.configurations.shadow ?? .none
        }
        set {
            NSView.swizzleAnimationForKey()
            optionalLayer?.configurations.shadow.colorTransformer = newValue.colorTransformer
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.shadow.color, \.configurations.shadow.isVisible)
            shadowValues = newValue.values
            if newValue.isVisible {
                clipsToBounds = false
            }
        }
    }
    
    @objc fileprivate var shadowValues: [Any] {
        get { layer?.configurations.shadow.values ?? [] }
        set { optionalLayer?.configurations.shadow.values = newValue }
    }

    /**
     The shadow path of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().shadowPath`.

     The default value is `nil`, which results in a view with no shadow path.
     */
    public var shadowPath: NSBezierPath? {
        get { _shadowPath }
        set {
            NSView.swizzleAnimationForKey()
            _shadowPath = newValue
        }
    }

    @objc var _shadowPath: NSBezierPath? {
        get { layer?.shadowPath?.bezierPath }
        set { optionalLayer?.shadowPath = newValue?.cgPath }
    }

    /// The shape of the shadow.
    public var shadowShape: PathShape? {
        get { layer?.shadowShape }
        set { optionalLayer?.shadowShape = newValue }
    }

    func setupShadowShapeView() {
        if shadowShape == nil || maskShape == nil || !outerShadow.isVisible {
            shadowShapeView?.removeFromSuperview()
            shadowShapeView = nil
        } else if shadowShapeView == nil {
            shadowShapeView = ShadowShapeView(for: self)
        }
        shadowShapeView?.outerShadow = outerShadow
        shadowShapeView?.shadowShape = shadowShape
    }

    var shadowShapeView: ShadowShapeView? {
        get { getAssociatedValue("shadowShapeView") }
        set { setAssociatedValue(newValue, key: "shadowShapeView") }
    }

    class ShadowShapeView: NSUIView {
        var viewObservation: KeyValueObserver<NSUIView>?
        weak var view: NSUIView?

        init(for view: NSUIView) {
            super.init(frame: .zero)
            self.view = view
            viewObservation = KeyValueObserver(view)
            viewObservation?.add(\.superview) { [weak self] old, new in
                guard let self = self else { return }
                self.removeFromSuperview()
                new?.addSubview(self, positioned: .below, relativeTo: self.view)
            }
            viewObservation?.add(\.isHidden) { [weak self] old, new in
                guard let self = self else { return }
                self.isHidden = new
            }
            viewObservation?.add(\.alphaValue) { [weak self] old, new in
                guard let self = self else { return }
                self.alphaValue = new
            }
            viewObservation?.add(\.frame) { [weak self] old, new in
                guard let self = self else { return }
                self.frame = new
            }
            frame = view.frame
            isHidden = view.isHidden
            alphaValue = view.alphaValue
            view.superview?.addSubview(self, positioned: .below, relativeTo: view)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    /**
     The inner shadow of the view.

     The default value is `none`, which results in a view with no inner shadow.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().innerShadow`.
     */
    public var innerShadow: ShadowConfiguration {
        get { realSelf.layer?.configurations.innerShadow ?? .none }
        set {
            NSView.swizzleAnimationForKey()
            optionalLayer?.configurations.innerShadow.colorTransformer = newValue.colorTransformer
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.innerShadow.color, \.configurations.innerShadow.isVisible)
            innerShadowValues = newValue.values
        }
    }
    
    @objc fileprivate var innerShadowValues: [Any] {
        get { layer?.configurations.innerShadow.values ?? [] }
        set { optionalLayer?.configurations.innerShadow.values = newValue }
    }
    
    func animationColor(_ color: NSUIColor?, _ keyPath: ReferenceWritableKeyPath<CALayer, CGColor?>) -> NSUIColor? {
        let resolved = color?.resolvedColor(for: self)
        if isProxy(), resolved == nil {
            return .clear
        } else if let layer = layer, let resolved = resolved {
            let color = layer[keyPath: keyPath]
            if color == nil || color?.isVisible == false {
                layer[keyPath: keyPath] = resolved.withAlphaComponent(0.0).cgColor
            }
        }
        return color
    }
    
    func animationColor(_ color: NSUIColor?, _ keyPath: ReferenceWritableKeyPath<CALayer, NSUIColor?>, _ validate: KeyPath<CALayer, Bool>) -> NSUIColor? {
        let resolved = color?.resolvedColor(for: self)
        if isProxy(), resolved == nil {
            return .clear
        } else if let layer = layer, let resolved = resolved, !layer[keyPath: validate] {
            layer[keyPath: keyPath] = resolved.withAlphaComponent(0.0)
        }
        return color
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
     A Boolean value indicating whether the view is effectively visible within its window.

     This property does not check if the window itself is visible or onscreen. It only determines whether the view is visible within the window.

     The visibility determination considers the following factors:
     - The view must be associated with a `window`.
     - The view's `isHidden` must be `false`.
     - The view's `alphaValue` must be larger than `0.0`.
     - The view's `visibleRect` must not be empty.
     - If the view has a layer, the layer's `isHidden` must be `false` and `opacity` must be larger than `0.0`.
     - All of the view's superviews in the hierarchy must also be effectively visible.
     */
    @objc open var isVisible: Bool {
        window != nil && isVisibleInHierarchy
    }

    private var isVisibleInHierarchy: Bool {
        !isHidden && alphaValue > 0.0 && !bounds.isEmpty && layer?.isVisible ?? true && isVisibleInSuperview
    }

    private var isVisibleInSuperview: Bool {
        guard let superview = superview else { return true }
        return !frame.intersection(superview.bounds).isEmpty && superview.isVisibleInHierarchy
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

    /// Sets the text for the view’s tooltip.
    @discardableResult
    @objc open func toolTip(_ toolTip: String?) -> Self {
        self.toolTip = toolTip
        return self
    }

    /**
     Sets the view’s tag that you use to identify the view within your app.

     - Parameter tag: The tag for the view, or `nil` to use the view's original tag.
     */
    @discardableResult
    public func tag(_ tag: Int?) -> Self {
        revertHooks(for: #selector(getter: NSView.tag))
        guard let tag = tag else { return self }
        do {
            try hook(#selector(getter: NSView.tag), closure: { original, object, sel in
                return tag
            } as @convention(block) (
                (NSView, Selector) -> Int,
                NSView, Selector) -> Int)
        } catch {
            Swift.print(error)
        }
        return self
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

    /**
     The current location of the mouse inside the view, regardless of the current event being handled or of any events pending.

     It the view doesn't have a `window` associated,  `CGPoint(x: -1, y: -1)` is returned.
     */
    @objc open var mouseLocationOutsideOfEventStream: CGPoint {
        guard let mouseLocation = window?.mouseLocationOutsideOfEventStream else { return CGPoint(-1) }
        return convert(mouseLocation, from: nil)
    }

    /// Converts a point from the screen coordinate system to the view’s coordinate system.
    public func convertFromScreen(_ screenLocation: CGPoint) -> CGPoint {
        guard let window = window else { return screenLocation }
        return convertFromWindow(window.convertPoint(fromScreen: screenLocation))
    }

    /// Converts a point to the screen coordinate system from the view’s coordinate system.
    public func convertToScreen(_ location: CGPoint) -> CGPoint {
        guard let window = window else { return location }
        return window.convertPoint(toScreen: convertToWindow(location))
    }

    /// Converts a rectangle from the screen coordinate system to the view’s coordinate system.
    public func convertFromScreen(_ screenFrame: CGRect) -> CGRect {
        guard let window = window else { return screenFrame }
        return convertFromWindow(window.convertFromScreen(screenFrame))
    }

    /// Converts a rectangle to the screen coordinate system from the view’s coordinate system.
    public func convertToScreen(_ frame: CGRect) -> CGRect {
        guard let window = window else { return frame }
        return window.convertToScreen(convertToWindow(frame))
    }

    /// The view’s frame rectangle, which defines its position and size in its screen’s coordinate system.
    public var frameOnScreen: CGRect {
        get { _frameOnScreen }
        set {
            NSView.swizzleAnimationForKey()
            _frameOnScreen = newValue
        }
    }

    @objc var _frameOnScreen: CGRect {
        get { convertToScreen(frame) }
        set { frame = convertFromScreen(newValue) }
    }

    /**
     The view’s frame rectangle, which defines its position and size in its window’s coordinate system.

     If the view isn't added to a window, it returns `zero`.
     */
    public var frameInWindow: CGRect {
        get { _frameInWindow }
        set {
            NSView.swizzleAnimationForKey()
            _frameInWindow = newValue
        }
    }

    @objc var _frameInWindow: CGRect {
        get { convertToWindow(frame) }
        set { frame = convertFromWindow(newValue) }
    }

    /// Converts a point from the window coordinate system to the view’s coordinate system.
    public func convertFromWindow(_ windowLocation: CGPoint) -> CGPoint {
        convert(windowLocation, from: nil)
    }

    /// Converts a point to the window coordinate system from the view’s coordinate system.
    public func convertToWindow(_ location: CGPoint) -> CGPoint {
        convert(location, to: nil)
    }

    /// Converts a rectangle from the window coordinate system to the view’s coordinate system.
    public func convertFromWindow(_ windowFrame: CGRect) -> CGRect {
        convert(windowFrame, from: nil)
    }

    /// Converts a rectangle to the window coordinate system from the view’s coordinate system.
    public func convertToWindow(_ frame: CGRect) -> CGRect {
        convert(frame, to: nil)
    }

    static func swizzleAnimationForKey() {
        guard !didSwizzleAnimationForKey else { return }
        didSwizzleAnimationForKey = true
        do {
            _ = try Swizzle(NSView.self) {
                #selector(NSView.defaultAnimation(forKey:)) <~> #selector(NSView.swizzledDefaultAnimation(forKey:))
                #selector(NSView.animation(forKey:)) <-> #selector(NSView.swizzledAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error, (error as? LocalizedError)?.failureReason ?? "nil")
        }
    }

    @objc private class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
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
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAAnimation)?.delegate = animationDelegate
        return animation
    }

    private static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue("didSwizzleAnimationForKey") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleAnimationForKey") }
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

/// The `NSView` properties keys that can be animated.
fileprivate let NSViewAnimationKeys: Set<String> = ["_anchorPoint", "_anchorPointZ", "_animatableValues", "_center", "_contentOffset", "_contentOffsetFractional", "_cornerRadius", "_documentSize", "_fontSize", "_gradient", "_inverseMask", "_mask", "_placeholderTextColor", "_roundedCorners", "_screenFrame", "_selectionColor", "_selectionTextColor", "_shadowPath", "_transform", "_transform3D", "_windowFrame", "_zPosition", "__cornerRadius", "backgroundColor", "backgroundColorAnimatable", "bezelColor", "borderColor", "borderValues", "borderWidth", "contentTintColor", "cornerRadius", "fillColor", "innerShadowValues", "shadowColor", "shadowValues", "textColor"]

fileprivate extension CALayer {
    var isVisible: Bool {
        !isHidden && opacity > 0.0
    }
}

extension NSViewProtocol {
    /// Scrolls the enclosing scroll view to the top.
    public func scrollToTop() {
        enclosingScrollView?.animator(isProxy()).scrollToTop()
    }

    /// Scrolls the enclosing scroll view to the bottom.
    public func scrollToBottom() {
        enclosingScrollView?.animator(isProxy()).scrollToBottom()
    }

    /// Scrolls the enclosing scroll view to the left.
    public func scrollToLeft() {
        enclosingScrollView?.animator(isProxy()).scrollToLeft()
    }

    /// Scrolls the enclosing scroll view to the right.
    public func scrollToRight() {
        enclosingScrollView?.animator(isProxy()).scrollToRight()
    }
}

fileprivate extension BorderConfiguration {
    var values: [Any] {
        get { [width, color as Any, dash.phase, dash.pattern, insets.top, insets.leading, insets.bottom, insets.trailing] }
        set {
            width = newValue[0] as! CGFloat
            color = newValue[1] as? NSColor
            dash.phase = newValue[2] as! CGFloat
            dash.pattern = newValue[3] as! [CGFloat]
            insets = .init(top: newValue[4] as! CGFloat, leading: newValue[5] as! CGFloat, bottom: newValue[6] as! CGFloat, trailing: newValue[7] as! CGFloat)
        }
    }
}

fileprivate extension ShadowConfiguration {
    var values: [Any] {
        get { [offset.x, offset.y, opacity, radius, color as Any] }
        set {
            offset = .init(newValue[0] as! CGFloat, newValue[1] as! CGFloat)
            opacity = newValue[2] as! CGFloat
            radius = newValue[3] as! CGFloat
            color = newValue[4] as? NSColor
        }
    }
}

extension NSView {
    func attach(to view: NSView, positionedBelow: Bool = true, includingAlpha: Bool = true) {
        viewAttachment = ViewAttachment(for: self, target: view, below: positionedBelow, includeAloha: includingAlpha)
    }
    
    func dettachFromView() {
        viewAttachment = nil
    }
    
    fileprivate var viewAttachment: ViewAttachment? {
        get { getAssociatedValue("viewAttachment") }
        set { setAssociatedValue(newValue, key: "viewAttachment") }
    }
    
    fileprivate class ViewAttachment {
        let viewObservation: KeyValueObserver<NSView>
        var subviewsObservation: KeyValueObservation?
        weak var view: NSView?
        weak var target: NSView?
        let mode: NSWindow.OrderingMode
        
        func setupSubviewsObservation() {
            if let superview = view?.superview {
                subviewsObservation = superview.observeChanges(for: \.subviews) { [weak self] old, new in
                    guard let self = self else { return }
                    self.setupPosition()
                }
            } else {
                subviewsObservation = nil
            }
            setupPosition()
        }
        
        func setupPosition() {
            if let view = view, let superview = view.superview, let target = target, superview.subviews.contains(target) {
                superview.addSubview(view, positioned: mode, relativeTo: target)
            } else {
                view?.removeFromSuperview()
            }
        }
        
        init(for view: NSView, target: NSView, below: Bool = true, includeAloha: Bool = true) {
            self.view = view
            self.target = target
            self.mode = below ? .below : .above
            self.viewObservation = KeyValueObserver(target)
            view.frame = target.frame
            view.isHidden = target.isHidden
            
            setupSubviewsObservation()
            viewObservation.add(\.superview) { [weak self] old, new in
                guard let self = self else { return }
                self.setupSubviewsObservation()
            }
            viewObservation.add(\.isHidden) { [weak self] old, new in
                guard let self = self else { return }
                self.view?.isHidden = new
            }
            viewObservation.add(\.frame) { [weak self] old, new in
                guard let self = self else { return }
                self.view?.frame = new
            }
            guard includeAloha else { return }
            view.alphaValue = target.alphaValue
            viewObservation.add(\.alphaValue) { [weak self] old, new in
                guard let self = self else { return }
                self.view?.alphaValue = new
            }
        }
    }
}

#endif
