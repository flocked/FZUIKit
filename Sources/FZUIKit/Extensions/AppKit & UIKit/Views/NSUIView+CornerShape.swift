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
        get { getAssociatedValue(key: "NSView_cornerShape", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSView_cornerShape", object: self)
            if let newValue = newValue {
                if newValue != .rectangle {
                    if cornerShapeBoundsObserver == nil {
                        cornerShapeBoundsObserver = observeChanges(for: \.bounds) { [weak self] _, _ in
                            self?.updateCornerShape()
                        }
                    }
                } else {
                    cornerShapeBoundsObserver?.invalidate()
                    cornerShapeBoundsObserver = nil
                }
            } else {
                cornerShapeBoundsObserver?.invalidate()
                cornerShapeBoundsObserver = nil
            }
        }
    }

    internal var cornerShapeBoundsObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "view_cornerShapeBoundsObserver", object: self) }
        set { set(associatedValue: newValue, key: "view_cornerShapeBoundsObserver", object: self) }
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
