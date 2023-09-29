//
//  File.swift
//  
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import CoreGraphics
import Foundation
import AppKit
import FZSwiftUtils

/**
 The `WindowAnimator` class contains the supported NSWindow animatable properties, like `frame`, `alphaValue` and `backgroundColor`.
 
 In an Wave animation block, change these values to create an animation, like so:
 
 Example usage:
 ```swift
 Wave.animate(withSpring: spring) {
    myWindow.animator.frame = CGRect(x: 100, y: 100, width: 400, height: 400)
    myWindow.animator.alpha = 0.5
 }
 ```
 */
public class WindowAnimator {
    internal enum AnimatableProperty: Int {
        case frame
        case size
        case backgroundColor
        case alpha
    }
    
    private var window: NSWindow
    
    internal init(window: NSWindow) {
        self.window = window
    }
    
    /// The size of the attached  window.
    public var size: CGSize {
        get { frame.size }
        set {
            let oldFrame = frame
            var newFrame = oldFrame
            newFrame.size = newValue
            newFrame.center = oldFrame.center
            frame = newFrame
        }
    }
    
    /// The alpha of the attached  window.
    public var frame: CGRect {
        get {
            runningFrameAnimator?.target ?? window.frame
        }
        set {
            guard frame != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.window.animator.frame = newValue
                }
                return
            }
            
            let initialValue = window.frame
            let targetValue = newValue
            
            let animationType = AnimatableProperty.frame
            
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)
            
            let animation = (runningFrameAnimator ?? SpringAnimator<CGRect>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.window.setFrame(value, display: false)
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.window.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    /// The alpha of the attached  window.
    public var alpha: CGFloat {
        get {
            runningAlphaAnimator?.target ?? window.alphaValue
        }
        set {
            guard alpha != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.window.animator.alpha = newValue
                }
                return
            }
            
            let initialValue = window.alphaValue
            let targetValue = newValue
            
            let animationType = AnimatableProperty.alpha
            
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)
            
            let animation = (runningAlphaAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.window.alphaValue = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.window.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    /// The background color of the attached  window.
    public var backgroundColor: NSUIColor {
        get {
            if let targetComponents = runningBackgroundColorAnimator?.target {
                return targetComponents.color
            } else {
                return window.backgroundColor ?? .clear
            }
        }
        set {
            guard backgroundColor != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.window.animator.backgroundColor = newValue
                }
                return
            }
            
            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero.
            let initialValue = window.backgroundColor ?? .clear
            
            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue = (newValue == NSUIColor.clear) ? backgroundColor.withAlphaComponent(0) : newValue
            
            let animationType = AnimatableProperty.backgroundColor
            
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBackgroundColorAnimator?.groupUUID, finished: false, retargeted: true)
            
            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)
            
            let animation = (runningBackgroundColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.window.backgroundColor = components.color
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.window.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
}

public extension NSWindow {
    /**
     Use the `animator` property to set any animatable properties on a `NSWindow` in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```swift
     Wave.animateWith(spring: spring) {
        window.animator.frame = CGRect(x: 100, y: 100, width: 400, height: 400)
     }
     ```
     */
    var animator: WindowAnimator {
        get { getAssociatedValue(key: "Animator", object: self, initialValue: WindowAnimator(window: self)) }
        set { set(associatedValue: newValue, key: "Animator", object: self) }
    }

    internal var animations: [WindowAnimator.AnimatableProperty: AnimationProviding] {
        get { getAssociatedValue(key: "animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "animations", object: self) }
    }
}

extension WindowAnimator {
    private func start(animation: AnimationProviding, type: AnimatableProperty, delay: TimeInterval) {
        window.animations[type] = animation
        animation.start(afterDelay: delay)
    }
    
    private var runningBackgroundColorAnimator: SpringAnimator<RGBAComponents>? {
        window.animations[AnimatableProperty.backgroundColor] as? SpringAnimator<RGBAComponents>
    }
    
    private var runningFrameAnimator: SpringAnimator<CGRect>? {
        window.animations[AnimatableProperty.frame] as? SpringAnimator<CGRect>
    }
    
    private var runningAlphaAnimator: SpringAnimator<CGFloat>? {
        window.animations[AnimatableProperty.alpha] as? SpringAnimator<CGFloat>
    }
}

#endif
