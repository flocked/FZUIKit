//
//  EasingAnimation.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils

/**
 An animation that animates a value using an easing function (like `easeIn` or `linear`).
 
 Example usage:
 ```swift
 let easingAnimation = EasingAnimation(timingFunction = .easeIn, duration: 3.0, value: CGPoint(x: 0, y: 0), target: CGPoint(x: 50, y: 100))
 easingAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
 }
 easingAnimation.start()
 ```
 */
public class EasingAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// The delay (in seconds) after which the animations begin.
    public internal(set) var delay: TimeInterval = 0.0
    
    /// The information used to determine the timing curve for the animation.
    public var timingFunction: TimingFunction = .easeInEaseOut
    
    /// The total duration (in seconds) of the animation.
    public var duration: CGFloat = 0.0
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false
        
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries when the animation finishes. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
    public var autoStarts: Bool = false
    
    /*
    /**
     A Boolean value indicating whether a paused animation scrubs linearly or uses its specified timing information.
     
     The default value of this property is `true`, which causes the animator to use a linear timing function during scrubbing. Setting the property to `false` causes the animator to use its specified timing curve.
     */
    var scrubsLinearly: Bool = false
    */
    
    /// The completion percentage of the animation.
    public var fractionComplete: CGFloat = 0.0 {
        didSet {
            fractionComplete = fractionComplete.clamped(max: 1.0)
        }
    }
    
    /// The resolved fraction complete using the timing function.
    var resolvedFractionComplete: CGFloat {
        return timingFunction.solve(at: fractionComplete, duration: duration)
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
     Thex target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        get { Value(_target) }
        set { _target = newValue.animatableData }
    }
    
    internal var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else { return }
            if state == .running {
                fractionComplete = 0.0
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if autoStarts, target != value {
                start(afterDelay: 0.0)
            }
        }
    }

            
    /// The start value of the animation.
    internal var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    internal var _fromValue: Value.AnimatableData
    
    internal var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }
    
    internal var _velocity: Value.AnimatableData = .zero
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: Value, target: Value) {
        self._value = value.animatableData
        self._fromValue = _value
        self._target = target.animatableData
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
    
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        timingFunction = settings.animationType.timingFunction ?? timingFunction
        duration = settings.animationType.duration ?? duration
        integralizeValues = settings.integralizeValues
        repeats = settings.repeats
        autoStarts = settings.autoStarts
        autoreverse = settings.autoreverse
    }
    
    /// Resets the animation.
    func reset() {
        delayedStart?.cancel()
        fractionComplete = 0.0
        _velocity = .zero
    }
            
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running
        
        if value == target {
            fractionComplete = 1.0
        }
                
        let isAnimated = duration > .zero
        
        guard deltaTime > 0.0 else { return }
                
        let previousValue = _value

        if isAnimated {
            let secondsElapsed = deltaTime/duration
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
            _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
        } else {
            fractionComplete = isReversed ? 0.0 : 1.0
            _value = isReversed ? _fromValue : _target
        }
        
        _velocity = (_value - previousValue).scaled(by: 1.0/deltaTime)
        
        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated
        
        if animationFinished {
            if repeats, isAnimated {
                if autoreverse {
                    isReversed = !isReversed
                }
                fractionComplete = isReversed ? 1.0 : 0.0
                _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
            } else {
                _value = isReversed ? _fromValue : _target
            }
        }
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if (animationFinished && !repeats) || !isAnimated {
            stop(at: .current)
        }
    }
    
    /*
    func updateValue() {
        guard state != .running else { return }
        if scrubsLinearly {
            _value = _fromValue.interpolated(towards: _target, amount: fractionComplete)
        } else {
            _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
        }
        valueChanged?(value)
    }
    */
}

extension EasingAnimation: CustomStringConvertible {
    public var description: String {
        """
        EasingAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(groupUUID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state)
        
            value: \(value)
            target: \(target)
            fromValue: \(fromValue)
            velocity: \(velocity)
            fractionComplete: \(fractionComplete)

            timingFunction: \(timingFunction.name)
            duration: \(duration)
            isReversed: \(isReversed)
            repeats: \(repeats)
            autoreverse: \(autoreverse)
            integralizeValues: \(integralizeValues)
            autoStarts: \(autoStarts)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}

#endif

/*
 if duration != 0.0, #available(macOS 13.0.0, *) {
   //  Swift.print("VectorElements type", type(of: value.animatableData), (fromValue.animatableData as? any VectorElements) != nil, (fromValue.animatableData as? any VectorElements<CGFloat>) != nil, (fromValue.animatableData as? any VectorElements<Double>) != nil)
     /*
     if let duration = self.newDuration(oldTarget: oldValue, newTarget: self.target) {
         self.duration = duration
     }
      */
 }
 
 
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, *)
func newDuration(oldTarget: Value, newTarget: Value) -> TimeInterval? {
    if let fromValueAnimatable = fromValue.animatableData as? (any VectorElements<CGFloat>), let targetAnimatable = oldTarget.animatableData as? (any VectorElements<CGFloat>), let newTargetAnimated = newTarget.animatableData as? (any VectorElements<CGFloat>) {
        Swift.print("newDuration CGFloat", fromValue, oldTarget, newTarget)

        let range: ClosedRange<[CGFloat]>
        if fromValueAnimatable.elements < targetAnimatable.elements {
            range = fromValueAnimatable.elements...targetAnimatable.elements
        } else {
            range = targetAnimatable.elements...fromValueAnimatable.elements
        }
        
        guard let usableIndex = newTargetAnimated.indices.first(where: { i -> Bool in
            let fractionComplete = newTargetAnimated.elements[i] / (range.upperBound[i] - range.lowerBound[i])
            return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
        }) else { return nil }
        
        let fractionComplete = newTargetAnimated.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
        /*
        if fromValueAnimatable.elements > targetAnimatable.elements {
            fractionComplete = 1.0 - fractionComplete
        }
         */
        let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, duration: self.duration)
        let newDuration = duration * fractionTime
        Swift.print("newDuration CGFloat end", newDuration, fractionComplete)
        return newDuration
    } else if let fromValueAnimatable = fromValue.animatableData as? (any VectorElements<Double>), let targetAnimatable = oldTarget.animatableData as? (any VectorElements<Double>), let newTargetAnimated = newTarget.animatableData as? (any VectorElements<Double>) {
        Swift.print("newDuration Double", fromValue, oldTarget, newTarget)

        let range: ClosedRange<[Double]>
        if fromValueAnimatable.elements < targetAnimatable.elements {
            range = fromValueAnimatable.elements...targetAnimatable.elements
        } else {
            range = targetAnimatable.elements...fromValueAnimatable.elements
        }

        guard let usableIndex = newTargetAnimated.indices.first(where: { i -> Bool in
            let fractionComplete = newTargetAnimated.elements[i] / (range.upperBound[i] - range.lowerBound[i])
            return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
        }) else { return nil }
        
        let fractionComplete = newTargetAnimated.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
        /*
        if fromValueAnimatable.elements > targetAnimatable.elements {
            fractionComplete = 1.0 - fractionComplete
        }
         */
        let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, duration: self.duration)

        let newDuration = duration * fractionTime
        Swift.print("newDuration Double end", newDuration, fractionComplete)
        return newDuration
    } else if let fromValueAnimatable = fromValue.animatableData as? (any VectorElements<Float>), let targetAnimatable = oldTarget.animatableData as? (any VectorElements<Float>), let newTargetAnimated = newTarget.animatableData as? (any VectorElements<Float>) {
        Swift.print("newDuration Float", fromValue, oldTarget, newTarget)

        let range: ClosedRange<[Float]>
        if fromValueAnimatable.elements < targetAnimatable.elements {
            range = fromValueAnimatable.elements...targetAnimatable.elements
        } else {
            range = targetAnimatable.elements...fromValueAnimatable.elements
        }
        
        guard let usableIndex = newTargetAnimated.indices.first(where: { i -> Bool in
            let fractionComplete = newTargetAnimated.elements[i] / (range.upperBound[i] - range.lowerBound[i])
            return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
        }) else { return nil }
        
        let fractionComplete = newTargetAnimated.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
        
        let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, duration: self.duration)
        /*
        if fromValueAnimatable.elements > targetAnimatable.elements {
            fractionComplete = 1.0 - fractionComplete
        }
         */
        let newDuration = duration * fractionTime
        Swift.print("newDuration Float end", newDuration, fractionComplete)
        return newDuration
    }
    Swift.print("newDuration nil", type(of: fromValue))
    return nil
}
 */

/*
 func retargetFractionComplete(newValue: Value) {
     var foundValue: Bool = false
     let frameDuration = 1.0/60.0
     let fraction = frameDuration / duration
     var fractionComplete: Double = 0.0
     let targetMagnitude = newValue.animatableData.magnitudeSquared
     let targetAnimatable = newValue.animatableData
     while !foundValue && fractionComplete <= 1.0 {
         fractionComplete = fractionComplete + fraction
         let value = fromValue.animatableData.interpolated(towards: target.animatableData, amount: fractionComplete)
         foundValue = targetAnimatable == value
     //    foundValue = targetMagnitude.isApproximatelyEqual(to: value.magnitudeSquared, epsilon: 0.1)
     }
     if foundValue {
         Swift.print("retargetFraction: ", fractionComplete)
     } else {
         Swift.print("retargetFraction: nil")
     }
 }
 
 func retargetFractionComplete(newTarget: Value) {
     if let newTarget = newTarget.animatableData as? (any InterpolatablePosition) {
         if var interolatePosition = newTarget.interolatePositionAny(fromValue: fromValue.animatableData, toValue: target.animatableData) {
             if interolatePosition >= 0 && interolatePosition <= 1.0 {
                 (1.0 - interolatePosition) * duration
             }
             Swift.print("retarget", interolatePosition, fractionComplete)
         } else {
             Swift.print("retarget no position")
         }
     } else {
         Swift.print("retarget: nil")
     }
 }
 */
