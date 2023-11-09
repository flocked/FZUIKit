//
//  DecayFunction.swift
//  
//  Adopted from:
//  Motion. Created by Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation
import SwiftUI

public struct DecayFunction {
    /// The standard decay constant of a scrollview.
    public static let ScrollViewDecayConstant: Double = 0.998
    
    /// The rate at which the velocity decays over time. Defaults to `UIKitDecayConstant`.
    public var decayConstant: Double {
        didSet {
            updateConstants()
        }
    }

    /**
     A value used to round the final value. Defaults to 0.5.

     - Description: This is useful when implementing things like scroll views, where the final value will rest on nice pixel values so that text remains sharp. It defaults to 0.5, but applying 1.0 / the scale factor of the view will lead to similar behaviours as `UIScrollView`. Setting this to `0.0` disables any rounding.
     */
    public var roundingFactor: Double = 0.5

    /// A cached invocation of `1.0 / (ln(decayConstant) * 1000.0)`
    private(set) public var one_ln_decayConstant_1000: Double = 0.0
    
    /**
      Initializes a decay function.

      - Parameters:
         - decayConstant: The rate at which the velocity decays over time. Defaults to `UIKitDecayConstant`.
      */
    public init(decayConstant: Double = Self.ScrollViewDecayConstant) {
         self.decayConstant = decayConstant
         // Explicitly update constants.
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
    public func update<V>(value: inout V, velocity: inout V, deltaTime: TimeInterval) where V : AnimatableData {
        var valueAnimatableData = value.animatableData
        var velocityAnimatableData = velocity.animatableData
        update(value: &valueAnimatableData, velocity: &velocityAnimatableData, deltaTime: deltaTime)
        value = V(valueAnimatableData)
        velocity = V(velocityAnimatableData)
    }
    
    /**
     Solves the destination for the decay function based on the given parameters for a `Value`.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public func value<V>(value: V, velocity: V, decayConstant: Double = Self.ScrollViewDecayConstant) -> V where V : VectorArithmetic {
        let decay = log(decayConstant) * 1000
        let toValue = value - velocity.scaled(by: 1.0 / decay)
        // -2.0020026706730794
        // -4
        // 20
        return toValue
    }
    
    /**
     Solves the destination for the decay function based on the given parameters for a `Value`.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decayConstant: The decay constant.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public func value<V>(value: V, velocity: V, decayConstant: Double = Self.ScrollViewDecayConstant) -> V where V : AnimatableData {
        return V(self.value(value: value.animatableData, velocity: velocity.animatableData, decayConstant: decayConstant))
    }
    
    /*
    public func value(value: AnimatableVector, velocity: Double, decayConstant: Double = Self.ScrollViewDecayConstant) -> AnimatableVector {
        let velocity = AnimatableVector(Array(repeating: velocity, count: value.count))
        return AnimatableVector(self.value(value: value, velocity: velocity, decayConstant: decayConstant))
    }
    
    public func value<V>(value: V, velocity: Double, decayConstant: Double = Self.ScrollViewDecayConstant) -> V where V : AnimatableData, V.AnimatableData == AnimatableVector {
       return V(self.value(value: value.animatableData, velocity: velocity, decayConstant: decayConstant))
    }
    */
    
    /**
     Solves the velocity required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decayConstant: The decay constant.

     - Returns: The velocity required to reach `toValue`.
     */
    public func velocity<V>(fromValue: V, toValue: V, decayConstant: Double = Self.ScrollViewDecayConstant) -> V where V : VectorArithmetic {
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
    public func velocity<V>(fromValue: V, toValue: V, decayConstant: Double = Self.ScrollViewDecayConstant) -> V where V : AnimatableData {
        V(self.velocity(fromValue: fromValue.animatableData, toValue: toValue.animatableData, decayConstant: decayConstant))
    }
}
