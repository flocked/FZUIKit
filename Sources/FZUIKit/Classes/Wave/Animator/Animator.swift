//
//  Animator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils
import QuartzCore

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
    var animations: [String: AnimationProviding] {
        get { object._animations }
        set { object._animations = newValue }
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func value<Value: SpringInterpolatable>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value where Value.ValueType == Value, Value.VelocityType == Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: SpringInterpolatable>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value? where Value.ValueType == Value, Value.VelocityType == Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: SpringInterpolatable>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) where Value.ValueType == Value, Value.VelocityType == Value {
        guard value(for: keyPath, key: key) != newValue else {
            return
        }
        
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        
        if Value.self == NSUIColor.self, let iniVal = initialValue as? NSUIColor, let tarVal = newValue as? NSUIColor {
            if iniVal == .clear {
                initialValue = tarVal.withAlphaComponent(0.0) as! Value
            }
            if tarVal == .clear {
                targetValue = iniVal.withAlphaComponent(0.0) as! Value
            }
        }
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
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
        let animationKey = key ?? keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    func setValue<Value: SpringInterpolatable>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) where Value.ValueType == Value, Value.VelocityType == Value {
        guard value(for: keyPath, key: key) != newValue else {
            return
        }
        
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.ValueType.zero
        var targetValue = newValue ?? Value.ValueType.zero
        
        Swift.print("wave", Value.self == CGColor.self, (initialValue as? Optional<CGColor>) ?? "nil")
        Swift.print("wave 1", type(of: Value.self), Value.self, (initialValue as? NSUIColor) ?? "nil", type(of: initialValue))

        
        if Value.self == NSUIColor.self, let iniVal = initialValue as? Optional<NSUIColor>, let tarVal = newValue as? Optional<NSUIColor> {
            if iniVal == .clear || iniVal == nil {
                Swift.print("iniVal")
                initialValue = (tarVal.optional?.withAlphaComponent(0.0) ?? .clear) as! Value
            }
            if tarVal == .clear || tarVal == nil {
                Swift.print("tarVal")
                targetValue = (iniVal.optional?.withAlphaComponent(0.0) ?? .clear) as! Value
            }
        }
                
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
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
        let animationKey = key ?? keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
}

#endif
