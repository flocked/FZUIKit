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

/// A color gradient.
public struct Gradient: Hashable {
    /// The color stops of the gradient.
    public var stops: [ColorStop] = []
    
    /// The start point of the gradient.
    public var startPoint: Point = .top
    
    /// The end point of the gradient.
    public var endPoint: Point = .bottom
    
    /// The type of gradient.
    public var type: GradientType = .linear
    
    /// The colors of the gradient.
    public var colors: [NSUIColor] {
        get { stops.map({ $0.color }) }
        set { stops = newValue.stops }
    }
    
    /// Returns the gradient with the specified color stops.
    @discardableResult
    public func stops(_ stops: [ColorStop]) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified colors.
    @discardableResult
    public func colors(_ colors: [NSUIColor]) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified opacity.
    @discardableResult
    public func opacity(_ opacity: CGFloat) -> Self {
        Self(stops: stops.map({ $0.opacity(opacity) }), startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified start point.
    @discardableResult
    public func startPoint(_ startPoint: Point) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified end point.
    @discardableResult
    public func endPoint(_ endPoint: Point) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified gradient type.
    @discardableResult
    public func type(_ type: GradientType) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
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
    public init(colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
        stops = colors.stops
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
    public init(stops: [ColorStop], startPoint: Point = .top, endPoint: Point = .bottom, type: GradientType = .linear) {
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
        stops = preset.colors.stops
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    /// A linear gradient with the specified colors.
    public static func linear(_ colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A linear gradient with the specified color stops.
    public static func linear(_ stops: [ColorStop], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A linear gradient with the specified preset.
    public static func linear(_ preset: Preset, startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A conic gradient with the specified colors.
    public static func conic(_ colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A conic gradient with the specified color stops.
    public static func conic(_ stops: [ColorStop], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A conic gradient with the specified preset.
    public static func conic(_ preset: Preset, startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A radial gradient with the specified colors.
    public static func radial(_ colors: [NSUIColor], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// A radial gradient with the specified color stops.
    public static func radial(_ stops: [ColorStop], startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// A radial gradient with the specified preset.
    public static func radial(_ preset: Preset, startPoint: Point = .top, endPoint: Point = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// An empty gradient.
    public static func none() -> Gradient {
        Gradient(stops: [])
    }
}

public extension Gradient {
    /// The gradient type.
    enum GradientType: Int, Hashable, CustomStringConvertible {
        /// Linear gradient.
        case linear
        /// Conic gradient.
        case conic
        /// Radial gradient.
        case radial
        
        public var description: String {
            switch self {
            case .conic: return "conic"
            case .radial: return "radial"
            case .linear: return "axial"
            }
        }
        
        var gradientLayerType: CAGradientLayerType {
            CAGradientLayerType(rawValue: description)
        }
        
        init(_ gradientLayerType: CAGradientLayerType) {
            switch gradientLayerType {
            case .conic: self = .conic
            case .radial: self = .radial
            default: self = .linear
            }
        }
    }
    
    /// Color stop in a gradient.
    struct ColorStop: Hashable, CustomStringConvertible {
        /// The color for the stop.
        public var color: NSUIColor
        /// The parametric location of the stop.
        public var location: CGFloat
        
        public var description: String {
            "[color: \(color), location: \(location)]"
        }
        
        /// Returns the color stop with the specified color.
        public func color(_ color: NSUIColor) -> Self {
            Self(color: color, location: location)
        }
        
        /// Returns the color stop with the specified color opacity.
        public func opacity(_ opacity: CGFloat) -> Self {
            Self(color: color.withAlphaComponent(opacity), location: location)
        }
        
        /// Returns the color stop with the specified parametric location.
        public func location(_ location: CGFloat) -> Self {
            Self(color: color, location: location)
        }
        
        var transparent: Self {
            Self(color: color.withAlphaComponent(0.0), location: location)
        }
        
        /// Creates a color stop with a color and location.
        public init(color: NSUIColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
    }
    
    /// Point in a gradient.
    struct Point: Hashable, CustomStringConvertible {
        /// X.
        public var x: CGFloat
        /// Y.
        public var y: CGFloat
        
        public var description: String {
            "[x: \(x), y: \(y)]"
        }
        
        public init(x: CGFloat, y: CGFloat) {
            self.x = x
            self.y = y
        }
        
        public init(_ x: CGFloat, _ y: CGFloat) {
            self.x = x
            self.y = y
        }
        
        public init(_ xy: CGFloat) {
            self.x = xy
            self.y = xy
        }
        
        init(_ point: CGPoint) {
            x = point.x
            y = point.y
        }
        
        var point: CGPoint {
            CGPoint(x, y)
        }
        
        public static var left = Point(x: 0.0, y: 0.5)
        public static var center = Point(x: 0.5, y: 0.5)
        public static var right = Point(x: 1.0, y: 0.5)
        #if os(macOS)
        public static var bottomLeft = Point(x: 0.0, y: 0.0)
        public static var bottom = Point(x: 0.5, y: 0.0)
        public static var bottomRight = Point(x: 1.0, y: 0.0)
        
        public static var topLeft = Point(x: 0.0, y: 1.0)
        public static var top = Point(x: 0.5, y: 1.0)
        public static var topRight = Point(x: 1.0, y: 1.0)
        #else
        public static var bottomLeft = Point(x: 0.0, y: 1.0)
        public static var bottom = Point(x: 0.5, y: 1.0)
        public static var bottomRight = Point(x: 1.0, y: 1.0)
        
        public static var topLeft = Point(x: 0.0, y: 0.0)
        public static var top = Point(x: 0.5, y: 0.0)
        public static var topRight = Point(x: 1.0, y: 0.0)
        #endif
    }
}

public extension CALayer {
    /// The gradient of the layer.
    var gradient: Gradient? {
        get {
            if let layer = self as? CAGradientLayer {
                let colors = (layer.colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
                let locations = layer.locations?.compactMap { CGFloat($0.floatValue) } ?? []
                let stops = zip(colors, locations).map({ Gradient.ColorStop(color: $0.0, location: $0.1) })
                return Gradient(stops: stops, startPoint: .init(layer.startPoint), endPoint: .init(layer.endPoint), type: .init(layer.type))
            }
            return _gradientLayer?.gradient
        }
        set {
            if let newValue = newValue, !newValue.stops.isEmpty {
                if let layer = self as? CAGradientLayer {
                    layer.colors = newValue.stops.compactMap(\.color.cgColor)
                    layer.locations = newValue.stops.compactMap { NSNumber($0.location) }
                    layer.startPoint = newValue.startPoint.point
                    layer.endPoint = newValue.endPoint.point
                    layer.type = newValue.type.gradientLayerType
                } else {
                    if _gradientLayer == nil {
                        let gradientLayer = GradientLayer()
                        addSublayer(withConstraint: gradientLayer)
                        gradientLayer.sendToBack()
                        gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                    }
                    _gradientLayer?.gradient = newValue
                }
            } else {
                if let layer = self as? CAGradientLayer {
                    layer.colors = nil
                } else {
                    _gradientLayer?.removeFromSuperlayer()
                }
            }
        }
    }
    
    internal var _gradientLayer: GradientLayer? {
        firstSublayer(type: GradientLayer.self)
    }
}

/// The Objective-C class for ``Gradient``.
public class __Gradient: NSObject, NSCopying {
    let gradient: Gradient
    
    init(_ gradient: Gradient) {
        self.gradient = gradient
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __Gradient(gradient)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        gradient == (object as? __Gradient)?.gradient
    }
}

extension Gradient: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __Gradient
    
    public func _bridgeToObjectiveC() -> __Gradient {
        return __Gradient(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __Gradient, result: inout Gradient?) {
        result = source.gradient
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __Gradient, result: inout Gradient?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __Gradient?) -> Gradient {
        if let source = source {
            var result: Gradient?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return Gradient(colors: [])
    }
    
    public var description: String {
        "[stops: \(stops), type: \(type), start: \(startPoint), end: \(endPoint)]"
    }
    
    public var debugDescription: String {
        description
    }
}

fileprivate extension [NSUIColor] {
    var stops: [Gradient.ColorStop] {
        var stops: [Gradient.ColorStop] = []
        if count == 1 {
            stops.append(.init(color: self[0], location: 0.0))
        } else if count > 1 {
            let split = 1.0 / CGFloat(count - 1)
            for i in 0 ..< count {
                stops.append(.init(color: self[i], location: split * CGFloat(i)))
            }
        }
        return stops
    }
}

#endif
