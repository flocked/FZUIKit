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
            runningBackgroundColorAnimator?.target ?? window.backgroundColor ?? .clear
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
            
            let initialValue = window.backgroundColor ?? .clear
            let targetValue = newValue
            
            let animationType = AnimatableProperty.backgroundColor
            
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBackgroundColorAnimator?.groupUUID, finished: false, retargeted: true)
                        
            let animation = (runningBackgroundColorAnimator ??
                             SpringAnimator<NSUIColor>(
                                spring: settings.spring,
                                value: initialValue,
                                target: targetValue
                             )
            )
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] color in
                self?.window.backgroundColor = color
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
    
    private var runningBackgroundColorAnimator: SpringAnimator<NSUIColor>? {
        window.animations[AnimatableProperty.backgroundColor] as? SpringAnimator<NSUIColor>
    }
    
    private var runningFrameAnimator: SpringAnimator<CGRect>? {
        window.animations[AnimatableProperty.frame] as? SpringAnimator<CGRect>
    }
    
    private var runningAlphaAnimator: SpringAnimator<CGFloat>? {
        window.animations[AnimatableProperty.alpha] as? SpringAnimator<CGFloat>
    }
}

#endif
