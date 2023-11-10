//
//  Animation.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// An animator that animates a value using a physically-modeled spring.
public class SpringAnimation<Value: AnimatableProperty>: AnimationProviding   {
    
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID?
    
    /// The relative priority of the animation.
    var relativePriority: Int = 0

    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                startTime = .now

            default:
                break
            }
        }
    }
    
    /// A Boolean value indicating whether the animation is currently running.
    public internal(set)var isRunning: Bool = false

    /// The spring model that determines the animation's motion.
    public var spring: Spring
    
    /**
     How long the animation will take to complete, based off its `spring` property.

     - Note: This is useful for debugging purposes only. Do not use `settlingTime` to determine the animation's progress.
     */
    public var settlingTime: TimeInterval {
        spring.settlingDuration
    }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// Determines if the animation is stopped upon reaching `target`. If set to `false`,  any changes to the target value will be animated.
    public var stopsOnCompletion: Bool = true

    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: Value

    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        didSet {
            guard oldValue != target else {
                return
            }

            if state == .running {
                startTime = .now

                let event = AnimationEvent.retargeted(from: oldValue, to: target)
                completion?(event)
            }
        }
    }

    /**
     The current velocity of the animation.

     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: Value

    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /// The start time of the animation.
    var startTime: TimeInterval?
    
    /// The total running time of the animation.
    var runningTime: TimeInterval? {
        if let startTime = startTime {
            return (.now - startTime)
        } else {
            return nil
        }
    }
    
    /**
     Creates a new animation with a ``Spring/snappy`` spring, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(value: Value, target: Value, velocity: Value = .zero) {
        self.value = value
        self.target = target
        self.velocity = velocity
        self.spring = .snappy
    }

    /**
     Creates a new animation with a given ``Spring``, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - spring: The spring model that determines the animation's motion.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(spring: Spring, value: Value, target: Value, velocity: Value = .zero) {
        self.value = value
        self.target = target
        self.velocity = velocity
        self.spring = spring
    }

    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        guard isRunning == false else { return }
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")

        let start = {
            self.isRunning = true
            AnimationController.shared.runPropertyAnimation(self)
        }
        
        delayedStart?.cancel()

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }
    
    var delayedStart: DispatchWorkItem? = nil

    /// Stops the animation at the current value.
    public func stop(immediately: Bool = true) {
        delayedStart?.cancel()
        isRunning = false
        if immediately {
            state = .ended

            if let completion = completion {
                completion(.finished(at: value))
            }
        } else {
            target = value
        }
    }
    
    /// Stops the animation immediately at the specified value.
    internal func stop(at value: Value) {
        AnimationController.shared.stopPropertyAnimation(self)
        self.value = value
        target = value
        isRunning = false
        state = .inactive
        let callbackValue = integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)
        if let completion = self.completion {
            completion(.finished(at: value))
        }
    }

    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        spring = settings.spring
        if let gestureVelocity = settings.gestureVelocity {
            (self as? SpringAnimation<CGRect>)?.velocity.origin = gestureVelocity
            (self as? SpringAnimation<CGPoint>)?.velocity = gestureVelocity
        }
    }

    /// Resets the animation.
    func reset() {
        startTime = nil
        velocity = .zero
        state = .inactive
    }
    
    var epsilon: Double? = nil
    
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval) {
        guard value != target else {
            state = .inactive
            return
        }

        state = .running

        guard let runningTime = runningTime else {
            fatalError("Found a nil `runningTime` even though the animation's state is \(state)")
        }


        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &value, velocity: &velocity, target: target, deltaTime: deltaTime)
        } else {
            self.value = target
            velocity = Value.zero
        }

        let animationFinished = (runningTime >= settlingTime) || !isAnimated
        
        /*
        if animationFinished == false, let epsilon = self.epsilon, let value = self.value?.animatableValue as? AnimatableVector, let target = self.target?.animatableValue as? AnimatableVector {
            let val = value.isApproximatelyEqual(to: target, epsilon: epsilon)
            Swift.print("isApproximatelyEqual", val)
            animationFinished = val
        }
         */
        
        if animationFinished {
            value = target
        }

        let callbackValue = (animationFinished && integralizeValues) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished {
            stop(immediately: true)
        }
    }
}

extension SpringAnimation: CustomStringConvertible {
    public var description: String {
        """
        SpringAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)
            isRunning: \(isRunning)

            value: \(String(describing: value))
            target: \(String(describing: target))
            velocity: \(String(describing: velocity))

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            settlingTime: \(settlingTime)
            integralizeValues: \(integralizeValues)
            stopsOnCompletion: \(stopsOnCompletion)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}
#endif
