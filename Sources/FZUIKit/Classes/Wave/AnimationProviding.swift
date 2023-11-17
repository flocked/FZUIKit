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

    public func pauseAnimation() {
        guard var animation = self as? (any ConfigurableAnimationProviding) else { return }
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

/// An internal extension to `AnimationProviding` used for configurating animations.
internal protocol ConfigurableAnimationProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var state: AnimationState { get set }
    var groupUUID: UUID? { get set }
    var delayedStart: DispatchWorkItem? { get set }
    var value: Value { get set }
    var target: Value { get set }
    var fromValue: Value { get set }
    var integralizeValues: Bool { get set }
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    var animatorCompletion: (()->())? { get set }
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    func configure(withSettings settings: AnimationController.AnimationParameters)
}

/// An internal extension to `AnimationProviding` for animations with velocity.
internal protocol AnimationVelocityProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var velocity: Value { get set }
}

internal extension ConfigurableAnimationProviding {
    func _stop(at position: AnimationPosition) {
        var animation = self
        self.delayedStart?.cancel()
        animation.state = .ended
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
        animation.animatorCompletion = nil
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
