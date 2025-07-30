//
//  NSAnimator.swift
//  
//
//  Created by Florian Zand on 23.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

/// An animation that animates changes provided in a handler.
public class NSAnimator: NSObject {
    fileprivate var animatingKeys: [Weak<NSObject & NSAnimatablePropertyContainer>: Set<String>] = [:]
    var animate: ((_ complection: (()->())?)->()) = { _ in }
    var _duration = 0.0
    var animationTargetValues: [String: AnimationTargetValue] = [:]
    var spring: CASpringAnimation?
    
    /// Constants indicating the current state of the animation.
    public enum State {
        /// The animations have not yet started executing. This is the initial state of the animator.
        case inactive
        /// The animator is active and animations are running. An animator moves to this state after the first call of ``NSAnimator/start()``. It stays in the active state until the animations finish naturally or until you call the ``NSAnimator/stop()`` method.
        case running
        /// The animation is stopped. Putting an animation into this state ends the animation and leaves any animatable properties at their current values, instead of updating them to their intended final values.
        case stopped
    }
    
    /// The current state of the animation.
    public internal(set) var state: State = .inactive
    
    /// The total duration of the animation.
    public var duration: CGFloat {
        var totalDuration = _duration + repeatDuration + delay
        totalDuration += CGFloat(repeatCount) * _duration
        totalDuration += autoreverses ? _duration : 0.0
        return totalDuration
    }
    
    /// The completion handler that is called when the animation is finished.
    public var completion: (()->())? = nil
    
    /// Sets the completion handler that is called when the animation is finished.
    @discardableResult
    public func completion(_ completion: (()->())?) -> Self {
        self.completion = completion
        return self
    }
    
    /// Repeats the animation by the specified repeat count.
    public var repeatCount = 0 {
        didSet {
            guard oldValue != repeatCount else { return }
            repeatCount = repeatCount.clamped(min: 0)
            repeatDuration = 0.0
        }
    }
    
    /// Repeats the animation by the specified repeat count.
    @discardableResult
    public func repeatCount(_ repeatCount: Int) -> Self {
        self.repeatCount = repeatCount.clamped(min: 0)
        return self
    }
    
    /// Repeats the animation until the specified duration.
    public var repeatDuration = 0.0 {
        didSet {
            guard oldValue != repeatDuration else { return }
            repeatDuration = repeatDuration.clamped(min: 0)
            repeatCount = 0
        }
    }
    
    /// Repeats the animation until the specified duration.
    @discardableResult
    public func repeatDuration(_ repeatDuration: CGFloat) -> Self {
        self.repeatDuration = repeatDuration.clamped(min: 0)
        return self
    }
    
    /// Delays the animation start by the specified amount (in seconds).
    public var delay = 0.0 {
        didSet { delay = delay.clamped(min: 0) }
    }
    
    /// Delays the animation start by the specified amount (in seconds).
    @discardableResult
    public func delay(_ delay: CGFloat) -> Self {
        self.delay = delay.clamped(min: 0)
        return self
    }
    
    /// A Boolean value indicating whether the animation should autoreverse.
    public var autoreverses = false
    
    /// Sets the Boolean value indicating whether the animation should autoreverse.
    @discardableResult
    public func autoreverses(_ autoreverses: Bool) -> Self {
        self.autoreverses = autoreverses
        return self
    }
    
    /**
     Starts the animation.
     
     If the animation is currently animating or the animation is stopped, the animation is restarted.
     */
    public func start() {
        start(shouldRestart: true)
    }
    
    /// Stops the animation.
    public func stop() {
        guard state == .running else { return }
        animatingKeys.forEach({
            guard let object = $0.key.object else { return }
            $0.value.forEach({ object.stopAnimation(for: $0) })
        })
        animatingKeys = [:]
        animationTargetValues = [:]
        state = .inactive
    }
    
    @discardableResult
    func start(shouldRestart: Bool, next: (()->())? = nil) -> Self {
        guard !NSAnimationGroup.isActiveGroup else { return self }
        if state == .running {
            guard shouldRestart else { return self }
            let _completion = completion
            completion = { [weak self] in
                guard let self = self else { return }
                self.completion = _completion
                self.animationTargetValues = [:]
                self.animate(next)
            }
            stop()
        } else {
            self.animationTargetValues = [:]
            animate(next)
        }
        return self
    }
    
    @discardableResult
    func _start() -> Self {
        start(shouldRestart: true)
    }
    
    /**
     Creates an animation with the specified duration.
     
     - Parameters:
        - duration: The duration of the animation, measured in seconds. If you specify a negative value or `0`, the changes are made without animating.
        - timingFunction: A timing function for the animations.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
     */
    public init(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void) {
        AnimatablePropertyContainer.swizzleAll()
        super.init()
        _duration = duration
        animate = { nextAnimation in
            self.state = .running
            NSAnimationContext.runAnimationGroup({ context in
                context.animation = self
                context.duration = duration
                context.timingFunction = timingFunction
                context.allowsImplicitAnimation = allowsImplicitAnimation
                changes()
            }) { self.finish(nextAnimation) }
        }
    }
    
    /**
     Creates an animation using the specfied spring animation.
     
     - Parameters:
        - spring: The spring animation to use.
        - allowsImplicitAnimation: A Boolean value indicating whether animations are enabled for animations that occur as a result of another property change.
        - changes: The closure containing the changes to animate.
     */
    public init(spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping ()->()) {
        AnimatablePropertyContainer.swizzleAll()
        super.init()
        self.spring = spring
        _duration = spring.duration
        animate = { nextAnimation in
            self.state = .running
            NSAnimationContext.runAnimationGroup({ context in
                context.animation = self
                context.duration = spring.duration
                context.allowsImplicitAnimation = allowsImplicitAnimation
                changes()
            }) { self.finish(nextAnimation) }
        }
    }
    
    #if compiler(>=6.0)
    /**
     Creates an animation using the specfied `SwiftUI` animation.

     - Parameters:
        - animation: The `SwiftUI` animation
        - changes: The closure containing the changes to animate.
     */
    @available(macOS 15.0, *)
    public init(animation: Animation, changes: @escaping ()->()) {
        AnimatablePropertyContainer.swizzleAll()
        super.init()
        animate = { nextAnimation in
            self.state = .running
            NSAnimationContext.current.animation = self
            NSAnimationContext.animate(animation, changes: changes) {
                self.finish(nextAnimation)
            }
        }
    }
    #endif
    
    /// Creates an animator that runs the specified changes without animation.
    public init(nonAnimated changes: @escaping ()->()) {
        AnimatablePropertyContainer.swizzleAll()
        super.init()
        animate = { nextAnimation in
            self.state = .running
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.0
                context.allowsImplicitAnimation = true
                changes()
            } completionHandler: { self.finish(nextAnimation) }
        }
    }
    
    func finish(_ complete: (()->())?) {
        if NSAnimationContext.current.animation === self {
            NSAnimationContext.current.animation = nil
        }
        self.state = .stopped
        self.completion?()
        complete?()
    }
    
    func addAnimationKey(_ key: String, for object: NSObject & NSAnimatablePropertyContainer) {
        if let animationObject = animatingKeys.keys.first(where: {$0.object === object }) {
            animatingKeys[animationObject, default: []].insert(key)
        } else {
            animatingKeys[Weak(object), default: []].insert(key)
        }
    }
    
    func removeAnimationKey(_ key: String, for object: NSObject & NSAnimatablePropertyContainer) {
        guard let animationObject = animatingKeys.keys.first(where: {$0.object === object }) else { return }
        var keys = animatingKeys[animationObject, default: []]
        keys.remove(key)
        if keys.isEmpty {
            animatingKeys[animationObject] = nil
        } else {
            animatingKeys[animationObject] = keys
        }
    }
    
    override init() {
        super.init()
    }
}

extension NSAnimationContext {
    var animation: NSAnimator? {
        get { getAssociatedValue("contextAnimation") }
        set { setAssociatedValue(newValue, key: "contextAnimation") }
    }
}

extension NSAnimator {
    /// A builder for animators.
    @resultBuilder
    public enum Builder {
        public typealias Component = [NSAnimator]

        public static func buildExpression(_ expression: NSAnimator?) -> Component {
            expression.map({ [$0] }) ?? []
        }

        public static func buildExpression(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildBlock(_ components: Component...) -> Component {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildEither(first component: Component) -> Component {
            component
        }

        public static func buildEither(second component: Component) -> Component {
            component
        }

        public static func buildArray(_ components: [Component]) -> Component {
            components.flatMap { $0 }
        }

        public static func buildLimitedAvailability(_ component: Component) -> Component {
            component
        }

        public static func buildFinalResult(_ component: Component) -> [NSAnimator] {
            component
        }
    }
    
    struct AnimationTargetValue {
        let from: Any?
        let to: Any?
        let byValue: Any?
        var reversed: AnimationTargetValue {
            .init(from: to, to: from, byValue: byValue)
        }
    }
}

#endif
