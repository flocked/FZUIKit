//
//  ViewAnimator+View.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension NSUIView: AnimatablePropertyProvider { }

extension AnimatablePropertyProvider where Self: NSUIView {
    /// Provides animatable properties of the view.
    public var animator: ViewAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: ViewAnimator(self)) }
    }
}

/// Provides animatable properties of a view.
public class ViewAnimator<View: NSUIView>: PropertyAnimator<View> {
    /// The bounds of the view.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }
    
    /// The size of the view. Changing the value keeps the view centered. To change the size without centering use the view's frame size.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get { object.optionalLayer?.animator.backgroundColor?.nsUIColor }
        set {
            object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object).cgColor
            #if os(macOS)
            object.dynamicColors.background = newValue
            #endif
        }
    }
    
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { object.optionalLayer?.animator.opacity ?? 1.0 }
        set { object.optionalLayer?.animator.opacity = newValue }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { object.optionalLayer?.animator.cornerRadius ?? 0.0 }
        set { object.optionalLayer?.animator.cornerRadius = newValue }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { object.optionalLayer?.animator.borderColor?.nsUIColor  }
        set { object.optionalLayer?.animator.borderColor = newValue?.resolvedColor(for: object).cgColor
            #if os(macOS)
            object.dynamicColors.border = newValue
            #endif
        }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { object.optionalLayer?.animator.borderWidth ?? 0.0 }
        set { object.optionalLayer?.animator.borderWidth = newValue }
    }
    
    /// The shadow of the view.
    public var shadow: ContentConfiguration.Shadow {
        get { object.optionalLayer?.animator.shadow ?? .none() }
        set {
            #if os(macOS)
            object.dynamicColors.shadow = newValue._resolvedColor
            #endif
            var newValue = newValue
            newValue.color = newValue._resolvedColor?.resolvedColor(for: object)
            object.optionalLayer?.animator.shadow = newValue }
    }
    
    /// The inner shadow of the view.
    public var innerShadow: ContentConfiguration.InnerShadow {
        get { object.optionalLayer?.animator.innerShadow ?? .none() }
        set {
            #if os(macOS)
            object.dynamicColors.innerShadow = newValue._resolvedColor
            #endif
            var newValue = newValue
            newValue.color = newValue._resolvedColor?.resolvedColor(for: object)
            object.optionalLayer?.animator.innerShadow = newValue
        }
    }
    
    /// The three-dimensional transform of the view.
    public var transform3D: CATransform3D {
        get { object.optionalLayer?.transform ?? CATransform3DIdentity }
        set { object.optionalLayer?.transform = newValue }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { object.optionalLayer?.animator.scale ?? CGPoint(1, 1) }
        set { object.optionalLayer?.animator.scale = newValue  }
    }
    
    /// The rotation transform of the view.
    public var rotation: CGQuaternion {
        get { object.optionalLayer?.animator.rotation ?? .zero }
        set { object.optionalLayer?.animator.rotation = newValue }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { object.optionalLayer?.animator.translation ?? .zero }
        set { object.optionalLayer?.animator.translation = newValue }
    }
    
    /// The view's layer animator.
    public var layer: PropertyAnimator<CALayer> {
        #if os(macOS)
        self.object.wantsLayer = true
        #endif
        return self.object.optionalLayer!.animator
    }
    
    /// The property animators for the view's subviews.
    public var subviews: [ViewAnimator<NSUIView>] {
        object.subviews.compactMap({ $0.animator })
    }
    
    /// The property animator for the view's superview.
    public var superview: ViewAnimator<NSUIView>? {
        object.superview?.animator
    }
    
    /// The property animator for the view's mask.
    public var mask: ViewAnimator<NSUIView>? {
        object.mask?.animator
    }
    
    /**
     Adds the specified view animated. The subview's alpha value gets animated to `1.0`.
     
     - Note: The animation only occurs if the view's subviews doesn't contain the specified subview.
     */
    public func addSubview(_ view: NSUIView) {
        guard view.superview != object else { return }
        view.alpha = 0.0
        Anima.nonAnimate {
            view.animator.alpha = 0.0
        }
        object.addSubview(view)
        view.animator.alpha = 1.0
    }
    
    /**
     Inserts the view at the specified index animated. The subview's alpha value gets animated to `1.0`.
     
     - Note: The animation only occurs if the view's subviews doesn't contain the specified subview.
     */
    public func insertSubview(_ view: NSUIView, at index: Int) {
        guard view.superview != object else { return }
        view.alpha = 0.0
        Anima.nonAnimate {
            view.animator.alpha = 0.0
        }
        object.insertSubview(view, at: index)
        view.animator.alpha = 1.0
    }
    
    /**
     Inserts the view above another view animated. The subview's alpha value gets animated to `1.0`.
     
     - Note: The animation only occurs if the view's subviews doesn't contain the specified subview.
     */
    public func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView) {
        guard view.superview != object, object.subviews.contains(siblingSubview) else { return }
        view.alpha = 0.0
        Anima.nonAnimate {
            view.animator.alpha = 0.0
        }
        object.insertSubview(view, aboveSubview: siblingSubview)
        view.animator.alpha = 1.0
    }
    
    /**
     Inserts the view below another view animated. The subview's alpha value gets animated to `1.0`.
     
     - Note: The animation only occurs if the view's subviews doesn't contain the specified subview.
     */
    public func insertSubview(_ view: NSUIView, belowSubview siblingSubview: NSUIView) {
        guard view.superview != object, object.subviews.contains(siblingSubview) else { return }
        view.alpha = 0.0
        Anima.nonAnimate {
            view.animator.alpha = 0.0
        }
        object.insertSubview(view, belowSubview: siblingSubview)
        view.animator.alpha = 1.0
    }
    
    /**
     Removes the view from it's superview animated. The view's alpha value gets animated to `0.0` and on completion removed from it's superview.
     
     - Note: The animation only occurs if the view's superview isn't `nil`.
     */
    public func removeFromSuperview() {
        guard object.superview != nil else { return }
        guard object.alpha != 0.0 else {
            object.removeFromSuperview()
            return
        }
        setValue(0.0, for: \.alpha, completion: { [weak self] in
            guard let self = self else { return }
            self.object.removeFromSuperview()
        })
    }
}

extension ViewAnimator where View: NSUITextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension ViewAnimator where View: NSUITextView {
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

extension ViewAnimator where View: NSUIScrollView {
    /// The point at which the origin of the content view is offset from the origin of the scroll view.
    public var contentOffset: CGPoint {
        get { self[\.contentOffset] }
        set { self[\.contentOffset] = newValue }
    }
    
    #if os(macOS)
    /// The amount by which the content is currently scaled.
    public var magnification: CGFloat {
        get {  self[\.magnificationCentered] }
        set {
            object.animationCenterPoint = nil
            self[\.magnificationCentered] = newValue }
    }
    
    /// Magnify the content by the given amount and center the result on the given point.
    public func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint) {
        object.animationCenterPoint = point
        self[\.magnificationCentered] = magnification
    }
    #elseif canImport(UIKit)
    /// The scale factor applied to the scroll view’s content.
    public var zoomScale: CGFloat {
        get { self[\.zoomScaleCentered] }
        set {
            object.animationCenterPoint = nil
            self[\.zoomScaleCentered] = newValue }
    }
    
    /// The size of the content view.
    public var contentSize: CGSize {
        get { self[\.contentSize] }
        set { self[\.contentSize] = newValue }
    }
    
    /// The custom distance that the content view is inset from the safe area or scroll view edges.
    public var contentInset: UIEdgeInsets {
        get { self[\.contentInset] }
        set { self[\.contentInset] = newValue }
    }
    #endif
}

internal extension NSUIView {
    var _gradient: Gradient {
        get { self.gradient ?? .init(stops: []) }
        set { self.gradient = newValue }
    }
}

extension ViewAnimator where View: NSUIStackView {
    /// The minimum spacing, in points, between adjacent views in the stack view.
    public var spacing: CGFloat {
        get {  self[\.spacing] }
        set { self[\.spacing] = newValue }
    }
    
    #if os(macOS)
    /// The geometric padding, in points, inside the stack view, surrounding its views.
    public var edgeInsets: NSEdgeInsets {
        get { self[\.edgeInsets] }
        set { self[\.edgeInsets] = newValue }
    }
    #endif
}

#if os(macOS)
extension ViewAnimator where View: NSImageView {
    /// The tint color of the image.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}

extension ViewAnimator where View: NSButton {
    /// The tint color of the button.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}

extension ViewAnimator where View: ImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor? {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension ViewAnimator where View: NSControl {
    /// The double value of the control.
    public var doubleValue: Double {
        get { self[\.doubleValue] }
        set { self[\.doubleValue] = newValue }
    }
    
    /// The float value of the control.
    public var floatValue: Float {
        get { self[\.floatValue] }
        set { self[\.floatValue] = newValue }
    }
}

extension ViewAnimator where View: GradientView {
    public var colors: [NSUIColor] {
        get { self.object.gradientLayer.animator.colors.compactMap({$0.nsUIColor}) }
        set { self.object.gradientLayer.animator.colors = newValue.compactMap({$0.resolvedColor(for: object).cgColor}) }
    }
    
    public var locations: [CGFloat] {
        get { self.object.gradientLayer.animator.locations }
        set { self.object.gradientLayer.animator.locations = newValue }
    }
    
    public var startPoint: CGPoint {
        get { self.object.gradientLayer.animator.startPoint }
        set { self.object.gradientLayer.animator.startPoint = newValue }
    }
    
    public var endPoint: CGPoint {
        get { self.object.gradientLayer.animator.endPoint }
        set { self.object.gradientLayer.animator.endPoint = newValue }
    }
}

extension ViewAnimator where View: NSColorWell {
    /// The selected color for the color well.
    public var color: NSColor {
        get { self[\.color] }
        set { self[\.color] = newValue }
    }
}

extension ViewAnimator where View: NSBox {
    /// The color of the box’s background when the box is a custom box with a simple line border.
    public var fillColor: NSColor {
        get { self[\.fillColor] }
        set { self[\.fillColor] = newValue }
    }
    
    /// The distances between the border and the content view.
    public var contentViewMargins: CGSize {
        get { self[\.contentViewMargins] }
        set { self[\.contentViewMargins] = newValue }
    }
    
    /// The font size of the title.
    public var titleFontSize: CGFloat {
        get {  self[\.titleFontSize] }
        set { self[\.titleFontSize] = newValue }
    }
}

extension ViewAnimator where View: NSProgressIndicator {
    /// The current value of the progress indicator.
    public var doubleValue: Double {
        get {  self[\.doubleValue] }
        set { self[\.doubleValue] = newValue }
    }
    
    /// The minimum value for the progress indicator.
    public var minValue: Double {
        get {  self[\.minValue] }
        set { self[\.minValue] = newValue }
    }
    
    /// The maximum value for the progress indicator.
    public var maxValue: Double {
        get {  self[\.maxValue] }
        set { self[\.maxValue] = newValue }
    }
}

internal extension NSView {
    func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }
    
    func insertSubview(_ view: NSUIView, belowSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }
}

internal extension NSUIScrollView {
    var magnificationCentered: CGFloat {
        get { magnification }
        set {
            if let animationCenterPoint = animationCenterPoint {
                self.setMagnification(newValue, centeredAt: animationCenterPoint)
            } else {
                magnification = newValue
            }
        }
    }
    
    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue(key: "animationCenterPoint", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "animationCenterPoint", object: self) }
    }
}

internal extension NSBox {
    var titleFontSize: CGFloat {
        get { titleFont.pointSize }
        set { titleFont = titleFont.withSize(newValue) }
    }
}

#elseif canImport(UIKit)
extension ViewAnimator where View: UIView {
    /// The default spacing to use when laying out content in a view,
    public var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { self[\.directionalLayoutMargins] }
        set { self[\.directionalLayoutMargins] = newValue }
    }
}

internal extension ViewAnimator where View: UIView {
    var preventsUserInteractions: Bool {
        get { getAssociatedValue(key: "preventsUserInteractions", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "preventsUserInteractions", object: self) }
    }
    
    /// Collects the animations that are configurated to prevent user interactions. If the set isn't empty the user interactions get disabled. When all animations finishes and the collection is empty, user interaction gets enabled again.
    var preventingUserInteractionAnimations: Set<UUID> {
        get { getAssociatedValue(key: "preventingAnimations", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "preventingAnimations", object: self)
            if !preventingUserInteractionAnimations.isEmpty, object.isUserInteractionEnabled, !preventsUserInteractions {
                object.isUserInteractionEnabled = false
                preventsUserInteractions = true
            } else if preventingUserInteractionAnimations.isEmpty, preventsUserInteractions {
                object.isUserInteractionEnabled = true
                preventsUserInteractions = false
            }
        }
    }
}

extension ViewAnimator where View: UIImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension ViewAnimator where View: UIButton {
    /// The tint color of the button.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension ViewAnimator where View: UILabel {
    /// The text color of the label.
    public var textColor: NSUIColor {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the label.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

#if os(iOS)
extension ViewAnimator where View: UIColorWell {
    /// The selected color in the color picker.
    public var selectedColor: NSUIColor? {
        get { self[\.selectedColor] }
        set { self[\.selectedColor] = newValue }
    }
}
#endif

extension ViewAnimator where View: UIProgressView {
    /// The current progress of the progress view.
    public var progress: Float {
        get { self[\.progress] }
        set { self[\.progress] = newValue }
    }
}

internal extension UIScrollView {
    var zoomScaleCentered: CGFloat {
        get { zoomScale }
        set {
            if let animationCenterPoint = animationCenterPoint {
                self.setZoomScale(newValue, centeredAt: animationCenterPoint)
            } else {
                zoomScale = newValue
            }
        }
    }
    
    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue(key: "animationCenterPoint", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "animationCenterPoint", object: self) }
    }
    
    func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, self.minimumZoomScale)
        var translatedZoomPoint : CGPoint = .zero
        translatedZoomPoint.x = point.x + contentOffset.x
        translatedZoomPoint.y = point.y + contentOffset.y
        
        let zoomFactor = 1.0 / zoomScale
        
        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor
        
        var destinationRect : CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5
        
        zoom(to: destinationRect, animated: false)
    }
}
#endif

extension ViewAnimator {
    /**
     The current animation for the property at the specified keypath.
     
     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> AnimationProviding? {
        if let layerAnimation = layerAnimation(for: keyPath) {
            return layerAnimation
        }
        _ = self[keyPath: keyPath]
        return animations[lastAnimationKey]
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
     
     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> Value? {
        return (animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
    
    internal func layerAnimation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> (any ConfigurableAnimationProviding)? {
        let layerKeys = object.optionalLayer?.animator.animations.keys.collect() ?? []
        Swift.print(keyPath.stringValue, keyPath == \.backgroundColor, layerKeys.sorted())
  
        switch keyPath {
        case \.backgroundColor: return object.optionalLayer?.animator.animation(for: \.backgroundColor)
        case \.borderColor: return object.optionalLayer?.animator.animation(for: \.borderColor)
        case \.borderWidth: return object.optionalLayer?.animator.animation(for: \.borderWidth)
        case \.shadow: return object.optionalLayer?.animator.animation(for: \.shadow)
        case \.innerShadow: return object.optionalLayer?.animator.animation(for: \.innerShadow)
        case \.alpha: return object.optionalLayer?.animator.animation(for: \.opacity)
        case \.cornerRadius: return object.optionalLayer?.animator.animation(for: \.cornerRadius)
        case \.transform3D: return object.optionalLayer?.animator.animation(for: \.transform)
        case \.scale: return object.optionalLayer?.animator.animation(for: \.scale)
        case \.translation: return object.optionalLayer?.animator.animation(for: \.translation)
        case \.rotation: return object.optionalLayer?.animator.animation(for: \.rotation)
        default: return nil
        }
    }
}
#endif

/*
/// The background gradient of the view.
public var gradient: Gradient? {
    get {
        guard let gradientLayer = object.optionalLayer?._gradientLayer else { return nil }
        let colors = self.gradientColors.compactMap({$0.nsUIColor})
        let locations = self.gradientLocations
        let stops = zip(colors, locations).compactMap({ Gradient.Stop(color: $0.0, location: $0.1) })
        let startPoint = Gradient.Point(gradientStartPoint)
        let endPoint = Gradient.Point(gradientEndPoint)
        return Gradient(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .init(gradientLayer.type))
       }
    set {
        let newGradient = newValue ?? .init(stops: [])

        var didSetupNewGradientLayer = false
        if newValue?.stops.isEmpty == false {
            didSetupNewGradientLayer = true
            #if os(macOS)
            self.object.wantsLayer = true
            #endif
            if self.object.optionalLayer?._gradientLayer == nil {
                let gradientLayer = GradientLayer()
                self.object.optionalLayer?.addSublayer(withConstraint: gradientLayer)
                gradientLayer.sendToBack()
                gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                
                gradientLayer.locations = newGradient.stops.compactMap({NSNumber($0.location)})
                gradientLayer.startPoint = newGradient.startPoint.point
                gradientLayer.endPoint = newGradient.endPoint.point
                gradientLayer.colors = newGradient.stops.compactMap({$0.color.resolvedColor(for: object).withAlphaComponent(0.0).cgColor})
            }
            Anima.nonAnimate {
                self.object.backgroundColor = nil
            }
        }
        if didSetupNewGradientLayer == false {
            self.gradientLocations = newGradient.stops.compactMap({$0.location})
            self.gradientStartPoint = newGradient.startPoint.point
            self.gradientEndPoint = newGradient.endPoint.point
        }
        
        self.gradientColors = newGradient.stops.compactMap({$0.color.cgColor})
        self.object.optionalLayer?._gradientLayer?.type = newGradient.type.gradientLayerType
    }
}

internal var gradientLocations: [CGFloat] {
    get { self[\._gradientLocations] }
    set { self[\._gradientLocations] = newValue }
}

internal var gradientStartPoint: CGPoint {
    get { self[\.gradientStartPoint] }
    set { self[\.gradientStartPoint] = newValue }
}

internal var gradientEndPoint: CGPoint {
    get { self[\.gradientStartPoint] }
    set { self[\.gradientStartPoint] = newValue }
}

internal var gradientColors: [CGColor] {
    get { self[\._gradientColors] }
    set { self[\._gradientColors] = newValue }
}
*/

/*
 if var animation = object.optionalLayer?.animator.setValue(newValue?.resolvedColor(for: object).cgColor, for: \.backgroundColor, completion: { [weak self] in
     guard let self = self else { return }
     self.animations[self.key(for: \.backgroundColor)] = nil }) {
 }
 
 if var animation = object.optionalLayer?.animator.setValue(Float(newValue), for: \.opacity, completion: { [weak self] in
     guard let self = self else { return }
     self.animations[self.key(for: \.alpha)] = nil }) {
 }
 */


/*
 internal func setLayerValue<Value: AnimatableProperty>(_ value: Value, for keyPath: WritableKeyPath<CALayer, Value>) {
     if let animation = self.object.optionalLayer?.animator.setValue(value, for: keyPath, completion: { [weak self] in
         guard let self = self else { return }
         self.animations[keyPath.stringValue] = nil
         
     }) {
         self.animations[keyPath.stringValue] = animation
     }
 }
 
 internal func setLayerValue<Value: AnimatableProperty>(_ value: Value, for keyPath: WritableKeyPath<CALayer, Value?>) {
     if let animation = self.object.optionalLayer?.animator.setValue(value, for: keyPath, completion: { [weak self] in
         guard let self = self else { return }
         self.animations[keyPath.stringValue] = nil
         
     }) {
         self.animations[keyPath.stringValue] = animation
     }
 }
 */