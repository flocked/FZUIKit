//
//  File.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation

public class EasingAnimatorN<T: AnimatableData>: AnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    ///  The execution state of the animation (`inactive`, `running`, or `ended`).
    public private(set) var state: AnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                runningTime = 0.0
                
            default:
                break
            }
        }
    }
    
    public var timingFunction: TimingFunction = .easeInEaseOut
    
    public var duration: CGFloat = 0.0
    
    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: T?
    
    internal var fromValue: T?
    
    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: T? {
        didSet {
            guard let oldValue = oldValue, let newValue = target else {
                return
            }

            if oldValue == newValue {
                return
            }

            if state == .running {
                runningTime = 0.0

                let event = AnimationEvent.retargeted(from: oldValue, to: newValue)
                completion?(event)
            }
        }
    }
    
    public var fractionComplete: CGFloat = 0.0
    
    public var isReversed: Bool = false
    
    /**
     The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
     */
    public var valueChanged: ((_ currentValue: T) -> Void)?

    /**
     The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     */
    public var completion: ((_ event: AnimationEvent<T>) -> Void)?
    
    /**
     Whether the values returned in `valueChanged` should be integralized to the screen's pixel boundaries.
     This helps prevent drawing frames between pixels, causing aliasing issues.

     Note: Enabling `integralizeValues` effectively quantizes `value`, so don't use this for values that are supposed to be continuous.
     */
    public var integralizeValues: Bool = false
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID?

    var relativePriority: Int = 0

    /**
     Creates a new animation with a given `Spring`, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - parameter spring: The spring model that determines the animation's motion.
     - parameter value: The initial, starting value of the animation.
     - parameter target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: T? = nil, target: T? = nil) {
        self.value = value
        self.fromValue = value
        self.target = target
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        precondition(value != nil, "Animation must have a non-nil `value` before starting.")
        precondition(target != nil, "Animation must have a non-nil `target` before starting.")
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")

        let start = {
            AnimationController.shared.runPropertyAnimation(self)
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
    
    public func pauseAnimation() {
        
    }

    /// Stops the animation at the current value.
    public func stop(immediately: Bool = true) {
        delayTask?.cancel()
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

    var runningTime: TimeInterval = 0.0
    
    func reset() {
        runningTime = 0.0
        state = .inactive
    }
    
    func updateAnimation(dt: TimeInterval) {
        guard var value = value, let fromValue = fromValue, let target = target else {
            // Can't start an animation without a value and target
            state = .inactive
            return
        }
        
        state = .running
        
        runningTime += dt
        
        let isAnimated = duration > .zero
        
        if isAnimated {
           var fraction = runningTime/duration
            fractionComplete = timingFunction.solve(at: fraction, duration: duration)
            value = T(fromValue.animatableData.interpolated(towards: target.animatableData, amount: fractionComplete))
            self.value = value
        } else {
            self.value = target
        }
        
        let animationFinished = (runningTime >= duration) || !isAnimated
        
        if animationFinished {
            self.value = target
        }

        if let value = self.value {
            let callbackValue = integralizeValues ? value.scaledIntegral : value
            valueChanged?(callbackValue)
        }

        if animationFinished {
            state = .ended
            // If an animation finishes on its own, call the completion handler with value `target`.
            completion?(.finished(at: target))
        }
    }
}
