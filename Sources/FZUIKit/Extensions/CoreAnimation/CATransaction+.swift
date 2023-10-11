//
//  CATransaction+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

#if canImport(QuartzCore)
import QuartzCore

public extension CATransaction {
    /**
     Animate changes to one or more layers using the specified duration, delay, options, and completion handler.
     
     - Parameters:
        - duration: The total duration of the animations, measured in seconds.  If you specify a value of 0, the changes are made without animating them.
        - timingFunction:  The timing function used for all animations within this transaction group.
        - animations: A block object containing the changes to commit to the layers. This is where you programmatically change any animatable properties of the layers in your view hierarchy.
        - completion: A block object to be executed when the animation sequence ends.
     
     */
    static func perform(duration: CGFloat = 0.4, timingFunction: CAMediaTimingFunction? = nil, animations: () -> Void, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setDisableActions(duration == 0.0)
        animations()
        CATransaction.commit()
    }
    
    /// Runs the changes of the specified changes block non animated.
    static func performNonAnimated(changes: ()->Void) {
        self.perform(duration: 0.0, animations: changes)
    }
}
#endif
