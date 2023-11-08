//
//  Animation.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

/*
#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public class SpringAnimator1<T: AnimatableData>   {
    
    /// A unique identifier for the animation.
    public let id = UUID()
    
    public enum SpringAnimationState {
        /// The animation is inactive.
        case inactive
        /// The animation is active and ready to animate change
        case active
        /// The animation is animating.
        case animating
    }

    ///  The execution state of the animation (`inactive`, `running`, or `ended`).
    public private(set) var state: SpringAnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.active, .animating):
                startTime = .now
            default:
                break
            }
        }
    }

    /// The spring model that determines the animation's motion.
    public var spring: Spring

    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: T? {
        didSet { startAnimatingIfNeeded() }
    }
    
    var shouldStartAnimating: Bool {
        state == .active && value != nil && target != nil && value != target
    }
    
    func startAnimatingIfNeeded() {
        if shouldStartAnimating {
            self.state = .animating
         //   AnimationController.shared.runPropertyAnimation(self)
        }
    }

    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: T? {
        didSet {
            if state == .animating, let oldTarget = oldValue, let target = target, target != oldTarget {
                startTime = .now
                let event = AnimationEvent.retargeted(from: oldTarget, to: target)
                completion?(event)
            }
            startAnimatingIfNeeded()
        }
    }

    /**
     The current velocity of the animation.

     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: T

    /**
     The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
     */
    public var valueChanged: ((_ currentValue: T) -> Void)?

    /**
     The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     */
    public var completion: ((_ event: AnimationEvent<T>) -> Void)?

    /**
     The animation's `mode`. If set to `.nonAnimated`, the animation will snap to the target value when run.
     */
   // public var mode: Wave.AnimationMode = .animated

    /**
     Whether the values returned in `valueChanged` should be integralized to the screen's pixel boundaries.
     This helps prevent drawing frames between pixels, causing aliasing issues.

     Note: Enabling `integralizeValues` effectively quantizes `value`, so don't use this for values that are supposed to be continuous.
     */
    public var integralizeValues: Bool = false
    
    /// Determines if the animation is stopped upon reaching `target`. If set to `false`,  any changes to the target value will be animated.
    public var stopsOnCompletion: Bool = true

    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID?

    var startTime: TimeInterval?

    var relativePriority: Int = 0

    /**
     Creates a new animation with a given `Spring`, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - parameter spring: The spring model that determines the animation's motion.
     - parameter value: The initial, starting value of the animation.
     - parameter target: The target value of the animation.
     */
    public init(spring: Spring, value: T? = nil, target: T? = nil) {
        self.value = value
        self.target = target
        velocity = T.zero

        self.spring = spring
    }

    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        if state == .inactive {
            state = .active
        }
        
        guard shouldStartAnimating else {
            return
        }

        let start = {
            self.startAnimatingIfNeeded()
        }
        
        delayTask?.cancel()

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            delayTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }
    
    internal var delayTask: DispatchWorkItem? = nil

    /// Stops the animation at the current value.
    public func stop(immediately: Bool = true) {
        guard self.state != .inactive else { return }
        delayTask?.cancel()
        if state == .active {
            state = .inactive
        } else {
            if immediately {
                state = .inactive
                
                if let value = value, let completion = completion {
                    completion(.finished(at: value))
                }
            } else {
                awaitsInactiveState = true
                target = value
            }
        }
    }
    var awaitsInactiveState: Bool = false

    /**
     How long the animation will take to complete, based off its `spring` property.

     Note: This is useful for debugging purposes only. Do not use `settlingTime` to determine the animation's progress.
     */
    public var settlingTime: TimeInterval {
        spring.settlingDuration
    }

    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        spring = settings.spring
    }

    var runningTime: TimeInterval? {
        if let startTime = startTime {
            return (.now - startTime)
        } else {
            return nil
        }
    }

    func reset() {
        startTime = nil
        velocity = .zero
        state = .inactive
    }
    
    var epsilon: Double? = nil
    
    func updateAnimation(dt: TimeInterval) {
        guard var value = value, let target = target else {
            // Can't start an animation without a value and target
            state = .inactive
            return
        }

        guard let runningTime = runningTime else {
            fatalError("Found a nil `runningTime` even though the animation's state is \(state)")
        }


        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &value, velocity: &velocity, target: target, deltaTime: dt)
            self.value = value
        } else {
            self.value = target
            velocity = T.zero
        }

        let animationFinished = (runningTime >= settlingTime) || !isAnimated
        
        if animationFinished {
            self.value = target
        }

        if let value = self.value {
            let callbackValue = integralizeValues ? value.scaledIntegral : value
            valueChanged?(callbackValue)
        }

        if animationFinished {
            
            if awaitsInactiveState || stopsOnCompletion {
                state = .inactive
                awaitsInactiveState = false
            } else {
                state = .active
            }
            completion?(.finished(at: target))
        }
    }
}

extension SpringAnimator1: CustomStringConvertible {
    public var description: String {
        """
        Animation<\(T.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)

            value: \(String(describing: value))
            target: \(String(describing: target))
            velocity: \(String(describing: velocity))

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            integralizeValues: \(integralizeValues)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}
#endif
*/
