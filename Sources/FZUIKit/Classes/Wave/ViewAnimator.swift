//
//  ViewAnimator.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/**
 The `ViewAnimator` class contains the supported NSView/UIView animatable properties, like `frame`, `center`, `cornerRadius`, and more.

 In an Wave animation block, change these values to create an animation, like so:

 Example usage:
 ```swift
 Wave.animate(withSpring: spring) {
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
        
        case borderColor
        case borderWidth

        case shadowColor
        case shadowOpacity
        case shadowOffset
        case shadowRadius
        
        case frameAlt
    }

    var view: NSUIView

    init(view: NSUIView) {
        self.view = view
        #if os(macOS)
        self.view.wantsLayer = true
        #endif
    }

    // MARK: - Public

    /// The bounds of the attached  view.
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

    /// The frame of the attached  view.
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

    /// The origin of the attached  view.
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

    /// The center of the attached  view.
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
    
    public var frameAlt: CGRect {
        get {
            runningFrameAltAnimator?.target ?? view.frame
        }
        set {
            guard frameAlt != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.frameAlt = newValue
                }
                return
            }

            let initialValue = view.frame
            let targetValue = newValue

            let animationType = AnimatableProperty.frameAlt

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningFrameAltAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningFrameAltAnimator ?? SpringAnimator<CGRect>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] frame in
                guard let strongSelf = self else { return }
                #if canImport(UIKit)
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
                #elseif os(macOS)
              //  strongSelf.view.bounds = CGRect(origin: .zero, size: frame.size)
                strongSelf.view.frame = frame
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
                #if canImport(UIKit)
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
                #elseif os(macOS)
             //   strongSelf.view.bounds.size = size
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

    /// The background color of the attached  view.
    var backgroundColor: NSUIColor {
            get {
                if let targetComponents = runningBackgroundColorAnimator?.target {
                    return targetComponents.color
                } else {
                    return view.backgroundColor ?? .clear
                }
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

                // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero.
                let initialValue = view.backgroundColor ?? .clear

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
                    self?.view.backgroundColor = components.color
                }

                let groupUUID = animation.groupUUID
                animation.completion = { [weak self] event in
                    switch event {
                    case .finished(at: _):
                        self?.view.animations.removeValue(forKey: animationType)
                        AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                    default:
                        break
                    }
                }

                start(animation: animation, type: animationType, delay: settings.delay)
            }
        }

    /// The alpha of the attached  view.
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

    /// The scale transform of the attached view.
    public var scale: CGPoint {
        get {
            return runningScaleAnimator?.target ?? self.view.layer?.scale ?? CGPoint(x: 1, y: 1)
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.scale = newValue
                }
                return
            }

            self.view.anchorPoint = CGPoint(0.5, 0.5)
            
            let initialValue = self.view.layer?.scale ?? CGPoint(x: 1, y: 1)
            let targetValue = newValue

            let animationType = AnimatableProperty.scale

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningScaleAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningScaleAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.view.layer?.scale = value
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

    /// The translation transform of the attached view.
    public var translation: CGPoint {
        get {
            return runningTranslationAnimator?.target ?? self.view.layer?.translation ?? CGPoint(x: 0, y: 0)
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.translation = newValue
                }
                return
            }

            let initialValue = self.view.layer?.translation ?? CGPoint(x: 0, y: 0)
            let targetValue = newValue

            let animationType = AnimatableProperty.translation

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningTranslationAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningTranslationAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                strongSelf.view.layer?.translation = value
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

    /// The corner radius of the attached view.
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
    
    /// The border color of the attached view.
    var borderColor: NSUIColor {
        get {
            if let targetComponents = runningBorderColorAnimator?.target {
                return targetComponents.color
            } else {
                return view.borderColor ?? .black
            }
        }

        set {
            guard borderColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.borderColor = newValue
                }
                return
            }

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: NSUIColor
            if let borderColor = view.borderColor {
                initialValue = borderColor
            } else {
                initialValue = NSUIColor.black
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: NSUIColor
            if newValue == .clear {
                targetValue = borderColor.withAlphaComponent(0)
            } else {
                targetValue = newValue
            }

            let animationType = AnimatableProperty.borderColor

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBorderColorAnimator?.groupUUID, finished: false, retargeted: true)

            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)

            let animation = (runningBorderColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.view.borderColor = components.color
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    var borderWidth: CGFloat {
        get {
            runningBorderWidthAnimator?.target ?? view.borderWidth
        }
        set {
            guard borderWidth != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.borderWidth = newValue
                }
                return
            }

            let initialValue = view.borderWidth
            let targetValue = newValue

            let animationType = AnimatableProperty.borderWidth

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBorderWidthAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBorderWidthAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.borderWidth = value
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    var shadowOpacity: CGFloat {
        get {
            runningShadowOpacityAnimator?.target ?? view.shadowOpacity
        }
        set {
            guard shadowOpacity != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOpacity = newValue
                }
                return
            }

            let initialValue = view.shadowOpacity
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOpacity

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOpacityAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOpacityAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                let clippedValue = clipUnit(value: value)
                self?.view.shadowOpacity = clippedValue
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    var shadowColor: NSUIColor {
        get {
            if let targetComponents = runningShadowColorAnimator?.target {
                return targetComponents.color
            } else {
                return view.backgroundColor ?? .clear
            }
        }

        set {
            guard shadowColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowColor = newValue
                }
                return
            }

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: NSUIColor
            if let shadowColor = view.shadowColor {
                initialValue = shadowColor
            } else {
                initialValue = .clear
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: NSUIColor
            if newValue == .clear {
                targetValue = shadowColor.withAlphaComponent(0)
            } else {
                targetValue = newValue
            }

            let animationType = AnimatableProperty.shadowColor

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowColorAnimator?.groupUUID, finished: false, retargeted: true)

            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)

            let animation = (runningShadowColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.view.shadowColor = components.color
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    /// The shadow offset of the attached layer.
    var shadowOffset: CGSize {
        get {
            runningShadowOffsetAnimator?.target ?? view.shadowOffset
        }
        set {
            guard shadowOffset != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOffset = newValue
                }
                return
            }

            let initialValue = view.shadowOffset
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOffset

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOffsetAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOffsetAnimator ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.shadowOffset = value
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
    
    var shadowRadius: CGFloat {
        get {
            runningShadowRadiusAnimator?.target ?? view.shadowRadius
        }
        set {
            guard shadowRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowRadius = newValue
                }
                return
            }

            let initialValue = view.shadowRadius
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.shadowRadius = max(0, value)
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
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
    
    private var runningBackgroundColorAnimator: SpringAnimator<RGBAComponents>? {
          view.animations[AnimatableProperty.backgroundColor] as? SpringAnimator<RGBAComponents>
      }

    
    private var runningBorderColorAnimator: SpringAnimator<RGBAComponents>? {
        view.animations[AnimatableProperty.borderColor] as? SpringAnimator<RGBAComponents>
       }

       private var runningBorderWidthAnimator: SpringAnimator<CGFloat>? {
           view.animations[AnimatableProperty.borderWidth] as? SpringAnimator<CGFloat>
       }

       private var runningShadowColorAnimator: SpringAnimator<RGBAComponents>? {
           view.animations[AnimatableProperty.shadowColor] as? SpringAnimator<RGBAComponents>
       }

       private var runningShadowOpacityAnimator: SpringAnimator<CGFloat>? {
           view.animations[AnimatableProperty.shadowOpacity] as? SpringAnimator<CGFloat>
       }

       private var runningShadowOffsetAnimator: SpringAnimator<CGSize>? {
           view.animations[AnimatableProperty.shadowOffset] as? SpringAnimator<CGSize>
       }

       private var runningShadowRadiusAnimator: SpringAnimator<CGFloat>? {
           view.animations[AnimatableProperty.shadowRadius] as? SpringAnimator<CGFloat>
       }
    
    private var runningFrameAltAnimator: SpringAnimator<CGRect>? {
        view.animations[AnimatableProperty.frameAlt] as? SpringAnimator<CGRect>
    }
}
#endif
