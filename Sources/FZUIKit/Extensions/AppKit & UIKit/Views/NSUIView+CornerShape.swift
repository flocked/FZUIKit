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
    case rectangle
    case roundedRect(CGFloat)
    case roundedRectRelative(CGFloat)
    case circular
    case capsule
}
#elseif canImport(UIKit)
import UIKit
public enum UIViewCornerShape: Hashable {
    case rectangle
    case roundedRect(CGFloat)
    case roundedRectRelative(CGFloat)
    case circular
    case capsule
}
#endif

public extension NSUIView {
    var cornerShape: NSUIViewCornerShape? {
        get { getAssociatedValue(key: "_viewCornerShape", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_viewCornerShape", object: self)
            if let newValue = newValue {
                if newValue != .rectangle {
                    if cornerShapeBoundsKVO == nil {
                        cornerShapeBoundsKVO = observeChanges(for: \.bounds) { [weak self] _, _ in
                            self?.updateCornerShape()
                        }
                    }
                } else {
                    cornerShapeBoundsKVO?.invalidate()
                    cornerShapeBoundsKVO = nil
                }
            } else {
                cornerShapeBoundsKVO?.invalidate()
                cornerShapeBoundsKVO = nil
            }
        }
    }

    internal var cornerShapeBoundsKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "view_cornerShape_bounds_KVO", object: self) }
        set { set(associatedValue: newValue, key: "view_cornerShape_bounds_KVO", object: self) }
    }
    
    internal func updateCornerShape() {
        #if os(macOS)
        self.wantsLayer = true
        let layer = self.layer
        #elseif canImport(UIKit)
        let layer: CALayer? = self.layer
        #endif
        switch cornerShape {
        case let .roundedRect(radius):
            layer?.cornerRadius = radius
        case let .roundedRectRelative(value):
            let value = value.clamped(max: 1.0)
            layer?.cornerRadius = (bounds.size.height / 2.0) * value
        case .capsule, .circular:
            layer?.cornerRadius = bounds.size.height / 2.0
        default:
            layer?.cornerRadius = 0.0
        }
    }
}
