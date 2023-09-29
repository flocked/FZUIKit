//
//  Spring.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/**
 `Spring` determines the timing curve and settling duration of an animation.

 Springs are created by providing a `dampingRatio` greater than zero, and _either_ a `response` or `stiffness` value. See the initializers ``init(dampingRatio:response:mass:)`` and ``init(dampingRatio:stiffness:mass:)`` for usage information.
 */
public class Spring: Equatable {
    // MARK: - Spring Properties

    /**
     The amount of oscillation the spring will exhibit (i.e. "springiness").
     */
    public let dampingRatio: CGFloat

    /**
     Represents the frequency response of the spring. This value affects how
     quickly the spring animation reaches its target value.
     */
    public let response: CGFloat

    /**
     The spring constant `k`. Used as an alternative to `response`.
     */
    public let stiffness: CGFloat

    /**
     The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public let mass: CGFloat

    /**
     The viscous damping coefficient `c`. This value is derived.
     */
    public let dampingCoefficient: CGFloat

    /**
     The time the spring will take to settle or "complete". This value is derived.
     */
    public let settlingDuration: TimeInterval

    private static let DefaultSettlingPercentage = 0.0001

    // MARK: - Spring Initialization

    /**
     Creates a spring with the given damping ratio and frequency response.

     - parameter dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness").
     A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation.
     Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.

     - parameter stiffness: Represents the spring constant, `k`. This value affects how
     quickly the spring animation reaches its target value.  Using `stiffness` values is an alternative to
     configuring springs with a `response` value.

     - parameter mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(dampingRatio: CGFloat, stiffness: CGFloat, mass: CGFloat = 1.0) {
        precondition(stiffness > 0)
        precondition(dampingRatio > 0)

        self.dampingRatio = dampingRatio
        self.stiffness = stiffness
        self.mass = mass
        response = Spring.response(stiffness: stiffness, mass: mass)

        dampingCoefficient = Spring.dampingCoefficient(dampingRatio: dampingRatio, response: response, mass: mass)
        settlingDuration = Spring.settlingTime(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
    }

    /**
     Creates a spring with the given damping ratio and frequency response.

     - parameter dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness").
     A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation.
     Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.

     - parameter response: Represents the frequency response of the spring. This value affects how
     quickly the spring animation reaches its target value. The frequency response is the duration of one period
     in the spring's undamped system, measured in seconds.
     Values closer to `0` create a very fast animation, while values closer to `1.0` create a relatively slower animation.

     - parameter mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(dampingRatio: CGFloat, response: CGFloat, mass: CGFloat = 1.0) {
        precondition(dampingRatio >= 0)
        precondition(response >= 0)

        self.dampingRatio = dampingRatio
        self.response = response

        self.mass = mass
        stiffness = Spring.stiffness(response: response, mass: mass)

        let unbandedDampingCoefficient = Spring.dampingCoefficient(dampingRatio: dampingRatio, response: response, mass: mass)
        dampingCoefficient = rubberband(value: unbandedDampingCoefficient, range: 0 ... 60, interval: 15)

        settlingDuration = Spring.settlingTime(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
    }

    // MARK: - Default Springs

    /// A reasonable, slightly underdamped spring to use for interactive animations (like dragging an item around).
    public static let defaultInteractive = Spring(dampingRatio: 0.8, response: 0.20)

    /// A reasonable, critically damped spring to use for non-interactive animations.
    public static let defaultAnimated = Spring(dampingRatio: 1.0, response: 0.82)

    /// A placeholder spring to use when using the `nonAnimated` mode. See `AnimationMode` for more info.
    public static let defaultNonAnimated = Spring(dampingRatio: 1.0, response: 0.0)
    
    /// A smooth spring with a predefined duration and no bounce.
    public static let smooth = Spring(dampingRatio: 1.0, response: 0.5, mass: 1.0)
    
    /**
     A smooth spring with a predefined duration and no bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.
     */
    public static func smooth(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        Spring(dampingRatio: 1.0-extraBounce, response: duration, mass: 1.0)
    }
    
    /// A spring with a predefined duration and higher amount of bounce.
    public static let bouncy = Spring(dampingRatio: 0.7, response: 0.5, mass: 1.0)
    
    /**
     A spring with a predefined duration and higher amount of bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.3.
     */
    public static func bouncy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        Spring(dampingRatio: 0.7-extraBounce, response: duration, mass: 1.0)
    }
    
    /// iA spring with a predefined duration and small amount of bounce that feels more snappy.
    public static let snappy = Spring(dampingRatio: 0.85, response: 0.5, mass: 1.0)
    
    /**
     A spring with a predefined duration and small amount of bounce that feels more snappy and can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.15.
     */
    public static func snappy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        Spring(dampingRatio: 0.85-extraBounce, response: duration, mass: 1.0)
    }

    // MARK: - Equatable

    public static func == (lhs: Spring, rhs: Spring) -> Bool {
        return lhs.dampingRatio == rhs.dampingRatio && lhs.response == rhs.response && lhs.mass == rhs.mass
    }

    static func stiffness(response: CGFloat, mass: CGFloat) -> CGFloat {
        pow(2.0 * .pi / response, 2.0) * mass
    }

    static func response(stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        (2.0 * .pi) / sqrt(stiffness * mass)
    }

    static func dampingCoefficient(dampingRatio: CGFloat, response: CGFloat, mass: CGFloat) -> CGFloat {
        4.0 * .pi * dampingRatio * mass / response
    }

    static let logOfSettlingPercentage = log(Spring.DefaultSettlingPercentage)

    static func settlingTime(dampingRatio: CGFloat, stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        if stiffness == .infinity {
            // A non-animated mode (i.e. a `response` of 0) results in a stiffness of infinity, and a settling time of 0.
            // We need the settling time to be non-zero such that the display link stays alive.
            return 1.0
        }

        if dampingRatio >= 1.0 {
            let criticallyDampedSettlingTime = settlingTime(dampingRatio: 1.0 - .ulpOfOne, stiffness: stiffness, mass: mass)
            return criticallyDampedSettlingTime * 1.25
        }

        let undampedNaturalFrequency = Spring.undampedNaturalFrequency(stiffness: stiffness, mass: mass) // ωn
        return (-1 * (logOfSettlingPercentage / (dampingRatio * undampedNaturalFrequency)))
    }

    static func undampedNaturalFrequency(stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        // ωn
        return sqrt(stiffness / mass)
    }
}

extension Spring: CustomStringConvertible {
    public var description: String {
        """
        Spring(
            // Parameters
            dampingRatio: \(dampingRatio)
            response: \(response)
            mass: \(mass)

            // Derived
            settlingDuration: \(String(format: "%.3f", settlingDuration))
            stiffness: \(String(format: "%.3f", stiffness))
            animated: \(response != .zero)
        )
        """
    }
}
#endif
