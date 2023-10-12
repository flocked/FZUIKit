//
//  SIMDRepresentable.swift
//
//
//  Created by Adam Bell on 8/1/20.
//  Taken from https://github.com/b3ll/Motion

import CoreGraphics
import Foundation
import simd
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif


/// A protocol that defines supported `SIMD` types that conform to `SIMDRepresentable` and `EquatableEnough`.
public protocol SupportedSIMD: SIMD, SIMDRepresentable where Scalar: SupportedScalar {}

/// A protocol that defines supported `SIMD` Scalar types that conform to `FloatingPointInitializable`, `EquatableEnough`, and are `RealModule.Real` numbers.
public protocol SupportedScalar: SIMDScalar, FloatingPointInitializable, Decodable, Encodable { }

extension Float: SupportedScalar {}
extension Double: SupportedScalar {}

extension SupportedSIMD where Self:  Comparable, Scalar: SupportedScalar {
    public static func < (lhs: Self, rhs: Self) -> Bool {
            return all(lhs .< rhs)
    }
}

extension SIMD2: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD3: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD4: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD8: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD16: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD32: SupportedSIMD, Comparable where Scalar: SupportedScalar {}
extension SIMD64: SupportedSIMD, Comparable where Scalar: SupportedScalar {}


// MARK: - SIMDRepresentable

/// A protocol that defines how something that can be represented / stored in a `SIMD` type as well as instantiated from said `SIMD` type.
public protocol SIMDRepresentable: Comparable where Self.SIMDType == Self.SIMDType.SIMDType {

    /**
     The `SIMD` type that `self` can be represented by.
      - Description: i.e. `CGPoint` can be stored in `SIMD2<Double>`.
     */
    associatedtype SIMDType: SupportedSIMD = Self

    /// Initializes `self` with a `SIMDType`.
    init(_ simdRepresentation: SIMDType)

    /// Returns a `SIMDType` that represents `self`.
    func simdRepresentation() -> SIMDType

    /// A version of `self` that represents zero.
    static var zero: Self { get }

}

/// All `SIMD` types are `SIMDRepresentable` by default.
extension SIMDRepresentable where SIMDType == Self {

    @inlinable public init(_ simdRepresentation: SIMDType) {
        self = simdRepresentation
    }

    @inlinable public func simdRepresentation() -> Self {
        return self
    }

}

extension SIMD2: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD3: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD4: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD8: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD16: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD32: SIMDRepresentable where Scalar: SupportedScalar {}
extension SIMD64: SIMDRepresentable where Scalar: SupportedScalar {}

extension Float: SIMDRepresentable {
    
    @inlinable public init(_ simdRepresentation: SIMD2<Float>) {
        self = simdRepresentation[0]
    }

    /// `SIMD2` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD2<Float> {
        return [self, 0]
    }

}

extension Double: SIMDRepresentable {
    
    @inlinable public init(_ simdRepresentation: SIMD2<Double>) {
        self = simdRepresentation[0]
    }

    /// `SIMD2` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD2<Double> {
        return [self, 0]
    }

}

// MARK: - CoreGraphics Extensions

extension CGFloat: SIMDRepresentable {

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self = CGFloat(simdRepresentation[0])
    }

    /// `SIMD2` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [self, 0]
    }

}

extension CGPoint: SIMDRepresentable {

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(x: simdRepresentation[0], y: simdRepresentation[1])
    }

    /// `SIMD2` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [x, y]
    }

    @inlinable public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }

}

extension CGSize: SIMDRepresentable {

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(width: simdRepresentation[0], height: simdRepresentation[1])
    }

    /// `SIMD2` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return [width, height]
    }

    @inlinable public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width < rhs.width && lhs.height < rhs.height
    }

}

extension CGRect: SIMDRepresentable {

    @inlinable public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(x: simdRepresentation[0], y: simdRepresentation[1], width: simdRepresentation[2], height: simdRepresentation[3])
    }

    /// `SIMD4` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD4<Double> {
        return [x, y, width, height]
    }

    @inlinable public static func < (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin < rhs.origin && lhs.size < rhs.size
    }

}

extension SIMDRepresentable where Self: NSUIColor {
    /// Initializes with a `SIMD4`.
    @inlinable public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(red: simdRepresentation[0], green: simdRepresentation[1], blue: simdRepresentation[2], alpha: simdRepresentation[3])
    }
}

extension NSUIColor: SIMDRepresentable {
    /// `SIMD4` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
    @inlinable public static func < (lhs: NSUIColor, rhs: NSUIColor) -> Bool {
        return lhs.simdRepresentation() < rhs.simdRepresentation()
    }
}

extension CGAffineTransform: SIMDRepresentable {
    /// Initializes with a `SIMD8`.
    @inlinable public init(_ simdRepresentation: SIMD8<CGFloat.NativeType>) {
        self.init(simdRepresentation[0], simdRepresentation[1], simdRepresentation[2], simdRepresentation[3], simdRepresentation[4], simdRepresentation[5])
    }
    
    /// `SIMD8` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD8<CGFloat.NativeType> {
        return [a, b, c, d, tx, ty, 0, 0]
    }
    
    @inlinable public static func < (lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool {
        lhs.simdRepresentation() < rhs.simdRepresentation()
    }
}

extension CATransform3D: SIMDRepresentable {
    /// Initializes with a `SIMD16`.
    @inlinable public init(_ simdRepresentation: SIMD16<CGFloat.NativeType>) {
        self.init(m11: simdRepresentation[0], m12: simdRepresentation[1], m13: simdRepresentation[2], m14: simdRepresentation[3], m21: simdRepresentation[4], m22: simdRepresentation[5], m23: simdRepresentation[6], m24: simdRepresentation[7], m31: simdRepresentation[8], m32: simdRepresentation[9], m33: simdRepresentation[10], m34: simdRepresentation[11], m41: simdRepresentation[12], m42: simdRepresentation[13], m43: simdRepresentation[14], m44: simdRepresentation[15])
    }
    
    /// `SIMD16` representation of the value.
    @inlinable public func simdRepresentation() -> SIMD16<CGFloat.NativeType> {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
    
    @inlinable public static func < (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        lhs.simdRepresentation() < rhs.simdRepresentation()
    }
}

extension CGQuaternion: SIMDRepresentable {
    public init(_ simdRepresentation: SIMD4<Double>) {
        self.storage = .init(vector: simdRepresentation)
    }
    
    public func simdRepresentation() -> SIMD4<Double> {
        self.storage.vector
    }
    
    public static var zero: CGQuaternion {
        CGQuaternion(SIMD4<Double>.zero)
    }
    
    public static func < (lhs: CGQuaternion, rhs: CGQuaternion) -> Bool {
        lhs.storage.vector < rhs.storage.vector
    }
}

extension SIMDRepresentable where Self: CGColor {
    /// Initializes with a `SIMD4`.
    @inlinable public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(red: simdRepresentation[0], green: simdRepresentation[1], blue: simdRepresentation[2], alpha: simdRepresentation[3])
    }
}

extension CGColor: SIMDRepresentable {
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    /// `SIMD4` representation of the value.
    public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
        let rgba = self.nsUIColor?.rgbaComponents() ?? (red: 0, green: 0, blue: 0, alpha: 0)
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
    
    @inlinable public static func < (lhs: CGColor, rhs: CGColor) -> Bool {
        return lhs.simdRepresentation() < rhs.simdRepresentation()
    }
}
