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
     Animate changes to one or more views using the specified duration, delay, options, and completion handler.
     
     - Parameters:
        - duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
        - timingFunction: The timing function of the animations.
        - allowsImplicitAnimation: The Boolean value that indicates if animations are enabled or not for animations that occur as a result of another property change.
        - animations: The handler containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: The handler to be executed when the animation sequence ends.
     */
    public static func animate(withDuration duration: CGFloat = 0.2, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, animations: () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.springAnimation = nil
            context.duration = duration.clamped(min: 0.0)
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            animations()
        }, completionHandler: completion)
    }
    
    /**
     Animate changes to one or more views using the specified spring animation and completion handler.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: The Boolean value that indicates if animations are enabled or not for animations that occur as a result of another property change.
        - animations: The handler containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: The handler to be executed when the animation sequence ends.
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
