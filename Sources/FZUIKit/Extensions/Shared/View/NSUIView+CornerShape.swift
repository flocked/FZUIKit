//
//  NSUIView+CornerShape.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
public enum NSViewCornerShape: Hashable {
    /// A view with rounded shape.
    case rounded(CGFloat)
    /// A view with relative rounded shape.
    case roundedRelative(CGFloat)
    /// A view with circular shape.
    case circular
    /// A view with capsule shape.
    case capsule
}
#elseif canImport(UIKit)
import UIKit
public enum UIViewCornerShape: Hashable {
    /// A view with rounded shape.
    case rounded(CGFloat)
    /// A view with relative rounded shape.
    case roundedRelative(CGFloat)
    /// A view with circular shape.
    case circular
    /// A view with capsule shape.
    case capsule
}
#endif

public extension NSUIView {
    /// The corner shape of the view.
    var cornerShape: NSUIViewCornerShape? {
        get { getAssociatedValue(key: "_cornerShape", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_cornerShape", object: self)
            if newValue != nil {
                    if cornerShapeBoundsObserver == nil {
                        cornerShapeBoundsObserver = observeChanges(for: \.bounds) { [weak self] _, _ in
                            self?.updateCornerShape()
                        }
                    }
            } else {
                cornerShapeBoundsObserver?.invalidate()
                cornerShapeBoundsObserver = nil
            }
        }
    }

    internal var cornerShapeBoundsObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_cornerShapeBoundsObserver", object: self) }
        set { set(associatedValue: newValue, key: "_cornerShapeBoundsObserver", object: self) }
    }
    
    internal func updateCornerShape() {
        #if os(macOS)
        self.wantsLayer = true
        let layer = self.layer
        #elseif canImport(UIKit)
        let layer: CALayer? = self.layer
        #endif
        switch cornerShape {
        case let .rounded(radius):
            layer?.cornerRadius = radius
        case let .roundedRelative(value):
            layer?.cornerRadius = (bounds.size.height / 2.0) * value.clamped(max: 1.0)
        case .capsule:
            layer?.cornerRadius = bounds.size.height / 2.0
        case .circular:
            if bounds.size.height >= bounds.size.width {
                layer?.cornerRadius = bounds.size.height / 2.0
            } else {
                layer?.cornerRadius = bounds.size.width / 2.0
            }
        default:
            layer?.cornerRadius = 0.0
        }
    }
}
