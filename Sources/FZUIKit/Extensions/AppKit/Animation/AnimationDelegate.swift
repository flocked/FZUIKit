//
//  AnimationDelegate.swift
//
//
//  Created by Florian Zand on 01.08.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

class AnimationDelegate: NSObject, CAAnimationDelegate {
    weak var object: AnimatablePropertyProvider?
    var animationKeys: Set<String> = []
    
    init(for object: AnimatablePropertyProvider) {
        self.object = object
    }
    
    func animationDidStart(_ animation: CAAnimation) {
        guard let animation = animation as? CAPropertyAnimation, let key = animation.keyPath else { return }
        animationKeys.insert(key)
        guard let object = object, let animator = NSAnimationContext.current.animator else { return }
        animator.addAnimationKey(key, for: object)
        animation.animator = animator
        animation.setValue(safely: Float(animator.repeatCount), forKey: "repeatCount")
        animation.setValue(safely: animator.repeatDuration, forKey: "repeatDuration")
        animation.setValue(safely: animator.autoreverses, forKey: "autoreverses")
        animation.setValue(safely: CACurrentMediaTime() + animator.delay, forKey: "beginTime")
        guard let animation = animation as? CABasicAnimation else { return }
        animator.animationTargetValues[key] = .init(from: animation.fromValue, to: object.value(forKeySafely: key))
    }
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        guard let key = (animation as? CAPropertyAnimation)?.keyPath else { return }
        if let animator = animation.animator, animation.autoreverses, let object = object, let value = animator.animationTargetValues[key]?.from {
            if !animator.isStopped {
            object.setValue(value, forKeyPath: key)
                if let layer = object as? CALayer {
                    if key == "bounds", let value = value as? CGRect {
                        layer.parentView?.frame.size = value.size
                    } else if key == "position", let value = value as? CGPoint {
                        layer.parentView?.frame.origin = value
                    } else if key == "opacity", let value = value as? CGFloat {
                        layer.parentView?.alphaValue = value
                    }
                }
            }
            if let layer = object as? CALayer, layer.animation(forKey: key) == animation {
                layer.removeAnimation(forKey: key)
            }
        }
        animationKeys.remove(key)
        guard let object = object else { return }
        animation.animator?.removeAnimationKey(key, for: object)
        animation.animator = nil
        guard animationKeys.isEmpty else { return }
    }
}

fileprivate extension CAAnimation {
    var animator: NSAnimator? {
        get { getAssociatedValue("animator") }
        set { setAssociatedValue(weak: newValue, key: "animator") }
    }
}

#endif
