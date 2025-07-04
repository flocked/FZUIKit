//
//  NSView+Animate.swift
//
//
//  Created by Florian Zand on 04.01.25.
//

#if os(macOS)
import AppKit

extension NSView {
    /**
     Animate changes to one or more views.
     
     - Parameters:
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled or not for animations that occur as a result of another property change.
        - animations: The block containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: A completion block to be executed when the animations have completed.
     */
    public static func animate(timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, _ animations: () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.springAnimation = nil
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            animations()
        }, completionHandler: completion)
    }
    
    /**
     Animate changes to one or more views with the specified animation duration.
     
     - Parameters:
        - duration: The duration of the animations (in seconds). If you specify a negative value or `0`, the changes are made without animating.
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled or not for animations that occur as a result of another property change.
        - animations: The block containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: A completion block to be executed when the animations have completed.
     */
    public static func animate(withDuration duration: CGFloat, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, _ animations: () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.springAnimation = nil
            context.duration = duration.clamped(min: 0.0)
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            animations()
        }, completionHandler: completion)
    }
    
    /**
     Animate changes to one or more views using the specified spring animation.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled or not for animations that occur as a result of another property change.
        - animations: The block containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: A completion block to be executed when the animations have completed.
     */
    public static func animate(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, animations: ()->(), completion: (()->())? = nil) {
        NSAnimationContext.run(withSpring: spring, allowsImplicitAnimation: allowsImplicitAnimation, animations: animations, completion: completion)
    }
    
    /// Runs the specified closure without any animations.
    public static func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void) {
        CATransaction.performNonAnimated {
            actionsWithoutAnimation()
        }
    }
}

#endif
