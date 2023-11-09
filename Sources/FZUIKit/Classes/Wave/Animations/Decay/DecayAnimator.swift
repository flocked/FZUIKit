//
//  DecayAnimator.swift
//
//  Adopted from:
//  Motion. Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation
import FZSwiftUtils

/// An animator that animates a value using a decay function.
public class DecayAnimator<Value: AnimatableData>: AnimationProviding {
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
    
    internal var decay: DecayFunction
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// The rate at which the velocity decays over time.
    public var decayConstant: Double {
        get { decay.decayConstant }
        set { decay.decayConstant = newValue }
    }
    
    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value
    
    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value
    
    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.
     
     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get {
            return DecayFunction.destination(value: value, velocity: velocity, decayConstant: decay.decayConstant)
        }
        set {
            self.velocity = DecayFunction.velocity(fromValue: value, toValue: newValue)
        }
    }
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decayConstant: The rate at which the velocity decays over time. Defaults to ``DecayFunction/ScrollViewDecayConstant``.
     */
    public init(value: Value, velocity: Value = .zero, decayConstant: Double = DecayFunction.ScrollViewDecayConstant) {
        self.decay = DecayFunction(decayConstant: decayConstant)
        self.value = value
        self.velocity = velocity
    }
    
    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        guard isRunning == false, state != .running, velocity != .zero else { return }
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
    
    public func pauseAnimation() {
        guard state == .running else { return }
        state = .inactive
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
            if let completion = completion {
                completion(.finished(at: value))
            }
        } else {
            velocity = .zero
        }
    }
    
    /// Stops the animation immediately at the specified value.
    internal func stop(at value: Value) {
        AnimationController.shared.stopPropertyAnimation(self)
        self.value = value
        velocity = .zero
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
    }
    
    /// Resets the animation.
    func reset() {
        state = .inactive
        velocity = .zero
    }
        
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval) {
        guard velocity != .zero else {
            // Can't start an animation without a value and target
            state = .inactive
            return
        }
                
        state = .running
        
        decay.update(value: &value, velocity: &velocity, deltaTime: deltaTime)

        let animationFinished = velocity.animatableData.magnitudeSquared < 0.1
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished {
            stop(immediately: true)
        }
    }
}

extension DecayAnimator: CustomStringConvertible {
    public var description: String {
        """
        DecayAnimator<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)
            isRunning: \(isRunning)

            value: \(String(describing: value))
            velocity: \(String(describing: velocity))
            target: \(String(describing: target))

            integralizeValues: \(integralizeValues)
            decayConstant: \(decayConstant)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}
