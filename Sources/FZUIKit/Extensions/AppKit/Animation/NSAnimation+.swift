//
//  NSAnimation+.swift
//  
//
//  Created by Florian Zand on 21.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSAnimation {
    /// The handlers for the animation.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if newValue.needsDelegate {
                if handlers.valueForProgress == nil {
                    animationDelegate = AnimationDelegate(for: self)
                } else {
                    animationDelegate = AnimationValueDelegate(for: self)
                }
            } else if !newValue.needsDelegate {
                animationDelegate = nil
            }
        }
    }
    
    fileprivate var animationDelegate: AnimationDelegate? {
        get { getAssociatedValue("animationDelegate") }
        set { setAssociatedValue(newValue, key: "animationDelegate") }
    }
    
    /// The handlers for an animation.
    public struct Handlers {
        /// The handler that is called when animation is stopped before it completes its run.
        public var didStop: (()->())?
        /// The handler that is called when animation completes its run.
        public var didEnd: (()->())?
        /// The handler that determinates if the animation should start.
        public var shouldStart: (()->(Bool))?
        /// The handler for a custom curve value for the current progress value.
        public var valueForProgress: ((Progress)->(Float))?
        /// The handler that is called when animation reaches a specific progress mark.
        public var didReachProgressMark: ((Progress)->())?

        var needsDelegate: Bool {
            didStop != nil || didEnd != nil || shouldStart != nil || valueForProgress != nil || didReachProgressMark != nil
        }
    }

    fileprivate class AnimationDelegate: NSObject, NSAnimationDelegate {
        weak var animation: NSAnimation?
        var delegate: NSAnimationDelegate?
        var observation: KeyValueObservation?
        
        nonisolated func animationDidEnd(_ animation: NSAnimation) {
            animation.handlers.didEnd?()
        }
        
        nonisolated func animationDidStop(_ animation: NSAnimation) {
            animation.handlers.didStop?()
        }
        
        nonisolated func animationShouldStart(_ animation: NSAnimation) -> Bool {
            animation.handlers.shouldStart?() ?? true
        }
   
        
        nonisolated func animation(_ animation: NSAnimation, didReachProgressMark progress: NSAnimation.Progress) {
            animation.handlers.didReachProgressMark?(progress)
        }

        init(for animation: NSAnimation) {
            self.animation = animation
            delegate = animation.delegate
            super.init()
            animation.delegate = self
            observation = animation.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, self.animation?.delegate !== self else { return }
                self.delegate = new
                self.animation?.delegate = self
            }
        }
        
        deinit {
            animation?.delegate = delegate
        }
    }
    
    fileprivate class AnimationValueDelegate: AnimationDelegate {
        nonisolated func animation(_ animation: NSAnimation, valueForProgress progress: NSAnimation.Progress) -> Float {
            animation.handlers.valueForProgress?(progress) ?? progress
        }
    }
}
#endif
