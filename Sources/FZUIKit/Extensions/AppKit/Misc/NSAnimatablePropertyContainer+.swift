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
                setValue(value(forKey: key), forKey: key)
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
        NSAnimationContext.performWithoutAnimation {
            setValue(value(forKey: key), forKey: key)
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
    
    /// An array of keys of the object's properties that are currently animated.
    var animationKeys: [String] {
        animationDelegate.animationKeys.sorted()
    }
    
    internal var animationDelegate: AnimationDelegate {
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
    
    init(for object: Object) {
        self.object = object
    }
    
    func animationDidStart(_ animation: CAAnimation) {
        guard let key = (animation as? CAPropertyAnimation)?.keyPath else { return }
        animationKeys.insert(key)
        if let object = object, Self.animatingObjects[ObjectIdentifier(object)] == nil {
            Self.animatingObjects[object.objectIdentifier] = Weak(object)
        }
    }
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        guard let key = (animation as? CAPropertyAnimation)?.keyPath else { return }
        animationKeys.remove(key)
        if animationKeys.isEmpty, let object = object {
            Self.animatingObjects[object.objectIdentifier] = nil
        }
    }
}

#endif
