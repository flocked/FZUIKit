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

     - Parameter animated: A Boolean value indicating whether to return the animator proxy object or the receiver.
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
    /// Stops all animations of properties.
    func stopAllAnimations() {
        animationDelegate.animationKeys.forEach({ stopAnimation(for: $0) })
        (self as? NSView)?.layer?.stopAllAnimations()
    }
    
    /// Stops the animation of the specified property.
    func stopAnimation(for keyPath: PartialKeyPath<Self>) {
        guard let key = keyPath.kvcStringValue else { return }
        stopAnimation(for: key)
    }
    
    /// Stops the animation of the specified property.
    func stopAnimation(for key: String) {
        if animationDelegate.animationKeys.contains(key), let value = value(forKeySafely: key) {
            NSAnimationContext.performWithoutAnimation {
                self.setValue(safely: value, forKey: key)
            }
        }
        (self as? NSView)?.layer?.stopAnimation(for: key)
    }
    
    /// An array of keys of the object's properties that are currently animated.
    var animationKeys: [String] {
        (animationDelegate.animationKeys + ((self as? NSView)?.layer?.animationKeys() ?? [])).sorted()
    }
    
    var animationDelegate: AnimationDelegate {
        getAssociatedValue("propertyAnimationDelegate", initialValue: AnimationDelegate(for: self as! AnimatablePropertyProvider))
    }
}

extension NSAnimationContext {
    fileprivate static var didSwizzleDefaultAnimation: Bool {
        get { getAssociatedValue("didSwizzleDefaultAnimation") ?? false }
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
    /// Stops all animations of properties.
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
    
    /// Stops the animation of the specified property.
    func stopAnimation(for keyPath: PartialKeyPath<CALayer>) {
        guard let key = keyPath.kvcStringValue else { return }
        stopAnimation(for: key)
    }
    
    /// Stops the animation of the specified property.
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
            if #available(macOS 12.0, *) {
                new.preferredFrameRateRange = animation.preferredFrameRateRange
            }
            if animation.autoreverses {
                new.fillMode = .forwards
                new.isRemovedOnCompletion = false
            }
            new.delegate = animationDelegate
            return new
        }
        return action
    }
    
    static let animatableKeys: Set<String> = ["bounds", "position", "zPosition", "anchorPoint", "anchorPointZ", "transform",  "frame", "contents", "contentsRect", "contentsScale", "contentsCenter", "opacity", "backgroundColor", "cornerRadius", "borderWidth", "borderColor", "shadowColor", "shadowOpacity", "shadowOffset", "shadowRadius", "shadowPath", "mask", "masksToBounds", "fillColor", "strokeColor", "lineDashPattern", "lineWidth", "fillColor", "strokeStart", "strokeEnd", "lineDashPhase", "isHidden", "contents", "path", "inverseMask"]
    
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
    
    static var didSwizzleActionForKey: Bool {
        get { getAssociatedValue("didSwizzleActionForKey", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleActionForKey") }
    }
}

extension AnimatablePropertyProvider {
    static func swizzleAnimationForKey() {
        guard !didSwizzleAnimationForKey else { return }
        didSwizzleAnimationForKey = true
        do {
            _ = try Swizzle(NSView.self) {
                #selector(NSView.defaultAnimation(forKey:)) <~> #selector(NSObject.swizzledDefaultAnimation(forKey:))
                #selector(NSView.animation(forKey:)) <-> #selector(NSObject.swizzledAnimation(forKey:))
            }
        } catch {
            Swift.debugPrint(error, (error as? LocalizedError)?.failureReason ?? "nil")
        }
    }

    private static var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue("didSwizzleAnimationForKey") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleAnimationForKey") }
    }
}

fileprivate extension NSObject {
    @objc class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        guard let animation = swizzledDefaultAnimation(forKey: key) else { return nil }
        if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
            return springAnimation
        }
        return animation
    }
    
    @objc func swizzledAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        let animation = swizzledAnimation(forKey: key)
        (animation as? CAAnimation)?.delegate = (self as! AnimatablePropertyProvider).animationDelegate
        return animation
    }
}

fileprivate extension NSView {
    @objc override class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if let animation = swizzledDefaultAnimation(forKey: key) {
            if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
                return springAnimation
            }
            return animation
        } else if Self.animatableKeys.contains(key) {
             return swizzledDefaultAnimation(forKey: "frameOrigin")
        }
        return nil
    }
    
    static let animatableKeys: Set<String> = ["_contentOffset", "_contentOffsetFractional", "_documentSize", "_fontSize", "_placeholderTextColor", "_roundedCorners", "_selectionColor", "_selectionTextColor", "backgroundColor", "bezelColor", "borderColor", "borderWidth", "contentTintColor", "cornerRadius", "fillColor", "shadowColor", "textColor"]
}

fileprivate extension NSWindow {
    @objc override class func swizzledDefaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if let animation = swizzledDefaultAnimation(forKey: key) {
            if animation is CABasicAnimation, NSAnimationContext.hasActiveGrouping, let springAnimation = NSAnimationContext.current.animator?.spring {
                return springAnimation
            }
            return animation
        } else if animatableKeys.contains(key) {
            return swizzledDefaultAnimation(forKey: "alphaValue")
        }
        return nil
    }
    
    static let animatableKeys = ["_frameAnimatable", "_contentSize"]
}

#endif
