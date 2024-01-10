//
//  NSView+Animate.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSView {
        /**
         Animate changes to the view using the specified duration, timing function, options, and completion handler.

         - Parameters:
            - duration:The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
            - timingFunction: The timing function of the animations.
            - animations: A block object containing the changes to commit to the view. This is where you programmatically change any animatable properties of the view.
            - completion: A block to be executed when the animation sequence ends.
         */
        func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: @escaping (Self) -> Void, completion: (() -> Void)? = nil) {
            Self.animate(duration: duration, timingFunction: timingFunction, animations: {
                animations(self.animator() as! Self)
            }, completion: completion)
        }

        /**
         Animate changes to one or more views using the specified duration, timingFunction, options, and completion handler.

         - Parameters:
            - duration:The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
            - timingFunction: The timing function of the animations.
            - animations: A block object containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy. This block takes no parameters and has no return value.
            - completion: A block to be executed when the animation sequence ends.
         */
        static func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = duration
                context.timingFunction = timingFunction ?? context.timingFunction
                context.allowsImplicitAnimation = true
                context.completionHandler = completion
                animations()
            }
        }
    }

#endif
