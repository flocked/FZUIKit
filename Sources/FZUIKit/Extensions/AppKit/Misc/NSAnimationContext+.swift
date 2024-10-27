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
            runAnimationGroup { context in
                context.duration = 0.0
                context.allowsImplicitAnimation = true
                changes()
            }
        }

        /**
         Runs the animation group.

         - Parameters:
            - duration: The duration of the animations, measured in seconds. If you specify a value of `0`, the changes are made without animating them.
            - timingFunction: An optional timing function for the animations.
            - allowsImplicitAnimation: A Boolean value that indicates whether animations are enabled for animations that occur as a result of another property change.
            - animations: A block containing the changes to animate.
            - completion: An optional completion block that is called when the animations have completed.
         */
        class func run(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: () -> Void, completion: (() -> Void)? = nil) {
            NSAnimationContext.runAnimationGroup ({ context in
                context.duration = duration
                context.timingFunction = timingFunction
                context.allowsImplicitAnimation = allowsImplicitAnimation
                changes()
            }, completionHandler: completion)
        }
        
        /**
         A Boolean value that indicates whether the the current animation context has an active grouping.
         
         The property returns `true`, if it's called inside a `runAnimationGroup(_:)` closure or between `beginGrouping()` and `endGrouping()`.
         */
        class var hasActiveGrouping: Bool {
            value(forKey: "_hasActiveGrouping") as? Bool ?? false
        }
    }
#endif
