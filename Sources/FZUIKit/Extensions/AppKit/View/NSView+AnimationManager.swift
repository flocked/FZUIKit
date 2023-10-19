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
    var animations: [String: CAAnimation] = [:]

    func add(_ animation: CAAnimation, handler: @escaping ()->()) {
        animation.delegate = self
        animationHandlers[animation] = handler
    }
    
    func add(_ animation: CAAnimation, key: String) {
        animation.delegate = self
        animations[key] = animation
        Swift.print("add animation", key, animations.count)
    }
    
    func targetValue<Value>(for keyPath: KeyPath<Object, Value?>) -> Value? {
        let keyPathString = keyPath.stringValue
        Swift.print("targetValue 0", keyPathString, self.animations[keyPathString] ?? "nil")
        if let animation = self.animations[keyPathString] as? CABasicAnimation {
            Swift.print("targetValue 1", animation.toValue as? Optional<Value> ?? "nil")
            return animation.toValue as? Value
        }
        return nil
    }
    
    func targetValue<Value>(for keyPath: KeyPath<Object, Value>) -> Value? {
        let keyPathString = keyPath.stringValue
        Swift.print("targetValue 0 d", keyPathString, self.animations[keyPathString] ?? "nil")
        if let animation = self.animations[keyPathString] as? CABasicAnimation {
            Swift.print("targetValue 1 d", animation.toValue as? Value ?? "nil")
            return animation.toValue as? Value
        }
        return nil
    }
        
    func animationDidStart(_ anim: CAAnimation) {
        if let anim = anim as? CABasicAnimation {
            Swift.print("animationDidStart", anim.keyPath ?? "nil", anim.toValue != nil ? type(of: anim.toValue!) : "nil", anim.toValue ?? "nil")
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationHandlers[anim]?()
        animationHandlers[anim] = nil
        if let anim = anim as? CABasicAnimation {
            Swift.print("animationDidStop", anim.keyPath ?? "nil")
        }
        if let val = animations.first(where: {$0.value == anim}) {
            animations[val.key] = nil
        }
    }
}
#endif
