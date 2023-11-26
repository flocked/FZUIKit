//
//  File.swift
//  
//
//  Created by Florian Zand on 26.11.23.
//

import Foundation


open class BaseAnimation<Value: AnimatableProperty>: AnimationProviding, ConfigurableAnimationProviding, AnimationVelocityProviding {
    public var id: UUID = UUID()
    public internal(set) var groupUUID: UUID?
    public var relativePriority: Int = 0
    public internal(set) var state: AnimationState = .inactive
    public internal(set) var delay: TimeInterval = 0.0
    internal var delayedStart: DispatchWorkItem?
    public var fromValue: Value
    public var value: Value
    public var target: Value
    public var velocity: Value
    public var valueChanged: ((Value) -> Void)? = nil
    public var completion: ((AnimationEvent<Value>) -> Void)?

    public init(value: Value, target: Value) {
        self.value = value
        self.target = target
        self.fromValue = value
        self.velocity = .zero
    }
    
    public func updateAnimation(deltaTime: TimeInterval) {
        
    }
    
    public func start(afterDelay delay: TimeInterval = 0.0) {
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
    
    public func pause() {
        guard state == .running else { return }
        self.state = .inactive
        self.delayedStart?.cancel()
        self.delay = 0.0
        AnimationController.shared.stopAnimation(self)
    }
    
    public func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
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
