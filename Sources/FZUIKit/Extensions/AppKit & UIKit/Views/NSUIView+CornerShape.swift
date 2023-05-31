//
//  File.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
public typealias NSUIViewCornerShape = NSViewCornerShape
public enum NSViewCornerShape: Hashable {
    case rectangle
    case roundedRect(CGFloat)
    case roundedRectRelative(CGFloat)
    case circular
    case capsule
}

#elseif canImport(UIKit)
import UIKit
public typealias NSUIViewCornerShape = UIViewCornerShape
public enum UIViewCornerShape: Hashable {
    case rectangle
    case roundedRect(CGFloat)
    case roundedRectRelative(CGFloat)
    case circular
    case capsule
}
#endif

import FZSwiftUtils

public extension NSUIView {
    var cornerShape: NSUIViewCornerShape? {
        get { getAssociatedValue(key: "_viewCornerShape", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_viewCornerShape", object: self)
            if let newValue = newValue, newValue != .rectangle {
                updateCornerShape()
                if _boundsKVO == nil {
                    _boundsKVO = observeChange(\.bounds) { [weak self] _,_, _ in
                        self?.updateCornerShape()
                    }
                }
            } else {
                _boundsKVO?.invalidate()
                _boundsKVO = nil
            }
        }
    }

    internal var _boundsKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewBoundsKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewBoundsKVO", object: self) }
    }

    #if os(macOS)
    internal func updateCornerShape() {
        wantsLayer = true
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

    #elseif canImport(UIKit)
    internal func updateCornerShape() {
        switch cornerShape {
        case let .roundedRect(radius):
            layer.cornerRadius = radius
        case let .roundedRectRelative(value):
            let value = value.clamped(max: 1.0)
            layer.cornerRadius = (bounds.size.height / 2.0) * value
        case .capsule, .circular:
            layer.cornerRadius = bounds.size.height / 2.0
        default:
            layer.cornerRadius = 0.0
        }
    }
    #endif
}
