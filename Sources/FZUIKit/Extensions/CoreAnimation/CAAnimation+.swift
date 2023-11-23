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
    
    internal var delegateProxy: DelegateProxy? {
        get { getAssociatedValue(key: "delegateProxy", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "delegateProxy", object: self) }
    }
    
    internal func updateAnimationDelegate() {
        if onStart != nil || onStop != nil {
            if delegateProxy == nil || !(delegate is DelegateProxy) {
                delegateProxy = DelegateProxy(self, delegate: self.delegate)
            }
        } else {
            if (delegate is DelegateProxy) {
                self.delegate = nil
            }
            delegateProxy = nil
        }
    }
    
    internal class DelegateProxy: NSObject, CAAnimationDelegate {
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
