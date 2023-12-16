//
//  PropertyAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import QuartzCore
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/**
 Provides animatable properties of an object conforming to `AnimatablePropertyProvider`.
 
 For easier access of a animatable property, you can extend the object's PropertyAnimator.
 
 ```swift
 extension: MyObject: AnimatablePropertyProvider { }
 
 public extension PropertyAnimator<MyObject> {
    var myAnimatableProperty: CGFloat {
        get { self[\.myAnimatableProperty] }
        set { self[\.myAnimatableProperty] = newValue }
    }
 }
 
 let object = MyObject()
 Anima.animate(withSpring: .smooth) {
    object.animator.myAnimatableProperty = newValue
 }
 ```
 */
public class PropertyAnimator<Object: AnimatablePropertyProvider> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    /// A dictionary containing the current animated property keys and associated animations.
    public internal(set) var animations: [String: AnimationProviding] = [:]
    
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Anima`` animation block animates to the new value.
     
     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    /**
     The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

     - Parameter velocity: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value>) -> Value {
        get { animation(for: velocity)?.velocity as? Value ?? .zero  }
        set { animation(for: velocity)?.setVelocity(newValue) }
    }

    /**
     The current animation for the property at the specified keypath.
     
     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> AnimationProviding? {
        return self.animations[keyPath.stringValue]
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
     
     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> Value? {
        return (animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
    
    var lastAnimationKey: String = ""
}

internal extension PropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>) -> Value {
        if AnimationController.shared.currentAnimationParameters?.needsVelocityValue == true {
            return animation(for: keyPath)?.velocity as? Value ?? .zero
        }
        return animation(for: keyPath)?.target as? Value ?? object[keyPath: keyPath]
    }
    
    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, completion: (()->())? = nil) {
        guard let settings = AnimationController.shared.currentAnimationParameters, settings.isAnimation else {
            animation(for: keyPath)?.stop(at: .current, immediately: true)
            object[keyPath: keyPath] = newValue
            return
        }
        
        if value(for: keyPath) == newValue {
            Swift.print("same value", settings.animationType?.rawValue ?? "nil", animation(for: keyPath)?.animationType.rawValue ?? "nil")
            if let animationType = settings.animationType {
                guard animationType != animation(for: keyPath)?.animationType else {
                    return
                }
            } else {
                return
            }
        }
        Swift.print("set value", settings.animationType?.rawValue ?? "nil", animation(for: keyPath)?.animationType.rawValue ?? "nil")
        
        var value = object[keyPath: keyPath]
        var target = newValue
        Swift.print("--------------")
        Swift.print("set value 0")
        Swift.print(value.animatableData)
        Swift.print(target.animatableData)
        updateValue(&value, target: &target)
        Swift.print("set value 1")
        Swift.print(value.animatableData)
        Swift.print(target.animatableData)
        Swift.print("--------------")

        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.configuration {
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath) ?? DecayAnimation(value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath) ?? EasingAnimation(timingFunction: .linear, duration: 1.0, value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .spring(_,_):
            let animation = springAnimation(for: keyPath) ?? SpringAnimation(spring: .smooth, value: value, target: target)
            if let oldAnimation = self.animation(for: keyPath), oldAnimation.id != animation.id, let velocity = oldAnimation._velocity as? Value.AnimatableData {
                animation._velocity = velocity
            }
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .velocityUpdate:
            animation(for: keyPath)?.setVelocity(target)
        case .nonAnimated:
            break
        }  
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: WritableKeyPath<Object, Value>, settings: AnimationController.AnimationParameters, completion: (()->())? = nil) {
        
        var animation = animation
        animation.reset()
        
        if settings.configuration.isDecayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._fromVelocity = animation._velocity
        } else {
            animation.target = target
        }

        animation.fromValue = animation.value
        animation.configure(withSettings: settings)
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        
        Swift.print("configurate animation")
        Swift.print(animation.value.animatableData)
        Swift.print(animation.target.animatableData)
        
        #if os(iOS) || os(tvOS)
        if settings.preventUserInteraction {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.insert(animation.id)
        } else {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
        }
        #endif
        
        let animationKey = keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                #if os(iOS) || os(tvOS)
                (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
                #endif
                AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        
        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            oldAnimation.stop(at: .current, immediately: true)
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    /// Updates the current  and target of an animatable property for better interpolation/animations.
    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if let color = value as? any AnimatableColor, let targetColor = target as? any AnimatableColor {
            value = color.animatable(to: targetColor) as! V
            target = targetColor.animatable(to: color) as! V
        } else if let collection = value.animatableData as? any AnimatableCollection, let targetCollection = target.animatableData as? any AnimatableCollection, collection.count != targetCollection.count {
            value =  V(collection.animatable(to: targetCollection) as! V.AnimatableData)
            target =  V(targetCollection.animatable(to: collection) as! V.AnimatableData)
        } else if let shadow = value as? any AnimatableShadow, let targetShaodw = target as? AnimatableShadow {
            value = shadow.animatable(to: targetShaodw) as! V
            target = targetShaodw.animatable(to: shadow) as! V
        }
    }
}

internal extension PropertyAnimator {
    /// The current animation for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>) -> (any ConfigurableAnimationProviding)? {
        let key = keyPath.stringValue
        lastAnimationKey = key
        return animations[key] as? any ConfigurableAnimationProviding
    }

    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Val>) -> SpringAnimation<Val>? {
        animation(for: keyPath) as? SpringAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Val>) -> EasingAnimation<Val>? {
        animation(for: keyPath) as? EasingAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Val>) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath) as? DecayAnimation<Val>
    }
}

#if canImport(UIKit)
internal extension DynamicPropertyAnimator<UIView> {
    var preventsUserInteractions: Bool {
        get { getAssociatedValue(key: "preventsUserInteractions", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "preventsUserInteractions", object: self) }
    }
    
    /// Collects the animations that are configurated to prevent user interactions. If the set isn't empty the user interactions get disabled. When all animations finishes and the collection is empty, user interaction gets enabled again.
    var preventingUserInteractionAnimations: Set<UUID> {
        get { getAssociatedValue(key: "preventingAnimations", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "preventingAnimations", object: self)
            if !preventingUserInteractionAnimations.isEmpty, object.isUserInteractionEnabled, !preventsUserInteractions {
                object.isUserInteractionEnabled = false
                preventsUserInteractions = true
            } else if preventingUserInteractionAnimations.isEmpty, preventsUserInteractions {
                object.isUserInteractionEnabled = true
                preventsUserInteractions = false
            }
        }
    }
}
#endif

#endif



/*
/**
 The current value of the property at the specified keypath. Assigning a new value inside a ``Anima`` animation block animates to the new value.
 
 - Parameter keyPath: The keypath to the animatable property.
 */
public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>) -> Value? {
    get { value(for: keyPath) }
    set { setValue(newValue, for: keyPath) }
}
 
 /**
  The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

  - Parameter velocity: The keypath to the animatable property for the velocity.
  */
 public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value?>) -> Value {
     get { ((self.animation(for: velocity)?.velocity as? Value)) ?? .zero  }
     set { self.animation(for: velocity)?.setVelocity(newValue) }
 }
 
 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator, Value?>) -> Value? {
     return (self.animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
 }
 */


/*
/// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value?>) -> Value?  {
    if AnimationController.shared.currentAnimationParameters?.type.needsVelocityValue == true {
        return (self.animation(for: keyPath)?.velocity as? Value) ?? .zero
    }
    return (self.animation(for: keyPath)?.target as? Value) ?? object[keyPath: keyPath]
}
 
 
 /// Animates the value of the property at the keypath to a new value.
 func setValue<Value: AnimatableProperty>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, completion: (()->())? = nil) {
     guard let settings = AnimationController.shared.currentAnimationParameters, settings.isAnimation else {
         self.animation(for: keyPath)?.stop(at: .current, immediately: true)
         self.object[keyPath: keyPath] = newValue
         return
     }
             
     guard value(for: keyPath) != newValue else {
         return
     }
             
     var initialValue = object[keyPath: keyPath] ?? Value.zero
     var target = newValue ?? Value.zero
     let valueChanged: ((_ currentValue: Value) -> Void)? = { [weak self] value in
         self?.object[keyPath: keyPath] = value
     }
     updateValue(&initialValue, target: &target)
     setupAnimation(initialValue, target: target, keyPath: keyPath, settings: settings, valueChanged: valueChanged, completion: completion)
 }
      
 /// Setups an animation for the specified value of the property at the keypath to a new value.
 func setupAnimation<Value: AnimatableProperty>(_ value: Value, target: Value, keyPath: PartialKeyPath<Object>, settings: AnimationController.AnimationParameters,  valueChanged: ((_ currentValue: Value) -> Void)?, completion: (()->())? = nil) {
     AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
     switch settings.type {
     case .spring(_,_):
         let animation = springAnimation(for: keyPath) ?? SpringAnimation(spring: .smooth, value: value, target: target)
         configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, valueChanged: valueChanged, completion: completion)
     case .easing(_,_):
         let animation = easingAnimation(for: keyPath) ?? EasingAnimation(timingFunction: .linear, duration: 1.0, value: value, target: target)
         configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, valueChanged: valueChanged, completion: completion)
     case .decay(_,_):
         let animation = decayAnimation(for: keyPath) ?? DecayAnimation(value: value, target: target)
         configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, valueChanged: valueChanged, completion: completion)
     case .velocityUpdate:
         animation(for: keyPath)?.setVelocity(target)
     case .nonAnimated:
         break
     }
 }
 */
