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
public protocol AnimatableObject: AnyObject { }

extension AnimatableObject  {
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
public class Animator<Object: AnimatableObject> {
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
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: Spring.nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring.response == 0.0 && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        
        if Value.self == CGColor.self {
            let iniVal = (initialValue as! CGColor).nsUIColor
            let tarVal = (newValue as! CGColor).nsUIColor
            if iniVal?.isVisible == false || iniVal == nil {
                initialValue = (tarVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
            if tarVal?.isVisible == false || tarVal == nil {
                targetValue = (iniVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
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
                completion?()
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: Spring.nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring.response == 0.0 && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        
        if Value.self == CGColor.self {
            let iniVal = (object[keyPath: keyPath] as! Optional<CGColor>)?.nsUIColor
            let tarVal = (newValue as! Optional<CGColor>)?.nsUIColor
            if iniVal?.isVisible == false || iniVal == nil {
                initialValue = (tarVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
            if tarVal?.isVisible == false || tarVal == nil {
                targetValue = (iniVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
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
                completion?()
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
