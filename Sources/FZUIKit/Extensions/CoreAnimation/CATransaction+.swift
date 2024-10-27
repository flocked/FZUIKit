//
//  CATransaction+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if canImport(QuartzCore)
    import QuartzCore

    public extension CATransaction {
        /// Runs the changes of the specified block non-animated.
        static func performNonAnimated(changes: () -> Void) {
            perform(duration: 0.0, disableActions: true, animations: changes)
        }

        /**
         Animate changes to one or more layers using the specified duration, timing function, and completion handler.

         - Parameters:
            - duration: The duration of the animations, measured in seconds.  If you specify a value of `0`, the changes are made without animating them.
            - timingFunction: An optional timing function for the animations.
            - disableActions: A Boolean value that indicates whether actions triggered as a result of property changes are suppressed.
            - animations: A block containing the changes to commit animated to the layers.
            - completionHandler: An optional completion block that is called when the animations have completed.

         */
        static func perform(duration: CGFloat = 0.25, timingFunction: CAMediaTimingFunction? = nil, disableActions: Bool = false, animations: () -> Void, completionHandler: (() -> Void)? = nil) {
            CATransaction.begin()
            CATransaction.completionHandler = completionHandler
            CATransaction.animationDuration = duration
            CATransaction.timingFunction = timingFunction
            CATransaction.disableActions = disableActions
            animations()
            CATransaction.commit()
        }

        /// The animation timing function of the current transaction group.
        static var timingFunction: CAMediaTimingFunction? {
            get { CATransaction.animationTimingFunction() }
            set { CATransaction.setAnimationTimingFunction(newValue) }
        }

        /// A Boolean value that indicates whether changes made within the current transaction group are suppressed.
        static var disableActions: Bool {
            get { CATransaction.disableActions() }
            set { CATransaction.setDisableActions(newValue) }
        }

        /// The animation duration of the current transaction group.
        static var animationDuration: TimeInterval {
            get { CATransaction.animationDuration() }
            set { CATransaction.setAnimationDuration(newValue) }
        }

        /// The completion block of the current transaction group that is called as soon as all animations have completed.
        static var completionHandler: (() -> Void)? {
            get { CATransaction.completionBlock() }
            set { CATransaction.setCompletionBlock(newValue) }
        }
    }
#endif
