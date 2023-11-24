//
//  DecayAnimation.swift
//
//  Adopted from:
//  Motion. Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 03.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils

/// An animator that animates a value using a decay function.
public class DecayAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding, AnimationVelocityProviding {

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
                runningTime = 0.0
            default:
                break
            }
        }
    }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``velocity`` value isn't `zero`.
    public var autoStarts: Bool = false
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false
    
    /// The rate at which the velocity decays over time.
    public var decelerationRate: Double {
        get { decayFunction.decelerationRate }
        set { decayFunction.decelerationRate = newValue }
    }
    
    /// The decay function used to calculate the animation.
    var decayFunction: DecayFunction
    
    /// The current value of the animation. This value will change as the animation executes.
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData  }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromValue = _value
        }
    }
    
    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value {
        get { Value(_velocity) }
        set {
            _velocity = newValue.animatableData
            calculatedTarget = Value(DecayFunction.destination(value: _value, velocity: _velocity, decelerationRate: decayFunction.decelerationRate))
        }
    }
    
    var _velocity: Value.AnimatableData {
        didSet {
            guard oldValue != _velocity else { return }
            if autoStarts, state != .running, _velocity != .zero {
                start(afterDelay: 0.0)
            }
            if state != .running {
                _fromVelocity = _velocity
            }
        }
    }
    
    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.
     
     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get { return calculatedTarget }
        set {
            self._velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: newValue.animatableData)
            self._fromVelocity = self._velocity
            self.runningTime = 0.0
        }
    }
    
    internal var calculatedTarget: Value = .zero {
        didSet {
            if state == .running {
                let event = AnimationEvent.retargeted(from: oldValue, to: calculatedTarget)
                completion?(event)
            }
        }
    }
    
    var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    var _fromValue: Value.AnimatableData {
        didSet {
            guard oldValue != _fromValue else { return }
            updateTotalDuration()
        }
    }
    
    var fromVelocity: Value {
        get { Value(_fromVelocity) }
        set { _fromVelocity = newValue.animatableData }
    }
    
    var _fromVelocity: Value.AnimatableData {
        didSet {
            guard oldValue != _fromVelocity else { return }
            updateTotalDuration()
        }
    }
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    var totalDuration: TimeInterval = 0.0
    
    var runningTime: TimeInterval = 0.0
    
    /// The completion percentage of the animation.
    var fractionComplete: CGFloat {
        runningTime / totalDuration
    }
    
    func updateTotalDuration() {
      // totalDuration = DecayFunction.duration(value: _fromValue, velocity: _fromVelocity, decelerationRate: decelerationRate)
    }
    
    /**
     Creates a new animation with the specified initial value and velocity.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decelerationRate: The rate at which the velocity decays over time. Defaults to ``DecayFunction/ScrollViewDecelerationRate``.
     */
    public init(value: Value, velocity: Value, decelerationRate: Double = ScrollViewDecelerationRate) {
        self.decayFunction = DecayFunction(decelerationRate: decelerationRate)
        self._value = value.animatableData
        self._fromValue = _value
        self._velocity = velocity.animatableData
        self._fromVelocity = _velocity
        self.calculatedTarget = Value(DecayFunction.destination(value: _value, velocity: _velocity, decelerationRate: decayFunction.decelerationRate))
        self.updateTotalDuration()
    }
    
    /**
     Creates a new animation with the specified initial value and target.

     - Parameters:
        - value: The start value of the animation.
        - target: The target value of the animation.
        - decelerationRate: The rate at which the velocity decays over time. Defaults to ``DecayFunction/ScrollViewDecelerationRate``.
     */
    public init(value: Value, target: Value, decelerationRate: Double = ScrollViewDecelerationRate) {
        self.decayFunction = DecayFunction(decelerationRate: decelerationRate)
        self._value = value.animatableData
        self._fromValue = _value
        self._velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: target.animatableData)
        self._fromVelocity = _velocity
        self.calculatedTarget = Value(DecayFunction.destination(value: _value, velocity: _velocity, decelerationRate: decayFunction.decelerationRate))
        self.updateTotalDuration()
    }
    
    deinit {
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
        
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        repeats = settings.repeats
        autoStarts = settings.autoStarts
        integralizeValues = settings.integralizeValues
        if decelerationRate != settings.animationType.decelerationRate {
            decelerationRate = settings.animationType.decelerationRate ?? decelerationRate
            updateTotalDuration()
        }
    }
            
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running
        
        decayFunction.update(value: &_value, velocity: &_velocity, deltaTime: deltaTime)

        let animationFinished = _velocity.magnitudeSquared < 0.05
                
        if animationFinished, repeats {
            _value = _fromValue
            _velocity = _fromVelocity
        }
        
        runningTime = runningTime + deltaTime
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)
        
        if animationFinished, !repeats {
            stop(at: .current)
        }
    }
}

extension DecayAnimation: CustomStringConvertible {
    public var description: String {
        """
        DecayAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(groupUUID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state)

            value: \(value)
            velocity: \(velocity)
            target: \(target)

            decelerationRate: \(decelerationRate)
            repeats: \(repeats)
            autoreverse: \(autoreverse)
            isReversed: \(isReversed)
            integralizeValues: \(integralizeValues)
            autoStarts: \(autoStarts)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}

/// The mode how a decaying animation should animate properties.
public enum DecayAnimationMode {
    /// The value of animated properties will increase or decrease (depending on the values applied) with a decelerating rate.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
    case velocity
    /// The animated properties will animate to the applied values  with a decelerating rate.
    case value
}

/*
 /// Resets the animation.
 public func reset() {
     state = .inactive
     velocity = .zero
     fromValue = value
 } 
 */

#endif
