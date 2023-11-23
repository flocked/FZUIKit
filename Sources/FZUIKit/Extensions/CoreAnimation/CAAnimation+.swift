//
//  CAAnimation+.swift
//
//
//  Created by Florian Zand on 23.11.23.
//

#if canImport(QuartzCore)
import QuartzCore
import FZSwiftUtils

extension CAAnimation {
    /// A handler that gets called when the animation starts.
    public var onStart: (()->())? {
        get { getAssociatedValue(key: "didStart", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "didStart", object: self)
            updateAnimationDelegate()
        }
    }
    
    /// A handler that gets called when the animation stops.
    public var onStop: (()->())? {
        get { getAssociatedValue(key: "didFinish", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "didFinish", object: self)
            updateAnimationDelegate()
        }
    }
    
    internal var animationDelegate: AnimationDelegate? {
        get { getAssociatedValue(key: "animationDelegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "animationDelegate", object: self) }
    }
    
    internal func updateAnimationDelegate() {
        if onStart != nil || onStop != nil {
            if animationDelegate == nil || !(delegate is AnimationDelegate) {
                animationDelegate = AnimationDelegate(self, delegate: self.delegate)
            }
        } else {
            if (delegate is AnimationDelegate) {
                self.delegate = nil
            }
            animationDelegate = nil
        }
    }
    
    internal class AnimationDelegate: NSObject, CAAnimationDelegate {
        weak var animation: CAAnimation?
        var delegate: CAAnimationDelegate? = nil
        init(_ animation: CAAnimation, delegate: CAAnimationDelegate? = nil) {
            self.animation = animation
            super.init()
            self.delegate = delegate
            animation.delegate = self
        }
        
        func animationDidStart(_ anim: CAAnimation) {
            animation?.onStart?()
            delegate?.animationDidStart?(anim)
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            animation?.onStop?()
            delegate?.animationDidStop?(anim, finished: flag)
        }
    }
}

#endif
