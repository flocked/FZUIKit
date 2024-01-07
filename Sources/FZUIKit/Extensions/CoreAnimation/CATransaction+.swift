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
        - duration: The total duration of the animations, measured in seconds.  If you specify a value of 0, the changes are made without animating them. The default value is `0.25`.
        - timingFunction:  An optional timing function used for all animations within this transaction group. The default value is `nil`.
        - animations: A block object containing the changes to commit to the layers. This is where you programmatically change any animatable properties of the layers in your view hierarchy.
        - completion: An optional completion block object to be executed when the animation sequence ends. The default value is `nil`.
     
     */
    static func perform(duration: CGFloat = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: () -> Void, completion: (() -> Void)? = nil) {
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
    
    /// The timing function of the current transaction group.
    static var timingFunction: CAMediaTimingFunction? {
        get { value(forKey: kCATransactionAnimationTimingFunction) as? CAMediaTimingFunction }
        set { setValue(newValue, forKey: kCATransactionAnimationTimingFunction) }
    }
    
    /// A Boolean value that indicates whether changes made within the current transaction group are suppressed.
    static var disableActions: Bool {
        get { (value(forKey: kCATransactionDisableActions) as? Bool) ?? false }
        set { setValue(newValue, forKey: kCATransactionDisableActions) }
    }
    
    /// The animation duration of the current transaction group.
    static var animationDuration: TimeInterval {
        get { (value(forKey: kCATransactionAnimationDuration) as? TimeInterval) ?? 0.0 }
        set { setValue(newValue, forKey: kCATransactionAnimationDuration) }
    }
    
    /// The completion block object that is called (on the main thread) as soon as all animations of the current transaction group have completed.
    static var completionBlock: (()->())? {
        get {
            if let block = value(forKey: kCATransactionCompletionBlock) {
                let blockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
                return unsafeBitCast(blockPtr, to: CompletionBlock.self)
            }
            return nil
        }
        set { 
            if let newValue = newValue {
                let newValue = newValue as CompletionBlock
                let value = unsafeBitCast(newValue, to: AnyObject.self)
                setValue(value, forKey: kCATransactionCompletionBlock)
            } else {
                setValue(nil, forKey: kCATransactionCompletionBlock)
            }
        }
    }
    internal typealias CompletionBlock = @convention(block) () -> Void
}
#endif
