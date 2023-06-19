//
//  ViewAnimator.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/**
 The `ViewAnimator` class contains the supported UIView animatable properties, like `frame`, `center`, `cornerRadius`, and more.

 In an Wave animation block, change these values to create an animation, like so:

 Example usage:
 ```
 Wave.animateWith(spring: spring) {
 myView.animator.center = CGPoint(x: 100, y: 100)
 myView.animator.alpha = 0.5
 }
 ```
 */
public class ViewAnimator {
    internal enum AnimatableProperty: Int {
        case frameCenter
        case frameOrigin

        case boundsSize
        case boundsOrigin

        case alpha
        case backgroundColor

        case scale
        case translation
        case cornerRadius
    }

    var view: NSUIView

    init(view: NSUIView) {
        self.view = view
        #if os(macOS)
        self.view.wantsLayer = true
        #endif
    }

    // MARK: - Public

    /// The bounds of the attached `UIView`.
    public var bounds: CGRect {
        get {
            CGRect(origin: view.animator.boundsOrigin, size: view.animator.boundsSize)
        }
        set {
            guard bounds != newValue else {
                return
            }

            // `bounds.size`
            boundsSize = newValue.size

            // `bounds.origin`
            boundsOrigin = newValue.origin
        }
    }

    /// The frame of the attached `UIView`.
    public var frame: CGRect {
        get {
            CGRect(aroundPoint: view.animator.center, size: view.animator.boundsSize)
        }
        set {
            guard frame != newValue else {
                return
            }

            // `bounds.size`
            boundsSize = newValue.size

            // `frame.center`
            center = newValue.center
        }
    }

    /// The origin of the attached `UIView`.
    public var origin: CGPoint {
        get {
            view.animator.frame.origin
        }
        set {
            guard origin != newValue else {
                return
            }

            // `frame.center`
            center = CGPoint(x: newValue.x + bounds.width / 2.0, y: newValue.y + bounds.height / 2.0)
        }
    }

    /// The center of the attached `UIView`.
    public var center: CGPoint {
        get {
            runningCenterAnimator?.target ?? view.center
        }
        set {
            guard center != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.center = newValue
                }
                return
            }

            let initialValue = view.center
            let targetValue = newValue

            let animationType = AnimatableProperty.frameCenter

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningCenterAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningCenterAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            if let gestureVelocity = settings.gestureVelocity {
                animation.velocity = gestureVelocity
            }

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.center = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    private var boundsOrigin: CGPoint {
        get {
            runningBoundsOriginAnimator?.target ?? view.bounds.origin
        }
        set {
            guard boundsOrigin != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.origin = newValue
                }
                return
            }

            let initialValue = view.bounds.origin
            let targetValue = newValue

            let animationType = AnimatableProperty.boundsOrigin

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBoundsOriginAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBoundsOriginAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] boundsOrigin in
                self?.view.bounds.origin = boundsOrigin
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    private var boundsSize: CGSize {
        get {
            runningBoundsSizeAnimator?.target ?? view.bounds.size
        }
        set {
            guard boundsSize != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.size = newValue
                }
                return
            }

            let initialValue = view.bounds.size
            let targetValue = newValue

            let animationType = AnimatableProperty.boundsSize

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBoundsSizeAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBoundsSizeAnimator ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] size in
                guard let strongSelf = self else { return }
                #if os(iOS)
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
                #elseif os(macOS)
                strongSelf.view.bounds.size = size
                strongSelf.view.frame.size = size
                #endif
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The background color of the attached `UIView`.
    public var backgroundColor: NSUIColor? {
        get {
            view.backgroundColor
        }
        set {
            guard backgroundColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.backgroundColor = newValue
                }
                return
            }

            guard let targetValue = newValue else {
                view.backgroundColor = nil
                return
            }

            let animationType = AnimatableProperty.backgroundColor
            let existingAnimationForType = view.animations[animationType]

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: existingAnimationForType?.groupUUID, finished: false, retargeted: true)

            let animation = (existingAnimationForType as? SpringAnimator<CGFloat> ?? SpringAnimator<CGFloat>(spring: settings.spring, value: 0, target: 1))

            animation.configure(withSettings: settings)

            let initialColor = view.backgroundColor

            animation.valueChanged = { [weak self] progress in
                if let initialColor = initialColor {
                    self?.view.backgroundColor = initialColor.blended(withFraction: progress, of: targetValue)
                }
            }

            animation.value = 0
            animation.target = 1.0
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The alpha of the attached `UIView`.
    public var alpha: CGFloat {
        get {
            runningAlphaAnimator?.target ?? view.alpha
        }
        set {
            guard alpha != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.alpha = newValue
                }
                return
            }

            let initialValue = view.alpha
            let targetValue = newValue

            let animationType = AnimatableProperty.alpha

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningAlphaAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.alpha = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The scale transform of the attached `UIView`'s `layer`.
    public var scale: CGPoint {
        get {
            let currentScale = CGPoint(x: view.transform.a, y: view.transform.d)
            return runningScaleAnimator?.target ?? currentScale
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.scale = newValue
                }
                return
            }

            let initialValue = CGPoint(x: view.transform.a, y: view.transform.d)
            let targetValue = newValue

            let animationType = AnimatableProperty.scale

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningScaleAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningScaleAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.a = max(value.x, 0.0) // [1, 1]
                transform.d = max(value.y, 0.0) // [2, 2]
                strongSelf.view.transform = transform
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The translation transform of the attached `UIView`'s `layer`.
    public var translation: CGPoint {
        get {
            let currentTranslation = CGPoint(x: view.transform.tx, y: view.transform.ty)
            return runningTranslationAnimator?.target ?? currentTranslation
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.translation = newValue
                }
                return
            }

            let initialValue = CGPoint(x: view.transform.tx, y: view.transform.ty)
            let targetValue = newValue

            let animationType = AnimatableProperty.translation

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningTranslationAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningTranslationAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.tx = value.x
                transform.ty = value.y
                strongSelf.view.transform = transform
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The corner radius of the attached `UIView`'s `layer`.
    public var cornerRadius: CGFloat {
        get {
            runningCornerRadiusAnimator?.target ?? view.cornerRadius
        }
        set {
            guard cornerRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.cornerRadius = newValue
                }
                return
            }

            let initialValue = view.cornerRadius
            let targetValue = newValue

            let animationType = AnimatableProperty.cornerRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningCornerRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningCornerRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.cornerRadius = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
}

extension ViewAnimator {
    // MARK: - Internal

    private func start(animation: AnimationProviding, type: AnimatableProperty, delay: TimeInterval) {
        view.animations[type] = animation
        animation.start(afterDelay: delay)
    }

    private var runningCenterAnimator: SpringAnimator<CGPoint>? {
        view.animations[AnimatableProperty.frameCenter] as? SpringAnimator<CGPoint>
    }

    private var runningBoundsOriginAnimator: SpringAnimator<CGPoint>? {
        view.animations[AnimatableProperty.boundsOrigin] as? SpringAnimator<CGPoint>
    }

    private var runningBoundsSizeAnimator: SpringAnimator<CGSize>? {
        view.animations[AnimatableProperty.boundsSize] as? SpringAnimator<CGSize>
    }

    private var runningScaleAnimator: SpringAnimator<CGPoint>? {
        view.animations[AnimatableProperty.scale] as? SpringAnimator<CGPoint>
    }

    private var runningTranslationAnimator: SpringAnimator<CGPoint>? {
        view.animations[AnimatableProperty.translation] as? SpringAnimator<CGPoint>
    }

    private var runningAlphaAnimator: SpringAnimator<CGFloat>? {
        view.animations[AnimatableProperty.alpha] as? SpringAnimator<CGFloat>
    }

    private var runningCornerRadiusAnimator: SpringAnimator<CGFloat>? {
        view.animations[AnimatableProperty.cornerRadius] as? SpringAnimator<CGFloat>
    }
}
