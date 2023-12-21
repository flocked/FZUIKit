//
//  UIView+.swift
//  
//
//  Created by Florian Zand on 12.08.22.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UIView {
    /// The parent view controller managing the view.
    var parentController: UIViewController? {
        if let responder = next as? UIViewController {
            return responder
        } else if let responder = next as? UIView {
            return responder.parentController
        } else {
            return nil
        }
    }
    
    /// The rotation of the view as euler angles in degrees.
    dynamic var rotation: CGVector3 {
        get { self.transform3D.eulerAnglesDegrees }
        set { self.transform3D.eulerAnglesDegrees = newValue }
    }
    
    /// The rotation of the view as euler angles in radians.
    dynamic var rotationInRadians: CGVector3 {
        get { self.transform3D.eulerAngles }
        set { self.transform3D.eulerAngles = newValue }
    }
    
    /**
     The scale transform of the view.

     The default value of this property is `CGPoint(x: 1.0, y: 1.0)`.
     */
    dynamic var scale: CGPoint {
        get { layer.scale }
        set { self.transform3D.scale = Scale(newValue.x, newValue.y, transform3D.scale.z) }
    }
    
    /// The border of the view.
    var border: BorderConfiguration {
        get { dashedBorderLayer?.configuration ?? .init(color: borderColor, width: borderWidth) }
        set { self.configurate(using: newValue) }
    }

    /// The border color of the view.
    @objc internal dynamic var borderColor: UIColor? {
        get { layer.borderColor?.nsUIColor }
        set { layer.borderColor = newValue?.cgColor }
    }

    /// The border width of the view.
    @objc internal dynamic var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    /// The rounded corners of the view.
    @objc dynamic var roundedCorners: CACornerMask {
        get { layer.maskedCorners }
        set { layer.maskedCorners = newValue }
    }

    /// The corner radius of the view.
    @objc dynamic var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    /// The corner curve of the view.
    @objc dynamic var cornerCurve: CALayerCornerCurve {
        get { layer.cornerCurve }
        set { layer.cornerCurve = newValue }
    }
    
    /// The shadow color of the view.
    @objc internal dynamic var shadowColor: NSUIColor? {
        get { layer.shadowColor?.uiColor }
        set { layer.shadowColor = newValue?.cgColor }
    }
    
    /// The shadow offset of the view.
    @objc internal dynamic var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    /// The shadow radius of the view.
    @objc internal dynamic var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    /// The shadow opacity of the view.
     @objc internal dynamic var shadowOpacity: CGFloat {
        get { CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }
    
    /// The shadow path of the view.
    @objc internal dynamic var shadowPath: CGPath? {
        get { layer.shadowPath }
        set { layer.shadowPath = newValue }
    }
    
    /// The inner shadow of the view.
    dynamic var innerShadow: ShadowConfiguration {
        get { self.layer.innerShadowLayer?.configuration ?? .none() }
        set { self.configurate(using: newValue, type: .inner) }
    }
    
    @objc internal dynamic var innerShadowColor: NSUIColor? {
        get { self.layer.innerShadowLayer?.shadowColor?.nsUIColor }
        set { self.layer.innerShadowLayer?.shadowColor = newValue?.cgColor }
    }
    
    @objc internal dynamic var innerShadowOpacity: CGFloat {
        get { CGFloat(self.layer.innerShadowLayer?.shadowOpacity ?? 0) }
        set { self.layer.innerShadowLayer?.shadowOpacity = Float(newValue) }
    }
    
    @objc internal dynamic var innerShadowRadius: CGFloat {
        get { self.layer.innerShadowLayer?.shadowRadius ?? 0 }
        set { self.layer.innerShadowLayer?.shadowRadius = newValue }
    }
    
    @objc internal dynamic var innerShadowOffset: CGSize {
        get { self.layer.innerShadowLayer?.shadowOffset ?? .zero }
        set { self.layer.innerShadowLayer?.shadowOffset = newValue }
    }

    /// The shadow of the view.
    dynamic var shadow: ShadowConfiguration {
        get { ShadowConfiguration(color: shadowColor, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height)) }
        set { self.configurate(using: newValue, type: .outer) }
    }
}

extension UIView.ContentMode: CaseIterable {
    /// All content modes.
    public static var allCases: [UIView.ContentMode] = [.scaleToFill, .scaleAspectFit, .scaleAspectFill, .redraw, .center, .top, .bottom, .left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight]
}

internal extension UIView.ContentMode {
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
