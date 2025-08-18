//
//  NSAnimationGroup.swift
//  FZUIKit
//
//  Created by Florian Zand on 23.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

/**
 A group of animations that are run in a serial order.
 
 Example usage:
 
 ```swift
 NSAnimationGroup {
    NSAnimator(duration: 4.0) {
        view.backgroundColor = .red
        view.frame.size.width = 200
    }.repeats(2)
    NSAnimator(duration: 2.0) {
        view.backgroundColor = .blue
        view.frame.size.width = 100
    }.delay(1.0)
 }
 ```
 */
public class NSAnimationGroup: NSAnimator {
    fileprivate let id = UUID()
    static var isActiveGroup = false
    fileprivate let animations: [NSAnimator]
    fileprivate var animationQueue: [NSAnimator] = []
    fileprivate var currentAnimationIndex = -1
    fileprivate var repeatTimer: Timer?
    fileprivate var repeatIndex = 0
    fileprivate var delayedStart: DispatchWorkItem?
    fileprivate var nextAnimation: (()->())?
    
    /// Creates an animation group running the specified animations.
    public init(@NSAnimator.Builder animations: @escaping () -> [NSAnimator]) {
        Self.isActiveGroup = true
        self.animations = animations()
        Self.isActiveGroup = false
        super.init()
        self.animate = { nextAnimation in
            self.nextAnimation = nextAnimation
            self.start()
        }
        guard !Self.isActiveGroup else { return }
        start()
    }
    
    /// The total duration of the animation group.
    public override var duration: CGFloat {
        animations.map({ $0.duration }).sum()
    }
    
    /// The number of ``NSAnimator`` animations in the animation group.
    public var animationsCount: Int {
        animations.count
    }
    
    /**
     A Boolean value indicating whether the animations are run synchronously.
     
     If set to `false`, the animations are animated at the same time.
     
     The default value is `true` and animates one animation at the time.
     */
    public var isSynchronous: Bool = true
    
    /**
     Sets the Boolean value indicating whether the animations are run synchronously.
     
     If set to `false`, the animations are animated at the same time.
     
     The default value is `true` and animates one animation at the time.
     */
    @discardableResult
    public func isSynchronous(_ isSynchronous: Bool) -> Self {
        self.isSynchronous = isSynchronous
        return self
    }
    
    /**
     Starts the animation group.
     
     If the animation group is currently animating or the group is stopped, the animation group is restarted.
     */
    public override func start() {
        start(shouldRestart: true)
    }
    
    /// Stops the animation group.
    public override func stop() {
        guard state == .running else { return }
        state = .stopped
        animationQueue = []
        animations.forEach({ $0.stop() })
        reset()
    }
    
    @discardableResult
    override func start(shouldRestart: Bool, next: (() -> ())? = nil) -> Self {
        guard !animations.isEmpty else { return self }
        NSAnimationContext.swizzleAll()
        if shouldRestart {
            reset()
        }
        if state != .running, delay > 0 {
            delayedStart = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.startGroup()
            }.perform(after: delay)
        } else {
            startGroup()
        }
        return self
    }
    
    func startGroup() {
        state = .running
        animationQueue = animations
        NSAnimationContext.beginGrouping()
        if isSynchronous {
            let animation = animationQueue.removeFirst()
            animation.start(shouldRestart: true) {
                self.runNextAnimation()
            }
        } else {
            animationQueue.forEach({ animation in
                animation.start(shouldRestart: true) {
                    self.runNextAnimation()
                }
            })
        }
        NSAnimationContext.endGrouping()
    }
    
    fileprivate func reset() {
        currentAnimationIndex = -1
        repeatTimer = nil
        repeatIndex = 0
        delayedStart?.cancel()
        delayedStart = nil
    }
    
    fileprivate func runNextAnimation() {
        guard !animationQueue.isEmpty else {
            currentAnimationIndex = -1
            if repeatCount > repeatIndex {
                repeatIndex += 1
                start(shouldRestart: false)
            } else if repeatDuration > 0 {
                if repeatTimer == nil {
                    repeatTimer = .scheduledTimer(withTimeInterval: repeatDuration, repeats: false) { [weak self] timer in
                        guard let self = self else { return }
                        self.stop()
                        completion?()
                    }
                }
                start(shouldRestart: false)
            } else {
                completion?()
                AnimationManager.runningAnimationGroups.remove(self)
                state = .stopped
                nextAnimation?()
                nextAnimation = nil
            }
            return
        }
        let animation = animationQueue.removeFirst()
        currentAnimationIndex += 1
        guard isSynchronous else { return }
        animation.start(shouldRestart: true) {
            self.runNextAnimation()
        }
    }
    
    private override init(nonAnimated changes: @escaping () -> ()) {
        animations = []
        super.init()
    }
    
    #if compiler(>=6.0)
    private override init(animation: Animation, changes: @escaping () -> ()) {
        animations = []
        super.init()
    }
    #endif
    
    private override init(spring: CASpringAnimation, allowsImplicitAnimation: Bool = false, changes: @escaping () -> ()) {
        animations = []
        super.init()
    }
    
    private override init(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, allowsImplicitAnimation: Bool = false, changes: @escaping () -> Void) {
        animations = []
        super.init()
    }
}

class AnimationManager {
    static var runningAnimationGroups: Set<NSAnimationGroup> = []
}

#endif
