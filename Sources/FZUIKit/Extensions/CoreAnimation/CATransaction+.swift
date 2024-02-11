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
            - duration: The duration of the animations, measured in seconds.  If you specify a value of `0`, the changes are made without animating them. The default value is `0.25`.
            - timingFunction: An optional timing function for the animations. The default value is `nil`.
            - disableActions: A Boolean value that indicates whether actions triggered as a result of property changes are suppressed. The default value is `false`.
            - animations: A block containing the changes to commit animated to the layers.
            - completionHandler: An optional completion block that is called when the animations have completed. The default value is `nil`.

         */
        static func perform(duration: CGFloat = 0.25, timingFunction: CAMediaTimingFunction? = nil, disableActions: Bool = false, animations: () -> Void, completionHandler: (() -> Void)? = nil) {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completionHandler)
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(timingFunction)
            CATransaction.setDisableActions(disableActions)
            animations()
            CATransaction.commit()
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

        /// The completion block of the current transaction group that is called as soon as all animations have completed.
        static var completionHandler: (() -> Void)? {
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
