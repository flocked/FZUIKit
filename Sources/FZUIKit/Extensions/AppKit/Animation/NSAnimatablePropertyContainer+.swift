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
        CATransaction.disabledActions {
            for key in animationKeys {
                if let value = presentation.value(forKeyPath: key) {
                    layer.setValue(value, forKeyPath: key)
                }
            }
        }
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
            self.setValue(safely: self.value(forKeySafely: key), forKey: key)
        }
        guard let layer = (self as? NSView)?.layer, layer.animation(forKey: key) != nil, let presentation = layer.presentation() else { return }
        CATransaction.disabledActions {
            if let value = presentation.value(forKeyPath: key) {
                layer.setValue(value, forKeyPath: key)
            }
        }
        layer.removeAnimation(forKey: key)
    }
    
    /// An array of keys of the object's properties that are currently animated.
    var animationKeys: [String] {
        animationDelegate.animationKeys.sorted()
    }
    
    var animationDelegate: AnimationDelegate {
        getAssociatedValue("propertyAnimationDelegate", initialValue: AnimationDelegate(for: self as! AnimatablePropertyProvider))
    }
}

extension NSAnimationContext {
    /**
     Stops all animations of properties animated using [animator()](https://developer.apple.com/documentation/appkit/nsanimatablepropertycontainer/animator()).
     */
    class func stopAllAnimations() {
        AnimationDelegate.animatingObjects.values.forEach({ $0.object?.stopAllAnimations() })
    }
    
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
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
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
        (animation as? CAAnimation)?.delegate = animationDelegate
        return animation
    }
}

fileprivate extension NSPageController {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAAnimation)?.delegate = animationDelegate
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
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
            return springAnimation
        }
        return animation
    }
    
    @objc private func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAAnimation)?.delegate = animationDelegate
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

protocol AnimatablePropertyProvider: NSObject {
    func stopAnimation(for key: String)
    func stopAllAnimations()
    var animationDelegate: AnimationDelegate { get }
}

extension NSView: AnimatablePropertyProvider { }
extension NSWindow: AnimatablePropertyProvider { }
extension NSLayoutConstraint: AnimatablePropertyProvider { }
extension NSPageController: AnimatablePropertyProvider { }
extension NSSplitViewItem: AnimatablePropertyProvider { }
extension CALayer: AnimatablePropertyProvider { }

class WeakAnimatablePropertyProvider: Equatable, Hashable {
    private let id = UUID()
    weak var object: AnimatablePropertyProvider?
    init(_ provider: AnimatablePropertyProvider) {
        object = provider
    }
    
    static func == (lhs: WeakAnimatablePropertyProvider, rhs: WeakAnimatablePropertyProvider) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        if let object = object {
            hasher.combine(ObjectIdentifier(object))
        } else {
            hasher.combine(id)
        }
    }
}

extension CALayer {
    func stopAllAnimations() {
        guard var animationKeys = animationKeys(), let presentation = presentation() else { return }
        let keys = animationDelegate.animationKeys
        animationKeys = animationKeys.filter({ keys.contains($0) })
        CATransaction.disabledActions {
            for key in animationKeys {
                if let value = presentation.value(forKeyPath: key) {
                    setValue(value, forKeyPath: key)
                }
            }
        }
        animationKeys.forEach({ removeAnimation(forKey: $0) })
    }
    
    func stopAnimation(for key: String) {
        guard animation(forKey: key) != nil, let presentation = presentation() else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let value = presentation.value(forKeyPath: key) {
            setValue(value, forKeyPath: key)
            if let parentView = parentView, let value = parentView.value(forKeySafely: key) {
                parentView.setValue(safely: value, forKey: key)
            }
            if key == "bounds", let value = value as? CGRect {
                parentView?.frame.size = value.size
            } else if key == "position", let value = value as? CGPoint {
                parentView?.frame.origin = value
            } else if key == "opacity", let value = value as? CGFloat {
                parentView?.alphaValue = value
            }
        }
        CATransaction.commit()
        removeAnimation(forKey: key)
    }
    
    var animationDelegate: AnimationDelegate {
        getAssociatedValue("propertyAnimationDelegate", initialValue: AnimationDelegate(for: self))
    }
}

fileprivate extension CALayer {
    @objc func swizzled_action(forKey event: String) -> (any CAAction)? {
        var action = swizzled_action(forKey: event)
        if action == nil, Self.animatableKeys.contains(event) {
            action = CABasicAnimation(keyPath: event)
        }
        if let animation = NSAnimationContext.current.animator, let action = action as? CAAnimation, let new = action.copy() as? CAAnimation {
            new.repeatCount = Float(animation.repeatCount)
            new.repeatDuration = animation.repeatDuration
            new.autoreverses = animation.autoreverses
            new.beginTime = CACurrentMediaTime() + animation.delay
            new.delegate = animationDelegate
            return new
        }
        return action
    }
    
    static let animatableKeys: Set<String> = ["bounds", "position", "zPosition", "anchorPoint", "anchorPointZ", "transform",  "frame", "contents", "contentsRect", "contentsScale", "contentsCenter", "opacity", "backgroundColor", "cornerRadius", "borderWidth", "borderColor", "shadowColor", "shadowOpacity", "shadowOffset", "shadowRadius", "shadowPath", "mask", "masksToBounds", "fillColor", "strokeColor", "lineDashPattern", "lineWidth", "fillColor", "strokeStart", "strokeEnd", "lineDashPhase", "isHidden", "contents", "path", "inverseMask"]
    
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
