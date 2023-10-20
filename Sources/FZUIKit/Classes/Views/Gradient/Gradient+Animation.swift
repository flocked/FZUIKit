//
//  Gradient+Animation.swift
//  
//
//  Created by Florian Zand on 13.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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
            }
        } else if diff > 0 {
            let count = value.stops.count
            for i in 0..<diff {
                var targetStop = target.stops[count+i]
                targetStop.color = targetStop.color.withAlphaComponent(0.0)
                value.stops.append(targetStop)
            }
        }
        
        let velocityDiff = target.stops.count - velocity.stops.count
        if velocityDiff > 0 {
            for _ in 0..<velocityDiff {
                velocity.stops.append(.zero)
            }
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

/*
extension Animator where Object: GradientView {
    /// The gradient of the view.
    public var gradient: Gradient {
        get { value(for: \.gradient, key: "gradient") }
        set { setValue(newValue, for: \.gradient, key: "gradient") }
    }
}
 */


#endif
