//
//  DynamicPropertyAnimator.swift
//  
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import QuartzCore
import FZSwiftUtils

/**
 Provides animatable properties of an object conforming to `AnimatablePropertyProvider`.

 All properties conforming to `AnimatableProperty` can be animated. A property can be accessed dynamically by writting it's name.
 
 ```swift
 public class MyObject: AnimatablePropertyProvider {
    var floatValue: CGFloat = 1.0
    var color: NSColor = .red
 }
 
 let object = MyObject()
 Wave.animate(withSpring: .smooth) {
    object.animator.floatValue = newFloat
    object.animator.color = newColor
 }
 ```
 
 To integralize a value  to the screen's pixel boundaries when animating, use it's keyPath and `integralizeValue`.  This helps prevent drawing frames between pixels, causing aliasing issues. Note: Enabling it effectively quantizes values, so don't use this for values that are supposed to be continuous.
 
 ```swift
 self[\.myAnimatableProperty, integralizeValue: true] = newValue
 ```
 */
@dynamicMemberLookup
public class DynamicPropertyAnimator<Object: AnyObject> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    
    internal var animations: [String: AnimationProviding] {
        get { getAssociatedValue(key: "animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "animations", object: self) }
    }
    
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value>) -> Value where Value: AnimatableProperty  {
        get { value(for: member, key: nil) }
        set { setValue(newValue, for: member) }
    }
    
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value?>) -> Value? where Value: AnimatableProperty  {
        get { value(for: member, key: nil) }
        set { setValue(newValue, for: member) }
    }
}

public extension DynamicPropertyAnimator {
    subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>, integralizeValue integralizeValue: Bool = false) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>, integralizeValue integralizeValue: Bool = false, epsilon epsilon: Double? = nil) -> Value  where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false, epsilon epsilon: Double? = nil) -> Value? where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValue: integralizeValue) }
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<DynamicPropertyAnimator, Value>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimation<Value> {
            return animation.velocity
        } else if let animation = (object as? NSUIView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimation<Value> {
            return animation.velocity
        }
        return nil
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<DynamicPropertyAnimator, Value?>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimation<Value> {
            return animation.velocity
        } else if let animation = (object as? NSUIView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimation<Value> {
            return animation.velocity
        }
        return nil
    }
}

internal extension DynamicPropertyAnimator {
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimation<Val>
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimation<Val>
    }
    
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath, key: key) ?? SpringAnimation<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        
        configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, epsilon: epsilon, integralizeValue: integralizeValue, completion: completion)
    }
    
    func setValue<Value: AnimatableProperty>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        let animation = (animation(for: keyPath, key: key) ?? SpringAnimation<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        
        configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, epsilon: epsilon, integralizeValue: integralizeValue, completion: completion)
    }
    
    func configurateAnimation<Value>(_ animation: SpringAnimation<Value>, target: Value, keyPath: PartialKeyPath<Object>, key: String? = nil, settings: AnimationController.AnimationParameters, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil) {
        animation.target = target
        animation.epsilon = epsilon
        animation.integralizeValues = integralizeValue
        animation.configure(withSettings: settings)
        if let keyPath = keyPath as? WritableKeyPath<Object, Value> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
        } else if let keyPath = keyPath as? WritableKeyPath<Object, Value?> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
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

    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let val = (value as! CGColor).nsUIColor
            let tar = (target as! CGColor).nsUIColor
            if val?.isVisible == false {
                value = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
            if tar?.isVisible == false {
                target = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
        } else if var val = value as? [Double], var tar = target as? [Double], val.count != tar.count {
            let diff = tar.count - val.count
            if diff < 0 {
                for i in tar.count-(diff * -1)..<tar.count {
                    tar[i] = .zero
                }
            } else if diff > 0 {
                val.append(contentsOf: Array(repeating: .zero, count: diff))
            }
            value = val as! V
            target = tar as! V
        }
    }
}

#endif
