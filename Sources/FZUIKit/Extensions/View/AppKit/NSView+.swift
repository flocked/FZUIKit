//
//  NSView+.swift
//
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

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
        - managed: A Boolean value indicating whether the scroll view should automatically manage the view.
        - bordered: A Boolean value indicating whether the scroll view is bordered.
        - drawsBackground: A Boolean value indicating whether the scroll view draws it's background.
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
     
     The default value is `nil`, which results in a view with no mask.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var mask: NSView? {
        get { (layer?.mask as? InverseMaskLayer)?.maskLayer?.parentView ?? layer?.mask?.parentView }
        set {
            newValue?.removeFromSuperview()
            optionalLayer?.mask = newValue?.optionalLayer
        }
    }

    /// The shape that is used for masking the view.
    public var maskShape: (any Shape)? {
        get { layer?.maskShape }
        set { optionalLayer?.maskShape = newValue }
    }
    
    /**
     The view whose inverse alpha channel is used to mask a view’s content.

     In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.
     
     The default value is `nil`, which results in a view with no inverse mask.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var inverseMask: NSView? {
        get { mask }
        set {
            newValue?.removeFromSuperview()
            optionalLayer?.inverseMask = newValue?.optionalLayer
        }
    }

    /**
     The center point of the view's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.

     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }

    /**
     The view’s position on the z axis.

     Changing the value of this property changes the front-to-back ordering of views onscreen. Higher values place the view visually closer to the viewer than views with lower values. This can affect the visibility of views whose frame rectangles overlap.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open var zPosition: CGFloat {
        get { layer?.zPosition ?? 0.0 }
        set { optionalLayer?.zPosition = newValue.clamped(to: -CGFloat(Int.max)...CGFloat(Int.max)) }
    }

    /**
     The transform to apply to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.). Transformations occur relative to the view's ``anchorPoint``.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.

     The default value is `CGAffineTransformIdentity`, which results in a view with no transformation.
     */
    @objc open var transform: CGAffineTransform {
        get { layer?.affineTransform() ?? CGAffineTransformIdentity }
        set { optionalLayer?.setAffineTransform(newValue) }
    }

    /**
     The three-dimensional transform to apply to the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator().transform3D`.

     The default value is `CATransform3DIdentity`, which results in a view with no transformation.
     */
    @objc open var transform3D: CATransform3D {
        get { layer?.transform ?? CATransform3DIdentity }
        set { optionalLayer?.transform = newValue }
    }

    /**
     The rotation of the view as euler angles in degrees.
     
     The default value is `0.0`, which results in a view with no rotation.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var rotation: Rotation {
        get { transform3D.eulerAnglesDegrees.rotation }
        set { transform3D.eulerAnglesDegrees = newValue.vector }
    }

    /**
     The rotation of the view as euler angles in radians.
     
     The default value is `0.0`, which results in a view with no rotation.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var rotationInRadians: Rotation {
        get { transform3D.eulerAngles.rotation }
        set { transform3D.eulerAngles = newValue.vector }
    }

    /**
     The scale transform of the view.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `none`, which results in a view displayed at it's original scale.
     */
    @objc open var scale: Scale {
        get { layer?.scale ?? .none }
        set { transform3D.scale = newValue.vector }
    }

    /**
     The perspective of the view's transform.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `zero`, which results in a view with no transformed perspective.
     */
    @objc open var perspective: Perspective {
        get { transform3D.perspective }
        set { transform3D.perspective = newValue }
    }


    /**
     The translation of the view's transform.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `zero`, which results in a view with no transformed translation.
     */
    @objc open var translation: Translation {
        get { transform3D.translation }
        set { transform3D.translation = newValue }
    }

    /**
     The shearing of the view's transform.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `zero`, which results in a view with no transformed shearing.
     */
    @objc open var skew: Skew {
        get { transform3D.skew }
        set { transform3D.skew = newValue }
    }

    /**
     The anchor point for the view’s position along the z axis.

     You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner.

     All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `zero`.
     */
    @objc open var anchorPoint: FractionalPoint {
        get {
            let anchorPoint = layer?.anchorPoint ?? .zero
            return FractionalPoint(anchorPoint.x, anchorPoint.y)
        }
        set { setAnchorPoint(CGPoint(newValue.x, newValue.y)) }
    }

    /**
     The anchor point for the view’s position along the z axis.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     The default value is `0.0`.
     */
    @objc open var anchorPointZ: CGFloat {
        get { layer?.anchorPointZ ?? .zero }
        set { optionalLayer?.anchorPointZ = newValue }
    }

    /**
     The corner radius of the view.
     
     The default value is `0.0`, which results in a view with no rounded corners.

     Setting the corner radius to value other than `0.0`, sets the ``cornerShape`` to `normal`.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var cornerRadius: CGFloat {
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

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var cornerCurve: CALayerCornerCurve {
        get { layer?.cornerCurve ?? .circular }
        set { optionalLayer?.cornerCurve = newValue }
    }

    /**
     The rounded corners of the view.

     Using this property turns the view into a layer-backed view.

     The default value is `all`, which results in a view with all corners rounded to the radius specified at ``cornerRadius``.
     */
    @objc open var roundedCorners: CACornerMask {
        get { layer?.maskedCorners.toAll ?? .all }
        set {
            optionalLayer?.maskedCorners = newValue
            dashedBorderView?.update()
            visualEffectBackgroundView?.roundedCorners = newValue
        }
    }

    /**
     The border of the view.
     
     The default value is `none`, which results in a view with no border.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var border: BorderConfiguration {
        get { layer?.configurations.border ?? .none }
        set {
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.border.color, \.configurations.border.isVisible)
            optionalLayer?.configurations.border = newValue
        }
    }
    
    /**
     The outer shadow of the view.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     
     If the shadow is visible, `clipsToBounds` is set to `false`.

     The default value is `none`, which results in a view with no outer shadow.
     */
    @objc open var outerShadow: ShadowConfiguration {
        get {
            let view = realSelf
            return view.layer?.configurations.shadow ?? .none
        }
        set {
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.shadow.color, \.configurations.shadow.isVisible)
            optionalLayer?.configurations.shadow = newValue
            if newValue.isVisible {
                clipsToBounds = false
            }
        }
    }

    /**
     The shadow path of the view.
     
     The default value is `nil`, which results in a view with no shadow path.

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var shadowPath: NSBezierPath? {
        get { layer?.shadowPath?.bezierPath }
        set { optionalLayer?.shadowPath = newValue?.cgPath }
    }

    /// The shape of the shadow.
    public var shadowShape: (any Shape)? {
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

     Changes to this property turns the view into a layer-backed view.
     
     The property can be animated by changing it inside a `NSView` animation block like ``AppKit/NSView/animate(withDuration:timingFunction:allowsImplicitAnimation:changes:completion:)``.
     */
    @objc open var innerShadow: ShadowConfiguration {
        get { realSelf.layer?.configurations.innerShadow ?? .none }
        set {
            var newValue = newValue
            newValue.color = animationColor(newValue.color, \.configurations.innerShadow.color, \.configurations.innerShadow.isVisible)
            optionalLayer?.configurations.innerShadow = newValue
        }
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
            } as @convention(block) ((NSView, Selector) -> Int, NSView, Selector) -> Int)
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
    @objc open var frameOnScreen: CGRect {
        get { convertToScreen(frame) }
        set { frame = convertFromScreen(newValue) }
    }

    /**
     The view’s frame rectangle, which defines its position and size in its window’s coordinate system.

     If the view isn't added to a window, it returns `zero`.
     */
    @objc open var frameInWindow: CGRect {
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
}

public extension NSView.AutoresizingMask {
    /// An empy autoresizing mask.
    static let none: NSView.AutoresizingMask = []
    /// An autoresizing mask with flexible size.
    static let flexibleSize: NSView.AutoresizingMask = [.height, .width]
    /// An autoresizing mask with flexible size and fixed margins.
    static let all: NSView.AutoresizingMask = [.height, .width, .minYMargin, .minXMargin, .maxXMargin, .maxYMargin]
}

extension NSViewProtocol {
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public var backgroundColor: NSColor? {
        get { layer?.configurations.backgroundColor }
        set { optionalLayer?.configurations.backgroundColor = newValue }
    }
    
    /**
     Sets the background color of the view.
     
     Using this property turns the view into a layer-backed view.
     */
    @discardableResult
    public func backgroundColor(_ color: NSUIColor?) -> Self {
        backgroundColor = color
        return self
    }
    
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
