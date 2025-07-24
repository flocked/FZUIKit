//
//  NSAnimatablePropertyContainer+.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSAnimatablePropertyContainer {
    /**
     Returns either the animation proxy object for the receiver or the receiver itself.

     - Parameter animated: A Boolean value that indicates whether to return the animator proxy object or the receiver.
     */
    public func animator(_ animate: Bool) -> Self {
        animate ? animator() : self
    }

    /// Returns either the animation proxy object for the receiver or the receiver itself, depending if called within an active `NSAnimationContext` group with a positive duration.
    public func animatorIfNeeded() -> Self {
        NSAnimationContext.hasActiveGrouping && NSAnimationContext.current.duration > 0.0  ? animator() : self
    }
}

extension NSAnimatablePropertyContainer where Self: NSObject {
    /**
     Stops all animations of properties animated using [animator()](https://developer.apple.com/documentation/appkit/nsanimatablepropertycontainer/animator()).
     */
    func stopAllAnimations() {
        let keys = animationDelegate.animationKeys
        NSAnimationContext.performWithoutAnimation {
            for key in keys {
                self.setValue(self.value(forKey: key), forKey: key)
            }
        }
        guard let layer = (self as? NSView)?.layer, var animationKeys = layer.animationKeys(), let presentation = layer.presentation() else { return }
        animationKeys = animationKeys.filter({ keys.contains($0) })
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for key in animationKeys {
            if let value = presentation.value(forKeyPath: key) {
                layer.setValue(value, forKeyPath: key)
            }
        }
        CATransaction.commit()
        animationKeys.forEach({ layer.removeAnimation(forKey: $0) })
    }
    
    /// Stops the animation of the specified property.
    func stopAnimation(for keyPath: PartialKeyPath<Self>) {
        guard let key = keyPath.kvcStringValue else { return }
        stopAnimation(for: key)
    }
    
    /// Stops the animation of the specified property.
    func stopAnimation(for key: String) {
        guard animationDelegate.animationKeys.contains(key) else { return }
        animationDelegate.animationKeys.remove(key)
        NSAnimationContext.performWithoutAnimation {
            self.setValue(self.value(forKey: key), forKey: key)
        }
        guard let layer = (self as? NSView)?.layer, layer.animation(forKey: key) != nil, let presentation = layer.presentation() else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let value = presentation.value(forKeyPath: key) {
            layer.setValue(value, forKeyPath: key)
        }
        CATransaction.commit()
        layer.removeAnimation(forKey: key)
    }
    
    fileprivate func updateValue(_ value: Any, for key: String) {
        guard animationDelegate.animationKeys.contains(key) else { return }
        self.setValue(safely: value, forKey: key)
        guard let layer = (self as? NSView)?.layer, layer.animation(forKey: key) != nil else { return }
        layer.setValue(safely: value, forKeyPath: key)
    }
    
    /// An array of keys of the object's properties that are currently animated.
    var animationKeys: [String] {
        animationDelegate.animationKeys.sorted()
    }
    
    var animationDelegate: AnimationDelegate {
        getAssociatedValue("propertyAnimationDelegate", initialValue: AnimationDelegate(for: self))
    }
}

extension NSAnimationContext {
    /**
     Stops all animations of properties animated using [animator()](https://developer.apple.com/documentation/appkit/nsanimatablepropertycontainer/animator()).
     */
    class func stopAllAnimations() {
        AnimationDelegate.animatingObjects.values.forEach({ $0.object?.stopAllAnimations() })
    }
}

class AnimationDelegate: NSObject, CAAnimationDelegate {
    typealias Object = NSAnimatablePropertyContainer & NSObject
    static var animatingObjects: SynchronizedDictionary<ObjectIdentifier, Weak<Object>> = [:]
    weak var object: Object?
    var animationKeys: Set<String> = []
    var animators: [String: Weak<NSAnimator>] = [:]
    
    init(for object: Object) {
        self.object = object
    }
    
    func animationDidStart(_ animation: CAAnimation) {
        guard let animation = animation as? CAPropertyAnimation, let key = animation.keyPath else { return }
        if let animation = animation as? CABasicAnimation {
        }
        animationKeys.insert(key)
        guard let object = object else { return }
        if Self.animatingObjects[ObjectIdentifier(object)] == nil {
            Self.animatingObjects[object.objectId] = Weak(object)
        }
        guard let animator = NSAnimationContext.current.animation else { return }
        animators[key] = Weak(animator)
        Swift.print(animation)
        animator.addAnimationKey(key, for: object)
        let beginTime = CACurrentMediaTime() + animator.delay
        animation.setValue(safely: Float(animator.repeatCount), forKey: "repeatCount")
        animation.setValue(safely: animator.repeatDuration, forKey: "repeatDuration")
        animation.setValue(safely: animator.autoreverses, forKey: "autoreverses")
        animation.setValue(safely: CACurrentMediaTime() + animator.delay, forKey: "beginTime")
        

        if Int(animation.repeatCount) != animator.repeatCount || animation.repeatDuration != animator.repeatDuration || animation.autoreverses != animator.autoreverses || animation.beginTime != beginTime {
            if let animation = animation as? CABasicAnimation, let layer = (object as? NSView)?.layer, layer.animation(forKey: key) != nil {
                Swift.print(key, animation.toValue ?? "nil", animation.fromValue ?? "nil", animation.duration)
                let newAnimation = animation.copy() as! CABasicAnimation
                newAnimation.repeatCount = Float(animator.repeatCount)
                newAnimation.repeatDuration = animator.repeatDuration
                newAnimation.autoreverses = animator.autoreverses
                newAnimation.beginTime = CACurrentMediaTime() + animator.delay
                newAnimation.delegate  = animation.delegate
                Swift.print("GGGGGGGG")
             //  layer.add(newAnimation, forKey: key)
            }
        }
        
       // animation.repeatCount = Float(animator.repeatCount)
       // animation.repeatDuration = animator.repeatDuration
      //  animation.autoreverses = animator.autoreverses
       // animation.beginTime = CACurrentMediaTime() + animator.delay
        guard let animation = animation as? CABasicAnimation else { return }
        animator.animationTargets[key] = .init(from: animation.fromValue, to: animation.toValue, byValue: animation.byValue)
    }
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        guard let key = (animation as? CAPropertyAnimation)?.keyPath else { return }
        if animators[key]?.object?.autoreverses == true, let animation = animation as? CABasicAnimation {
            object?.updateValue(animation.fromValue, for: key)
        }
        animationKeys.remove(key)
        guard let object = object else { return }
        animators[key]?.object?.removeAnimationKey(key, for: object)
        animators[key] = nil
        guard animationKeys.isEmpty else { return }
        Self.animatingObjects[object.objectId] = nil
    }
}

class AnimatablePropertyContainer: NSObject {
    fileprivate static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAll() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        NSView.swizzleAnimationForKey()
        NSWindow.swizzleAnimationForKey()
        NSLayoutConstraint.swizzleAnimationForKey()
        NSPageController.swizzleAnimationForKey()
        NSSplitViewItem.swizzleAnimationForKey()
        CALayer.swizzleActionForKey()
    }
}

fileprivate extension NSLayoutConstraint {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSLayoutConstraint.self) {
                #selector(NSLayoutConstraint.defaultAnimation(forKey:)) <~> #selector(NSLayoutConstraint.swizzledDefaultAnimation(forKey:))
                #selector(NSLayoutConstraint.animation(forKey:)) <-> #selector(NSLayoutConstraint.swizzledAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
}

fileprivate extension NSPageController {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSPageController.self) {
                #selector(NSPageController.defaultAnimation(forKey:)) <~> #selector(NSPageController.swizzledDefaultAnimation(forKey:))
                #selector(NSPageController.animation(forKey:)) <-> #selector(NSPageController.swizzledAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}

fileprivate extension NSSplitViewItem {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.springAnimation {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAPropertyAnimation)?.delegate = animationDelegate
        return animation
    }
    
    static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleDefaultAnimation") }
    }
    
    static func swizzleAnimationForKey() {
        guard !didSwizzleDefaultAnimation else { return }
        didSwizzleDefaultAnimation = true
        do {
            _ = try Swizzle(NSSplitViewItem.self) {
                #selector(NSSplitViewItem.defaultAnimation(forKey:)) <~> #selector(NSSplitViewItem.swizzledDefaultAnimation(forKey:))
                #selector(NSSplitViewItem.animation(forKey:)) <-> #selector(NSSplitViewItem.swizzledAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}

fileprivate extension NSObject {
    func isPropertyReadOnly(_ propertyName: String) -> Bool {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(object_getClass(self), &count) else {
            return false
        }
        defer { free(properties) }

        for i in 0..<count {
            let property = properties[Int(i)]
            let name = property_getName(property)
            let propName = String(cString: name)
            if propName == propertyName {
                if let attributes = property_getAttributes(property) {
                    let attrString = String(cString: attributes)
                    // A read-only property contains "R" in the attribute string
                    return attrString.contains(",R,") || attrString.hasPrefix("R,") || attrString.hasSuffix(",R")
                }
            }
        }
        return false // Not found
    }
}

extension CALayer {
     @objc private func swizzled_action(forKey event: String) -> (any CAAction)? {
         let action = swizzled_action(forKey: event)
         if let action = action as? CABasicAnimation, let animation = NSAnimationContext.current.animation {
             let new = action.copy() as! CABasicAnimation
             new.repeatCount = Float(animation.repeatCount)
             new.repeatDuration = animation.repeatDuration
             new.autoreverses = animation.autoreverses
             new.beginTime = CACurrentMediaTime() + animation.delay
             return new
         }
         return action
     }
    
    static var didSwizzleActionForKey: Bool {
        get { getAssociatedValue("didSwizzleActionForKey", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleActionForKey") }
    }
    
    static func swizzleActionForKey() {
        guard !didSwizzleActionForKey else { return }
        didSwizzleActionForKey = true
        do {
            _ = try Swizzle(CALayer.self) {
                #selector(CALayer.action(forKey:)) <-> #selector(CALayer.swizzled_action(forKey:))
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}

#endif
