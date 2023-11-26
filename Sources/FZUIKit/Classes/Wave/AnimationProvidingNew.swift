//
//  File.swift
//  
//
//  Created by Florian Zand on 26.11.23.
//

import Foundation


open class BaseAnimation<Value: AnimatableProperty>: AnimationProviding, ConfigurableAnimationProviding, AnimationVelocityProviding {
    open var id: UUID = UUID()
    open internal(set) var groupUUID: UUID?
    open var relativePriority: Int = 0
    public internal(set) var state: AnimationState = .inactive
    open internal(set) var delay: TimeInterval = 0.0
    internal var delayedStart: DispatchWorkItem?
    open var fromValue: Value
    open var value: Value
    open var target: Value
    open var velocity: Value
    open var valueChanged: ((Value) -> Void)? = nil
    open var completion: ((AnimationEvent<Value>) -> Void)?

    internal init(value: Value, target: Value) {
        self.value = value
        self.target = target
        self.fromValue = value
        self.velocity = .zero
    }
    
    open func updateAnimation(deltaTime: TimeInterval) {
        
    }
    
    open func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")
        guard state != .running else { return }
        
        let start = {
            AnimationController.shared.runAnimation(self)
        }
        
        self.delayedStart?.cancel()
        self.delay = delay

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
    
    open func pause() {
        guard state == .running else { return }
        self.state = .inactive
        self.delayedStart?.cancel()
        self.delay = 0.0
        AnimationController.shared.stopAnimation(self)
    }
    
    open func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        self.delayedStart?.cancel()
        self.delay = 0.0
        if immediately == false, isVelocityAnimation {
            switch position {
            case .start:
                self.target = fromValue
            case .current:
                self.target = value
            default: break
            }
        } else {
            self.state = .ended
            switch position {
            case .start:
                self.value = fromValue
                self.valueChanged?(value)
            case .end:
                self.value = target
                self.valueChanged?(value)
            default: break
            }
            self.target = value
            completion?(.finished(at: value))
            AnimationController.shared.stopAnimation(self)
        }
    }
    
    public func reset() {
        
    }
    
    internal func configure(withSettings settings: AnimationController.AnimationParameters) {
        
    }
}
