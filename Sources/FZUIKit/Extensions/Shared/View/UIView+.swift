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
    
    /**
     The left edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var left: CGFloat {
        get { frame.left }
        set { frame.left = newValue }
    }
    
    /**
     The right edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var right: CGFloat {
        get { frame.right }
        set { frame.right = newValue }
    }
    
    /**
     The top edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
          */
    @objc dynamic var top: CGFloat {
        get { frame.top }
        set { frame.top = newValue }
    }
    
    /**
     The bottom edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var bottom: CGFloat {
        get { frame.bottom }
        set { frame.bottom = newValue }
    }
    
    /**
     The top-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var topLeft: CGPoint {
        get { frame.topLeft }
        set { frame.topLeft = newValue }
    }
    
    /**
     The top-center point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var topCenter: CGPoint {
        get { frame.topCenter }
        set { frame.topCenter = newValue }
    }
    
    /**
     The top-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var topRight: CGPoint {
        get { frame.topRight }
        set { frame.topRight = newValue }
    }
    
    /**
     The center-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var centerLeft: CGPoint {
        get { frame.centerLeft }
        set { frame.centerLeft = newValue }
    }
    
    /**
     The center-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var centerRight: CGPoint {
        get { frame.centerRight }
        set { frame.centerRight = newValue }
    }
    
    /**
     The bottom-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var bottomLeft: CGPoint {
        get { frame.bottomLeft }
        set { frame.bottomLeft = newValue }
    }
    
    /**
     The bottom-center point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var bottomCenter: CGPoint {
        get { frame.bottomCenter }
        set { frame.bottomCenter = newValue }
    }
    
    /**
     The bottom-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     */
    @objc dynamic var bottomRight: CGPoint {
        get { frame.bottomRight }
        set { frame.bottomRight = newValue }
    }
    
    /**
     Specifies the rotation applied to the view.
     */
    dynamic var rotation: CGQuaternion {
        get { return layer.rotation }
        set { self.transform3D.rotation = newValue }
    }
    
    /**
     The scale transform of the view..

     The default value of this property is `CGPoint(x: 1.0, y: 1.0)`.
     */
    dynamic var scale: CGPoint {
        get { layer.scale }
        set { self.transform3D.scale = Scale(newValue.x, newValue.y, transform3D.scale.z) }
    }
    
    /// The border of the view.
    var border: ContentConfiguration.Border {
        get { dashedBorderLayer?.configuration ?? .init(color: borderColor, width: borderWidth) }
        set { self.configurate(using: newValue) }
    }

    /// The border color of the view.
    @objc internal dynamic var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
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
        set { layer.borderColor = newValue?.cgColor }
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
    
    /// The shadow of the view.
    var shadow: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: shadowColor, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height)) }
        set {
            shadowColor = newValue._resolvedColor?.resolvedColor(for: self)
            shadowOpacity = newValue.opacity
            shadowOffset = CGSize(newValue.offset.x, newValue.offset.y)
            shadowRadius = newValue.radius
            
        }
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
