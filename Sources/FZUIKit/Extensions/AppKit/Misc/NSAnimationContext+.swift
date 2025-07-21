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
    public class func performWithoutAnimation(_ changes: () -> Void) {
        runAnimationGroup { context in
            context.springAnimation = nil
            context.duration = 0.0
            context.allowsImplicitAnimation = true
            changes()
        }
    }
    
    /**
     Runs the animation group with the specified duration.
     
     - Parameters:
        - duration: The duration of the animations, measured in seconds. If you specify a negative value or `0`, the changes are made without animating.
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @discardableResult
    public class func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimationContext {
        .run { $0.animate(duration: duration, timingFunction: timingFunction, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes, completion: completion) }
    }
    
    /**
     Runs the animation group after the previous with the specified duration.
     
     - Parameters:
        - duration: The duration of the animations, measured in seconds. If you specify a negative value or `0`, the changes are made without animating.
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @discardableResult
    public func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void, completion: (() -> Void)? = nil) -> NSAnimationContext {
        animationQueue +=  { nextAnimation in
            Self.run(duration: duration, timingFunction: timingFunction, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes) {
                completion?()
                nextAnimation()
            }
        }
        return self
    }
    
    /**
     Runs the animation group using the specified spring animation.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @discardableResult
    public class func animate(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimationContext {
        .run { $0.animate(withSpring: spring, changes: changes, completion: completion) }
    }
    
    /**
     Runs the animation group after the previous using the specfied spring animation.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @discardableResult
    public func animate(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimationContext {
        Self.swizzleAll()
        animationQueue += { nextAnimation in
            Self.run(spring: spring, allowsImplicitAnimation: allowsImplicitAnimation, changes: changes) {
                if NSAnimationContext.current.springAnimation == spring {
                    NSAnimationContext.current.springAnimation = nil
                }
                completion?()
                nextAnimation()
            }
        }
        return self
    }
    
    /**
     Runs the animation group using the specified `SwiftUI` animation.
     
     - Parameters:
        - animation: The `SwiftUI` animation
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @available(macOS 15.0, *)
    @discardableResult
    public class func animate(_ animation: Animation, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimationContext {
        .run { $0.animate(animation, changes: changes, completion: completion) }
    }
    
    /**
     Runs the animation group after the previous using the specfied `SwiftUI` animation.

     - Parameters:
        - animation: The `SwiftUI` animation
        - changes: The closure containing the changes to animate.
        - completion: A closure to execute after the animation completes.
     */
    @discardableResult
    @available(macOS 15.0, *)
    public func animate(_ animation: Animation, changes: @escaping ()->(), completion: (()->())? = nil) -> NSAnimationContext {
        animationQueue += { nextAnimation in
            NSAnimationContext.animate(animation, changes: changes) {
                completion?()
                nextAnimation()
            }
        }
        return self
    }
    
    /// Runs the changes of the specified block non-animated.
    @discardableResult
    public func nonAnimate(_ changes: @escaping () -> Void) -> NSAnimationContext {
        animationQueue += { nextAnimation in
            NSAnimationContext.performWithoutAnimation {
                changes()
                nextAnimation()
            }
        }
        return self
    }
        
    @discardableResult
    func repeating(_ repeatCount: Int) -> NSAnimationContext {
        guard repeatCount > 1, let animation = animationQueue.removeLastSafetly() else { return self }
        animationQueue += Array(repeating: animation, count: repeatCount)
        return self
    }
    
    fileprivate class func run(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup ({ context in
            context.springAnimation = nil
            context.duration = duration
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            changes()
        }, completionHandler: completion)
    }
    
    fileprivate class func run(spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: ()->(), completion: (()->())? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.springAnimation = spring
            context.duration = spring.duration
            context.allowsImplicitAnimation = allowsImplicitAnimation
            changes()
        }, completionHandler: {
            if NSAnimationContext.current.springAnimation == spring {
                NSAnimationContext.current.springAnimation = nil
            }
            completion?()
        })
    }
    
    fileprivate class func run(_ animation: (_ context: NSAnimationContext)->()) ->  NSAnimationContext {
        var context: NSAnimationContext = .current
        NSAnimationContext.beginGrouping()
        context = .current
        context.duration = 0.0
        animation(context)
        context.completionHandler = {
            context.runNextAnimation()
        }
        NSAnimationContext.endGrouping()
        return context
    }
    
    fileprivate func runNextAnimation() {
        guard let animation = animationQueue.removeFirstSafetly() else { return }
        animation { [weak self] in
            self?.runNextAnimation()
        }
    }
    
    fileprivate var animationQueue: [(@escaping () -> Void) -> Void] {
        get { getAssociatedValue("animationQueue") ?? [] }
        set { setAssociatedValue(newValue, key: "animationQueue") }
    }
    
    var springAnimation: CASpringAnimation? {
        get { getAssociatedValue("springAnimation") }
        set { setAssociatedValue(newValue, key: "springAnimation") }
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    fileprivate static func swizzleAll() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        NSView.swizzleAnimationForKey()
        NSWindow.swizzleAnimationForKey()
        NSLayoutConstraint.swizzleAnimationForKey()
        NSPageController.swizzleAnimationForKey()
        NSSplitViewItem.swizzleAnimationForKey()
    }
}

fileprivate extension NSLayoutConstraint {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSLayoutConstraint.self) {
                #selector(NSLayoutConstraint.defaultAnimation(forKey:)) <~> #selector(NSLayoutConstraint.swizzledDefaultAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
}

fileprivate extension NSPageController {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSPageController.self) {
                #selector(NSPageController.defaultAnimation(forKey:)) <~> #selector(NSPageController.swizzledDefaultAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}

fileprivate extension NSSplitViewItem {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSSplitViewItem.self) {
                #selector(NSPageController.defaultAnimation(forKey:)) <~> #selector(NSPageController.swizzledDefaultAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}
#endif
