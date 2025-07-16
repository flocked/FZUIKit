//
//  NSView+Animate.swift
//
//
//  Created by Florian Zand on 04.01.25.
//

#if os(macOS)
import AppKit
import SwiftUI

 extension NSView {
     /**
      Animate changes to one or more views.
      
      - Parameters:
         - timingFunction: A timing function for the animations.
         - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
         - changes: The closure containing the changes to animate. This is where you programmatically change any animatable properties of the views in your view hierarchy.
         - completion: A closure to execute after the animation completes.
      */
     @discardableResult
     public static func animate(timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimationContext {
         .animate(timingFunction: timingFunction, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes, completion: completion)
     }
     
     /**
      Animate changes to one or more views with the specified animation duration.
      
      - Parameters:
         - duration: The duration of the animations (in seconds). If you specify a negative value or `0`, the changes are made without animating.
         - timingFunction: A timing function for the animations.
         - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
         - changes: The closure containing the changes to animate. This is where you programmatically change any animatable properties of the views in your view hierarchy.
         - completion: A closure to execute after the animation completes.
      */
     @discardableResult
     public static func animate(withDuration duration: TimeInterval, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimationContext {
         .animate(duration: duration, timingFunction: timingFunction, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes, completion: completion)
     }
     
     /**
      Animate changes to one or more views using the specified spring animation.
      
      - Parameters:
         - spring: The spring animation to use.
         - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
         - changes: The closure containing the changes to animate. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: A closure to execute after the animation completes.
      */
     @discardableResult
     public static func animate(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimationContext {
         .animate(withSpring: spring, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes, completion: completion)
     }
     
     /**
      Animate changes to one or more views using the specified `SwiftUI` animation.
      
      - Parameters:
         - animation: The `SwiftUI` animation.
         - changes: The closure containing the changes to animate. This is where you programmatically change any animatable properties of the views in your view hierarchy.
         - completion: A closure to execute after the animation completes.
      */
     @available(macOS 15.0, *)
     public static func animate(_ animation: Animation, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimationContext {
         .animate(animation, changes: changes, completion: completion)
     }
     
     /// Runs the specified closure without any animations.
     public static func performWithoutAnimation(_ changes: () -> Void) {
         NSAnimationContext.performWithoutAnimation(changes)
         // CATransaction.performNonAnimated(changes)
     }
 }

#endif
