//
//  UIView+.swift
//
//
//  Created by Florian Zand on 12.08.22.
//

#if os(iOS) || os(tvOS)
    import UIKit

    extension UIView {
        /// The parent view controller managing the view.
        public var parentController: UIViewController? {
            next as? UIViewController ?? (next as? UIView)?.parentController
        }

        /**
         The rotation of the view as euler angles in degrees.

         Changes to this property can be animated. The default value is is `zero`, which results in a view with no rotation.
         */
        public var rotation: Rotation {
            get { self.transform3D.eulerAnglesDegrees.rotation }
            set { self.transform3D.eulerAnglesDegrees = newValue.vector }
        }

        /**
         The rotation of the view as euler angles in radians.

         Changes to this property can be animated. The default value is is `zero`, which results in a view with no rotation.
         */
        public var rotationInRadians: Rotation {
            get { self.transform3D.eulerAngles.rotation }
            set { self.transform3D.eulerAngles = newValue.vector }
        }

        /**
         The scale transform of the view.

         Changes to this property can be animated. The default value is is `none`, which results in a view displayed at it's original scale.
         */
        public var scale: Scale {
            get { self.layer.scale }
            set { self.layer.scale = newValue }
        }
        
        /**
         The translation of the view's transform.

         Changes to this property can be animated. The default value is `zero`, which results in a view with no transformed translation.
         */
        public var translation: Translation {
            get { transform3D.translation }
            set { transform3D.translation = newValue }
        }

        /**
         The perspective of the view's transform

         The property can be animated by changing it via `animator().perspective`.

         The default value is `zero`, which results in a view with no transformed perspective.
         */
        public var perspective: Perspective {
            get { self.transform3D.perspective }
            set { self.transform3D.perspective = newValue }
        }

        /**
         The shearing of the view's transform.

         The property can be animated by changing it via `animator().skew`.

         The default value is `zero`, which results in a view with no transformed shearing.
         */
        public var skew: Skew {
            get { transform3D.skew }
            set { transform3D.skew = newValue }
        }
        
        /**
         The view’s position on the z axis.
         
         Changing the value of this property changes the front-to-back ordering of views onscreen. Higher values place the view visually closer to the viewer than views with lower values. This can affect the visibility of views whose frame rectangles overlap.         
         */
        @objc open var zPosition: CGFloat {
            get { layer.zPosition }
            set { layer.zPosition = newValue }
        }
        
        /// The shape that is used for masking the view.
        public var maskShape: PathShape? {
            get { layer.maskShape }
            set { layer.maskShape = newValue }
        }

        /**
         The border of the view.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no border.
         */
        public var border: BorderConfiguration {
            get { dashedBorderView?.configuration ?? _border }
            set {
                _border = newValue
                if newValue.needsDashedBorder {
                    borderColor = nil
                    layer.borderWidth = 0.0
                    if dashedBorderView == nil {
                        dashedBorderView = DashedBorderView()
                        addSubview(withConstraint: dashedBorderView!)
                        dashedBorderView?.sendToBack()
                    }
                    dashedBorderView?.configuration = newValue
                } else {
                    dashedBorderView?.removeFromSuperview()
                    dashedBorderView = nil
                    let newColor = newValue.resolvedColor()
                    if borderColor?.alphaComponent == 0.0 || borderColor == nil {
                        borderColor = newColor?.withAlphaComponent(0.0) ?? .clear
                    }
                    borderColor = newColor
                    layer.borderWidth = newValue.width
                }
            }
        }
        
        var _border: BorderConfiguration {
            get { getAssociatedValue("_border", initialValue: BorderConfiguration(color: layer.borderColor?.nsUIColor, width: layer.borderWidth)) }
            set { setAssociatedValue(newValue, key: "_border") }
        }

        @objc var borderColor: UIColor? {
            get { dynamicColors.border ?? layer.borderColor?.nsUIColor }
            set { 
                layer.borderColor = newValue?.resolvedColor(for: self).cgColor
                dynamicColors.border = newValue
            }
        }

        /**
         The rounded corners of the view.

         The default value is `[]`, which results in a view with all corners rounded when ``cornerRadius`` isn't `0`.
         */
        @objc public var roundedCorners: CACornerMask {
            get { layer.maskedCorners }
            set { 
                layer.maskedCorners = newValue
                dashedBorderView?.update()
            }
        }

        /**
         The corner radius of the view.

         Changes to this property can be animated. The default value is `0.0`, which results in a view with no rounded corners.
         */
        @objc public var cornerRadius: CGFloat {
            get { layer.cornerRadius }
            set { layer.cornerRadius = newValue }
        }

        /// The corner curve of the view.
        @objc public var cornerCurve: CALayerCornerCurve {
            get { layer.cornerCurve }
            set { layer.cornerCurve = newValue }
        }

        /**
         The view whose inverse alpha channel is used to mask a view’s content.

         In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.

         Changes to this property can be animated. The default value is `nil`, which results in a view with no inverse mask.
         */
        @objc public var inverseMask: NSUIView? {
            get { (layer.mask as? InverseMaskLayer)?.maskLayer?.parentView }
            set { layer.mask = newValue?.layer.inverseMask }
        }

        /**
         The outer shadow of the view.
         
         If the shadow is visible, `clipsToBounds` is set to `false`.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no shadow.
         */
        public var shadow: ShadowConfiguration {
            get { ShadowConfiguration(color: shadowColor, colorTransformer: shadowColorTransformer, opacity: CGFloat(layer.shadowOpacity), radius: layer.shadowRadius, offset: layer.shadowOffset.point) }
            set {
                let color = newValue.resolvedColor()
                if shadowColor?.alphaComponent == 0.0 || shadowColor == nil {
                    shadowColor = color?.withAlphaComponent(0.0) ?? .clear
                }
                shadowColor = color
                shadowColorTransformer = newValue.colorTransformer
                layer.shadowOffset = newValue.offset.size
                layer.shadowOpacity = Float(newValue.opacity)
                layer.shadowRadius = newValue.radius
                if !newValue.isInvisible {
                    clipsToBounds = false
                }
            }
        }
        
        var shadowColorTransformer: ColorTransformer? {
            get { getAssociatedValue("shadowColorTransformer") }
            set { setAssociatedValue(newValue, key: "shadowColorTransformer") }
        }
        
        /// The shadow color of the view.
        @objc var shadowColor: NSUIColor? {
            get { dynamicColors.shadow ?? layer.shadowColor?.uiColor }
            set {
                layer.shadowColor = newValue?.resolvedColor(for: self).cgColor
                dynamicColors.shadow = newValue
            }
        }

        /**
         The inner shadow of the view.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no inner shadow.
         */
        public var innerShadow: ShadowConfiguration {
            get { layer.innerShadowLayer?.configuration ?? .none() }
            set { 
                if newValue.isInvisible {
                    innerShadowLayer?.removeFromSuperlayer()
                } else {
                    if let innerShadowLayer = innerShadowLayer {
                        innerShadowLayer.configuration = newValue
                    } else {
                        let innerShadowLayer = InnerShadowLayer(configuration: newValue)
                        layer.addSublayer(withConstraint: innerShadowLayer)
                        innerShadowLayer.sendToBack()
                    }
                }
            }
        }

        /**
         The inner shadow of the view.

         Changes to this property can be animated. The default value is `nil`, which results in a view with no shadow path.
         */
        @objc public var shadowPath: NSUIBezierPath? {
            get { layer.shadowPath?.bezierPath }
            set { layer.shadowPath = newValue?.cgPath }
        }
        
        /// The shape of the shadow.
        public var shadowShape: PathShape? {
            get { layer.shadowShape }
            set { layer.shadowShape = newValue }
        }
        
        /**
         The distance (in points) between the top of the view’s alignment rectangle and its topmost baseline.
         
         For views with multiple lines of text, this represents the baseline of the top row of text.
         
         - Note: For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
         */
        public var firstBaselineOffsetFromTop: CGFloat? {
            if let view = self as? UITextField {
                return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
            } else if let view = self as? UITextView {
                return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
            } else if let view = self as? UILabel {
                return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
            }
            return nil
        }
        
        /**
         The distance (in points) between the bottom of the view’s alignment rectangle and its bottommost baseline.
         
         For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
         */
        public var lastBaselineOffsetFromBottom: CGFloat? {
            if let view = self as? UITextField {
                return value(forKeySafely: "_lastBaselineOffsetFromBottom") as? CGFloat
            } else if let view = self as? UITextView {
                return value(forKeySafely: "_lastBaselineOffsetFromBottom") as? CGFloat
            } else if let view = self as? UILabel {
                return value(forKeySafely: "_baselineOffsetFromBottom") as? CGFloat
            }
            return nil
        }
        
        /**
         The coordinate of the baseline for the topmost line of text in the view.
         
         For views with multiple lines of text, this represents the baseline of the top row of text.
         
         - Note: For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or else `0` is returned.
         */
        public var firstBaselineOffset: CGPoint {
            guard firstBaselineOffsetFromTop ?? 0.0 != 0 else { return frame.origin }
            return CGPoint(frame.x, frame.y + frame.height - (firstBaselineOffsetFromTop ?? 0.0) - 0.5)
        }
        
        /// Handlers for the view.
        public struct Handlers {
            /// The handler that gets called when the trait collection changes.
            public var trait: ((UITraitCollection)->())?
            
            /// The handler that gets called when the user interface style changes.
            public var userInterfaceStyle: ((UIUserInterfaceStyle)->())?
            
            /// The handler that gets called when the active appearance changes.
            public var activeAppearance: ((UIUserInterfaceActiveAppearance)->())?
            
            var needsTraitObservation: Bool {
                trait != nil || userInterfaceStyle != nil || activeAppearance != nil
            }
        }
        
        /// The handlers for the view.
        public var handlers: Handlers {
            get { getAssociatedValue("handlers", initialValue: Handlers()) }
            set {
                setAssociatedValue(newValue, key: "handlers")
                setupTraitObservation()
            }
        }
        
        func setupTraitObservation() {
            if !handlers.needsTraitObservation && dynamicColors._border == nil && dynamicColors._shadow == nil {
                traitObserverView?.removeFromSuperview()
                traitObserverView = nil
            } else if traitObserverView == nil {
                traitObserverView = TraitObserverView(for: self)
            }
        }
        
        var traitObserverView: TraitObserverView? {
            get { getAssociatedValue("traitObserverView") }
            set { setAssociatedValue(newValue, key: "traitObserverView") }
        }
        
        class TraitObserverView: UIView {
            var previousTraitCollection: UITraitCollection?
            init(for view: UIView) {
                super.init(frame: .zero)
                view.addSubview(self)
                previousTraitCollection = traitCollection
                sendToBack()
                zPosition = -10000
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                guard let superview = superview, let previous = previousTraitCollection ?? self.previousTraitCollection else { return }
                self.previousTraitCollection = previousTraitCollection ?? self.previousTraitCollection
                superview.handlers.trait?(traitCollection)
                if previous.activeAppearance != traitCollection.activeAppearance {
                    superview.handlers.activeAppearance?(traitCollection.activeAppearance)
                }
                if previous.userInterfaceStyle != traitCollection.userInterfaceStyle {
                    superview.dynamicColors.update()
                    superview.handlers.userInterfaceStyle?(traitCollection.userInterfaceStyle)
                }
            }
        }
    }

    extension UIView.ContentMode: CaseIterable {
        /// All content modes.
        public static var allCases: [UIView.ContentMode] = [.scaleToFill, .scaleAspectFit, .scaleAspectFill, .redraw, .center, .top, .bottom, .left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    extension UIView.ContentMode {
        var layerContentsGravity: CALayerContentsGravity {
            switch self {
            case .scaleToFill: return .resizeAspectFill
            case .scaleAspectFit: return .resizeAspectFill
            case .scaleAspectFill: return .resizeAspectFill
            case .redraw: return .resizeAspectFill
            case .center: return .center
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .topLeft: return .left
            case .topRight: return .right
            case .bottomLeft: return .left
            case .bottomRight: return .right
            @unknown default: return .center
            }
        }

        init(contentsGravity: CALayerContentsGravity) {
            let rawValue = UIView.ContentMode.allCases.first(where: { $0.layerContentsGravity == contentsGravity })?.rawValue ?? UIView.ContentMode.scaleAspectFit.rawValue
            self.init(rawValue: rawValue)!
        }
    }

import FZSwiftUtils
extension UIView {
        
    struct DynamicColors {

        var shadow: UIColor? {
            mutating get { get(\._shadow, view?.layer.shadowColor) }
            set { _shadow = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var border: UIColor? {
            mutating get { get(\._border, view?.layer.borderColor) }
            set { _border = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var _shadow: UIColor?
        var _border: UIColor?
        weak var view: UIView?
        
        mutating func update() {
            guard let view = view else { return }
            if let shadow = shadow?.resolvedColor(for: view).cgColor {
                view.layer.shadowColor = shadow
            }
            if let border = border?.resolvedColor(for: view).cgColor {
                view.layer.borderColor = border
            }
        }

        mutating func get(_ keyPath: WritableKeyPath<Self, UIColor?>, _ cgColor: CGColor?) -> UIColor? {
            guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return nil }
            if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                self[keyPath: keyPath] = nil
            }
            return self[keyPath: keyPath]
        }
        
        var needsObserver: Bool {
           _border != nil || _shadow != nil
        }
    }

    var dynamicColors: DynamicColors {
        get { getAssociatedValue("dynamicColors", initialValue: DynamicColors(view: self)) }
        set { setAssociatedValue(newValue, key: "dynamicColors")
            setupTraitObservation()
        }
    }
}

#endif
