//
//  Animator+View.swift
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

/// The property animator for views.
public typealias ViewAnimator = PropertyAnimator<NSUIView>

extension PropertyAnimator where Object: NSUIView {
    
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
    
    /// The size of the view. Compared to changing the size via frame, it keeps the view centered.
    public var size: CGSize {
        get { frame.size }
        set { frame.sizeCentered = newValue }
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
        get { object.optionalLayer?.animator.backgroundColor }
        set {
            object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object)
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
        get { object.optionalLayer?.animator.borderColor ?? .zero }
        set { object.optionalLayer?.animator.borderColor = newValue?.resolvedColor(for: object)
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
    
    /// The background gradient of the view.
    public var gradient: Gradient? {
        get {  self[\.gradient] }
        set {
            self[\.gradient] = newValue
            /*
            let newGradient = newValue ?? .zero

            var didSetupNewGradientLayer = false
            if newValue?.stops.isEmpty == false {
                didSetupNewGradientLayer = true
                self.object.wantsLayer = true
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
                Wave.nonAnimate {
                    self.object.backgroundColor = nil
                }
            }
            if didSetupNewGradientLayer == false {
                self.gradientLocations = AnimatableVector(newGradient.stops.compactMap({Double($0.location)}))
                self.gradientStartPoint = newGradient.startPoint.point
                self.gradientEndPoint = newGradient.endPoint.point
            }
            self.gradientColors = AnimatableDataArray<CGColor>(newGradient.stops.compactMap({$0.color.resolvedColor(for: object).cgColor}))
            self.object.optionalLayer?._gradientLayer?.type = newGradient.type.gradientLayerType
             */
        }
    }
    
    internal var gradientLocations: AnimatableVector {
        get { self[\.__gradientLocations] }
        set { self[\.__gradientLocations] = newValue }
    }
    
    internal var gradientStartPoint: CGPoint {
        get { self[\.gradientStartPoint] }
        set { self[\.gradientStartPoint] = newValue }
    }
    
    internal var gradientEndPoint: CGPoint {
        get { self[\.gradientStartPoint] }
        set { self[\.gradientStartPoint] = newValue }
    }
    
    internal var gradientColors: AnimatableDataArray<CGColor> {
        get { self[\.__gradientColors] }
        set { self[\.__gradientColors] = newValue }
    }
    
    /*
    internal var gradientColors: AnimatableArray<CGColor> {
        get { AnimatableArray<CGColor>(self[\._gradientColors]) }
        set { self[\.__gradientLocations] = newValue }
    }
     */
    
    /// The view's layer animator.
    public var layer: LayerAnimator {
        #if os(macOS)
        self.object.wantsLayer = true
        #endif
        return self.object.optionalLayer!.animator
    }
}

extension PropertyAnimator where Object: NSUITextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue?.resolvedColor(for: object) }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension PropertyAnimator where Object: NSUITextView {
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue?.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: NSUIScrollView {
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
        get {  self[\.zoomScaleCentered] }
        set {
            object.animationCenterPoint = nil
            self[\.zoomScaleCentered] = newValue }
    }
    #endif
}

internal extension NSUIView {
    var __gradientLocations: AnimatableVector {
        get { AnimatableVector.init(_gradientLocations.compactMap({ Double($0) })) }
        set { self._gradientLocations = newValue.elements.compactMap({ CGFloat($0) }) }
    }
    
    var __gradientColors: AnimatableDataArray<CGColor> {
        get { AnimatableDataArray<CGColor>(_gradientColors) }
        set { self._gradientColors = newValue.elements }
    }
    
    var _gradient: Gradient {
        get { self.gradient ?? .zero }
        set { self.gradient = newValue }
    }
}


#if os(macOS)
extension PropertyAnimator where Object: NSImageView {
    /// The tint color of the image.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue?.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: NSButton {
    /// The tint color of the button.
    public var contentTintColor: NSUIColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue?.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: ImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor? {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue?.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: NSControl {
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

extension PropertyAnimator where Object: GradientView {
    public var colors: [NSUIColor] {
        get { self.object.gradientLayer.animator.colors }
        set { self.object.gradientLayer.animator.colors = newValue }
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

extension PropertyAnimator where Object: NSStackView {
    /// The minimum spacing, in points, between adjacent views in the stack view.
    public var spacing: CGFloat {
        get {  self[\.spacing] }
        set { self[\.spacing] = newValue }
    }
    
    /// The geometric padding, in points, inside the stack view, surrounding its views.
    public var edgeInsets: NSEdgeInsets {
        get { self[\.edgeInsets] }
        set { self[\.edgeInsets] = newValue }
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

#elseif canImport(UIKit)
extension PropertyAnimator where Object: UIView {
    /// The default spacing to use when laying out content in a view,
    public var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { self[\.directionalLayoutMargins] }
        set { self[\.directionalLayoutMargins] = newValue }
    }
}

extension PropertyAnimator where Object: UIImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: UIButton {
    /// The tint color of the button.
    public var tintColor: NSUIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue.resolvedColor(for: object) }
    }
}

extension PropertyAnimator where Object: UILabel {
    /// The text color of the label.
    public var textColor: NSUIColor {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue.resolvedColor(for: object) }
    }
    
    /// The font size of the label.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension PropertyAnimator where Object: UIStackView {
    /// The distance in points between the adjacent edges of the stack view’s arranged views.
    public var spacing: CGFloat {
        get { self[\.spacing] }
        set { self[\.spacing] = newValue }
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
#endif
