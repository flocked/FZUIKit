//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

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

     - parameter dt: The delta time.
     */
    func updateAnimation(dt: TimeInterval)
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

public enum AnimationEvent<T> {
    /// Indicates the animation has fully completed.
    case finished(at: T)

    /**
     Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).

     - parameter from: The previous `target` value of the animation.
     - parameter to: The new `target` value of the animation.
     */
    case retargeted(from: T, to: T)
}
#endif
