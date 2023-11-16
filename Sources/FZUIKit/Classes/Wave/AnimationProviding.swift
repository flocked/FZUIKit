//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/**
 A type that provides an animation.
 
 It provides default implementations for ``start(afterDelay:)``, ``pauseAnimation()`` and ``stop(at:)``.
 */
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
    func pauseAnimation()
    
    /**
     Stops the animation at the specified position.
     
     - Parameters:
        - position: The position at which the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``).
     */
    func stop(at position: AnimationPosition)
    
    /// Resets the animation.
    func reset()
}

/// An internal extension to `AnimationProviding` used for configurating animations.
internal protocol ConfigurableAnimationProviding<Value>: AnyObject, AnimationProviding {
    associatedtype Value: AnimatableProperty
    /// The current state of the animation.
    var state: AnimationState { get set }
    
    var groupUUID: UUID? { get set }
    
    /// The current value of the animation.
    var value: Value { get set }
    
    /// The current target value of the animation.
    var target: Value { get set }
    
    /// The value at the start of the animation.
    var fromValue: Value { get set }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? { get set }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    var integralizeValues: Bool { get set }
    
    /// /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters)
    
    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    
    /// The completion block gets called to remove the animation from the animators `animations` dictionary.
    var animatorCompletion: (()->())? { get set }
            
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
}

/// An internal extension to `AnimationProviding` for animations with velocity.
internal protocol AnimationVelocityProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var velocity: Value { get set }
}

/// An internal extension to `AnimationProviding` for animations with running time.
internal protocol RunningTimeProviding: AnimationProviding {
    var runningTime: TimeInterval { get set }
}

extension AnimationProviding {
    public func start(afterDelay delay: TimeInterval) {
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")
        guard let animation = self as? (any ConfigurableAnimationProviding) else { return }
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

    public func pauseAnimation() {
        guard let animation = self as? (any ConfigurableAnimationProviding) else { return }
        guard state == .running else { return }
        animation.state = .inactive
        animation.delayedStart?.cancel()
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    public func stop(at position: AnimationPosition) {
        if let animation = self as? any ConfigurableAnimationProviding {
            animation._stop(at: position)
        }
    }
}

internal extension ConfigurableAnimationProviding  {
    func _stop(at position: AnimationPosition) {
        delayedStart?.cancel()
        state = .ended
        switch position {
        case .start:
            value = fromValue
        case .end:
            value = target
        default: break
        }
        target = value
        completion?(.finished(at: value))
        animatorCompletion?()
        animatorCompletion = nil
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
        if var animation = (self as? RunningTimeProviding) {
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
    if var animation = (self as? RunningTimeProviding) {
        animation.runningTime = 0.0
    }
    let callbackValue = integralizeValues ? value.scaledIntegral : value
    valueChanged?(callbackValue)
    completion?(.finished(at: value))
    animatorCompletion?()
    animatorCompletion = nil
}
 */
