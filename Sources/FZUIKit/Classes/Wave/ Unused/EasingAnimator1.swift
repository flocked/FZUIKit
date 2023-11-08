//
//  EaseAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
/*
public class EasyAnimator: AnimationProviding {
    let id = UUID()
    var groupUUID: UUID?
    var relativePriority: Int = 0
    
    var value: AnimatableVector = .zero
    
    var fromValue: AnimatableVector = .zero {
        didSet { updateRange() }
    }
    var toValue: AnimatableVector = .zero {
        didSet { updateRange() }
    }
    var range: ClosedRange<AnimatableVector> = AnimatableVector.zero...AnimatableVector.zero
    
    public var duration: CFTimeInterval = 0.3
    
    public var resolvingEpsilon: Double = 0.01
    
    public var easingFunction: EasingFunction = .linear
    
    internal var accumulatedTime: CFTimeInterval = 0.0
    
    public var valueChanged: ((_ currentValue: AnimatableVector) -> Void)?
    
    public var completion: (() -> Void)?
    
    
    func updateRange() {
        range = fromValue...toValue
    }
    
    public private(set) var state: AnimationState = .inactive
    
    func updateAnimation(deltaTime: TimeInterval) {
        if duration.isApproximatelyEqual(to: 0.0) {
            stop(resolveImmediately: true, postValueChanged: true)
            return
        }
        
        state = .running
        
        accumulatedTime += dt
        
        let fraction = min(max(0.0, accumulatedTime / duration), 1.0)
        
        value = easingFunction.solveInterpolatedValue(range, fraction: fraction)
        
        valueChanged?(value)
        
        if value.isApproximatelyEqual(to: toValue, epsilon: resolvingEpsilon) {
            stop()
            completion?()
        }
    }
    
    internal func hasResolved(value: inout AnimatableVector, epsilon: inout Double, toValue: inout AnimatableVector) -> Bool {
        /* Must Be Mirrored Above */
        
        return value.isApproximatelyEqual(to: toValue, epsilon: epsilon)
    }
    
    func start(afterDelay delay: TimeInterval) {
        let start = {
            self.attemptToUpdateAccumulatedTimeToMatchValue()
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
        
    }
    
    func stop(resolveImmediately: Bool = false, postValueChanged: Bool = false) {
        if resolveImmediately {
            state = .ended
            
            //    completion(.finished(at: value)
        } else {
            toValue = value
        }
        if postValueChanged {
            valueChanged?(value)
        }
    }
    
    
    func reset() {
        
    }
    
    func reset(postValueChanged: Bool) {
        stop(immediately: true)
        self.accumulatedTime = 0.0
        self.value = fromValue
        if postValueChanged {
            valueChanged?(value)
        }
    }
    
    internal func attemptToUpdateAccumulatedTimeToMatchValue() {
        if !value.isApproximatelyEqual(to: fromValue, epsilon: resolvingEpsilon) && !value.isApproximatelyEqual(to: toValue, epsilon: resolvingEpsilon) {
            // Try to find out where we are in the animation.
            if let accumulatedTime = solveAccumulatedTime(easingFunction: easingFunction, range: &range, value: &value) {
                self.accumulatedTime = accumulatedTime * duration
            } else {
                // Unexpected state, reset to beginning of animation.
                reset(postValueChanged: false)
            }
        } else {
            // We're starting this animation fresh, so ensure all state is correct.
            reset(postValueChanged: false)
        }
    }
    
    internal func solveAccumulatedTime(easingFunction: EasingFunction, range: inout ClosedRange<AnimatableVector>, value: inout AnimatableVector) -> CFTimeInterval? {
        /* Must Be Mirrored Above */
        
        if !range.contains(value) {
            return nil
        }
        
        return easingFunction.solveAccumulatedTime(range, value: value)
    }
    
}
*/
