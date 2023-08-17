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
