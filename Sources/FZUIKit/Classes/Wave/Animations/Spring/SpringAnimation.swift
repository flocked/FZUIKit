//
//  Animation.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// An animator that animates a value using a physically-modeled spring.
public class SpringAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding, AnimationVelocityProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?
    
    /// The relative priority of the animation.
    public var relativePriority: Int = 0

    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                startTime = .now
            default:
                break
            }
        }
    }

    /// The spring model that determines the animation's motion.
    public var spring: Spring
    
    /**
     How long the animation will take to complete, based off its `spring` property.

     - Note: This is useful for debugging purposes only. Do not use `settlingTime` to determine the animation's progress.
     */
    public var settlingTime: TimeInterval {
        spring.settlingDuration
    }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// Determines if the animation is stopped upon reaching `target`. If set to `false`,  any changes to the target value will be animated.
    public var stopsOnCompletion: Bool = true
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false {
        didSet {
            guard oldValue != repeats else { return }
         //   updateAutoreverse()
        }
    }

    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromValue = _value
        }
    }

    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        get { Value(_target) }
        set { _target = newValue.animatableData }
    }
    
    var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else {
                return
            }

            if state == .running {
                startTime = .now
                let event = AnimationEvent.retargeted(from: Value(oldValue), to: target)
                completion?(event)
            }
        }
    }

    /**
     The current velocity of the animation.

     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }
    
    var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromVelocity = _velocity
        }
    }

    
    var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    var _fromValue: Value.AnimatableData
    
    var fromVelocity: Value {
        get { Value(_fromVelocity) }
        set { _fromVelocity = newValue.animatableData }
    }
    
    var _fromVelocity: Value.AnimatableData


    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /// The completion block gets called to remove the animation from the animators `animations` dictionary.
    var animatorCompletion: (()->())? = nil
    
    var startTime: TimeInterval = 0.0
    
    /// The total running time of the animation.
    var runningTime: TimeInterval {
        return (CACurrentMediaTime() - startTime)
    }
    
    /**
     Creates a new animation with a ``Spring/snappy`` spring, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(value: Value, target: Value, velocity: Value = .zero) {
        self._value = value.animatableData
        self._target = target.animatableData
        self._velocity = velocity.animatableData
        self.spring = .snappy
        self._fromValue = _value
        self._fromVelocity = _velocity
    }

    /**
     Creates a new animation with a given ``Spring``, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - spring: The spring model that determines the animation's motion.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(spring: Spring, value: Value, target: Value, velocity: Value = .zero) {
        self._value = value.animatableData
        self._target = target.animatableData
        self._velocity = velocity.animatableData
        self.spring = spring
        self._fromValue = _value
        self._fromVelocity = _velocity
    }
    
    init(settings: AnimationController.AnimationParameters, value: Value, target: Value, velocity: Value = .zero) {
        self._value = value.animatableData
        self._target = target.animatableData
        self._velocity = velocity.animatableData
        self.spring = settings.animationType.spring ?? .smooth
        self._fromValue = _value
        self._fromVelocity = _velocity
        self.configure(withSettings: settings)
    }
    
    deinit {
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil

    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        if let spring = settings.animationType.spring {
            self.spring = spring
        }
        if let gestureVelocity = settings.animationType.gestureVelocity {
            (self as? SpringAnimation<CGRect>)?.velocity.origin = gestureVelocity
            (self as? SpringAnimation<CGRect>)?.fromVelocity.origin = gestureVelocity
            
            (self as? SpringAnimation<CGPoint>)?.velocity = gestureVelocity
            (self as? SpringAnimation<CGPoint>)?.fromVelocity = gestureVelocity
        }
        self.repeats = settings.repeats
        if settings.integralizeValues == true {
            self.integralizeValues = settings.integralizeValues
        }
    }

    /// Resets the animation.
    public func reset() {
        startTime = .now
        velocity = .zero
        state = .inactive
    }
        
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        guard _value != _target else {
            state = .inactive
            return
        }

        state = .running

        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &_value, velocity: &_velocity, target: _target, deltaTime: deltaTime)
        } else {
            self._value = _target
            velocity = Value.zero
        }
        
     //   runningTime = runningTime + deltaTime

        let animationFinished = (runningTime >= settlingTime) || !isAnimated
        
        if animationFinished {
            if repeats, isAnimated {
                _value = _fromValue
                _velocity = _fromVelocity
            } else {
                _value = _target
            }
            startTime = .now
        }

        let callbackValue = (animationFinished && integralizeValues) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !repeats || !isAnimated {
            stop(at: .current)
        }
    }
}

extension SpringAnimation: CustomStringConvertible {
    public var description: String {
        """
        SpringAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))
            priority: \(relativePriority)
            state: \(state)

            value: \(String(describing: value))
            target: \(String(describing: target))
            velocity: \(String(describing: velocity))

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            settlingTime: \(settlingTime)
            integralizeValues: \(integralizeValues)
            stopsOnCompletion: \(stopsOnCompletion)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}
#endif


/*
if animationFinished == false, let epsilon = self.epsilon, let value = self.value?.animatableValue as? AnimatableVector, let target = self.target?.animatableValue as? AnimatableVector {
    let val = value.isApproximatelyEqual(to: target, epsilon: epsilon)
    animationFinished = val
}
 */
