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
import AppKit

public protocol SupportedSIMD: SIMD { }

extension SIMD2: SupportedSIMD { }
extension SIMD3: SupportedSIMD { }
extension SIMD4: SupportedSIMD { }
extension SIMD8: SupportedSIMD { }
extension SIMD16: SupportedSIMD { }
extension SIMD32: SupportedSIMD { }
extension SIMD64: SupportedSIMD { }



public protocol SIMDRepresentable {

    /**
     The `SIMD` type that `self` can be represented by.
      - Description: i.e. `CGPoint` can be stored in `SIMD2<Double>`.
     */
    associatedtype SIMDType: SupportedSIMD = Self
    
    static func valueForSIMD(_ simdRepresentation: SIMDType) -> Self

    /// Returns a `SIMDType` that represents `self`.
    func simdRepresentation() -> SIMDType

    /// A version of `self` that represents zero.
    static var zero: Self { get }
}

extension CGFloat: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGFloat {
        return simdRepresentation[0]
    }
    
    public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [self, 0]
    }
}

extension CGPoint: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGPoint {
        return CGPoint(simdRepresentation[0], simdRepresentation[1])
    }
    
    public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [x, y]
    }
}

extension CGAffineTransform: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD8<CGFloat.NativeType>) -> CGAffineTransform {
        CGAffineTransform(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3], simdRepresentation[4], simdRepresentation[5])
    }
    
    public func simdRepresentation() -> SIMD8<CGFloat.NativeType> {
        return [a, b, c, d, tx, ty, 0, 0]
    }
}

extension CATransform3D: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD16<CGFloat.NativeType>) -> CATransform3D {
        CATransform3D(m11: simdRepresentation[0], m12: simdRepresentation[1], m13: simdRepresentation[2], m14: simdRepresentation[3], m21: simdRepresentation[4], m22: simdRepresentation[5], m23: simdRepresentation[6], m24: simdRepresentation[7], m31: simdRepresentation[8], m32: simdRepresentation[9], m33: simdRepresentation[10], m34: simdRepresentation[11], m41: simdRepresentation[12], m42: simdRepresentation[13], m43: simdRepresentation[14], m44: simdRepresentation[15])
    }
    
    public func simdRepresentation() -> SIMD16<CGFloat.NativeType> {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension CGSize: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGSize {
        return CGSize(simdRepresentation[0], simdRepresentation[1])
    }
    
    public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [width, height]
    }
}

extension CGRect: SIMDRepresentable  {
    public static func valueForSIMD(_ simdRepresentation: SIMD4<CGFloat.NativeType>) -> CGRect {
        return CGRect(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3])
    }
    
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        return [x, y, width, height]
    }
}

extension NSUIColor: SIMDRepresentable {
    public static func valueForSIMD(_ simdRepresentation: SIMD4<CGFloat.NativeType>) -> Self {
        return Self(red: simdRepresentation[0], green: simdRepresentation[1], blue: simdRepresentation[2], alpha: simdRepresentation[3])
    }
    
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
}
