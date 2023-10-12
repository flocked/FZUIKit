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
        get { getAssociatedValue(key: "_viewBackgroundColor", object: self, initialValue: self.layer?.backgroundColor?.nsColor) }
        set {
            Self.swizzleAnimationForKey()
            var newValue = newValue
            if newValue == nil, self.isProxy() {
                newValue = .clear
            }
            self._backgroundColor = newValue
            set(associatedValue: newValue, key: "_viewBackgroundColor", object: self)
        }
    }
}

internal extension NSView {
    @objc dynamic var _backgroundColor: NSColor? {
        get { layer?.backgroundColor?.nsColor }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
            if newValue != nil {
                if _effectiveAppearanceKVO == nil {
                    _effectiveAppearanceKVO = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                        self?.updateBackgroundColor()
                    }
                    layer?.backgroundColorObserver = layer?.observeChanges(for: \.backgroundColor)  { [weak self] _, new in
                        guard let self = self else { return }
                        if new != self.backgroundColor?.resolvedColor(for: self.effectiveAppearance).cgColor {
                            Swift.print("backgroundColor not same")
                            set(associatedValue: new?.nsColor, key: "_viewBackgroundColor", object: self)
                        }
                    }
                }
            } else {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }
    }
    
    var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
    }

    func updateBackgroundColor() {
        wantsLayer = true
        if let backgroundColor: NSColor = getAssociatedValue(key: "_viewBackgroundColor", object: self) {
            layer?.backgroundColor = backgroundColor.resolvedColor(for: effectiveAppearance).cgColor
        }
        layer?.backgroundColor = backgroundColor?.resolvedColor(for: effectiveAppearance).cgColor
    }
}

internal extension CALayer {
    var backgroundColorObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "backgroundColorObserver", object: self) }
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
