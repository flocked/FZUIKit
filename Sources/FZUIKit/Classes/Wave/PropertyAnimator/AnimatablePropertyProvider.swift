//
//  AnimatablePropertyProvider.swift
//  
//
//  Created by Florian Zand on 27.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils

/// An object that provides animatable properties that can be accessed via ``AnimatablePropertyProvider/animator``.
public protocol AnimatablePropertyProvider: AnyObject {
    associatedtype Provider: AnimatablePropertyProvider = Self
    
    /**
     Provides animatable properties. To animate a property, change it's value in an ``Wave/animate(withSpring:delay:gestureVelocity:animations:completion:)`` animation block.
          
     Example usage:
     ```swift
     Wave.animate(withSpring: .smooth) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     
     myView.animator.alpha = 0.0 // Stops animating the property and changes it imminently.
     ```
     
     To get/set a property of the object that is not provided as `animator` property, use the properties keypath on `animator`. The property needs to confirm to ``AnimatableProperty``.
     
     ```swift
     Wave.animate(withSpring: .smooth) {
        myView.animator[\.myAnimatableProperty] = newValue
     }
     ```
     For easier access of the property, you can extend the object's PropertyAnimator.
     
     ```swift
     public extension PropertyAnimator<NSView> {
        var myAnimatableProperty: CGFloat {
            get { self[\.myAnimatableProperty] }
            set { self[\.myAnimatableProperty] = newValue }
        }
     }
     
     Wave.animate(withSpring: .smooth) {
        myView.animator.myAnimatableProperty = newValue
     }
     ```
     */
    var animator: PropertyAnimator<Provider> { get }
}

extension AnimatablePropertyProvider {
    public var animator: PropertyAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: PropertyAnimator(self)) }
    }
}

public extension AnimatablePropertyProvider {
    /// A dictionary containing the current animated property keys and associated animations.
    var animations: [String: AnimationProviding] {
        animator.animations
    }
    
    /**
     The current animation for the property at the specified keypath.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> AnimationProviding? {
        animator.animation(for: keyPath)
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values..
    func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator<Self>, Value>) -> Value? {
        animator.animationVelocity(for: keyPath)
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values..
    func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator<Self>, Value?>) -> Value? {
        animator.animationVelocity(for: keyPath)
    }
}

#endif
