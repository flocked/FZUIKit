//
//  NSUIView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A type that provides a background color.
public protocol BackgroundColorSettable {
    /// The background color of the object.
    var backgroundColor: NSUIColor? { get set }
}

extension NSUIView: BackgroundColorSettable {}

public extension BackgroundColorSettable where Self: NSView {
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    var backgroundColor: NSColor? {
        get { backgroundColorAnimatable }
        set {
            wantsLayer = true
            Self.swizzleAnimationForKey()
            NSView.toRealSelf(self).dynamicColors.background = newValue
            var animatableColor = newValue?.resolvedColor(for: self)
            if animatableColor == nil, isProxy() {
                animatableColor = .clear
            }

            if layer?.backgroundColor?.isVisible == false || layer?.backgroundColor == nil {
                layer?.backgroundColor = animatableColor?.withAlphaComponent(0.0).cgColor ?? .clear
            }
            backgroundColorAnimatable = animatableColor
        }
    }
}

extension NSView {
    @objc var backgroundColorAnimatable: NSColor? {
        get { layer?.backgroundColor?.nsColor }
        set {
            layer?.backgroundColor = newValue?.cgColor
        }
    }

    struct DynamicColors {
        var shadow: NSColor? {
            didSet { if shadow?.isDynamic == false { shadow = nil } }
        }

        var innerShadow: NSColor? {
            didSet { if innerShadow?.isDynamic == false { innerShadow = nil } }
        }

        var border: NSColor? {
            didSet { if border?.isDynamic == false { border = nil } }
        }

        var background: NSColor? {
            didSet { if background?.isDynamic == false { background = nil } }
        }

        var needsAppearanceObserver: Bool {
            background != nil || border != nil || shadow != nil || innerShadow != nil
        }

        mutating func update(_ keyPath: WritableKeyPath<Self, NSColor?>, cgColor: CGColor?) {
            guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return }
            if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                self[keyPath: keyPath] = nil
            }
        }
    }

    var dynamicColors: DynamicColors {
        get { getAssociatedValue(key: "dynamicColors", object: self, initialValue: DynamicColors()) }
        set { set(associatedValue: newValue, key: "dynamicColors", object: self)
            setupEffectiveAppearanceObserver()
        }
    }

    var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
    }

    func setupEffectiveAppearanceObserver() {
        
        
        if dynamicColors.needsAppearanceObserver {
            if _effectiveAppearanceKVO == nil {
                _effectiveAppearanceKVO = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                    self?.updateEffectiveColors()
                }
            }
        } else {
            _effectiveAppearanceKVO?.invalidate()
            _effectiveAppearanceKVO = nil
        }
    }

    func updateEffectiveColors() {
        dynamicColors.update(\.shadow, cgColor: layer?.shadowColor)
        dynamicColors.update(\.background, cgColor: layer?.backgroundColor)
        dynamicColors.update(\.border, cgColor: layer?.borderColor)
        dynamicColors.update(\.innerShadow, cgColor: innerShadowLayer?.shadowColor)

        if let color = dynamicColors.shadow?.resolvedColor(for: self).cgColor {
            layer?.shadowColor = color
        }
        if let color = dynamicColors.border?.resolvedColor(for: self).cgColor {
            if let dashedBorderLayer = dashedBorderLayer {
                dashedBorderLayer.borderColor = color
            } else {
                layer?.borderColor = color
            }
        }
        if let color = dynamicColors.background?.resolvedColor(for: self).cgColor {
            layer?.backgroundColor = color
        }
        if let color = dynamicColors.innerShadow?.resolvedColor(for: self).cgColor {
            innerShadowLayer?.shadowColor = color
        }

        if dynamicColors.needsAppearanceObserver == false {
            _effectiveAppearanceKVO?.invalidate()
            _effectiveAppearanceKVO = nil
        }
    }
}
#endif
