//
//  NSUIView+DynamicColors.swift
//  
//
//  Created by Florian Zand on 16.07.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension NSUIView {
    struct DynamicColors {
        private var colors: [ReferenceWritableKeyPath<CALayer, CGColor?>: NSUIColor] = [:]
        private let _view: Weak<NSUIView>
        private var view: NSUIView? { _view.object }
        private var _gradientColors: [NSUIColor] = []
        
        fileprivate init(view: NSUIView) {
            self._view = Weak<NSUIView>(view)
        }
        
        var needsObserving: Bool {
            !colors.isEmpty || !_gradientColors.isEmpty
        }
        
        var background: NSUIColor? {
            mutating get { self[\.backgroundColor] }
            set { self[\.backgroundColor] = newValue }
        }
        
        var border: NSUIColor? {
            mutating get { self[\._borderColor] }
            set { self[\._borderColor] = newValue }
        }

        var shadow: NSUIColor? {
            mutating get { self[\.shadowColor] }
            set { self[\.shadowColor] = newValue }
        }
        
        var innerShadow: NSUIColor? {
            mutating get { self[\.innerShadowColor] }
            set { self[\.innerShadowColor] = newValue }
        }
        
        var gradientColors: [NSUIColor] {
            mutating get {
                guard let view = view, let layer = view.optionalLayer else {
                    _gradientColors = []
                    return _gradientColors
                }

                let layerColors = layer.gradientColors
                if layerColors.count != _gradientColors.count ||
                    zip(layerColors, _gradientColors).contains(where: {
                        let dynamic = $0.1.dynamicColors
                        return dynamic.light.cgColor != $0.0 && dynamic.dark.cgColor != $0.0
                    }) {
                    _gradientColors = []
                }
                return _gradientColors
            }
            set {
                _gradientColors = newValue
            }
        }

        subscript(keyPath: ReferenceWritableKeyPath<CALayer, CGColor?>) -> NSUIColor? {
            mutating get {
                guard let dynamics = colors[keyPath]?.dynamicColors else { return nil }
                let cgColor = view?.optionalLayer?[keyPath: keyPath]
                if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                    colors[keyPath] = nil
                }
                return colors[keyPath]
            }
            set { colors[keyPath] = newValue?.isDynamic == true ? newValue : nil }
        }
        
        subscript(resolved keyPath: ReferenceWritableKeyPath<CALayer, CGColor?>) -> NSUIColor? {
            mutating get {
                guard let view = view else { return nil }
                return self[keyPath]?.resolvedColor(for: view)
            }
        }
                
        mutating func update() {
            guard let view = view, let layer = view.optionalLayer else { return }
            colors.forEach({ layer[keyPath: $0.key] = $0.value.resolvedColor(for: view).cgColor })
            guard !_gradientColors.isEmpty else { return }
            layer.gradientColors = _gradientColors.map({ $0.resolvedColor(for: view).cgColor })
        }
    }
    
    var dynamicColors: DynamicColors {
        get { getAssociatedValue("dynamicColors", initialValue: DynamicColors(view: self)) }
        set { setAssociatedValue(newValue, key: "dynamicColors")
            #if os(macOS)
            setupEffectiveAppearanceObserver()
            #else
            setupTraitObservation()
            #endif
        }
    }

    #if os(macOS)
    var effectiveAppearanceObservation: KeyValueObservation? {
        get { getAssociatedValue("effectiveAppearanceObservation") }
        set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
    }

    func setupEffectiveAppearanceObserver() {
        if !dynamicColors.needsObserving {
            effectiveAppearanceObservation = nil
        } else if effectiveAppearanceObservation == nil {
            effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.dynamicColors.update()
            }
        }
    }
    #endif
}
#endif
