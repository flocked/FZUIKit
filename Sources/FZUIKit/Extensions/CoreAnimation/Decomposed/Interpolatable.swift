//
//  Interpolatable.swift
//
//
//  Created by Adam Bell on 5/17/20.
//

#if canImport(QuartzCore)

import QuartzCore
import simd
import Accelerate
import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
extension CATransform3D.DecomposedTransform: Interpolatable {
    public func interpolated(to: Self, fraction: Double) -> Self {
        CATransform3D.DecomposedTransform(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
}

extension CATransform3D: FZSwiftUtils.Interpolatable {
    public func interpolated(to: Self, fraction: CGFloat) -> Self {
        CATransform3D(_decomposed().interpolated(to: to._decomposed(), fraction: Double(fraction)).recomposed())
    }
}
#endif

extension CGQuaternion: Interpolatable {
    public func interpolated(to: CGQuaternion, fraction: CGFloat) -> CGQuaternion {
        CGQuaternion(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
}

extension CGVector3: Interpolatable {
    public func interpolated(to: CGVector3, fraction: CGFloat) -> CGVector3 {
        CGVector3(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
}

extension CGVector4: Interpolatable {
    public func interpolated(to: CGVector4, fraction: CGFloat) -> CGVector4 {
        CGVector4(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension matrix_double4x4.DecomposedTransform: Interpolatable {
    public func interpolated(to: Self, fraction: Double) -> Self {
        matrix_double4x4.DecomposedTransform(translation: translation.interpolated(to: to.translation, fraction: fraction),
                                             scale: scale.interpolated(to: to.scale, fraction: fraction),
                                             rotation: rotation.interpolated(to: to.rotation, fraction: fraction),
                                             eulerAngles: eulerAngles.interpolated(to: to.eulerAngles, fraction: fraction),
                                             skew: skew.interpolated(to: to.skew, fraction: fraction),
                                             perspective: perspective.interpolated(to: to.perspective, fraction: fraction))
    }
}

extension matrix_double4x4: FZSwiftUtils.Interpolatable {
    public func interpolated(to: Self, fraction: Double) -> Self {
        decomposed().interpolated(to: to.decomposed(), fraction: Double(fraction)).recomposed()
    }
}

extension matrix_float4x4.DecomposedTransform: Interpolatable {
    public func interpolated(to: Self, fraction: Float) -> Self {
        matrix_float4x4.DecomposedTransform(translation: translation.interpolated(to: to.translation, fraction: fraction),
                                            scale: scale.interpolated(to: to.scale, fraction: fraction),
                                            rotation: rotation.interpolated(to: to.rotation, fraction: fraction),
                                            eulerAngles: eulerAngles.interpolated(to: to.eulerAngles, fraction: fraction),
                                            skew: skew.interpolated(to: to.skew, fraction: fraction),
                                            perspective: perspective.interpolated(to: to.perspective, fraction: fraction))
    }
}

extension matrix_float4x4: FZSwiftUtils.Interpolatable {
    public func interpolated(to: Self, fraction: Float) -> Self {
        decomposed().interpolated(to: to.decomposed(), fraction: fraction).recomposed()
    }
}
#endif

#endif
