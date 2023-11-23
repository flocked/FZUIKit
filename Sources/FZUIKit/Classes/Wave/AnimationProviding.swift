//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
///  A type that provides an animation.
public protocol AnimationProviding {
    /// A unique identifier for the animation.
    var id: UUID { get }
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID? { get }
    
    /// The relative priority of the animation.
    var relativePriority: Int { get set }
    
    /// The current state of the animation.
    var state: AnimationState { get }
    
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval)
    
    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    func start(afterDelay delay: TimeInterval)
    
    /// Pauses the animation.
    func pause()
    
    /**
     Stops the animation at the specified position.
     
     - Parameters:
        - position: The position at which the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``).
        - immediately: A Boolean value that indicates whether the animation should stop immediately  at the specified position.
     */
    func stop(at position: AnimationPosition, immediately: Bool)
    
    /// Resets the animation.
    func reset()
}

extension AnimationProviding where Self: AnyObject {
    public func start(afterDelay delay: TimeInterval) {
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")
        guard var animation = self as? (any ConfigurableAnimationProviding) else { return }
        guard state != .running else { return }
        
        let start = {
            AnimationController.shared.runPropertyAnimation(self)
        }
        
        animation.delayedStart?.cancel()

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            animation.delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }

    public func pause() {
        guard var animation = self as? (any ConfigurableAnimationProviding) else { return }
        guard state == .running else { return }
        animation.state = .inactive
        animation.delayedStart?.cancel()
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    public func stop(at position: AnimationPosition, immediately: Bool = true) {
        if let animation = self as? any ConfigurableAnimationProviding {
            animation._stop(at: position, immediately: immediately)
        }
    }
}

/// An internal extension to `AnimationProviding` used for configurating animations.
internal protocol ConfigurableAnimationProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var state: AnimationState { get set }
    var groupUUID: UUID? { get set }
    /// The current value of the animation.
    var value: Value { get set }
    /// The target value of the animation.
    var target: Value { get set }
    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    
    var fromValue: Value { get set }
    var delayedStart: DispatchWorkItem? { get set }
    var integralizeValues: Bool { get set }
    var animatorCompletion: (()->())? { get set }
    func configure(withSettings settings: AnimationController.AnimationParameters)
}

/// An internal extension to `AnimationProviding` for animations with velocity.
internal protocol AnimationVelocityProviding<Value>: ConfigurableAnimationProviding {
    var velocity: Value { get set }
}

internal extension AnimationVelocityProviding {
    func setVelocity(_ value: Any, delay: TimeInterval = 0.0) {
        var animation = self
        
        let velocityUpdate = {
            if let value = value as? Value {
                animation.velocity = value
            }
        }
        
        if delay == .zero {
            velocityUpdate()
        } else {
            let task = DispatchWorkItem {
                velocityUpdate()
            }
            animation.delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }
}

internal extension ConfigurableAnimationProviding {
    func _stop(at position: AnimationPosition, immediately: Bool = true) {
        var animation = self
        self.delayedStart?.cancel()
        animation.state = .ended
        if immediately == false, (isSpringAnimation || isDecayAnimation) {
            switch position {
            case .start:
                animation.target = fromValue
            case .current:
                animation.target = value
            default: break
            }
        } else {
            switch position {
            case .start:
                animation.value = fromValue
                animation.valueChanged?(value)
            case .end:
                animation.value = target
                animation.valueChanged?(value)
            default: break
            }
            animation.target = value
            if let springAnimation = self as? SpringAnimation<Value> {
                springAnimation.startTime = .now
            }
            completion?(.finished(at: value))
            animatorCompletion?()
            AnimationController.shared.stopPropertyAnimation(self)
        }
    }
    
    /// A Boolean value that indicates whether the animation's type is ``SpringAnimation``.
    var isSpringAnimation: Bool {
        (self as? SpringAnimation<Value>) != nil
    }
    
    /// A Boolean value that indicates whether the animation's type is ``DecayAnimation``.
    var isDecayAnimation: Bool {
        (self as? DecayAnimation<Value>) != nil
    }
    
    /// A Boolean value that indicates whether the animation's type is ``EasingAnimation``.
    var isEasingAnimation: Bool {
        (self as? EasingAnimation<Value>) != nil
    }
}

#endif


/*
mutating func _stop(immediately: Bool = true) {
    delayedStart?.cancel()
    if self is DecayAnimation<Value> {
        velocity = .zero
    }
    if immediately {
        state = .ended
        completion?(.finished(at: value))
        animatorCompletion?()
        if var animation = (self as? AnimationRunningTimeProviding) {
            animation.runningTime = 0.0
        }
    } else {
        target = value
    }
}

/// Stops the animation immediately at the current value.
mutating func stopAtCurrentValue() {
    self.stop(at: value)
}

/// Stops the animation immediately at the specified value.
mutating func stop(at value: Value) {
    AnimationController.shared.stopPropertyAnimation(self)
    self.value = value
    if self is DecayAnimation<Value> {
        velocity = .zero
    }
    state = .inactive
    if var animation = (self as? AnimationRunningTimeProviding) {
        animation.runningTime = 0.0
    }
    let callbackValue = integralizeValues ? value.scaledIntegral : value
    valueChanged?(callbackValue)
    completion?(.finished(at: value))
    animatorCompletion?()
    animatorCompletion = nil
}
 */
