//
//  SIMDRepresentable.swift
//
//
//  Created by Adam Bell on 8/1/20.
//

import CoreGraphics
import Foundation
import simd
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public protocol SIMDRepresentable {
    /**
     The `SIMD` type that `self` can be represented by.
      - Description: i.e. `CGPoint` can be stored in `SIMD2<Double>`.
     */
    associatedtype SIMDType: SIMD
    
    /// Initializes with a `SIMDType`.
    init(_ simdRepresentation: SIMDType)

    /// Returns a `SIMDType` that represents `self`.
    func simdRepresentation() -> SIMDType
}

extension CGFloat: SIMDRepresentable {
    /// Initializes with a `SIMD2`.
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0])
    }
     
     /// `SIMD2` representation of the value.
     public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
         return [self, 0]
     }
 }

extension CGPoint: SIMDRepresentable {    
    /// Initializes with a `SIMD2`.
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1])
    }
     
     /// `SIMD2` representation of the value.
     public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
         return [x, y]
     }
 }
 
extension CGSize: SIMDRepresentable {
    /// Initializes with a `SIMD2`.
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1])
    }
    
    /// `SIMD2` representation of the value.
    public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [width, height]
    }
}

extension CGRect: SIMDRepresentable  {
    /// Initializes with a `SIMD4`.
    public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3])
    }
    
    /// `SIMD4` representation of the value.
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        return [x, y, width, height]
    }
}

extension CGAffineTransform: SIMDRepresentable {
    /// Initializes with a `SIMD8`.
    public init(_ simdRepresentation: SIMD8<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3], simdRepresentation[4], simdRepresentation[5])
    }
    
    /// `SIMD8` representation of the value.
    public func simdRepresentation() -> SIMD8<CGFloat.NativeType> {
        return [a, b, c, d, tx, ty, 0, 0]
    }
}

extension CATransform3D: SIMDRepresentable {
    /// Initializes with a `SIMD16`.
    public init(_ simdRepresentation: SIMD16<CGFloat.NativeType>) {
        self.init(m11: simdRepresentation[0], m12: simdRepresentation[1], m13: simdRepresentation[2], m14: simdRepresentation[3], m21: simdRepresentation[4], m22: simdRepresentation[5], m23: simdRepresentation[6], m24: simdRepresentation[7], m31: simdRepresentation[8], m32: simdRepresentation[9], m33: simdRepresentation[10], m34: simdRepresentation[11], m41: simdRepresentation[12], m42: simdRepresentation[13], m43: simdRepresentation[14], m44: simdRepresentation[15])
    }
    
    /// `SIMD16` representation of the value.
    public func simdRepresentation() -> SIMD16<CGFloat.NativeType> {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension NSUIColor: SIMDRepresentable {
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
}

extension SIMDRepresentable where Self: NSUIColor {
    public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(red: simdRepresentation[0], green: simdRepresentation[1], blue: simdRepresentation[2], alpha: simdRepresentation[3])
    }
}
