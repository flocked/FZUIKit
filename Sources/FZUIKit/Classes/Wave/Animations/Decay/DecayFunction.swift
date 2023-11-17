//
//  DecayFunction.swift
//  
//  Adopted from:
//  Motion. Created by Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 09.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import SwiftUI

public struct DecayFunction {
    /// The default deceleration rate for a scroll view.
    public static let ScrollViewDecelerationRate: Double = 0.998
    
    /// A fast deceleration rate for a scroll view.
    public static let ScrollViewDecelerationRateFast: Double = 0.99
    
    /// The rate at which the velocity decays over time.
    public var decayConstant: Double {
        didSet {
            updateConstants()
        }
    }

    /// A cached invocation of `1.0 / (ln(decayConstant) * 1000.0)`
    private(set) public var one_ln_decayConstant_1000: Double = 0.0
    
    /**
      Initializes a decay function.

      - Parameters:
         - decayConstant: The rate at which the velocity decays over time. Defaults to ``ScrollViewDecelerationRate``.
      */
    public init(decayConstant: Double = ScrollViewDecelerationRate) {
         self.decayConstant = decayConstant
         updateConstants()
     }

     fileprivate mutating func updateConstants() {
         self.one_ln_decayConstant_1000 =  1.0 / (log(decayConstant) * 1000.0)
     }
    
    /// Updates the current value and velocity of a decay animation.
    public func update<V>(value: inout V, velocity: inout V, deltaTime: TimeInterval) where V : VectorArithmetic {
        let d_1000_dt = pow(decayConstant, deltaTime * 1000.0)
        
        // Analytic decay equation with constants extracted out.
        value = value + velocity.scaled(by:  ((d_1000_dt - 1.0) * one_ln_decayConstant_1000))
        
        // Velocity is the derivative of the above equation
        velocity = velocity.scaled(by: d_1000_dt)
    }
    
    /// Updates the current value and velocity of a decay animation.
    public func update<V>(value: inout V, velocity: inout V, deltaTime: TimeInterval) where V : AnimatableProperty {
        var valueAnimatableData = value.animatableData
        var velocityAnimatableData = velocity.animatableData
        update(value: &valueAnimatableData, velocity: &velocityAnimatableData, deltaTime: deltaTime)
        value = V(valueAnimatableData)
        velocity = V(velocityAnimatableData)
    }
}

extension DecayFunction {
    /**
     Solves the destination for the specified value and starting velocity.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public static func destination<V>(value: V, velocity: V, decayConstant: Double = Self.ScrollViewDecelerationRate) -> V where V : VectorArithmetic {
        let decay = log(decayConstant) * 1000
        let toValue = value - velocity.scaled(by: 1.0 / decay)
        return toValue
    }
    
    /**
     Solves the destination for the specified value and starting velocity.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.
        - integralizeValue: A Boolean value that indicates whether the destionation value should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is 'false'.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public static func destination<V>(value: V, velocity: V, decayConstant: Double = Self.ScrollViewDecelerationRate, integralizeValue: Bool = false) -> V where V : AnimatableProperty {
        if integralizeValue {
            return V(self.destination(value: value.animatableData, velocity: velocity.animatableData, decayConstant: decayConstant)).scaledIntegral
        }
        return V(self.destination(value: value.animatableData, velocity: velocity.animatableData, decayConstant: decayConstant))
    }
    
    /**
     Solves the velocity required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decayConstant: The decay constant.

     - Returns: The velocity required to reach `toValue`.
     */
    public static func velocity<V>(fromValue: V, toValue: V, decayConstant: Double = Self.ScrollViewDecelerationRate) -> V where V : VectorArithmetic {
        let decay = log(decayConstant) * 1000.0
        return (fromValue - toValue).scaled(by: decay)
    }
    
    /**
     Solves the velocity required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decayConstant: The decay constant.

     - Returns: The velocity required to reach `toValue`.
     */
    public static func velocity<V>(fromValue: V, toValue: V, decayConstant: Double = Self.ScrollViewDecelerationRate) -> V where V : AnimatableProperty {
        V(self.velocity(fromValue: fromValue.animatableData, toValue: toValue.animatableData, decayConstant: decayConstant))
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: VectorArithmetic>(value: Value, velocity: Value, decayConstant: Double = Self.ScrollViewDecelerationRate) -> TimeInterval {
        var value = value
        var velocity = velocity
        let decayFunction = DecayFunction(decayConstant: decayConstant)
        let deltaTime = 1.0 / 60.0
        var duration: TimeInterval = 0.0
        var hasResolved = false
        while !hasResolved {
            decayFunction.update(value: &value, velocity: &velocity, deltaTime: deltaTime)
            hasResolved = velocity.magnitudeSquared < 0.05
            duration = duration + deltaTime
        }
        return duration
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decayConstant: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: VectorArithmetic>(fromValue value: Value, toValue: Value, decayConstant: Double = Self.ScrollViewDecelerationRate) -> TimeInterval {
        let velocity = DecayFunction.velocity(fromValue: value, toValue: toValue)
        return self.duration(value: value, velocity: velocity, decayConstant: decayConstant)
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: AnimatableProperty>(value: Value, velocity: Value, decayConstant: Double = Self.ScrollViewDecelerationRate) -> TimeInterval {
        return duration(value: value.animatableData, velocity: velocity.animatableData, decayConstant: decayConstant)
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decayConstant: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: AnimatableProperty>(fromValue value: Value, toValue: Value, decayConstant: Double = Self.ScrollViewDecelerationRate) -> TimeInterval {
        return duration(fromValue: value.animatableData, toValue: toValue.animatableData, decayConstant: decayConstant)
    }
}

/*
/**
 Solves the destination frame for the specified frame and starting velocity.

 - Parameters:
    - frame: The starting frame.
    - velocity: The starting velocity of the decay.
    - decayConstant: The decay constant.

 - Returns: The destination frame when the decay reaches zero velocity.
 */
public static func destination(frame: CGRect, velocity: CGPoint, decayConstant: Double = Self.ScrollViewDecelerationRate) -> CGRect {
    var frame = frame
    frame.origin = destination(value: frame.origin, velocity: velocity, decayConstant: decayConstant)
    return frame
}

public func destination(value: AnimatableVector, velocity: Double, decayConstant: Double = Self.ScrollViewDecelerationRate) -> AnimatableVector {
    let velocity = AnimatableVector(Array(repeating: velocity, count: value.count))
    return AnimatableVector(self.value(value: value, velocity: velocity, decayConstant: decayConstant))
}

public func destination<V>(value: V, velocity: Double, decayConstant: Double = Self.ScrollViewDecelerationRate) -> V where V : AnimatableData, V.AnimatableData == AnimatableVector {
   return V(self.value(value: value.animatableData, velocity: velocity, decayConstant: decayConstant))
}
*/

/*
 /**
  A value used to round the final value. Defaults to 0.5.

  - Description: This is useful when implementing things like scroll views, where the final value will rest on nice pixel values so that text remains sharp. It defaults to 0.5, but applying 1.0 / the scale factor of the view will lead to similar behaviours as `UIScrollView`. Setting this to `0.0` disables any rounding.
  */
 public var roundingFactor: Double = 0.5
 */

#endif
