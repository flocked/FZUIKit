//
//  GradientView.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension GradientView {
        /*
         /// The gradient.
         var gradient: Gradient {
             get { gradientLayer.gradient }
             set {
                 self.startPoint = newValue.startPoint.point
                 self.endPoint = newValue.endPoint.point
                 self.colors = newValue.stops.compactMap({$0.color.cgColor})
                 self.locations = newValue.stops.compactMap({NSNumber($0.location)})
                 self.type = newValue.type.gradientLayerType
             }
         }
         */
    }

    /// A view that displays a gradient.
    public class GradientView: NSUIView {
        @objc var locations: [NSNumber] {
            get { gradientLayer.locations ?? [] }
            set { gradientLayer.locations = newValue }
        }

        @objc var colors: [CGColor] {
            get { (gradientLayer.colors as? [CGColor]) ?? [] }
            set { gradientLayer.colors = newValue }
        }

        @objc var startPoint: CGPoint {
            get { gradientLayer.startPoint }
            set { gradientLayer.startPoint = newValue }
        }

        @objc var endPoint: CGPoint {
            get { gradientLayer.endPoint }
            set { gradientLayer.endPoint = newValue }
        }

        @objc var type: CAGradientLayerType {
            get { gradientLayer.type }
            set { gradientLayer.type = newValue }
        }

        /**
         Initalizes an inner shadow view with the specified configuration.

         - Parameter configuration: The configuration of the inner shadow.
         - Returns: The inner shadow view.
         */
        public init(gradient: Gradient) {
            super.init(frame: .zero)
            self.gradient = gradient
        }

        var gradientLayer: GradientLayer {
            #if os(macOS)
                self.wantsLayer = true
            #endif
            return self.layer as! GradientLayer
        }

        #if os(macOS)
            override public func makeBackingLayer() -> CALayer {
                let gradientLayer = GradientLayer()
                return gradientLayer
            }
        #else
            override public class var layerClass: AnyClass {
                GradientLayer.self
            }
        #endif

        override public init(frame: CGRect) {
            super.init(frame: frame)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        #if os(macOS)
            override public func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
                if Self.gradientAnimationKeys.contains(key) {
                    let animation = CABasicAnimation()
                    animation.timingFunction = .default
                    return animation
                }
                return super.animation(forKey: key)
            }

            static let gradientAnimationKeys = ["locations", "colors", "startPoint", "endPoint"]
        #endif
    }
#endif
