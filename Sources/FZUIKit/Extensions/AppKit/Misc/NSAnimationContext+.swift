//
//  NSAnimationContext+.swift
//
//
//  Created by Florian Zand on 11.10.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSAnimationContext {
    /// Runs the changes of the specified block non-animated.
    class func runNonAnimated(_ changes: () -> Void) {
        runAnimationGroup { context in
            context.springAnimation = nil
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
            context.springAnimation = nil
            context.duration = duration
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            changes()
        }, completionHandler: completion)
    }
    
    /**
     Animate changes to one or more views using the specified spring animation and completion handler.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: The Boolean value that indicates if animations are enabled or not for animations that occur as a result of another property change.
        - animations: The handler containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
        - completion: The handler to be executed when the animation sequence ends.
     */
    class func run(withSpring spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, animations: ()->(), completion: (()->())? = nil) {
        NSView.swizzleAnimationForKey()
        NSWindow.swizzleAnimationForKey()
        NSLayoutConstraint.swizzleAnimationForKey()
        NSPageController.swizzleAnimationForKey()
        NSAnimationContext.runAnimationGroup({ context in
            context.springAnimation = spring
            context.duration = spring.duration
            // context.timingFunction = timingFunction
            context.allowsImplicitAnimation = allowsImplicitAnimation
            animations()
        }, completionHandler: {
            if NSAnimationContext.current.springAnimation == spring {
                NSAnimationContext.current.springAnimation = nil
            }
            completion?()
        })
    }
    
    /**
     A Boolean value that indicates whether the the current animation context has an active grouping.
     
     The property returns `true`, if it's called inside a `runAnimationGroup(_:)` closure or between `beginGrouping()` and `endGrouping()`.
     */
    class var hasActiveGrouping: Bool {
        value(forKey: Keys.hasActiveGrouping.unmangled) as? Bool ?? false
    }
    
    internal var springAnimation: CASpringAnimation? {
        get { getAssociatedValue("springAnimation") }
        set { setAssociatedValue(newValue, key: "springAnimation") }
    }
    
    private struct Keys {
       static let hasActiveGrouping = "_hasActiveGrouping".mangled
    }
}

extension NSLayoutConstraint {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if let animation = swizzledDefaultAnimation(forKey: key) {
            if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
                return springAnimation
            }
            return animation
        }
        return nil
    }
    
    /// A Boolean value that indicates whether windows are swizzled to support additional properties for animating.
    static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue("didSwizzleAnimationForKey", initialValue: false) }
        set {
            setAssociatedValue(newValue, key: "didSwizzleAnimationForKey")
        }
    }
    
    /// Swizzles windows to support additional properties for animating.
    static func swizzleAnimationForKey() {
        if didSwizzleAnimationForKey == false {
            didSwizzleAnimationForKey = true
            do {
                try Swizzle(NSLayoutConstraint.self) {
                    #selector(NSLayoutConstraint.defaultAnimation(forKey:)) <~> #selector(NSLayoutConstraint.swizzledDefaultAnimation(forKey:))
                }
            } catch {
                Swift.debugPrint(error)
            }
        }
    }
}

extension NSPageController {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if let animation = swizzledDefaultAnimation(forKey: key) {
            if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
                return springAnimation
            }
            return animation
        }
        return nil
    }
    
    /// A Boolean value that indicates whether windows are swizzled to support additional properties for animating.
    static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue("didSwizzleAnimationForKey", initialValue: false) }
        set {
            setAssociatedValue(newValue, key: "didSwizzleAnimationForKey")
        }
    }
    
    /// Swizzles windows to support additional properties for animating.
    static func swizzleAnimationForKey() {
        if didSwizzleAnimationForKey == false {
            didSwizzleAnimationForKey = true
            do {
                try Swizzle(NSPageController.self) {
                    #selector(NSPageController.defaultAnimation(forKey:)) <~> #selector(NSPageController.swizzledDefaultAnimation(forKey:))
                }
            } catch {
                Swift.debugPrint(error)
            }
        }
    }
}

/*
public class CustomSpringAnimation: CASpringAnimation {
    public override var toValue: Any? {
        get { super.toValue }
        set {
            super.toValue = newValue
            Swift.print("toValue", newValue ?? "nil")
        }
    }
    
    public override var byValue: Any? {
        get { super.byValue }
        set {
            super.byValue = newValue
            Swift.print("byValue", newValue ?? "nil")
        }
    }
    
    public override var fromValue: Any? {
        get { super.fromValue }
        set {
            super.fromValue = newValue
            Swift.print("fromValue", newValue ?? "nil")
        }
    }
    
    public override var keyPath: String? {
        get { super.keyPath }
        set {
            super.keyPath = newValue
            Swift.print("keyPath", newValue ?? "nil")
        }
    }
}
 */
#endif
