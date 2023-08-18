//
//  NSUIView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

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
    var backgroundColor: NSColor? {
        get { getAssociatedValue(key: "_viewBackgroundColor", object: self) }
        set {
            set(associatedValue: newValue, key: "_viewBackgroundColor", object: self)
            updateBackgroundColor()
            if newValue != nil {
                if _effectiveAppearanceKVO == nil {
                    _effectiveAppearanceKVO = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                        self?.updateBackgroundColor()
                    }
                }
            } else {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }
    }
    
    internal var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
    }

    internal func updateBackgroundColor() {
        wantsLayer = true
        layer?.backgroundColor = backgroundColor?.resolvedColor(for: effectiveAppearance).cgColor
    }
}
#endif
