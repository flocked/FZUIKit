//
//  CASpringAnimation+.swift
//
//
//  Created by Florian Zand on 04.01.25.
//

#if canImport(QuartzCore)
import Foundation
import QuartzCore

extension CASpringAnimation {
    /// A reasonable, slightly underdamped spring to use for interactive animations (like dragging an item around).
    public static let interactive = CASpringAnimation(response: 0.28, dampingRatio: 0.86)

    /// A spring with a predefined duration and higher amount of bounce.
    public static let bouncy = CASpringAnimation.bouncy()

    /**
     A spring with a predefined duration and higher amount of bounce that can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.3.
     */
    public static func bouncy(duration: Double = 0.5, extraBounce: Double = 0.0) -> CASpringAnimation {
        CASpringAnimation(response: duration, dampingRatio: 0.7 - extraBounce, mass: 1.0)
    }

    /// A smooth spring with a predefined duration and no bounce.
    public static let smooth = CASpringAnimation.smooth()

    /**
     A smooth spring with a predefined duration and no bounce that can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.
     */
    public static func smooth(duration: Double = 0.5, extraBounce: Double = 0.0) -> CASpringAnimation {
        CASpringAnimation(response: duration, dampingRatio: 1.0 - extraBounce, mass: 1.0)
    }

    /// A spring with a predefined duration and small amount of bounce that feels more snappy.
    public static let snappy = CASpringAnimation.snappy()

    /**
     A spring with a predefined duration and small amount of bounce that feels more snappy and can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.15.
     */
    public static func snappy(duration: Double = 0.5, extraBounce: Double = 0.0) -> CASpringAnimation {
        CASpringAnimation(response: duration, dampingRatio: 0.85 - extraBounce, mass: 1.0)
    }
    
    /// Creates a spring animation with `stiffness`, `dampingRatio`, and `mass`.
    public convenience init(stiffness: Double, dampingRatio: Double, mass: Double = 1.0) {
        self.init()
        
        let response = Self.response(stiffness: stiffness, mass: mass)
        self.stiffness = stiffness
        self.mass = mass
        self.damping = Self.damping(dampingRatio: dampingRatio, response: response, mass: mass)
        self.duration = settlingDuration
    }
    
    /// Creates a spring animation with `response`, `dampingRatio`, and `mass`.
    public convenience init(response: Double, dampingRatio: Double, mass: Double = 1.0) {
        self.init()
        self.mass = 1.0
        stiffness = Self.stiffness(response: response, mass: mass)
       // self.damping = 4 * .pi * dampingRatio / response
        let unbandedDampingCoefficient = Self.damping(dampingRatio: dampingRatio, response: response, mass: mass)
        damping = Rubberband.value(for: unbandedDampingCoefficient, range: 0 ... 60, interval: 15)
        duration = settlingDuration
    }
    
    static func response(stiffness: Double, mass: Double) -> Double {
        (2.0 * .pi) / sqrt(stiffness * mass)
    }
    
    static func stiffness(response: Double, mass: Double) -> Double {
        pow(2.0 * .pi / response, 2.0) * mass
    }
    
    static func damping(dampingRatio: Double, response: Double, mass: Double) -> Double {
        4.0 * .pi * dampingRatio * mass / response
    }
    
    static func settlingTime(dampingRatio: Double, stiffness: Double, mass: Double, epsilon: Double = defaultSettlingPercentage) -> Double {
        if stiffness == .infinity {
            // A non-animated mode (i.e. a `response` of 0) results in a stiffness of infinity, and a settling time of 0.
            // We need the settling time to be non-zero such that the display link stays alive.
            return 1.0
        }

        if dampingRatio >= 1.0 {
            let criticallyDampedSettlingTime = settlingTime(dampingRatio: 1.0 - .ulpOfOne, stiffness: stiffness, mass: mass)
            return criticallyDampedSettlingTime * 1.25
        }

        let undampedNaturalFrequency = Self.undampedNaturalFrequency(stiffness: stiffness, mass: mass) // ωn
        return -1 * (log(epsilon) / (dampingRatio * undampedNaturalFrequency))
    }
    
    static let defaultSettlingPercentage = 0.001

    static func undampedNaturalFrequency(stiffness: Double, mass: Double) -> Double {
        sqrt(stiffness / mass)
    }
}
#endif
