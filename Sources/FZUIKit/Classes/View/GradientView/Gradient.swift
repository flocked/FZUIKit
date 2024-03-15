//
//  Gradient.swift
//
//
//  Created by Florian Zand on 13.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    /*
     extension NSView {
         var gradient: Gradient {
             get { .zero }
         }
     }
     */

    public struct Gradient: Hashable {
        /// The array of color stops.
        public var stops: [Stop] = []
        /// The start point of the gradient.
        public var startPoint: Point = .top
        /// The end point of the gradient.
        public var endPoint: Point = .bottom
        /// The type of gradient.
        public var type: GradientType = .linear

        /**
         Creates a gradient from an array of colors.

         The gradient synthesizes its location values to evenly space the colors along the gradient.

         - Parameters:
            - colors: An array of colors.
            - startPoint: The start point of the gradient.
            - endPoint: The end point of the gradient.
            - type: The type of gradient.
         */
        public init(colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
            stops = Self.stops(for: colors)
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.type = type
        }

        /**
         Creates a gradient from an array of colors.

         The gradient synthesizes its location values to evenly space the colors along the gradient.

         - Parameters:
            - colors: An array of colors.
            - startPoint: The start point of the gradient.
            - endPoint: The end point of the gradient.
            - type: The type of gradient.
         */
        public init(_ colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
            stops = Self.stops(for: colors)
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.type = type
        }

        /**
         Creates a gradient from an array of color stops.

         - Parameters:
            - stops: An array of color stops.
            - startPoint: The start point of the gradient.
            - endPoint: The end point of the gradient.
            - type: The type of gradient.
         */
        public init(stops: [Stop], startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
            self.stops = stops
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.type = type
        }

        /**
         Returns a gradient for the specified preset.

         - Parameters:
            - preset: The gradient preset.
            - startPoint: The start point of the gradient.
            - endPoint: The end point of the gradient.
            - type: The type of gradient.
         */
        public init(preset: Preset, startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
            stops = Self.stops(for: preset.colors)
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.type = type
        }

        /// An empty gradient.
        public static func none() -> Gradient {
            Gradient(stops: [])
        }

        static func stops(for colors: [NSUIColor]) -> [Stop] {
            var stops: [Stop] = []
            if colors.count == 1 {
                stops.append(Stop(color: colors[0], location: 0.0))
            } else if colors.count > 1 {
                let split = 1.0 / CGFloat(colors.count - 1)
                for i in 0 ..< colors.count {
                    stops.append(Stop(color: colors[i], location: split * CGFloat(i)))
                }
            }
            return stops
        }
    }

    public extension Gradient {
        /// The gradient type.
        enum GradientType: Int, Hashable {
            case linear
            case conic
            case radial

            var stringValue: String {
                switch self {
                case .conic: return "conic"
                case .radial: return "radial"
                case .linear: return "axial"
                }
            }

            var gradientLayerType: CAGradientLayerType {
                CAGradientLayerType(rawValue: stringValue)
            }

            init(_ gradientLayerType: CAGradientLayerType) {
                switch gradientLayerType {
                case .conic: self = .conic
                case .radial: self = .radial
                default: self = .linear
                }
            }
        }

        /// One color stop in the gradient.
        struct Stop: Hashable {
            /// The color for the stop.
            public var color: NSUIColor
            /// The parametric location of the stop.
            public var location: CGFloat
            /// Creates a color stop with a color and location.
            public init(color: NSUIColor, location: CGFloat) {
                self.color = color
                self.location = location
            }
        }

        /// A point in the gradient.
        struct Point: Hashable {
            public var x: CGFloat
            public var y: CGFloat

            public init(x: CGFloat, y: CGFloat) {
                self.x = x
                self.y = y
            }

            public init(_ x: CGFloat, _ y: CGFloat) {
                self.x = x
                self.y = y
            }

            init(_ point: CGPoint) {
                x = point.x
                y = point.y
            }

            var point: CGPoint {
                CGPoint(x, y)
            }

            public static var leading = Point(x: 0.0, y: 0.5)
            public static var center = Point(x: 0.5, y: 0.5)
            public static var trailing = Point(x: 1.0, y: 0.5)
            #if os(macOS)
                public static var bottomLeading = Point(x: 0.0, y: 0.0)
                public static var bottom = Point(x: 0.5, y: 0.0)
                public static var bottomTrailing = Point(x: 1.0, y: 0.0)

                public static var topLeading = Point(x: 0.0, y: 1.0)
                public static var top = Point(x: 0.5, y: 1.0)
                public static var topTrailing = Point(x: 1.0, y: 1.0)
            #else
                public static var bottomLeading = Point(x: 0.0, y: 1.0)
                public static var bottom = Point(x: 0.5, y: 1.0)
                public static var bottomTrailing = Point(x: 1.0, y: 1.0)

                public static var topLeading = Point(x: 0.0, y: 0.0)
                public static var top = Point(x: 0.5, y: 0.0)
                public static var topTrailing = Point(x: 1.0, y: 0.0)
            #endif
        }
    }

    public extension NSUIView {
        /**
         Configurates the gradient of the view.

         - Parameters:
            - gradient:The gradient.
         */
        func configurate(using gradient: Gradient) {
            var gradient = gradient
            gradient.stops.editEach { $0.color = $0.color.resolvedColor(for: self) }
            #if os(macOS)
                wantsLayer = true
                layer?.configurate(using: gradient)
            #else
                layer.configurate(using: gradient)
            #endif
        }
    }

    public extension CALayer {
        /**
         Configurates the gradient of the layer.

         - Parameters:
         - gradient:The gradient.
         */
        func configurate(using gradient: Gradient) {
            if gradient.stops.isEmpty {
                _gradientLayer?.removeFromSuperlayer()
            } else {
                if _gradientLayer == nil {
                    let gradientLayer = GradientLayer()
                    addSublayer(withConstraint: gradientLayer)
                    gradientLayer.sendToBack()
                    gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                }
                _gradientLayer?.gradient = gradient
            }
        }

        internal var _gradientLayer: GradientLayer? {
            firstSublayer(type: GradientLayer.self)
        }
    }

#endif
