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

    /// The border color of the view.
    @objc dynamic var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    /// The border width of the view.
    @objc dynamic var borderWidth: CGFloat {
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
