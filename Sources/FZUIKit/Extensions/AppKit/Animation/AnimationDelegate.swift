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
    static var animatingObjects: SynchronizedDictionary<ObjectIdentifier, WeakAnimatablePropertyProvider> = [:]
    weak var object: AnimatablePropertyProvider?
    var animationKeys: Set<String> = []
    var animators: [String: Weak<NSAnimator>] = [:]
    
    init(for object: AnimatablePropertyProvider) {
        self.object = object
    }
    
    func animationDidStart(_ animation: CAAnimation) {
        guard let animation = animation as? CAPropertyAnimation, let key = animation.keyPath else { return }
        animationKeys.insert(key)
        guard let object = object else { return }
        if Self.animatingObjects[ObjectIdentifier(object)] == nil {
            Self.animatingObjects[object.objectID] = WeakAnimatablePropertyProvider(object)
        }
        guard let animator = NSAnimationContext.current.animator else { return }
        animators[key] = Weak(animator)
        animator.addAnimationKey(key, for: object)
        animation.setValue(safely: Float(animator.repeatCount), forKey: "repeatCount")
        animation.setValue(safely: animator.repeatDuration, forKey: "repeatDuration")
        animation.setValue(safely: animator.autoreverses, forKey: "autoreverses")
        animation.setValue(safely: CACurrentMediaTime() + animator.delay, forKey: "beginTime")
        guard let animation = animation as? CABasicAnimation else { return }
        animator.animationTargetValues[key] = .init(from: animation.fromValue, to: object.value(forKeySafely: key))
        Swift.print("animationStart", key, animation.fromValue ?? "nil", animation.toValue ?? "nil", object.value(forKeySafely: key) ?? "nil")
    }
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        guard let key = (animation as? CAPropertyAnimation)?.keyPath else { return }
        if animators[key]?.object?.autoreverses == true, let animation = animation as? CABasicAnimation, let object = object {
            object.setValue(safely: animation.fromValue, forKey: key)
            guard let layer = (object as? NSView)?.layer, layer.animation(forKey: key) != nil else { return }
            layer.setValue(safely: animation.fromValue, forKeyPath: key)
        }
        animationKeys.remove(key)
        guard let object = object else { return }
        animators[key]?.object?.removeAnimationKey(key, for: object)
        animators[key] = nil
        guard animationKeys.isEmpty else { return }
        Self.animatingObjects[object.objectID] = nil
    }
}

#endif
