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
public class NSAnimationGroup: Hashable {
    fileprivate let id = UUID()
    static var isActiveGroup = false
    fileprivate let animations: [NSAnimator]
    fileprivate var animationQueue: [NSAnimator] = []
    fileprivate var currentAnimationIndex = -1
    fileprivate var repeatTimer: Timer?
    fileprivate var repeatIndex = 0
    fileprivate var delayedStart: DispatchWorkItem?
    
    var repeatCount = 0
    var repeatDuration = 0.0
    var delay = 0.0
    
    /// Creates an animation group running the specified animations.
    public init(@NSAnimator.Builder animations: @escaping () -> [NSAnimator]) {
        Self.isActiveGroup = true
        self.animations = animations()
        Self.isActiveGroup = false
        start()
    }
    
    /// A Boolean value indicating whether the animation group is animating.
    public private(set) var isRunning = false
    
    /// The completion handler that is called when the animation group is finished.
    public var completion: (()->())? = nil
    
    /// The total duration of the animation group.
    public var duration: CGFloat {
        animations.map({ $0.duration }).sum()
    }
    
    /// The number of animations in the animation group.
    public var animationsCount: Int {
        animations.count
    }
    
    /// Sets the completion handler that is called when the animation group is finished.
    @discardableResult
    public func completion(_ completion: (()->())?) -> Self {
        self.completion = completion
        return self
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
    
    /// Restarts the animation group from the start.
    public func restart() {
        delayedStart = nil
        if isRunning {
            let _completion = completion
            completion = { [weak self] in
                guard let self = self else { return }
                self.completion = _completion
                self.start()
            }
            stop()
        } else {
            start()
        }
    }
    
    /// Stops the animation group.
    public func stop() {
        guard isRunning else { return }
        isRunning = false
        animationQueue = []
        animations.forEach({ $0.stop() })
        reset()
    }
    
    fileprivate func start(shouldReset: Bool = true) {
        guard !animations.isEmpty else { return }
        AnimatablePropertyContainer.swizzleAll()
        if shouldReset {
            reset()
        }
        isRunning = true
        if !isRunning, delay > 0 {
            delayedStart = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self._start()
            }.perform(after: delay)
        } else {
            _start()
        }
    }
    
    func _start() {
        animationQueue = animations
        var context: NSAnimationContext = .current
        NSAnimationContext.beginGrouping()
        context = .current
      //  context.duration = 0.0
        if isSynchronous {
            let animation = animationQueue.removeFirst()
            animation.animate {
                self.runNextAnimation()
            }
        } else {
            animationQueue.forEach({ animation in
                animation.animate {
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
        delayedStart = nil
    }
    
    fileprivate func runNextAnimation() {
        guard !animationQueue.isEmpty else {
            currentAnimationIndex = -1
            if repeatCount > repeatIndex {
                repeatIndex += 1
                start(shouldReset: false)
            } else if repeatDuration > 0 {
                if repeatTimer == nil {
                    repeatTimer = .scheduledTimer(withTimeInterval: repeatDuration, repeats: false) { [weak self] timer in
                        guard let self = self else { return }
                        self.stop()
                        completion?()
                    }
                }
                start(shouldReset: false)
            } else {
                completion?()
                AnimationManager.runningAnimationGroups.remove(self)
                isRunning = false
            }
            return
        }
        let animation = animationQueue.removeFirst()
        currentAnimationIndex += 1
        guard isSynchronous else { return }
        animation.animate {
            self.runNextAnimation()
        }
    }
    
    public static func == (lhs: NSAnimationGroup, rhs: NSAnimationGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#endif
