//
//  File.swift
//  
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public class LayoutConstraintAnimator {
    
    private var layoutConstraint: NSLayoutConstraint
    
    internal init(constraint: NSLayoutConstraint) {
        self.layoutConstraint = constraint
    }
    
    /// The constant added to the multiplied second attribute participating in the constraint.
    public var constant: CGFloat {
        get {
            layoutConstraint.constantAnimator?.target ?? layoutConstraint.constant
        }
        set {
            guard constant != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.layoutConstraint.animator.constant = newValue
                }
                return
            }
            
            let initialValue = layoutConstraint.constant
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: layoutConstraint.constantAnimator?.groupUUID, finished: false, retargeted: true)
            
            let animation = (layoutConstraint.constantAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layoutConstraint.constant = value
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layoutConstraint.constantAnimator = nil
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            self.layoutConstraint.constantAnimator = animation
            animation.start(afterDelay: settings.delay)
        }
    }
    
}

public extension NSLayoutConstraint {
    /**
     Use the `animator` property to set any animatable properties on a `NSLayoutConstraint` in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```swift
     Wave.animateWith(spring: spring) {
        widthConstraint.animator.constant = 500
     }
     ```
     */
    var animator: LayoutConstraintAnimator {
        get {
            getAssociatedValue(key: "Animator", object: self, initialValue: LayoutConstraintAnimator(constraint: self))
        }
        set {
            set(associatedValue: newValue, key: "Animator", object: self)
        }
    }

    internal var constantAnimator: SpringAnimator<CGFloat>? {
        get {
            getAssociatedValue(key: "constantAnimator", object: self, initialValue: nil)
        }
        set {
            set(associatedValue: newValue, key: "constantAnimator", object: self)
        }
    }
}

#endif
