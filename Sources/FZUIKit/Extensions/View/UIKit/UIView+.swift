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
        public var rotation: CGVector3 {
            get { self.transform3D.eulerAnglesDegrees }
            set { self.transform3D.eulerAnglesDegrees = newValue }
        }

        /**
         The rotation of the view as euler angles in radians.

         Changes to this property can be animated. The default value is is `zero`, which results in a view with no rotation.
         */
        public var rotationInRadians: CGVector3 {
            get { self.transform3D.eulerAngles }
            set { self.transform3D.eulerAngles = newValue }
        }

        /**
         The scale transform of the view.

         Changes to this property can be animated. The default value is is `CGPoint(x: 1.0, y: 1.0)`, which results in a view displayed at it's original scale.
         */
        public var scale: CGPoint {
            get { self.layer.scale }
            set { self.layer.scale = newValue }
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
         The border of the view.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no border.
         */
        public var border: BorderConfiguration {
            get { dashedBorderLayer?.configuration ?? .init(color: borderColor, width: borderWidth) }
            set { 
                if newValue.needsDashedBordlerLayer {
                    borderColor = nil
                    borderWidth = 0.0
                    if dashedBorderView == nil {
                        dashedBorderView = DashedBorderView()
                        addSubview(withConstraint: dashedBorderView!)
                        dashedBorderView?.sendToBack()
                    }
                    dashedBorderView?.configuration = configuration
                } else {
                    dashedBorderView?.removeFromSuperview()
                    dashedBorderView = nil
                    let newColor = configuration.resolvedColor()?.resolvedColor(for: self)
                    if borderColor?.alphaComponent == 0.0 || borderColor == nil {
                        borderColor = newColor?.withAlphaComponent(0.0) ?? .clear
                    }
                    borderColor = newColor
                    borderWidth = configuration.width
                }
            }
        }

        /// The border color of the view.
        @objc var borderColor: UIColor? {
            get { layer.borderColor?.nsUIColor }
            set { layer.borderColor = newValue?.cgColor }
        }

        /// The border width of the view.
        @objc var borderWidth: CGFloat {
            get { layer.borderWidth }
            set { layer.borderWidth = newValue }
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
            set {
                if let newMaskLayer = newValue?.layer {
                    layer.mask = InverseMaskLayer(maskLayer: newMaskLayer)
                } else {
                    layer.mask = nil
                }
            }
        }

        /**
         The outer shadow of the view.
         
         If the shadow is visible, `clipsToBounds` is set to `false`.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no shadow.
         */
        public var shadow: ShadowConfiguration {
            get { ShadowConfiguration(color: shadowColor, opacity: shadowOpacity, radius: shadowRadius, offset: shadowOffset) }
            set { self.configurate(using: newValue, type: .outer) }
        }

        /**
         The inner shadow of the view.

         Changes to this property can be animated. The default value is `none()`, which results in a view with no inner shadow.
         */
        public var innerShadow: ShadowConfiguration {
            get { layer.innerShadowLayer?.configuration ?? .none() }
            set { configurate(using: newValue, type: .inner) }
        }

        /// The shadow color of the view.
        @objc var shadowColor: NSUIColor? {
            get { layer.shadowColor?.uiColor }
            set { layer.shadowColor = newValue?.resolvedColor(for: self).cgColor }
        }

        @objc var shadowOffset: CGPoint {
            get { layer.shadowOffset.point }
            set { layer.shadowOffset = newValue.size }
        }

        @objc var shadowRadius: CGFloat {
            get { layer.shadowRadius }
            set { layer.shadowRadius = newValue }
        }

        @objc var shadowOpacity: CGFloat {
            get { CGFloat(layer.shadowOpacity) }
            set { layer.shadowOpacity = Float(newValue) }
        }

        /**
         The inner shadow of the view.

         Changes to this property can be animated. The default value is `nil`, which results in a view with no shadow path.
         */
        @objc public var shadowPath: CGPath? {
            get { layer.shadowPath }
            set { layer.shadowPath = newValue }
        }
        
        /**
         The distance (in points) between the top of the view’s alignment rectangle and its topmost baseline.
         
         For views with multiple lines of text, this represents the baseline of the top row of text.
         
         - Note: For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
         */
        public var firstBaselineOffsetFromTop: CGFloat? {
            if let view = self as? UITextField {
                return view.constraints.isEmpty ? nil : value(forKey: "_firstBaselineOffsetFromTop") as? CGFloat
            } else if let view = self as? UITextView {
                return view.constraints.isEmpty ? nil : value(forKey: "_firstBaselineOffsetFromTop") as? CGFloat
            }
            return value(forKey: "_firstBaselineOffsetFromTop") as? CGFloat
        }
        
        /**
         The distance (in points) between the bottom of the view’s alignment rectangle and its bottommost baseline.
         
         For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
         */
        public var lastBaselineOffsetFromBottom: CGFloat? {
            if let view = self as? UITextField {
                return view.constraints.isEmpty ? nil : value(forKey: "_lastBaselineOffsetFromBottom") as? CGFloat
            } else if let view = self as? UITextView {
                return view.constraints.isEmpty ? nil : value(forKey: "_lastBaselineOffsetFromBottom") as? CGFloat
            }
            return value(forKey: "_lastBaselineOffsetFromBottom") as? CGFloat
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

#endif
