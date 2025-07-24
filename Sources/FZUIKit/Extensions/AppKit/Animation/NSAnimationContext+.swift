//
//  NSAnimationContext+.swift
//
//
//  Created by Florian Zand on 11.10.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

extension NSAnimationContext {
    /**
     A Boolean value that indicates whether the the current animation context has an active grouping.
     
     The property returns `true`, if it's called inside a [runAnimationGroup(_:)](https://developer.apple.com/documentation/appkit/nsanimationcontext/runanimationgroup(_:completionhandler:)) closure or between [beginGrouping()](https://developer.apple.com/documentation/appkit/nsanimationcontext/begingrouping()) and [endGrouping()](https://developer.apple.com/documentation/appkit/nsanimationcontext/endrouping()).
     */
    public class var hasActiveGrouping: Bool {
        value(forKey: "_hasActiveGrouping") as? Bool ?? false
    }
    
    /// Runs the changes of the closure non-animated.
    @discardableResult
    public class func performWithoutAnimation(_ changes: @escaping () -> Void) -> NSAnimator {
        NSAnimator(nonAnimated: changes)._start()
    }
    
    /**
     Runs the animation group with the specified duration.
     
     - Parameters:
        - duration: The duration of the animations, measured in seconds. If you specify a negative value or `0`, the changes are made without animating.
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     - Returns: The animation group.
     */
    @discardableResult
    public class func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimator {
        .init(duration: duration, timingFunction: timingFunction, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes).completion(completion)._start()
    }
    
    /**
     Runs the animation group using the specified spring animation.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     - Returns: The animation group.
     */
    @discardableResult
    public class func animate(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimator {
        .init(spring: spring, changes: changes).completion(completion)._start()
    }
    
    /**
     Runs the animation group using the specified `SwiftUI` animation.
     
     - Parameters:
        - animation: The `SwiftUI` animation
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     - Returns: The animation group.
     */
    @available(macOS 15.0, *)
    @discardableResult
    public class func animate(animation: Animation, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimator {
        .init(animation: animation, changes: changes).completion(completion)._start()
    }
    
    /**
     Animates the specified animations in a serial order.
     
     Example usage:
     
     ```swift
     NSAnimationContext.animate {
        NSAnimator(duration: 4.0) {
            view.animator().backgroundColor = .red
            view.animator().frame.size.width = 200
        }.repeats(2)
        NSAnimator(duration: 2.0) {
            view.animator().backgroundColor = .blue
            view.animator().frame.size.width = 100
        }.delay(1.0)
     }
     ```
     */
    @discardableResult
    public static func animate(@NSAnimator.Builder _ animations: @escaping () -> [NSAnimator]) -> NSAnimationGroup {
        let group = NSAnimationGroup(animations: animations)
        AnimationManager.runningAnimationGroups.insert(group)
        return group
    }
    
    var springAnimation: CASpringAnimation? {
        get { getAssociatedValue("springAnimation") }
        set { setAssociatedValue(newValue, key: "springAnimation") }
    }
}

#endif
