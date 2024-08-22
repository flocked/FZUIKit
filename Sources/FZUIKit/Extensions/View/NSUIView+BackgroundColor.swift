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
            mutating get { get(\._background, view?.layer?.backgroundColor) }
            set { _background = newValue?.isDynamic == true ? newValue : nil }
        }

        var shadow: NSColor? {
            mutating get { get(\._shadow, view?.layer?.shadowColor) }
            set { _shadow = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var border: NSColor? {
            mutating get { get(\._border, view?.layer?.borderColor) }
            set { _border = newValue?.isDynamic == true ? newValue : nil }
        }
        
        var _shadow: NSColor?
        var _border: NSColor?
        var _background: NSColor?
        weak var view: NSView?
        
        mutating func update() {
            guard let view = view, let layer = view.layer else { return }
            if let shadow = shadow?.resolvedColor(for: view).cgColor {
                layer.shadowColor = shadow
            }
            if let border = border?.resolvedColor(for: view).cgColor {
                layer.borderColor = border
            }
            if let background = background?.resolvedColor(for: view).cgColor {
                layer.backgroundColor = background
            }
        }

        mutating func get(_ keyPath: WritableKeyPath<Self, NSColor?>, _ cgColor: CGColor?) -> NSColor? {
            guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return nil }
            if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                self[keyPath: keyPath] = nil
            }
            return self[keyPath: keyPath]
        }
        
        var needsObserver: Bool {
            _background != nil || _border != nil || _shadow != nil
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
        if !dynamicColors.needsObserver {
            effectiveAppearanceObservation = nil
        } else if effectiveAppearanceObservation == nil {
            effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.dynamicColors.update()
            }
        }
    }
}
#endif
