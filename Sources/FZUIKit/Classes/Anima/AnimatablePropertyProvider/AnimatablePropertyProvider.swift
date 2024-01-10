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
         Provides animatable properties. To animate a property, change it's value in a ``Anima`` animation block.

         Example usage:
         ```swift
         Anima.animate(withSpring: .smooth) {
            myView.animator.center = CGPoint(x: 100, y: 100)
            myView.animator.alpha = 0.5
         }

         myView.animator.alpha = 0.0 // Stops animating the property and changes it imminently.
         ```

         To get/set a property of the object that is not provided as `animator` property, use the properties keypath on `animator`. The property needs to confirm to ``AnimatableProperty``.

         ```swift
         Anima.animate(withSpring: .smooth) {
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

         Anima.animate(withSpring: .smooth) {
            myView.animator.myAnimatableProperty = newValue
         }
         ```
         */
        var animator: PropertyAnimator<Provider> { get }

        /**
         A Boolean value that indicates whether the animator should dynamically provide all animatable properties of the object.

         If `true` the properties are accessible by their names.
         */
        static var dynamicAnimatablePropertyLookup: Bool { get }
    }

    public extension AnimatablePropertyProvider {
        var animator: PropertyAnimator<Self> {
            if Self.dynamicAnimatablePropertyLookup {
                return getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: DynamicPropertyAnimator(self))
            }
            return getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: PropertyAnimator(self))
        }

        static var dynamicAnimatablePropertyLookup: Bool {
            false
        }
    }

#endif

/*

 #if os(macOS)
 public var propertyAnimations: [String: AnimationProviding] {
     get { getAssociatedValue(key: "propertyAnimations", object: self, initialValue: [:]) }
     set { set(associatedValue: newValue, key: "propertyAnimations", object: self) }
 }

 /**
  The current animation for the property at the specified keypath.

  - Parameter keyPath: The keypath to an animatable property.
  */
 public func propertyAnimation(for keyPath: PartialKeyPath<PropertyAnimator<Self>>) -> AnimationProviding? {
     var key = keyPath.stringValue
     if let animation = self.propertyAnimations[key] {
         return animation
     } else if key.contains("layer."), let viewAnimator = self as? PropertyAnimator<NSUIView> {
         key = key.replacingOccurrences(of: "layer.", with: "")
         return viewAnimator.object.optionalLayer?.animator.animations[key]
     }
     return nil
 }

 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator<Self>, Value>) -> Value? {
     return (self.propertyAnimation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
 }

 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator<Self>, Value?>) -> Value? {
     return (self.propertyAnimation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
 }
 #else
 public var animations: [String: AnimationProviding] {
     get { getAssociatedValue(key: "propertyAnimations", object: self, initialValue: [:]) }
     set { set(associatedValue: newValue, key: "propertyAnimations", object: self) }
 }

 /**
  The current animation for the property at the specified keypath.

  - Parameter keyPath: The keypath to an animatable property.
  */
 public func animation(for keyPath: PartialKeyPath<PropertyAnimator<Self>>) -> AnimationProviding? {
     var key = keyPath.stringValue
     if let animation = self.animations[key] {
         return animation
     } else if key.contains("layer."), let viewAnimator = self as? PropertyAnimator<NSUIView> {
         key = key.replacingOccurrences(of: "layer.", with: "")
         return viewAnimator.object.optionalLayer?.animator.animations[key]
     }
     return nil
 }

 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator<Self>, Value>) -> Value? {
     return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
 }

 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator<Self>, Value?>) -> Value? {
     return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
 }
 #endif
 */
