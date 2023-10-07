//
//  SIMDRepresentable.swift
//
//
//  Created by Adam Bell on 8/1/20.
//

/*
import CoreGraphics
import Foundation
import simd
import FZSwiftUtils
import AppKit

// MARK: - Supported Types

/// A protocol that defines supported `SIMD` types that conform to `SIMDRepresentable` and `EquatableEnough`.
public protocol SupportedSIMD: SIMD, SIMDRepresentable where Scalar: SupportedScalar {}

/// A protocol that defines supported `SIMD` Scalar types that conform to `FloatingPointInitializable`, `EquatableEnough`, and are `RealModule.Real` numbers.
public protocol SupportedScalar: SIMDScalar, FloatingPointInitializable, EquatableEnough, Decodable, Encodable {

    
    // These only really exist because for some reason the Swift compiler can't infer that Float and Double methods for these exist.
    static func exp(_ x: Self) -> Self
    static func sin(_ x: Self) -> Self
    static func cos(_ x: Self) -> Self
    static func pow(_ x: Self, _ n: Int) -> Self
    static func log(_ x: Self) -> Self
    

}

extension Float: SupportedScalar {}
extension Double: SupportedScalar {}

extension SIMD2: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD3: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD4: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD8: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD16: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD32: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}
extension SIMD64: SupportedSIMD, Comparable, EquatableEnough where Scalar: SupportedScalar {}


extension SIMD2: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD2<Scalar>) -> SIMD2<Scalar> {
        simdRepresentation
    }
}
extension SIMD3: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD3<Scalar>) -> SIMD3<Scalar> {
        simdRepresentation
    }
}
extension SIMD4: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD4<Scalar>) -> SIMD4<Scalar> {
        simdRepresentation
    }
}
extension SIMD8: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD8<Scalar>) -> SIMD8<Scalar> {
        simdRepresentation
    }
}
extension SIMD16: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD16<Scalar>) -> SIMD16<Scalar> {
        simdRepresentation
    }
}
extension SIMD32: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD32<Scalar>) -> SIMD32<Scalar> {
        simdRepresentation
    }
}
extension SIMD64: SIMDRepresentable where Scalar: SupportedScalar {
    public static func valueForSIMD(_ simdRepresentation: SIMD64<Scalar>) -> SIMD64<Scalar> {
        simdRepresentation
    }
}

// MARK: - SIMDRepresentable

/// A protocol that defines how something that can be represented / stored in a `SIMD` type as well as instantiated from said `SIMD` type.
public protocol SIMDRepresentable: Comparable where Self.SIMDType == Self.SIMDType.SIMDType {

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

/// All `SIMD` types are `SIMDRepresentable` by default.
extension SIMDRepresentable where SIMDType == Self {

    @inlinable public init(_ simdRepresentation: SIMDType) {
        self = simdRepresentation
    }

    @inlinable public func simdRepresentation() -> Self {
        return self
    }

}


// These single floating point conformances technically are wasteful, but it's still a single register it gets packed in, so it's "fine".
// Actually, don't quote me, but I think the compiler is smart and optimizes these anyways.

extension Float: SIMDRepresentable {
    public typealias SIMDType = SIMD2<Float>

    @inlinable public init(_ simdRepresentation: SIMD2<Float>) {
        self = simdRepresentation[0]
    }

    @inlinable public func simdRepresentation() -> SIMD2<Float> {
        return SIMD2(self, 0.0)
    }
    
    public static func valueForSIMD(_ simdRepresentation: SIMD2<Float>) -> Float {
        simdRepresentation[0]
    }
    
    public static func exp(_ x: Self) -> Self {
        Foundation.exp(x)
    }
    public static func sin(_ x: Self) -> Self {
        Foundation.sin(x)
    }
    public static func cos(_ x: Self) -> Self {
        Foundation.cos(x)
    }
    public static func pow(_ x: Self, _ n: Int) -> Self {
        Foundation.pow(x, Self(n))
    }
    public static func log(_ x: Self) -> Self {
        Foundation.log(x)
    }

}

extension Double: SIMDRepresentable {

    public typealias SIMDType = SIMD2<Double>

    @inlinable public init(_ simdRepresentation: SIMD2<Double>) {
        self = simdRepresentation[0]
    }
    
    public static func valueForSIMD(_ simdRepresentation: SIMD2<Double>) -> Double {
        simdRepresentation[0]
    }

    @inlinable public func simdRepresentation() -> SIMD2<Double> {
        return SIMD2(self, 0.0)
    }
    
    public static func exp(_ x: Self) -> Self {
        Foundation.exp(x)
    }
    public static func sin(_ x: Self) -> Self {
        Foundation.sin(x)
    }
    public static func cos(_ x: Self) -> Self {
        Foundation.cos(x)
    }
    public static func pow(_ x: Self, _ n: Int) -> Self {
        Foundation.pow(x, Self(n))
    }
    public static func log(_ x: Self) -> Self {
        Foundation.log(x)
    }

}

// MARK: - CoreGraphics Extensions

extension CGFloat: SIMDRepresentable {

    public typealias SIMDType = SIMD2<CGFloat.NativeType>

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self = CGFloat(simdRepresentation[0])
    }

    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return SIMD2(CGFloat.NativeType(self), 0.0)
    }
    
    public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGFloat {
        CGFloat(simdRepresentation[0])
    }
    
    public static func updateValueNew(spring: Spring, value: CGRect, target: CGRect, velocity: CGRect, dt: TimeInterval) -> (value: CGRect, velocity: CGRect) {
        precondition(spring.response > 0, "Shouldn't be calculating spring physics with a frequency response of zero.")
        let value = value.simdRepresentation()
        let target = target.simdRepresentation()
        let velocity = velocity.simdRepresentation()
        let displacement = value - target
        let springForce = (-spring.stiffness * displacement)
        let dampingForce = (spring.dampingCoefficient * velocity)
        let force = springForce - dampingForce
        let acceleration = force / spring.mass

        let newVelocity = (velocity + (acceleration * dt))
        let newValue = (value + (newVelocity * dt))
        
        return (value: CGRect(newValue), velocity:CGRect(newVelocity))
    }
    
}

extension NSUIColor: SIMDRepresentable {

    
    public static var zero: Self {
        NSUIColor(red: 0, green: 0, blue: 0, alpha: 0) as! Self
    }
    
    public static func < (lhs: NSColor, rhs: NSColor) -> Bool {
        lhs.simdRepresentation() < rhs.simdRepresentation()
    }
    
    public typealias SIMDType = SIMD4<CGFloat.NativeType>

     public convenience init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(red: simdRepresentation[0], green: simdRepresentation[0], blue: simdRepresentation[0], alpha: simdRepresentation[0])
    }
 
 public func simdRepresentation() -> SIMD4<CGFloat.NativeType> {
     let rgba = self.rgbaComponents()
     return SIMD4(CGFloat.NativeType(rgba.red), CGFloat.NativeType(rgba.green), CGFloat.NativeType(rgba.blue), CGFloat.NativeType(rgba.alpha))
 }
    
    public static func valueForSIMD(_ simdRepresentation: SIMD4<CGFloat.NativeType>) -> Self {
        Self(red: simdRepresentation[0], green: simdRepresentation[0], blue: simdRepresentation[0], alpha: simdRepresentation[0])
    }

}

extension CGPoint: SIMDRepresentable {
    @inlinable public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGPoint {
        return CGPoint(x: simdRepresentation[0], y: simdRepresentation[1])
    }
    

    public typealias SIMDType = SIMD2<CGFloat.NativeType>

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(x: simdRepresentation[0], y: simdRepresentation[1])
    }

    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return SIMD2(CGFloat.NativeType(x), CGFloat.NativeType(y))
    }

    @inlinable public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }

}

extension CGSize: SIMDRepresentable {
    @inlinable public static func valueForSIMD(_ simdRepresentation: SIMD2<CGFloat.NativeType>) -> CGSize {
        CGSize(width: simdRepresentation[0], height: simdRepresentation[1])
    }
    

    public typealias SIMDType = SIMD2<CGFloat.NativeType>

    @inlinable public init(_ simdRepresentation: SIMD2<CGFloat.NativeType>) {
        self.init(width: simdRepresentation[0], height: simdRepresentation[1])
    }

    @inlinable public func simdRepresentation() -> SIMD2<CGFloat.NativeType> {
        return SIMD2(CGFloat.NativeType(width), CGFloat.NativeType(height))
    }

    @inlinable public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width < rhs.width && lhs.height < rhs.height
    }

}

extension CGRect: SIMDRepresentable {
    @inlinable public static func valueForSIMD(_ simdRepresentation: SIMD4<CGFloat.NativeType>) -> CGRect {
        CGRect(x: simdRepresentation[0], y: simdRepresentation[1], width: simdRepresentation[2], height: simdRepresentation[3])
    }
    

    public typealias SIMDType = SIMD4<CGFloat.NativeType>

    @inlinable public init(_ simdRepresentation: SIMD4<CGFloat.NativeType>) {
        self.init(x: simdRepresentation[0], y: simdRepresentation[1], width: simdRepresentation[2], height: simdRepresentation[3])
    }

    @inlinable public func simdRepresentation() -> SIMD4<Double> {
        return SIMD4(CGFloat.NativeType(origin.x), CGFloat.NativeType(origin.y), CGFloat.NativeType(size.width), CGFloat.NativeType(size.height))
    }

    @inlinable public static func < (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin < rhs.origin && lhs.size < rhs.size
    }

}
*/
