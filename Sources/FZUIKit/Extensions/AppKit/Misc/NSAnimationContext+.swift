//
//  NSAnimationContext+.swift
//
//
//  Created by Florian Zand on 11.10.23.
//

#if os(macOS)
import AppKit

public extension NSAnimationContext {
    /// Runs the changes of the specified block non-animated.
    class func runNonAnimated(_ changes: () -> Void) {
        self.runAnimationGroup({ context in
            context.duration = 0.0
            context.allowsImplicitAnimation = true
            changes()
        })
    }
    
    /**
     Runs the animation group.
     
     - Parameters:
        - duration: The duration of the animations, measured in seconds. If you specify a value of `0, the changes are made without animating them. The default value is `0.25`.
        - timingFunction: An optional timing function for the animations. The default value is `nil`.
        - allowsImplicitAnimation: A Boolean value that indicates whether animations are enabled for animations that occur as a result of another property change.. The default value is `false`.
        - animations: A block containing the changes to animate.
        - completionHandler: An optional completion block that is called when the animations have completed. The default value is `nil`.

     */
    class func runAnimations(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: ()->(), completionHandler: (()->())? = nil) {
        NSAnimationContext.runAnimationGroup() { context in
            context.duration = duration
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            context.completionHandler = completionHandler
            changes()
        }
    }
}
#endif
