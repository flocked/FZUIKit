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
     The delay (in seconds) after which the animations begin.
     
     The default value of this property is `0`. When the value is greater than `0`, the start of any animations is delayed by the specified amount of time.
     To set a value for this property, use the ``start(afterDelay:)`` method when starting your animations.
     */
    var delay: TimeInterval { get }
    
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval)
    
    /**
     Starts the animation from its current position with an optional delay.
     
     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    func start(afterDelay delay: TimeInterval)
    
    /// Pauses the animation at the current position.
    func pause()
    
    /**
     Stops the animation at the specified position.
     
     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    func stop(at position: AnimationPosition, immediately: Bool)
}

extension AnimationProviding {
    /// Starts the animation from its current position.
    public func start() {
        self.start(afterDelay: 0.0)
    }
    
    /// Starts the animation immediately at its current position.
    public func stop() {
        stop(at: .current, immediately: true)
    }
}


/// An internal extension to `AnimationProviding` used for configurating animations.
internal protocol ConfigurableAnimationProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var state: AnimationState { get set }
    var delay: TimeInterval { get set }
    var value: Value { get set }
    var target: Value { get set }
    var fromValue: Value { get set }
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    var delayedStart: DispatchWorkItem? { get set }
    var velocity: Value { get set }
    var _velocity: Value.AnimatableData { get set }
    func configure(withSettings settings: AnimationController.AnimationParameters)
    func reset()
}

extension ConfigurableAnimationProviding {
    func setAnimatableVelocity(_ velocity: Any) {
        guard let velocity = velocity as? Value.AnimatableData, velocity != _velocity else { return }
        var animation = self
        animation._velocity = velocity
    }
    
    func setVelocity(_ velocity: Any) {
        guard let velocity = velocity as? Value, velocity != self.velocity else { return }
        var animation = self
        animation.velocity = velocity
    }
}
#endif

/*
 /// A Boolean value that indicates whether the animation can be started.
 var canBeStarted: Bool {
     guard state != .running else { return false }
     if let animation = (self as? DecayAnimation<Value>) {
         return animation._velocity != .zero
     }
     return value != target
 }
 
 public protocol PropertyAnimationProviding<Value>: AnimationProviding {
     associatedtype Value: AnimatableProperty
     /// The current state of the animation.
     var state: AnimationState { get set }
     /// The current value of the animation.
     var value: Value { get set }
     /// The target value of the animation.
     var target: Value { get set }
    /// The start value of the animation.
    var fromValue: Value { get set }
     /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
     /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
     var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
 }
 */
