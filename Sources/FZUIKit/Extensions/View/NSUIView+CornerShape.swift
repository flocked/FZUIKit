//
//  NSUIView+CornerShape.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    extension NSUIView {
        /// The corner shape of a view.
        public enum CornerShape: CustomStringConvertible {
            case rectangle
            /// A rounded shape with corner radius equal to the specified value.
            case rounded(CGFloat)
            /// A rounded shape with corner radius relative to half the length of the view's smallest edge.
            case roundedRelative(CGFloat)
            /// A circular shape with corner radius equal to half the length of the view's smallest edge.
            case circular
            /// A capsule shape with corner radius equal to half the length of the view's smallest edge.
            case capsule
            /// An ellipse shape.
            case ellipse
            /// A star shape.
            case star
            /// A star shape with rounded corners.
            case starRounded
            /// A shape with the specified path.
            case path(NSBezierPath)
            
            var needsLayer: Bool {
                switch self {
                case .circular, .star, .starRounded, .ellipse, .path: return true
                default: return false
                }
            }
            
            public var description: String {
                switch self {
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
        
        /// The corner shape of the view.
        public var cornerShape: CornerShape? {
            get { shapeView?.shape }
            set {
                if let shape = newValue {
                    if shapeView == nil {
                        let shapeView = ShapedView()
                        shapeView.frame.size = bounds.size
                        mask = shapeView
                        shapeBoundsObservation = observeChanges(for: \.frame) { old, new in
                            guard old.size != new.size else { return }
                            shapeView.frame.size = new.size
                        }
                    }
                    shapeView?.shape = shape
                } else {
                    shapeBoundsObservation = nil
                    if shapeView != nil {
                        mask = nil
                    }
                }
            }
        }
        
        /// Sets the corner shape of the view.
        @discardableResult
        public func cornerShape(_ shape: CornerShape?) -> Self {
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
