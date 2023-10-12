//
//  Animator+LayoutConstraint.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSLayoutConstraint: Animatable { }

extension Animator where Object: NSLayoutConstraint {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { value(for: \.constant) }
        set { setValue(newValue, for: \.constant) }
    }
}

public extension Collection where Element == NSLayoutConstraint {
    /// Use the `animator` property to animate changes to the layout constraints of the collection.
    var animator: LayoutConstraintsAnimator<Self> {
        LayoutConstraintsAnimator(self)
    }
}

/// An object for animating layout constraints in a collection.
public struct LayoutConstraintsAnimator<Object: Collection> where Object.Element == NSLayoutConstraint {
    internal var collection: Object
    internal init(_ collection: Object) {
        self.collection = collection
    }
    
    /// Updates the constant of the constraints and returns itself.
    public func constant(_ constant: CGFloat) {
        collection.forEach({ $0.animator.constant = constant })
    }
    
    /*
    public var insets: NSDirectionalEdgeInsets {
        get {
            var insets = NSDirectionalEdgeInsets()
            insets.leading = collection.leading?.animator.constant ?? 0
            insets.trailing = -(collection.trailing?.animator.constant ?? 0)
            insets.top = collection.top?.animator.constant ?? 0
            insets.bottom = -(collection.bottom?.animator.constant ?? 0)
            insets.width = -(collection.width?.animator.constant ?? 0)
            insets.height = -(collection.height?.animator.constant ?? 0)
            return insets
        }
        set {
            collection.leading?.animator.constant = newValue.leading
            collection.trailing?.animator.constant = -newValue.trailing
            collection.bottom?.animator.constant = -newValue.bottom
            collection.top?.animator.constant = newValue.top
            collection.width?.animator.constant = -newValue.width
            collection.height?.animator.constant = -newValue.height
        }
    }
    */
    
    /// Updates the constant of the constraints and returns itself.
    public func constant(_ insets: NSDirectionalEdgeInsets) {
        collection.leading?.animator.constant = insets.leading
        collection.trailing?.animator.constant = -insets.trailing
        collection.bottom?.animator.constant = -insets.bottom
        collection.top?.animator.constant = insets.top
        collection.width?.animator.constant = -insets.width
        collection.height?.animator.constant = -insets.height
    }

    /// Updates the constant of the constraints and returns itself.
    public func constant(_ insets: NSUIEdgeInsets)  {
        self.constant(insets.directional)
    }
    
    public var leading: Animator<NSLayoutConstraint>? {
        get { collection.leading?.animator }
    }
    
    public var trailing: Animator<NSLayoutConstraint>? {
        get { collection.trailing?.animator }
    }
    
    public var bottom: Animator<NSLayoutConstraint>? {
        get { collection.bottom?.animator }
    }
    
    public var top: Animator<NSLayoutConstraint>? {
        get { collection.top?.animator }
    }
    
    public var centerX: Animator<NSLayoutConstraint>? {
        get { collection.centerX?.animator }
    }
    
    public var centerY: Animator<NSLayoutConstraint>? {
        get { collection.centerY?.animator }
    }
    
    public var lastBaseline: Animator<NSLayoutConstraint>? {
        get { collection.lastBaseline?.animator }
    }
    
    public var firstBaseline: Animator<NSLayoutConstraint>? {
        get { collection.firstBaseline?.animator }
    }
}

#endif
