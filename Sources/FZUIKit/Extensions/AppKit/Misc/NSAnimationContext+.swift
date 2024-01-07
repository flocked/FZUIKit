//
//  NSAnimationContext+.swift
//
//
//  Created by Florian Zand on 11.10.23.
//

#if os(macOS)
import AppKit

public extension NSAnimationContext {
    /// Runs the specified block non animated.
    class func runNonAnimated(_ changes: () -> Void) {
        self.runAnimationGroup({ context in
            context.duration = 0.0
            changes()
        })
    }
    
    /**
     Runs the animation group.
     
     - Parameters:
        - duration: The duration of the animations. The default value is `nil`, which uses the default animation duration.
        - timingFunction: A optional timing function for the animations. The default value is `nil`.
        - allowsImplicitAnimation: A Boolean value that indicates whether the animator should dynamically provide all animatable properties of the object.animations are enabled or not for animations that occur as a result of another property change. The default value is `false`.
        - changes: The changes to animate.
        - completionHandler: An optional completion block that is called when the animations in the grouping are completed. The default value is `nil`.

     */
    class func runAnimations(duration: TimeInterval? = nil, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: ()->(), completionHandler: (()->())? = nil) {
        NSAnimationContext.runAnimationGroup() { context in
            context.duration = duration ?? context.duration
            context.timingFunction = timingFunction ?? context.timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            context.completionHandler = completionHandler
            changes()
        }
    }
}
#endif
