//
//  NSUIView+CornerShape.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

/// The corner shape of an object.
public enum CornerShape: CustomStringConvertible {
    /// The default shape that uses the object's corner radius.
    case normal
    /// A rectangle shape with no corner radius.
    case rectangle
    /// A rounded shape with corner radius equal to the specified value.
    case rounded(CGFloat)
    /// A rounded shape with corner radius relative to half the length of the object's smallest edge.
    case roundedRelative(CGFloat)
    /// A circular shape with corner radius equal to half the length of the object's smallest edge.
    case circular
    /// A capsule shape with corner radius equal to half the length of the object's smallest edge.
    case capsule
    /// An ellipse shape.
    case ellipse
    /// A star shape.
    case star
    /// A star shape with rounded corners.
    case starRounded
    /// A shape with the specified path.
    case path(NSUIBezierPath)
    
    var needsLayer: Bool {
        switch self {
        case .circular, .star, .starRounded, .ellipse, .path: return true
        default: return false
        }
    }
    
    var isNormal: Bool {
        switch self {
        case .normal: return true
        default: return false
        }
    }
    
    public var description: String {
        switch self {
        case .normal: return "Normal"
        case .rectangle: return "Rectangle"
        case .rounded(let radius): return "Rounded[\(radius)]"
        case .roundedRelative(let radius): return "RoundedRelative[\(radius)]"
        case .circular: return "Circle"
        case .capsule: return "Capsule"
        case .ellipse: return "Ellipse"
        case .star: return "Star"
        case .starRounded: return "StarRounded"
        case .path: return "Path"
        }
    }
}

    extension NSUIView {
        /// The corner shape of the view.
        public var cornerShape: CornerShape {
            get { shapeView?.shape ?? .normal }
            set {
                setCornerShape(newValue)
                visualEffectBackgroundView?.setCornerShape(newValue)
            }
        }
        
        func setCornerShape(_ newValue: CornerShape) {
            if !newValue.isNormal {
                if shapeView == nil {
                    let shapeView = ShapedView()
                    shapeView.frame.size = bounds.size
                    mask = shapeView
                    shapeBoundsObservation = observeChanges(for: \.frame) { old, new in
                        guard old.size != new.size else { return }
                        shapeView.frame.size = new.size
                    }
                }
                shapeView?.shape = newValue
                #if os(macOS)
                shapeView?.outerShadow = outerShadow
                #else
                shapeView?.shadow = shadow
                #endif
                shapeView?.border = border
             //   layer?.border = .none()
                optionalLayer?.masksToBounds = false
                shapeView?.clipsToBounds = false
                #if os(macOS)
                shapeView?.optionalLayer?.shadow = outerShadow
                #else
                shapeView?.optionalLayer?.shadow = shadow
                #endif
            } else {
                shapeBoundsObservation = nil
                if shapeView != nil {
                    mask = nil
                }
            }
        }
        
        /// Sets the corner shape of the view.
        @discardableResult
        public func cornerShape(_ shape: CornerShape) -> Self {
            cornerShape = shape
            return self
        }
        
        var shapeView: ShapedView? {
            mask as? ShapedView
        }
        
        var shapeBoundsObservation: KeyValueObservation? {
            get { getAssociatedValue("shapeBoundsObservation") }
            set { setAssociatedValue(newValue, key: "shapeBoundsObservation") }
        }
    }
#endif
