//
//  EasingAnimation.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation
import FZSwiftUtils

/// An animator that animates a value using an easing function.
public class EasingAnimation<Value: AnimatableProperty>: AnimationProviding, ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// A Boolean value indicating whether the animation is currently running.
    public internal(set)var isRunning: Bool = false
    
    /// The information used to determine the timing curve for the animation.
    public var timingFunction: TimingFunction = .easeInEaseOut
    
    /// The total duration (in seconds) of the animation.
    public var duration: CGFloat = 0.0
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false {
        didSet {
            guard oldValue != repeats else { return }
            updateAutoreverse()
        }
    }
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false {
        didSet {
            guard oldValue != autoreverse else { return }
            updateAutoreverse()
        }
    }
    
    func updateAutoreverse() {
        if autoreverse, repeats {
            if isAutoreversed == nil {
                isAutoreversed = false
            }
        } else {
            isAutoreversed = nil
        }
    }
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false {
        didSet { guard oldValue != isReversed else { return }
            fractionComplete = 1.0 - fractionComplete
        }
    }
    
    internal var isAutoreversed: Bool? = nil
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /**
     A Boolean value indicating whether a paused animation scrubs linearly or uses its specified timing information.
     
     The default value of this property is `true`, which causes the animator to use a linear timing function during scrubbing. Setting the property to `false` causes the animator to use its specified timing curve.
     */
    public var scrubsLinearly: Bool = false
    
    /// The completion percentage of the animation.
    public var fractionComplete: CGFloat = 0.0 {
        didSet {
            if (0...1.0).contains(fractionComplete) == false {
                fractionComplete = fractionComplete.clamped(max: 1.0)
            }
                updateValue()
        }
    }
    
    var resolvedFractionComplete: CGFloat {
        return timingFunction.solve(at: fractionComplete, duration: duration)
    }
    
    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value {
        didSet { 
            guard state != .running, isRunning == false else { return }
            fromValue = value
        }
    }
    
    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        didSet {
            guard oldValue != target else { return }

          //  fromValue.animatableData.scaled(by: 1.0 - tar)
          //  fromValue.animatableData / target.animatableData
            
            if duration != 0.0, #available(macOS 13.0.0, *) {
                Swift.print("VectorElements type", type(of: value.animatableData), (fromValue.animatableData as? any VectorElements) != nil, (fromValue.animatableData as? any VectorElements<CGFloat>) != nil, (fromValue.animatableData as? any VectorElements<Double>) != nil)
                if let fromValue = fromValue as? any VectorElements {
                    
                }
                if let duration = self.newDuration(oldTarget: oldValue, newTarget: self.target) {
                    self.duration = duration
                }
            }
            
            if state == .running {
                let event = AnimationEvent.retargeted(from: oldValue, to: target)
                completion?(event)
            }
        }
    }
    
    /// Not in use and only used to confirm to `ConfigurableAnimationProviding`.
    internal var velocity: Value {
        get { value }
        set { }
    }
    
    /// The start value of the animation.
    var fromValue: Value
        
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
        self.value = value
        self.fromValue = value
        self.target = target
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    internal init(settings: AnimationController.AnimationParameters, value: Value, target: Value, velocity: Value = .zero) {
        self.value = value
        self.fromValue = value
        self.target = target
        self.duration = settings.type.easingDuration ?? 0.0
        self.timingFunction = settings.type.timingFunction ?? .easeInEaseOut
        self.configure(withSettings: settings)
    }
    
    deinit {
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil

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
            target = value
        }
    }
    
    /// Stops the animation immediately at the specified value.
    internal func stop(at value: Value) {
        AnimationController.shared.stopPropertyAnimation(self)
        self.value = value
        target = value
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
        if let timingFunction = settings.type.timingFunction {
            self.timingFunction = timingFunction
        }
        if let duration = settings.type.easingDuration {
            self.duration = duration
        }
    }
    
    /// Resets the animation.
    public func reset() {
        state = .inactive
    }
    
    @available(macOS 13.0.0, *)
    func newDuration(oldTarget: Value, newTarget: Value) -> TimeInterval? {
        Swift.print("newDuration", fromValue is (any VectorElements), oldTarget is (any VectorElements), fromValue is (any VectorElements<CGFloat>))
        
        if let fromValue = fromValue.animatableData as? (any VectorElements<CGFloat>), let target = oldTarget.animatableData as? (any VectorElements<CGFloat>), let newTarget = newTarget.animatableData as? (any VectorElements<CGFloat>) {
            Swift.print("CGFloatVectorElements")

            let range = fromValue.elements...target.elements
            
            guard let usableIndex = newTarget.indices.first(where: { i -> Bool in
                let fractionComplete = newTarget.elements[i] / (range.upperBound[i] - range.lowerBound[i])
                return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
            }) else { return nil }
            
            let fractionComplete = newTarget.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
            let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, epsilon: 0.0001)
            return duration * fractionTime
        } else if let fromValue = fromValue.animatableData as? (any VectorElements<Double>), let target = oldTarget.animatableData as? (any VectorElements<Double>), let newTarget = newTarget.animatableData as? (any VectorElements<Double>) {
            Swift.print("DoubleVectorElements")

            let range = fromValue.elements...target.elements
            
            guard let usableIndex = newTarget.indices.first(where: { i -> Bool in
                let fractionComplete = newTarget.elements[i] / (range.upperBound[i] - range.lowerBound[i])
                return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
            }) else { return nil }
            
            let fractionComplete = newTarget.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
            let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, epsilon: 0.0001)
            return duration * fractionTime
        } else if let fromValue = fromValue.animatableData as? (any VectorElements<Float>), let target = oldTarget.animatableData as? (any VectorElements<Float>), let newTarget = newTarget.animatableData as? (any VectorElements<Float>) {
            Swift.print("FloatVectorElements")

            let range = fromValue.elements...target.elements
            
            guard let usableIndex = newTarget.indices.first(where: { i -> Bool in
                let fractionComplete = newTarget.elements[i] / (range.upperBound[i] - range.lowerBound[i])
                return !(fractionComplete.doubleValue.isApproximatelyEqual(to: 0.0) || fractionComplete.doubleValue.isApproximatelyEqual(to: 1.0))
            }) else { return nil }
            
            let fractionComplete = newTarget.elements[usableIndex] / (range.upperBound[usableIndex] - range.lowerBound[usableIndex])
            let fractionTime = timingFunction.solve(at: fractionComplete.doubleValue, epsilon: 0.0001)
            return duration * fractionTime
        }
        return nil
    }
        
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        guard value != target else {
            state = .inactive
            return
        }
                
        state = .running
                
        let isAnimated = duration > .zero
        
        guard deltaTime > 0.0 else { return }
                
        if isAnimated {
            let deltaTime = deltaTime/2.0 // Why?
            let secondsElapsed = deltaTime/duration
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
        } else {
            fractionComplete = 1.0
            self.value = target
        }
        
        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated
        
        if animationFinished {
            if repeats, isAnimated {
                fractionComplete = isReversed ? 1.0 : 0.0
            } else {
                self.value = isReversed ? fromValue : target
            }
        }
        
        let callbackValue = (animationFinished && integralizeValues) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !repeats || !isAnimated {
            stop(immediately: true)
        }
    }
    
    func updateValue() {
        if isRunning == false, state == .running, scrubsLinearly {
            value = Value(fromValue.animatableData.interpolated(towards: target.animatableData, amount: fractionComplete))
        } else {
            value = Value(fromValue.animatableData.interpolated(towards: target.animatableData, amount: resolvedFractionComplete))
        }
    }
}

extension EasingAnimation: CustomStringConvertible {
    public var description: String {
        """
        EasingAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)
            isRunning: \(isRunning)
            fractionComplete: \(fractionComplete)
            isReversed: \(isReversed)

            value: \(String(describing: value))
            target: \(String(describing: target))
            from: \(String(describing: fromValue))

            timingFunction: \(timingFunction.name)
            duration: \(duration)
            repeats: \(repeats)
            integralizeValues: \(integralizeValues)
            scrubsLinearly: \(scrubsLinearly)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}

