//
//  CATransaction+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import QuartzCore

public extension CATransaction {
    /// Runs the specified closure without any animations.
    static func performNonAnimated(_ changes: () -> Void) {
        perform(duration: 0.0, disableActions: true, changes: changes)
    }

    /// Runs the specified closure with disabled actions.
    static func disabledActions(_ changes: () -> Void) {
        CATransaction.begin()
        CATransaction.disableActions = true
        changes()
        CATransaction.commit()
    }

    /**
     Animate changes to one or more layers.

     - Parameters:
        - duration: The duration of the animations (in seconds).  If you specify a negative value or `0`, the changes are made without animating them.
        - timingFunction: A timing function for the animations.
        - disableActions: A Boolean value indicating whether actions triggered as a result of property changes are suppressed.
        - changes: The closure containing the changes to animate
        - completion: A closure to execute after the animation completes.
     */
    static func perform(duration: CGFloat = 0.25, timingFunction: CAMediaTimingFunction? = nil, disableActions: Bool = false, changes: () -> Void, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.completionHandler = completion
        CATransaction.animationDuration = duration
        CATransaction.timingFunction = timingFunction
        CATransaction.disableActions = disableActions
        changes()
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
