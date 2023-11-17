//
//  Wave.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation
import SwiftUI

/**
 Performs animations on animatable properties of an object conforming to ``AnimatablePropertyProvider``.
 
 Many objects provide animatable properties.
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView`, `NSLayoutConstraint`, `CALayer` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView`, `NSLayoutConstraint`, `CALayer`  and many more.
 
 There are three different types of animations :
 - **Spring:** ``Wave/animate(withSpring:delay:gestureVelocity:options:animations:completion:)``
 - **Easing:** ``Wave/animate(withEasing:duration:options:delay:animations:completion:)``
 - **Decay:** ``Wave/animate(withDecay:decelerationRate:options:delay:animations:completion:)``.
 
 To animate values, you must set the values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.

 ```swift
 Wave.animate(withSpring: Spring(dampingRatio: 0.6, response: 1.2)) {
    myView.animator.center = newCenterPoint
    myView.animator.backgroundColor = .systemBlue
 }
 ```
 To update values of properties that are currently animated use ``nonAnimate(changes:)``. It will stop their animations and sets their values immediately to the specified new values.

 ```swift
 Wave.nonAnimate() {
    myView.animator.center = newCenterPoint
    myView.animator.backgroundColor = .systemRed
 }
 ```
 Alternatively you can also update values non animated by  using the ``AnimatablePropertyProvider/animator-54mpy`` outside of a ``Wave`` animation block.

 ```swift
 myView.animator.center = newCenterPoint
 myView.animator.backgroundColor = .systemRed
 ```
 
 - Note: All animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.
 */
public enum Wave {
    /**
     Performs spring animations based on the specified ``Spring``.
     
     ```swift
     Wave.animate(withSpring: Spring(dampingRatio: 0.6, response: 1.2)) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```

     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Wave``.

     - Parameters:
        - spring: The ``Spring`` used to determine the timing curve and duration of the animation.
        - delay: An optional delay, in seconds, after which to start the animation.
        - gestureVelocity: If provided, this value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - repeats: A Boolean value that indicates whether the animation repeats indefinitely. The default value is `false`.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withSpring spring: Spring,
        delay: TimeInterval = 0,
        gestureVelocity: CGPoint? = nil,
        options: AnimationOptions = [],
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)
        
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            animationType: .spring(spring: spring, gestureVelocity: gestureVelocity),
            options: options,
            completion: completion
        )
                
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs easing animations based on the specified ``TimingFunction``.
     
     ```swift
     Wave.animate(withEasing: .easeInEaseOut), duration: 3.0) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Wave``.

     - Parameters:
        - timingFunction: The ``TimingFunction`` used to determine the timing curve.
        - duration: The duration of the animation.
        - repeats: A Boolean value that indicates whether the animation repeats indefinitely. The default value is `false`.
        - delay: An optional delay, in seconds, after which to start the animation.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withEasing timingFunction: TimingFunction,
        duration: TimeInterval,
        options: AnimationOptions = [],
        delay: TimeInterval = 0,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)
        
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            animationType: .easing(timingFunction: timingFunction, duration: duration),
            options: options,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs animations with a decaying acceleration.
     
     There are two decay modes:
     - **value:** The properties animate with a decaying acceleration to your values.
     - **velocity(CGPoint):**:  Values you assign to properties in the animation block will be ignored. Instead the properties will increase or decrease (depending on the `velocity` supplied) and will slow to a stop.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
     
     ```swift
     // This animates with a decaying acceleration to the new rect.
     Wave.animate(withDecay: .value) {
        myView.animator.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
     }
     
     // This increases the frame origin x & y value by 100 with a decaying acceleration.
     Wave.animate(withDecay: .velocity(CGPoint(x: 100, y: 100)) {
        myView.animator.frame = anyValue
     }
     ```
               
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Wave``.
     
     - Parameters:
        - mode: The mode how the animation should animate properties. 
            - If `value` the properties animate with a decaying acceleration to your provided values.
            - If `velocity(CGPoint)` the value of  properties will increase or decrease (depending on the `velocity` supplied) and will slow to a stop.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time. The values you assign to properties will be ignored.
        - decelerationRate: The rate at which the animation decelerates over time. The default value decelerates like scrollviews.
        - repeats: A Boolean value that indicates whether the animation repeats indefinitely. The default value is `false`.
        - delay: An optional delay, in seconds, after which to start the animation.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withDecay mode: DecayAnimationMode,
        decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate,
        options: AnimationOptions = [],
        delay: TimeInterval = 0,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            animationType: .decay(gestureVelocity: mode.velocity, decelerationRate: decelerationRate),
            options: options,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /// DecayAnimationMode
    
    /**
     Performs the specified changes non animated.
     
     Use it to immediately update the values of a properties that are currently animated. It will stop their animations and sets their values immediately to the specified new values.
     
     ```swift
     Wave.nonAnimate() {
        myView.animator.center = newCenterPoint
        myView.animator.backgroundColor = .systemRed
     }
     ```
     
     You can also update values non animated by using the ``AnimatablePropertyProvider/animator-54mpy`` outside of any ``Wave`` animation block.

     ```swift
     myView.animator.center = newCenterPoint
     myView.animator.backgroundColor = .systemRed
     ```
     
     - Note: For a list of all objects that provide animatable properties check ``Wave``.
     
     - Parameters changes: A block containing the changes to your objects' animatable properties that get updated non animated.
     */
    public static func nonAnimate(changes: () -> Void) {
        precondition(Thread.isMainThread)

        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: 0.0,
            animationType: .nonAnimated,
            options: [],
            completion: nil
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: changes, completion: nil)
    }
    
    /// Stops all animations at their current values.
    public static func stopAnimating() {
        AnimationController.shared.stopAllAnimations()
    }
}

#endif
