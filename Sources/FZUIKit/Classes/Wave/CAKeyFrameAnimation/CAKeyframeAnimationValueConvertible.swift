//
//  CAKeyframeAnimationValueConvertible.swift
//  
//  Copyright (c) 2020, Adam Bell
//  Modifed:
//  Florian Zand on 02.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

// MARK: - CAKeyframeAnimationValueConvertible

///  A type that can be converted to a value that can be used with `CAKeyframeAnimation` . It is required for ``CAKeyframeAnimationEmittable``.
public protocol CAKeyframeAnimationValueConvertible {
    associatedtype KeyFrameValue: AnyObject
    /// The representation of the value that can be used `CAKeyframeAnimation`.
    func toKeyframeValue() -> KeyFrameValue
}

extension Float: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSNumber {
        return self as NSNumber
    }
}

extension Double: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSNumber {
        return self as NSNumber
    }
}

extension CGFloat: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSNumber {
        return self as NSNumber
    }
}

extension CGPoint: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        #if os(macOS)
        return NSValue(point: self)
        #else
        return NSValue(cgPoint: self)
        #endif
    }
}

extension CGSize: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        #if os(macOS)
        return NSValue(size: self)
        #else
        return NSValue(cgSize: self)
        #endif
    }

}

extension CGRect: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        #if os(macOS)
        return NSValue(rect: self)
        #else
        return NSValue(cgRect: self)
        #endif
    }
}

extension CGColor: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> CGColor {
        self
    }
}

extension NSUIColor: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> CGColor {
        self.cgColor
    }
}

extension CATransform3D: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        NSValue(caTransform3D: self)
    }
}

extension CGAffineTransform: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        NSValue(cgAffineTransform: self)
    }
}

extension NSUIEdgeInsets: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        #if os(macOS)
        NSValue(edgeInsets: self)
        #else
        NSValue(uiEdgeInsets: self)
        #endif
    }
}

extension NSDirectionalEdgeInsets: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> NSValue {
        NSValue(directionalEdgeInsets: self)
    }
}

#endif
