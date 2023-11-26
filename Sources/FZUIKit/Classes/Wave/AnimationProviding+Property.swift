//
//  AnimationProviding+Property.swift
//
//
//  Created by Florian Zand on 26.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils

/// An animation that animates an animatable property conforming to ``AnimatableProperty``.
public protocol PropertyAnimationProviding<Value>: AnyObject, AnimationProviding {
    associatedtype Value: AnimatableProperty
    var state: AnimationState { get set }
    /// The current value of the animation. This value will change as the animation executes.
    var value: Value { get set }
    /// The start value of the animation.
    var fromValue: Value { get set }
    /// The target value of the animation.
    var toValue: Value { get set }
    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    /// Resets the animation.
    func reset()
}

public class TestAnimation<Value: AnimatableProperty>: PropertyAnimationProviding {
    public func reset() {
    }
    
    public var state: AnimationState = .inactive
    public var value: Value
    public var fromValue: Value
    public var toValue: Value
    public init(value: Value) {
        self.value = value
        self.toValue = value
        self.fromValue = value
    }
    
    public var completion: ((AnimationEvent<Value>) -> Void)?
    public var valueChanged: ((Value) -> Void)?
    public var id = UUID()
    public var groupUUID: UUID? = nil
    public var relativePriority: Int = 0
    public var delay: TimeInterval = 0.0
    public func updateAnimation(deltaTime: TimeInterval) {
        
    }
}

public extension PropertyAnimationProviding {
    func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
        guard state != .running else { return }
        
        let start = {
            AnimationController.shared.runAnimation(self)
        }
        
        self.delayedStart?.cancel()

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            self.delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }

    func pause() {
        guard state == .running else { return }
        self.state = .inactive
        self.delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        guard state == .running else { return }
        self.delayedStart?.cancel()
        if immediately == false {
            switch position {
            case .start:
                self.toValue = fromValue
            case .current:
                self.toValue = value
            default: break
            }
        } else {
            self.state = .ended
            switch position {
            case .start:
                self.value = fromValue
                self.valueChanged?(value)
            case .end:
                self.value = toValue
                self.valueChanged?(value)
            default: break
            }
            self.toValue = value
           // (self as? (any AnimationVelocityProviding))?.setVelocity(Value.zero)
            self.completion?(.finished(at: value))
            AnimationController.shared.stopAnimation(self)
        }
    }
    
    internal var delayedStart: DispatchWorkItem? {
        get { getAssociatedValue(key: "delayedStart", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "delayedStart", object: self) }
    }
}

#endif
