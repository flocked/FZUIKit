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

