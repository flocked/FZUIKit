//
//  EasingAnimator.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation
import FZSwiftUtils

/// An animator that animates a value using an easing function.
public class EasingAnimator<Value: AnimatableData>: AnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID?

    /// The relative priority of the animation.
    var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// A Boolean value indicating whether the animation is currently running.
    public internal(set)var isRunning: Bool = false
    
    /// The information used to determine the timing curve for the animation.
    public var timingFunction: TimingFunction = .easeInEaseOut
    
    /// The total duration (in seconds) of the animation.
    public var duration: CGFloat = 0.0
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false {
        didSet { guard oldValue != isReversed else { return }
            fractionComplete = 1.0 - fractionComplete
        }
    }
    
    /**
     A Boolean value that indicates whether the values returned in ``valueChanged`` should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.

     - Note: Enabling `integralizeValues` effectively quantizes ``value``, so don't use this for values that are supposed to be continuous.
     */
    public var integralizeValues: Bool = false
    
    /// The completion percentage of the animation.
    public var fractionComplete: CGFloat = 0.0 {
        didSet {
            if (0...1.0).contains(fractionComplete) == false {
                fractionComplete = fractionComplete.clamped(max: 1.0)
            }
        }
    }
    
    var resolvedFractionComplete: CGFloat {
        timingFunction.solve(at: fractionComplete, duration: duration)
    }
    
    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: Value?
    
    /// The start value of the animation.
    var fromValue: Value?
    
    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value? {
        didSet {
            guard let oldValue = oldValue, let newValue = target else {
                return
            }

            if oldValue == newValue {
                return
            }

            if state == .running {
                fractionComplete = 0.0
                let event = AnimationEvent.retargeted(from: oldValue, to: newValue)
                completion?(event)
            }
        }
    }
        
    /// The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?

    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: Value? = nil, target: Value? = nil) {
        self.value = value
        self.fromValue = value
        self.target = target
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    /**
     Creates a new animation with the specified easing function, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - easing: The easing function of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    convenience init(easing: EasingFunction, value: Value? = nil, target: Value? = nil) {
        self.init(timingFunction: easing.timingFunction, duration: easing.duration, value: value, target: target)
        repeats = easing.repeats
    }
    
    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        guard isRunning == false else { return }
        precondition(value != nil, "Animation must have a non-nil `value` before starting.")
        precondition(target != nil, "Animation must have a non-nil `target` before starting.")
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")

        Swift.print("start", value ?? "nil", fromValue ?? "nil", target ?? "nil", duration)
        
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
    
    public func pauseAnimation() {
        guard state == .running else { return }
        delayedStart?.cancel()
        AnimationController.shared.stopPropertyAnimation(self)
        isRunning = false
    }

    /// Stops the animation at the current value.
    public func stop(immediately: Bool = true) {
        delayedStart?.cancel()
        isRunning = false
        if immediately {
            state = .ended
            if let value = value, let completion = completion {
                completion(.finished(at: value))
            }
        } else {
            target = value
        }
    }
    
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
    }
    
    /// Resets the animation.
    func reset() {
        state = .inactive
    }
    
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval) {
        guard var value = value, let fromValue = fromValue, let target = target else {
            // Can't start an animation without a value and target
            state = .inactive
            return
        }
                
        state = .running
                
        let isAnimated = duration > .zero
        
        Swift.print("updateAnimation 0", isAnimated, duration, deltaTime)

        guard deltaTime > 0.0 else { return }
        
        if isAnimated {
            let part = duration/deltaTime
            
            Swift.print("updateAnimation 1", part, fractionComplete)

            
            fractionComplete = isReversed ? (fractionComplete - part) : (fractionComplete + part)
            Swift.print("updateAnimation 2", fractionComplete, value)

            value = Value(fromValue.animatableData.interpolated(towards: target.animatableData, amount: resolvedFractionComplete))
            Swift.print("updateAnimation 3", fractionComplete, value)

            self.value = value
        } else {
            self.value = target
        }
        
        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated
        
        Swift.print("updateAnimation 4", animationFinished)

        
        if animationFinished {
            self.value = target
        }

        if let value = self.value {
            let callbackValue = integralizeValues ? value.scaledIntegral : value
            valueChanged?(callbackValue)
        }

        if animationFinished {
            if repeats, isAnimated {
                fractionComplete = isReversed ? 1.0 : 0.0
                value = Value(isReversed ? target.animatableData : fromValue.animatableData)
                self.value = value
                let callbackValue = integralizeValues ? value.scaledIntegral : value
                valueChanged?(callbackValue)
            } else {
                stop(immediately: true)
            }
        }
    }
}

extension EasingAnimator: CustomStringConvertible {
    public var description: String {
        """
        EasingAnimator<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)
            isRunning: \(isRunning)
            fractionComplete: \(fractionComplete)
            isReversed: \(isReversed)

            value: \(String(describing: value))
            target: \(String(describing: target))
            from: \(String(describing: fromValue))

            timingFunction: \(timingFunction.name)
            duration: \(duration)
            repeats: \(repeats)
            integralizeValues: \(integralizeValues)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}
