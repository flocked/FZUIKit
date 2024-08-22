//
//  NSUIView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSUIView: NSViewProtocol { }

public extension NSViewProtocol where Self: NSView {
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    var backgroundColor: NSColor? {
        get { dynamicColors.color(\.background, cgColor: layer?.backgroundColor) }
        set {
            wantsLayer = true
            NSView.swizzleAnimationForKey()
            realSelf.dynamicColors.background = newValue
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
    
    /**
     Sets the background color of the view.
     
     Using this property turns the view into a layer-backed view.
     */
    @discardableResult
    func backgroundColor(_ color: NSUIColor?) -> Self {
        backgroundColor = color
        return self
    }
}

public extension NSViewProtocol where Self: NSTextField {
    /// Sets the background color of the text field.
    @discardableResult
    func backgroundColor(_ color: NSUIColor?) -> Self {
        backgroundColor = color
        drawsBackground = color != nil
        return self
    }
}

extension NSView {
    @objc var backgroundColorAnimatable: NSColor? {
        get { layer?.backgroundColor?.nsColor }
        set { layer?.backgroundColor = newValue?.cgColor }
    }

    struct DynamicColors {
        var background: NSColor? {
            didSet { if background?.isDynamic == false { background = nil } }
        }

        var shadow: NSColor? {
            didSet { if shadow?.isDynamic == false { shadow = nil } }
        }

        var border: NSColor? {
            didSet { if border?.isDynamic == false { border = nil } }
        }

        var needsObserver: Bool {
            background != nil || border != nil || shadow != nil
        }
        
        mutating func color(_ keyPath: WritableKeyPath<Self, NSColor?>, cgColor: CGColor?) -> NSUIColor? {
            update(\.border, cgColor: cgColor)
            return self[keyPath: keyPath] ?? cgColor?.nsUIColor
        }

        mutating func update(_ keyPath: WritableKeyPath<Self, NSColor?>, cgColor: CGColor?) {
            guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return }
            if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                self[keyPath: keyPath] = nil
            }
        }
    }

    var dynamicColors: DynamicColors {
        get { getAssociatedValue("dynamicColors", initialValue: DynamicColors()) }
        set { setAssociatedValue(newValue, key: "dynamicColors")
            setupEffectiveAppearanceObserver()
        }
    }

    var effectiveAppearanceObservation: KeyValueObservation? {
        get { getAssociatedValue("effectiveAppearanceObservation") }
        set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
    }

    func setupEffectiveAppearanceObserver() {
        if !dynamicColors.needsObserver {
            effectiveAppearanceObservation = nil
        } else if effectiveAppearanceObservation == nil {
            effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.updateEffectiveColors()
            }
        }
    }

    func updateEffectiveColors() {
        dynamicColors.update(\.shadow, cgColor: layer?.shadowColor)
        dynamicColors.update(\.background, cgColor: layer?.backgroundColor)
        dynamicColors.update(\.border, cgColor: layer?.borderColor)
        setupEffectiveAppearanceObserver()

        if let color = dynamicColors.background?.resolvedColor(for: self).cgColor {
            layer?.backgroundColor = color
        }
        if let color = dynamicColors.shadow?.resolvedColor(for: self).cgColor {
            layer?.shadowColor = color
        }
        if let color = dynamicColors.border?.resolvedColor(for: self).cgColor {
            layer?.borderColor = color
        }
    }
}
#endif
