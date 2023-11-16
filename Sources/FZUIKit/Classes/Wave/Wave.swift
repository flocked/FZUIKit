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
 
 The following objects provide animatable properties via `animator`.
 - macOS: `NSView`, `NSTextField`, `NSTextView`, `NSImageView`, `NSControl`, `NSScrollView`, `NSButton`, `NSStackView`, `NSWindow`, `NSLayoutConstraint` and `CALayer`.
 - iOS: `UIView`, `UITextField`, `UILabel`, `UITextView`, `UIImageView`, `UIScrollView`, `UIStackView`, `UIButton`, `NSLayoutConstraint` and `CALayer`.
 
 Animations can either be ``Spring``, easing (``TimingFunction``) or decay based. To animate use either ``animate(withSpring:delay:gestureVelocity:isUserInteractionEnabled:animations:completion:)``, ``animate(withEasing:duration:delay:isUserInteractionEnabled:animations:completion:)`` or ``animate(withDecay:delay:isUserInteractionEnabled:animations:completion:)``.
 
For animations to work correctly, you must set values on the objects's `animator`, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.

 ```swift
 Wave.animate(withSpring: Spring(dampingRatio: 0.6, response: 1.2)) {
    myView.animator.center = newCenterPoint
    myView.animator.backgroundColor = .systemBlue
 }
 ```
 
 To update the values of a properties that is currenty animated use ``nonAnimate(changes:)``.
 
 To immediately update the values of properties that are currenty animated use ``nonAnimate(changes:)``. It will stop their animations and sets their values immediately to the specified new values.

 
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
 */
public enum Wave {
    /**
     Performs spring animations based on a ``Spring`` configurated as ``Spring/snappy``.

     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.
     
     - Note: For a list of all objects that provide animatable properties check ``Wave``.

     ```swift
     Wave.animate() {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     - Parameters:
        - delay: An optional delay, in seconds, after which to start the animation.
        - gestureVelocity: If provided, this value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - isUserInteractionEnabled: A Boolean value indicating whether views receive mouse/touch events while animated.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        delay: TimeInterval = 0,
        gestureVelocity: CGPoint? = nil,
        isUserInteractionEnabled: Bool = true,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        self.animate(withSpring: .snappy, delay: delay, gestureVelocity: gestureVelocity, isUserInteractionEnabled: isUserInteractionEnabled, animations: animations, completion: completion)
    }
    
    /**
     Performs spring animations based on the specified ``Spring``.

     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.

     - Note: For a list of all objects that provide animatable properties check ``Wave``.

     ```swift
     Wave.animate(withSpring: Spring(dampingRatio: 0.6, response: 1.2)) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     - Parameters:
        - spring: The `Spring` used to determine the timing curve and duration of the animation. The default spring is ``Spring/snappy``.
        - delay: An optional delay, in seconds, after which to start the animation.
        - gestureVelocity: If provided, this value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - isUserInteractionEnabled: A Boolean value indicating whether views receive mouse/touch events while animated.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withSpring spring: Spring,
        delay: TimeInterval = 0,
        gestureVelocity: CGPoint? = nil,
        isUserInteractionEnabled: Bool = true,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)
        
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            type: .spring(.init(spring: spring, gestureVelocity: gestureVelocity)),
            isUserInteractionEnabled: isUserInteractionEnabled,
            completion: completion
        )
        
        Swift.print("wave spring", settings.type.spring != nil)
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs easing animations based on the specified ``TimingFunction``.
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.

     - Note: For a list of all objects that provide animatable properties check ``Wave``.

     ```swift
     Wave.animate(withEasing: .easeInEaseOut), duration: 3.0) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     - Parameters:
        - timingFunction: The ``TimingFunction`` used to determine the timing curve.
        - duration: The duration of the animation.
        - delay: An optional delay, in seconds, after which to start the animation.
        - isUserInteractionEnabled: A Boolean value indicating whether views receive mouse/touch events while animated.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withEasing timingFunction: TimingFunction,
        duration: TimeInterval,
        delay: TimeInterval = 0,
        isUserInteractionEnabled: Bool = true,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)
        
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            type: .easing(.init(timingFunction: timingFunction, duration: duration)),
            isUserInteractionEnabled: isUserInteractionEnabled,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs decaying animations based on the specified gesture velocity.
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator-54mpy``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.

     - Note: Only `CGPoint` and `CGRect` properties can be animated decaying.
     
     - Note: For a list of all objects that provide animatable properties check ``Wave``.

     ```swift
     Wave.animate(withDecay: CGPoint(x: -200, y: -100))) {
        myView.animator.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
     }
     ```
     
     - Parameters:
        - gestureVelocity: The value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - delay: An optional delay, in seconds, after which to start the animation.
        - isUserInteractionEnabled: A Boolean value indicating whether views receive mouse/touch events while animated.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withDecay gestureVelocity: CGPoint,
        delay: TimeInterval = 0,
        isUserInteractionEnabled: Bool = true,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)

        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            delay: delay,
            type: .decay(.init(gestureVelocity: gestureVelocity)),
            isUserInteractionEnabled: isUserInteractionEnabled,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
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
            type: .nonAnimated,
            isUserInteractionEnabled: true,
            completion: nil
        )
        
        Swift.print("wave nonAnimate", settings.type.isNonAnimated)

        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: changes, completion: nil)
    }
}

#endif
