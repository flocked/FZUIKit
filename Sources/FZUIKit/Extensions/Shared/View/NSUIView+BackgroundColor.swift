//
//  NSUIView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import FZSwiftUtils

/// A protocol for objects with background color.
public protocol BackgroundColorSettable {
    /// The background color of the object.
    var backgroundColor: NSUIColor? { get set }
}

extension NSUIView: BackgroundColorSettable { }

#if os(macOS)
public extension BackgroundColorSettable where Self: NSView {
    /// The background color of the view.
    dynamic var backgroundColor: NSColor? {
        get { self._backgroundColor }
        set {
            self.wantsLayer = true
            Self.swizzleAnimationForKey()
            var newValue = newValue?.resolvedColor(for: effectiveAppearance)
            if newValue == nil, self.isProxy() {
                newValue = .clear
            }
            if self.backgroundColor?.isVisible == true {
                self.layer?.backgroundColor = newValue?.withAlphaComponent(0.0).cgColor
            }
            self._backgroundColor = newValue
        }
    }
}

internal extension NSView {
    
    @objc dynamic var _backgroundColor: NSColor? {
        get { layer?.backgroundColor?.nsColor }
        set {
            __backgroundColor = newValue
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
    }
    
    var _shadowColor: NSUIColor? {
        get { getAssociatedValue(key: "_shadowColor", object: self, initialValue: self.layer?.shadowColor?.nsColor) }
        set { set(associatedValue: newValue, key: "_shadowColor", object: self)
            setupEffectiveAppearanceObserver()
        }
    }
    
    var _borderColor: NSUIColor? {
        get { getAssociatedValue(key: "_borderColor", object: self, initialValue: self.layer?.borderColor?.nsColor) }
        set { set(associatedValue: newValue, key: "_borderColor", object: self)
            setupEffectiveAppearanceObserver()
        }
    }
    
    var __backgroundColor: NSUIColor? {
        get { getAssociatedValue(key: "__backgroundColor", object: self, initialValue: self.layer?.backgroundColor?.nsColor) }
        set { 
            set(associatedValue: newValue, key: "__backgroundColor", object: self)
            setupEffectiveAppearanceObserver()
        }
    }
    
    var needsEffectiveAppearanceObserver: Bool {
        __backgroundColor != nil || _borderColor != nil || _shadowColor != nil
    }
    
    func setupEffectiveAppearanceObserver() {
        if needsEffectiveAppearanceObserver {
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
        if let backgroundColor = __backgroundColor?.resolvedColor(for: effectiveAppearance) {
            self.layer?.backgroundColor = backgroundColor.cgColor
        }
        
        if let borderColor = _borderColor?.resolvedColor(for: effectiveAppearance) {
            self.layer?.borderColor = borderColor.cgColor
        }
        
        if let shadowColor = _shadowColor?.resolvedColor(for: effectiveAppearance) {
            self.layer?.shadowColor = shadowColor.cgColor
        }
    }
}

internal extension CALayer {
    var backgroundColorObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "backgroundColorObserver", object: self) }
        set { set(associatedValue: newValue, key: "backgroundColorObserver", object: self) }
    }
    
    var colorObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "backgroundColorObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "backgroundColorObserver", object: self) }
    }
}
#endif

public extension NSUIView {
    /**
     Creates a view with the specified background color.
     
     - Parameters color: The background color of the view.
     - Returns: An initialized view object.
     */
    convenience init(color: NSUIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
    
    /**
     Creates a view with the specified background color and frame rectangle.
     
     - Parameters:
        - color: The background color of the view.
        - frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
     - Returns: An initialized view object.
     */
    convenience init(color: NSUIColor, frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = color
    }
}
#endif

/*
if let layer = self.layer, layer.colorObserver == nil {
    layer.colorObserver = KeyValueObserver(layer)
    layer.colorObserver?.add(\.backgroundColor, handler: { [weak self] _, color in
        guard let self = self else { return }
        if color != self.__backgroundColor?.resolvedColor(for: self.effectiveAppearance).cgColor {
            self.__backgroundColor = color?.nsColor
            self.setupEffectiveAppearanceObserver()
        }
    })
    layer.colorObserver?.add(\.borderColor, handler: { [weak self] _, color in
        guard let self = self else { return }
        if color != self._borderColor?.resolvedColor(for: self.effectiveAppearance).cgColor {
            self._borderColor = color?.nsColor
            self.setupEffectiveAppearanceObserver()
        }
    })
    layer.colorObserver?.add(\.shadowColor, handler: { [weak self] _, color in
        guard let self = self else { return }
        if color != self._shadowColor?.resolvedColor(for: self.effectiveAppearance).cgColor {
            self._shadowColor = color?.nsColor
            self.setupEffectiveAppearanceObserver()
        }
    })
}
 */
