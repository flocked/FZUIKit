//
//  NSUIView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSViewProtocol where Self: NSView {
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    var backgroundColor: NSColor? {
        get { dynamicColors.background ?? layer?.backgroundColor?.nsUIColor }
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

extension NSView {
    @objc var backgroundColorAnimatable: NSColor? {
        get { layer?.backgroundColor?.nsColor }
        set { layer?.backgroundColor = newValue?.cgColor }
    }

    struct DynamicColors {
        weak var view: NSView?
        var colors: [KeyPath<CALayer, CGColor?>: NSUIColor] = [:]
        
        var background: NSColor? {
            mutating get { get(\.backgroundColor) }
            set { colors[\.backgroundColor] = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var border: NSColor? {
            mutating get { get(\._borderColor) }
            set { colors[\._borderColor] = newValue?.isDynamic == true ? newValue : nil }
        }

        var shadow: NSColor? {
            mutating get { get(\.shadowColor) }
            set { colors[\.shadowColor] = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var innerShadow: NSColor? {
            mutating get { get(\.innerShadowColor) }
            set { colors[\.innerShadowColor] = newValue?.isDynamic == true ? newValue : nil }
        }

        subscript (keyPath: KeyPath<CALayer, CGColor?>) -> NSUIColor? {
            mutating get { get(keyPath) }
            set { colors[keyPath] = newValue?.isDynamic == true ? newValue : nil }
        }
        
        mutating func get(_ keyPath: KeyPath<CALayer, CGColor?>) -> NSColor? {
            guard let dynamics = colors[keyPath]?.dynamicColors else { return nil }
            let cgColor = view?.layer?[keyPath: keyPath]
            if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                colors[keyPath] = nil
            }
            return colors[keyPath]
        }
                
        mutating func update() {
            guard let view = view, let layer = view.layer else { return }
            if let shadow = shadow?.resolvedColor(for: view).cgColor {
                layer.shadowColor = shadow
            }
            if let innerShadow = innerShadow?.resolvedColor(for: view).cgColor {
                layer.innerShadowLayer?.shadowColor = innerShadow
            }
            if let border = border?.resolvedColor(for: view).cgColor {
                layer.borderColor = border
            }
            if let background = background?.resolvedColor(for: view).cgColor {
                layer.backgroundColor = background
            }
        }
    }

    var dynamicColors: DynamicColors {
        get { getAssociatedValue("dynamicColors", initialValue: DynamicColors(view: self)) }
        set { setAssociatedValue(newValue, key: "dynamicColors")
            setupEffectiveAppearanceObserver()
        }
    }

    var effectiveAppearanceObservation: KeyValueObservation? {
        get { getAssociatedValue("effectiveAppearanceObservation") }
        set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
    }

    func setupEffectiveAppearanceObserver() {
        if dynamicColors.colors.isEmpty {
            effectiveAppearanceObservation = nil
        } else if effectiveAppearanceObservation == nil {
            effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.dynamicColors.update()
            }
        }
    }
}
#endif
