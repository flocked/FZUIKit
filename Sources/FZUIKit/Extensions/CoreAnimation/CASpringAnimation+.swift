//
//  File.swift
//  
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
import QuartzCore

extension CASpringAnimation {
    /**
     Creates a spring animation with the given damping ratio and frequency response.

     - parameter dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness").
     A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation.
     Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.

     - parameter stiffness: Represents the spring constant, `k`. This value affects how
     quickly the spring animation reaches its target value.  Using `stiffness` values is an alternative to
     configuring springs with a `response` value.

     - parameter mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public convenience init(dampingRatio: CGFloat, stiffness: CGFloat, mass: CGFloat = 1.0) {
        self.init()
        self.mass = mass
        self.stiffness = stiffness
        self.damping = dampingRatio * 2 * sqrt(mass * stiffness)
        self.duration = Spring.response(stiffness: stiffness, mass: mass)
    }
    
    /**
     Creates a spring animation with the given damping ratio and frequency response.

     - parameter dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness").
     A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation.
     Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.

     - parameter response: Represents the frequency response of the spring. This value affects how
     quickly the spring animation reaches its target value. The frequency response is the duration of one period
     in the spring's undamped system, measured in seconds.
     Values closer to `0` create a very fast animation, while values closer to `1.0` create a relatively slower animation.

     - parameter mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public convenience init(dampingRatio: CGFloat, response: CGFloat, mass: CGFloat = 1.0) {
        self.init()
        self.mass = mass
        self.duration = response
        self.stiffness = Spring.stiffness(response: response, mass: mass)
        self.damping = dampingRatio * 2 * sqrt(mass * stiffness)
    }
    
    /// A spring animation with a predefined duration and higher amount of bounce.
    public static let bouncy = CASpringAnimation(dampingRatio: 0.7, response: 0.5, mass: 1.0)
    
    /**
     A spring animation with a predefined duration and higher amount of bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.3.
     */
    public static func bouncy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> CASpringAnimation {
        CASpringAnimation(dampingRatio: 0.7-extraBounce, response: duration, mass: 1.0)
    }
    
    /// A smooth spring animation with a predefined duration and no bounce.
    public static let smooth = CASpringAnimation(dampingRatio: 1.0, response: 0.5, mass: 1.0)
    
    /**
     A smooth spring animation with a predefined duration and no bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.
     */
    public static func smooth(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> CASpringAnimation {
        CASpringAnimation(dampingRatio: 1.0-extraBounce, response: duration, mass: 1.0)
    }
    
    /// A spring animation with a predefined duration and small amount of bounce that feels more snappy.
    public static let snappy = CASpringAnimation(dampingRatio: 0.85, response: 0.5, mass: 1.0)
    
    /**
     A spring animation with a predefined duration and small amount of bounce that feels more snappy and can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.15.
     */
    public static func snappy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> CASpringAnimation {
        CASpringAnimation(dampingRatio: 0.85-extraBounce, response: duration, mass: 1.0)
    }
    
    public var velocity: CGFloat {
        self.value(forKey: "velocity") as! CGFloat
    }
    
    internal convenience init(_ spring: Spring) {
        self.init()
        Swift.print("spring start", self.settlingDuration, self.mass, self.stiffness, self.damping)
        self.mass = spring.mass
        self.stiffness = spring.stiffness
        let damping =  spring.dampingRatio * 2 * sqrt(spring.mass * spring.stiffness)
        let unbandedDampingCoefficient = Spring.dampingCoefficient(dampingRatio: spring.dampingRatio, response: spring.response, mass: spring.mass)
        self.damping = spring.dampingCoefficient
        Swift.print("spring ", damping, spring.dampingCoefficient, unbandedDampingCoefficient, spring.dampingRatio)
      //  self.duration = spring.response
    }
    
}
