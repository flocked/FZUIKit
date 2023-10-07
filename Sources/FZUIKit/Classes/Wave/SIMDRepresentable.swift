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
    
    /// Initalizes with a `SIMDType`.
    init(_ simdRepresentation: SIMDType)

    /// Returns a `SIMDType` that represents `self`.
    func simdRepresentation() -> SIMDType
}

extension CGFloat: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0])
    }
     
     /// SIMD representation of the value.
     public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
         return [self, 0]
     }
 }

extension CGPoint: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1])
    }
     
     /// SIMD representation of the point.
     public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
         return [x, y]
     }
 }
 
extension CGSize: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1])
    }
    
    /// SIMD representation of the size.
    public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [width, height]
    }
}

extension CGRect: SIMDRepresentable  {
    public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3])
    }
    
    /// SIMD representation of the rect.
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        return [x, y, width, height]
    }
}

extension CGAffineTransform: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD8<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3], simdRepresentation[4], simdRepresentation[5])
    }
    
    /// SIMD representation of the transform.
    public func simdRepresentation() -> SIMD8<CGFloat.NativeType> {
        return [a, b, c, d, tx, ty, 0, 0]
    }
}

extension CATransform3D: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD16<CGFloat.NativeType>) {
        self.init(m11: simdRepresentation[0], m12: simdRepresentation[1], m13: simdRepresentation[2], m14: simdRepresentation[3], m21: simdRepresentation[4], m22: simdRepresentation[5], m23: simdRepresentation[6], m24: simdRepresentation[7], m31: simdRepresentation[8], m32: simdRepresentation[9], m33: simdRepresentation[10], m34: simdRepresentation[11], m41: simdRepresentation[12], m42: simdRepresentation[13], m43: simdRepresentation[14], m44: simdRepresentation[15])
    }
    
    /// SIMD representation of the transform.
    public func simdRepresentation() -> SIMD16<CGFloat.NativeType> {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}
