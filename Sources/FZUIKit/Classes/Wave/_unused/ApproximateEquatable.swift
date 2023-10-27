//
//  ApproximateEquatable.swift
//
//
//  Created by Adam Bell on 8/2/20.
//  Taken from https://github.com/b3ll/Motion


#if os(macOS) || os(iOS) || os(tvOS)

import CoreGraphics
import Foundation
import SwiftUI

/// A floating-point numeric type that can be initialized with a floating-point value.
public protocol FloatingPointInitializable: FloatingPoint & ExpressibleByFloatLiteral & Comparable & Equatable {
    init(_ value: Float)
    init(_ value: Double)
}

extension Float: FloatingPointInitializable { }
extension Double: FloatingPointInitializable { }
extension CGFloat: FloatingPointInitializable { }


/// A type that can be compared for approximate value equality.
public protocol ApproximateEquatable {
    associatedtype Epsilon: FloatingPointInitializable
    /**
     A Boolean value that indicates whether `self` and the specified `other` value are approximately equal.
     
     - Parameters:
        - other: The value to compare.
        - epsilon: The margin by which both values can differ and still be considered the same value.
     */
    func isApproximatelyEqual(to: Self, epsilon: Epsilon) -> Bool
}

extension Float: ApproximateEquatable {
    public func isApproximatelyEqual(to other: Float, epsilon: Float) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension Double: ApproximateEquatable {
    public func isApproximatelyEqual(to other: Double, epsilon: Double) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension CGFloat: ApproximateEquatable {
    public func isApproximatelyEqual(to other: CGFloat, epsilon: CGFloat) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension Array: ApproximateEquatable where Element: FloatingPointInitializable {
    public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
        for i in 0..<indices.count {
            if !self[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon) {
                return false
            }
        }
        return true
    }
}

extension Set: ApproximateEquatable where Element: FloatingPointInitializable {
    public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
        let check = Array(self)
        let other = Array(other)
        
        for i in 0..<indices.count {
            if !check[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon) {
                return false
            }
        }
        return true
    }
}

extension AnimatablePair: ApproximateEquatable  where First: ApproximateEquatable, Second: ApproximateEquatable {
    public func isApproximatelyEqual(to other: AnimatablePair<First, Second>, epsilon: Double) -> Bool {
        self.first.isApproximatelyEqual(to: other.first, epsilon: First.Epsilon(epsilon)) &&  self.second.isApproximatelyEqual(to: other.second, epsilon: Second.Epsilon(epsilon))
    }
}

extension Numeric where Magnitude: FloatingPoint {
    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.
     
     - Parameters:
        - other: The value to which `self` is compared.
        - relativeTolerance: The tolerance to use in the comparison. Defaults to `.ulpOfOne.squareRoot()`.
        - norm: The norm to use for the comparison. Defaults to `\.magnitude`.
     */
    public func isApproximatelyEqual(to other: Self, relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot(), norm: (Self) -> Magnitude = \.magnitude) -> Bool {
        return isApproximatelyEqual(to: other, absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude, relativeTolerance: relativeTolerance, norm: norm)
    }
    
    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.
     
     - Parameters:
        - other: The value to which `self` is compared.
        - absoluteTolerance: The absolute tolerance to use in the comparison.
        - relativeTolerance: The relative tolerance to use in the comparison. Defaults to `0`.
        - norm: The norm to use for the comparison. Defaults to `\.magnitude`.
     */
    @inlinable @inline(__always)
    public func isApproximatelyEqual(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0
    ) -> Bool {
        self.isApproximatelyEqual(
            to: other,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            norm: \.magnitude
        )
    }
}

extension AdditiveArithmetic {
    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.
     
     - Parameters:
     - other: The value to which `self` is compared.
     - absoluteTolerance: The absolute tolerance to use in the comparison.
     - relativeTolerance: The relative tolerance to use in the comparison. Defaults to `0`.
     - norm: The norm to use for the comparison. Defaults is `\.magnitude`.
     */
    @inlinable
    public func isApproximatelyEqual<Magnitude>(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0,
        norm: (Self) -> Magnitude
    ) -> Bool where Magnitude: FloatingPoint {
        assert(
            absoluteTolerance >= 0 && absoluteTolerance.isFinite,
            "absoluteTolerance should be non-negative and finite, " +
            "but is \(absoluteTolerance)."
        )
        assert(
            relativeTolerance >= 0 && relativeTolerance <= 1,
            "relativeTolerance should be non-negative and <= 1, " +
            "but is \(relativeTolerance)."
        )
        if self == other { return true }
        let delta = norm(self - other)
        let scale = max(norm(self), norm(other))
        let bound = max(absoluteTolerance, scale*relativeTolerance)
        return delta.isFinite && delta <= bound
    }
}


/*
 extension AnimatableVector: ApproximateEquatable {
 internal func isApproximatelyEqual(toOther other: Self, epsilon: Double) -> Bool {
 self.isApproximatelyEqual(to: other, epsilon: epsilon)
 }
 }
 
 extension FloatingPointInitializable {
 @inlinable public func isApproximatelyEqual(to other: Self, epsilon: Self) -> Bool {
 isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
 }
 }
 */

/*
 extension FloatingPointInitializable {
 public func isApproximatelyEqual(to other: Self, epsilon: Self) -> Bool {
 isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
 }
 }
 */

/*
 extension FloatingPointInitializable {
 public func isApproximatelyEqual(to other: Self, epsilon: Self) -> Bool {
 isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
 }
 }
 
 extension AnimatablePair: ApproximateEquatable  where First: ApproximateEquatable, Second: ApproximateEquatable {
 public func isApproximatelyEqual(to other: AnimatablePair<First, Second>, epsilon: Double) -> Bool {
 self.first.isApproximatelyEqual(to: other.first, epsilon: First.Epsilon(epsilon)) &&  self.second.isApproximatelyEqual(to: other.second, epsilon: Second.Epsilon(epsilon))
 }
 }
 
 extension Array: ApproximateEquatable where Element: FloatingPointInitializable {
 public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
 for i in 0..<indices.count {
 if !self[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon) {
 return false
 }
 }
 return true
 }
 }
 */


/*
 extension AnimatablePair: ApproximateEquatable where First: ApproximateEquatable, First == Second {
 @inlinable public func isApproximatelyEqual(to other: Self, epsilon: Self) -> Bool {
 self.first.isApproximatelyEqual(to: other.first, epsilon: epsilon)
 }
 
 }
 */
/*
 
 public protocol ApproximateEquatable {
 associatedtype EpsilonType: ApproximateEquatable, FloatingPointInitializable
 
 /**
  Declares whether or not something else is equal to `self` within a given tolerance.
  (e.g. a floating point value that is equal to another floating point value within a given epsilon)
  */
 func isApproximatelyEqual(to: Self, ep silon: EpsilonType) -> Bool
 }
 
 extension SIMD2: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 extension SIMD3: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 extension SIMD4: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 extension SIMD8: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 extension SIMD16: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 extension SIMD32: ApproximateEquatable where Scalar: FloatingPointInitializable & ApproximateEquatable { }
 
 
 extension ApproximateEquatable where Self: SIMD, Scalar: FloatingPointInitializable {
 @inlinable public func isApproximatelyEqual(to other: Self, epsilon: Scalar) -> Bool {
 for i in 0..<indices.count {
 let equal = self[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon)
 if !equal {
 return false
 }
 }
 return true
 }
 }
 */




/*
 extension SIMDRepresentable where SIMDType: ApproximateEquatable {
 public func isApproximatelyEqual(to: Self, epsilon: SIMDType.EpsilonType) -> Bool {
 self.simdRepresentation().isApproximatelyEqual(to: to.simdRepresentation(), epsilon: epsilon)
 }
 }
 */

#endif

