//
//  File.swift
//  
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation

/*
public class EaseAnimator<Value: SIMDRepresentable>: ValueAnimation {
    func start(afterDelay delay: TimeInterval) {
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")

        let start = {
            AnimationController.shared.runPropertyAnimation(self)
        }

        if delay == .zero {
            start()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                start()
            }
        }
    }
    
    func stop(immediately: Bool) {
        _value = _target
        state = .ended
        completion?()
    }
    
    func reset() {
        self.accumulatedTime = 0.0
        self.startTime = .now
        self._value = _fromValue
    }
        
    /**
     A unique identifier for the animation.
     */
    public let id = UUID()

    /**
     The execution state of the animation (`inactive`, `running`, or `ended`).
     */
    public private(set) var state: AnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                startTime = .now

            default:
                break
            }
        }
    }
    
    public var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.simdRepresentation() }
    }
    
    internal var _fromValue: Value.SIMDType = .zero
    
    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.simdRepresentation() }
    }
    
    internal var _value: Value.SIMDType = .zero


    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        get { Value(_target) }
        set { _target = newValue.simdRepresentation() }
    }
    
    internal var _target: Value.SIMDType = .zero {
        didSet {
            attemptToUpdateAccumulatedTimeToMatchValue()
        }
    }
    
    func attemptToUpdateAccumulatedTimeToMatchValue() {
        if let accumulatedTime = easingFunction.solveAccumulatedTimeSIMD(_range, value: _value) {
            self.accumulatedTime = accumulatedTime * duration
        } else {
            reset()
        }
    }

    
    /**
     The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
     */
    public var valueChanged: ((_ currentValue: Value) -> Void)? = nil

    /**
     The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     */
    public var completion: (() -> Void)? = nil
    
    /**
     A unique identifier that associates an animation with an grouped animation block.
     */
    var groupUUID: UUID?

    var startTime: TimeInterval = .now
    var duration: TimeInterval
    var accumulatedTime: TimeInterval = .zero
    
    var easingFunction: EasingFunction<Value.SIMDType> = .linear

    
    var relativePriority: Int = 0
    
    func updateAnimation(dt: TimeInterval) {
        if duration == .zero {
           stop(immediately: true)
            return
        }
        state = .running
        
        accumulatedTime = dt - startTime
        let fraction = min(max(0.0, accumulatedTime / duration), 1.0)

        _value = easingFunction.solveInterpolatedValueSIMD(_range, fraction: Value.SIMDType.Scalar(fraction))
        
        self.valueChanged?(value)
        
        if _value >= _target {
            stop(immediately: true)
        }

    }
    
    internal var range: ClosedRange<Value> {
        get { Value(_range.lowerBound)...Value(_range.upperBound) }
        set { _range = newValue.lowerBound.simdRepresentation()...newValue.upperBound.simdRepresentation() }
    }
    
    internal var _range: ClosedRange<Value.SIMDType> = Value.SIMDType.zero...Value.SIMDType.zero

    fileprivate func updateRange() {
        _range = _fromValue..._target
    }
    
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        duration = settings.mode.duration ?? 0.0
    }
    
    public init(from: Value, target: Value, duration: TimeInterval, easingFunction: EasingFunction<Value.SIMDType>) {
        self.duration = duration
        self.fromValue = from
        self.value = from
        self.target = target
        self.easingFunction = easingFunction
    }
}
*/
