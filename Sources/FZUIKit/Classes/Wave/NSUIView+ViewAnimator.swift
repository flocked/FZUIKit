//
//  NSUIView+ViewAnimator.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//


#if os(macOS) || os(iOS) || os(tvOS)
#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private var ViewAnimatorAssociatedObjectHandle: UInt8 = 1 << 4
private var ViewAnimationsAssociatedObjectHandle: UInt8 = 1 << 5

public extension NSUIView {
    /**
     Use the `animator` property to set any animatable properties on a `UIView` in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```swift
     Wave.animateWith(spring: spring) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     ```

     See ``ViewAnimator`` for a list of supported animatable properties on `UIView`.
     */
    var animator: ViewAnimator {
        get {
            if let viewAnimator = objc_getAssociatedObject(self, &ViewAnimatorAssociatedObjectHandle) as? ViewAnimator {
                return viewAnimator
            } else {
                self.animator = ViewAnimator(view: self)
                return self.animator
            }
        }
        set {
            objc_setAssociatedObject(self, &ViewAnimatorAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal var animations: [ViewAnimator.AnimatableProperty: AnimationProviding] {
        get {
            objc_getAssociatedObject(self, &ViewAnimationsAssociatedObjectHandle) as? [ViewAnimator.AnimatableProperty: AnimationProviding] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ViewAnimationsAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif
