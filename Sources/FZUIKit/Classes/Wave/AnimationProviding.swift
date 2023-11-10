//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/// A type that provides an animation.
internal protocol AnimationProviding {
    /// A unique identifier for the animation.
    var id: UUID { get }
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID? { get }
    
    /// The relative priority of the animation.
    var relativePriority: Int { get set }
    
    /// The current state of the animation.
    var state: AnimationState { get }
    
    /// A Boolean value indicating whether the animation is currently running.
    var isRunning: Bool { get }

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
    
    /// Stops the animation at the current value.
    func stop(immediately: Bool)
    
    /// Resets the animation.
    func reset()
}

internal protocol AnimationProvidingInternal<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var value: Value? { get set }
    var velocity: Value? { get set }
    var target: Value? { get set }
    
    func configure(withSettings settings: AnimationController.AnimationParameters)
}

/*
extension AnimationProviding {
    func start(afterDelay delay: TimeInterval) {
        guard var animation = self as? (any AnimationProvidingInternal) else { return }
        guard isRunning == false, state != .running else { return }
        precondition(animation.value != nil, "Animation must have a non-nil `value` before starting.")
        precondition(animation.target != nil, "Animation must have a non-nil `target` before starting.")
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")
        
        let start = {
            animation.isRunning = true
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
}
*/


public enum AnimationEvent<Value> {
    /// Indicates the animation has fully completed.
    case finished(at: Value)

    /**
     Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).

     - parameter from: The previous `target` value of the animation.
     - parameter to: The new `target` value of the animation.
     */
    case retargeted(from: Value, to: Value)
}
#endif
