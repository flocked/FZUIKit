//
//  Interpolatable.swift
//
//
//  Created by Adam Bell on 5/17/20.
//

#if canImport(QuartzCore)

import QuartzCore
import simd

/// A type that can be linearly interpolated.
public protocol Interpolatable {
    /// The type of the fraction that will be used to linearly interpolate `Self`.
    associatedtype FractionType: FloatingPoint

    /**
     Linearly interpolates `Self` to another instance of `Self` based on a given fraction.

     - Parameters:
        - to: The end value to interpolate to.
        - fraction: The fraction to interpolate between the two values (i.e. 0% is 0.0, 100% is 1.0).

     - Returns: An interpolated instance of `Self`.
     */
    func lerp(to: Self, fraction: FractionType) -> Self
}

/**
 - TODO: I would love to collapse these into a single generic for both `Double` and `Float` using `simd_mix` but I still haven't quite figured it out yet. PRs would be awesome!
 */

// MARK: - SIMD Extensions

extension SIMD2: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    // I would really like to use simd_mix here but for some reason it doesn't support SIMD2<Scalar> as an argument :(
    public func lerp(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD3: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func lerp(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD4: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func lerp(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension simd_quatf: Interpolatable {
    public func lerp(to: Self, fraction: Float) -> simd_quatf {
        simd_slerp(self, to, fraction)
    }
}

extension simd_quatd: Interpolatable {
    public func lerp(to: Self, fraction: Double) -> Self {
        simd_slerp(self, to, fraction)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension CATransform3D.DecomposedTransform: Interpolatable {
    public func lerp(to: Self, fraction: Double) -> Self {
        CATransform3D.DecomposedTransform(storage.lerp(to: to.storage, fraction: Double(fraction)))
    }
}

extension CATransform3D: Interpolatable {
    public func lerp(to: Self, fraction: CGFloat) -> Self {
        CATransform3D(_decomposed().lerp(to: to._decomposed(), fraction: Double(fraction)).recomposed())
    }
}
#endif

extension CGQuaternion: Interpolatable {
    public func lerp(to: CGQuaternion, fraction: CGFloat) -> CGQuaternion {
        CGQuaternion(storage.lerp(to: to.storage, fraction: Double(fraction)))
    }
}

extension CGVector3: Interpolatable {
    public func lerp(to: CGVector3, fraction: CGFloat) -> CGVector3 {
        CGVector3(storage.lerp(to: to.storage, fraction: Double(fraction)))
    }
}

extension CGVector4: Interpolatable {
    public func lerp(to: CGVector4, fraction: CGFloat) -> CGVector4 {
        CGVector4(storage.lerp(to: to.storage, fraction: Double(fraction)))
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension matrix_double4x4.DecomposedTransform: Interpolatable {
    public func lerp(to: Self, fraction: Double) -> Self {
        matrix_double4x4.DecomposedTransform(translation: translation.lerp(to: to.translation, fraction: fraction),
                                             scale: scale.lerp(to: to.scale, fraction: fraction),
                                             rotation: rotation.lerp(to: to.rotation, fraction: fraction),
                                             eulerAngles: eulerAngles.lerp(to: to.eulerAngles, fraction: fraction),
                                             skew: skew.lerp(to: to.skew, fraction: fraction),
                                             perspective: perspective.lerp(to: to.perspective, fraction: fraction))
    }
}

extension matrix_double4x4: Interpolatable {
    public func lerp(to: Self, fraction: Double) -> Self {
        decomposed().lerp(to: to.decomposed(), fraction: Double(fraction)).recomposed()
    }
}

extension matrix_float4x4.DecomposedTransform: Interpolatable {
    public func lerp(to: Self, fraction: Float) -> Self {
        matrix_float4x4.DecomposedTransform(translation: translation.lerp(to: to.translation, fraction: fraction),
                                            scale: scale.lerp(to: to.scale, fraction: fraction),
                                            rotation: rotation.lerp(to: to.rotation, fraction: fraction),
                                            eulerAngles: eulerAngles.lerp(to: to.eulerAngles, fraction: fraction),
                                            skew: skew.lerp(to: to.skew, fraction: fraction),
                                            perspective: perspective.lerp(to: to.perspective, fraction: fraction))
    }
}

extension matrix_float4x4: Interpolatable {
    public func lerp(to: Self, fraction: Float) -> Self {
        decomposed().lerp(to: to.decomposed(), fraction: fraction).recomposed()
    }
}
#endif

#endif
