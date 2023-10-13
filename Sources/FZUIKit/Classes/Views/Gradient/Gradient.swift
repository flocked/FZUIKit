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
        self.stops = Self.stops(for: colors)
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
        self.stops = Self.stops(for: preset.colors)
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    public static var none = Gradient(stops: [])
    
    internal static func stops(for colors: [NSUIColor]) -> [Stop] {
        var stops: [Stop] = []
        if colors.count == 1 {
            stops.append(Stop(color: colors[0], location: 0.0))
        } else if colors.count > 1 {
            let split = 1.0 / CGFloat(colors.count - 1)
            for i in 0..<colors.count {
                stops.append(Stop(color: colors[i], location: split*CGFloat(i)))
            }
        }
        return stops
    }
}

extension Gradient {
    /// The gradient type.
    public enum GradientType: String, Hashable {
        case linear = "axial"
        case conic = "conic"
        case radial = "radial"
        
        internal var gradientLayerType: CAGradientLayerType {
            CAGradientLayerType(rawValue: self.rawValue)
        }
        
        internal init(_ gradientLayerType: CAGradientLayerType) {
            self.init(rawValue: gradientLayerType.rawValue)!
        }
    }
    
    /// One color stop in the gradient.
    public struct Stop: Hashable {
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
    public struct Point: Hashable {
        public var x: CGFloat
        public var y: CGFloat
        
        public init() {
            self.x = 0
            self.y = 0
        }
        
        public init(x: CGFloat, y: CGFloat) {
            self.x = x
            self.y = y
        }
        
        internal init(_ point: CGPoint) {
            self.x = point.x
            self.y = point.y
        }
        
        internal var point: CGPoint {
            CGPoint(x, y)
        }
        
        public static var topLeading = Point(x: 0.0, y: 0.0)
        public static var top = Point(x: 0.5, y: 0.0)
        public static var topTrailing = Point(x: 1.0, y: 0.0)
        
        public static var leading = Point(x: 0.0, y: 0.5)
        public static var center = Point(x: 0.5, y: 0.5)
        public static var trailing = Point(x: 1.0, y: 0.5)

        public static var bottomLeading = Point(x: 0.0, y: 1.0)
        public static var bottom = Point(x: 0.5, y: 1.0)
        public static var bottomTrailing = Point(x: 1.0, y: 1.0)
    }
}

extension Gradient.Stop: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: Gradient.Stop, target: Gradient.Stop, velocity: Gradient.Stop, dt: TimeInterval) -> (value: Gradient.Stop, velocity: Gradient.Stop) {
        let color = NSUIColor.updateValue(spring: spring, value: value.color, target: target.color, velocity: velocity.color, dt: dt)
        let location = CGFloat.updateValue(spring: spring, value: value.location, target: target.location, velocity: velocity.location, dt: dt)
        return (Gradient.Stop(color: color.value, location: location.value), Gradient.Stop(color: color.velocity, location: velocity.location))
    }
    
    public var scaledIntegral: Gradient.Stop {
        Gradient.Stop(color: self.color.scaledIntegral, location: self.location.scaledIntegral)
    }
    
    public static var zero: Gradient.Stop {
        Gradient.Stop(color: .zero, location: .zero)
    }
}

extension Gradient: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: Gradient, target: Gradient, velocity: Gradient, dt: TimeInterval) -> (value: Gradient, velocity: Gradient) {
        var value = value
        var target = target
        var velocity = velocity
        let diff = target.stops.count - value.stops.count
        if diff < 0 {
            let toRemove = (diff * -1)
            let keep = (value.stops.count - toRemove)
            for var stop in value.stops[keep..<value.stops.count] {
                stop.color = stop.color.withAlphaComponent(0.0)
                target.stops.append(stop)
                if velocity.stops.count < target.stops.count {
                    velocity.stops.append(.zero)
                }
            }
        } else if diff > 0 {
            let count = value.stops.count
            for i in 0..<diff {
                var targetStop = target.stops[count+i]
                targetStop.color = targetStop.color.withAlphaComponent(0.0)
                value.stops.append(targetStop)
                if velocity.stops.count < value.stops.count {
                    velocity.stops.append(.zero)
                }
            }
        }
        
        Swift.print("stops", value.stops.count, target.stops.count, velocity.stops.count)
        Swift.print("value colors")
        for stop in value.stops {
            Swift.print(stop.color)
        }
        Swift.print("target colors")
        for stop in target.stops {
            Swift.print(stop.color)
        }
        
        var stops: [(value: Gradient.Stop, velocity: Gradient.Stop)] = []
        for i in 0..<target.stops.count {
            stops.append(Gradient.Stop.updateValue(spring: spring, value: value.stops[i], target: target.stops[i], velocity: velocity.stops[i], dt: dt))
        }
        
        let valueStops = stops.compactMap({$0.value})
        let velocityStops = stops.compactMap({$0.velocity})

        let startPoint = CGPoint.updateValue(spring: spring, value: value.startPoint.point, target: target.startPoint.point, velocity: velocity.startPoint.point, dt: dt)
        let endPoint = CGPoint.updateValue(spring: spring, value: value.endPoint.point, target: target.endPoint.point, velocity: velocity.endPoint.point, dt: dt)
        
        return (Gradient(stops: valueStops, startPoint: .init(startPoint.value), endPoint: .init(endPoint.value), type: target.type), Gradient(stops: velocityStops, startPoint: .init(startPoint.velocity), endPoint: .init(endPoint.velocity), type: target.type))
    }
    
    public typealias ValueType = Gradient
    
    public typealias VelocityType = Gradient
    
    public var scaledIntegral: Gradient {
        Gradient(stops: stops.compactMap({$0.scaledIntegral}), startPoint: .init(startPoint.point.scaledIntegral), endPoint: .init(endPoint.point.scaledIntegral), type: type)
    }
    
    public static var zero: Gradient {
        Gradient(stops: [])
    }
}

#endif

