//
//  Animator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
import FZSwiftUtils

/// An object that has animatable properties.
public protocol Animatable: AnyObject { }

extension Animatable  {
    /**
     Use the `animator` property to set any animatable properties in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```swift
     Wave.animateWith(spring: spring) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     ```
     */
    public var animator: Animator<Self> {
        get { getAssociatedValue(key: "Animator", object: self, initialValue: Animator(self)) }
        set { set(associatedValue: newValue, key: "Animator", object: self) }
    }
    
    internal var _animations: [String: AnimationProviding] {
        get { getAssociatedValue(key: "_animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "_animations", object: self) }
    }
}

/// Provides animatable properties of an object conforming to
public class Animator<Object: Animatable> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }

}

internal extension Animator {
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val?>) -> SpringAnimator<Val>? {
        guard let keyPath = keyPath._kvcKeyPathString else { return nil }
        return object._animations[keyPath] as? SpringAnimator<Val>
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>) -> SpringAnimator<Val>? {
        guard let keyPath = keyPath._kvcKeyPathString else { return nil }
        return object._animations[keyPath] as? SpringAnimator<Val>
    }
    
    func value<Value: SpringInterpolatable>(for keyPath: WritableKeyPath<Object, Value>) -> Value where Value.ValueType == Value, Value.VelocityType == Value {
        return animation(for: keyPath)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: SpringInterpolatable>(for keyPath: WritableKeyPath<Object, Value?>) -> Value? where Value.ValueType == Value, Value.VelocityType == Value {
        return animation(for: keyPath)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: SpringInterpolatable>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>) where Value.ValueType == Value, Value.VelocityType == Value {
        guard animation(for: keyPath)?.target ?? object[keyPath: keyPath] != newValue else {
            return
        }
        
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                self.setValue(newValue, for: keyPath)
            }
            return
        }
        
        let initialValue = object[keyPath: keyPath]
        let targetValue = newValue
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        let groupUUID = animation.groupUUID
        guard let animationKey = keyPath._kvcKeyPathString else { return }
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                self?.object._animations.removeValue(forKey: animationKey)
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        object._animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    func setValue<Value: SpringInterpolatable>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>) where Value.ValueType == Value, Value.VelocityType == Value {
        guard (animation(for: keyPath)?.target ?? object[keyPath: keyPath]) != newValue else {
            return
        }
        
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                self.setValue(newValue, for: keyPath)
            }
            return
        }
        
        let initialValue = object[keyPath: keyPath] ?? Value.VelocityType.zero
        let targetValue = newValue ?? Value.VelocityType.zero
                
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        let groupUUID = animation.groupUUID
        guard let animationKey = keyPath._kvcKeyPathString else { return }
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                self?.object._animations.removeValue(forKey: animationKey)
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        object._animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
}
