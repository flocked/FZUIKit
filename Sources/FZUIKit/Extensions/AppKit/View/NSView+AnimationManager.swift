//
//  NSView+AnimationManager.swift
//
//
//  Created by Florian Zand on 18.10.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

internal extension NSView {
    var animationManager: AnimationManager<NSView> {
        get { getAssociatedValue(key: "AnimationManager", object: self, initialValue: AnimationManager(self)) }
    }
}

internal class AnimationManager<Object: AnyObject>: NSObject, CAAnimationDelegate {
    let object: Object
    init(_ object: Object) {
        self.object = object
    }
    var animationHandlers: [CAAnimation: ()->()] = [:]
    
    func add(_ animation: CAAnimation, handler: @escaping ()->()) {
        animation.delegate = self
        animationHandlers[animation] = handler
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if let anim = anim as? CABasicAnimation {
            Swift.print("animationDidStart", anim, anim.toValue != nil ? type(of: anim.toValue!) : "nil")
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationHandlers[anim]?()
        animationHandlers[anim] = nil
    }
}
#endif
