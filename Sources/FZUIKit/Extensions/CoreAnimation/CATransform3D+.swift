//
//  CATransform3D+.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import FZSwiftUtils
import QuartzCore
import simd

public extension CATransform3D {
    /// Returns the identity matrix of `CATransform3D`
    static let identity = CATransform3DIdentity
    
    /// Returns a `CATransform3D` initialized with all zeros.
    static let zero = CATransform3D()
    
    /// Creates the matrix with the specified matrix.
    init(_ matrix: matrix_double4x4) {
        self = CATransform3DIdentity
        m11 = CGFloat(matrix[0][0])
        m12 = CGFloat(matrix[0][1])
        m13 = CGFloat(matrix[0][2])
        m14 = CGFloat(matrix[0][3])
        
        m21 = CGFloat(matrix[1][0])
        m22 = CGFloat(matrix[1][1])
        m23 = CGFloat(matrix[1][2])
        m24 = CGFloat(matrix[1][3])
        
        m31 = CGFloat(matrix[2][0])
        m32 = CGFloat(matrix[2][1])
        m33 = CGFloat(matrix[2][2])
        m34 = CGFloat(matrix[2][3])
        
        m41 = CGFloat(matrix[3][0])
        m42 = CGFloat(matrix[3][1])
        m43 = CGFloat(matrix[3][2])
        m44 = CGFloat(matrix[3][3])
    }
    
    /// Creates the matrix with the specified matrix.
    init(_ matrix: matrix_float4x4) {
        self.init(matrix_double4x4(matrix))
    }
    
    private var matrix: matrix_double4x4 {
        matrix_double4x4(self)
    }
    
    /// Returns the matrix decomposed into transform attributes (scale, translation, etc.).
    func decomposed() -> Decomposed {
        Decomposed(self)
    }
    
    /// The translation of the transform.
    var translation: CGVector3 {
        get { CGVector3(matrix.decomposed().translation) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.translation = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Returns a copy by translating the current transform by the given translation amount.
    func translated(by translation: CGVector3) -> Self {
        var transform = self
        transform.translate(by: translation)
        return transform
    }
    
    /**
     Returns a copy by translating the current transform by the given translation components.
     
     - Note: Omitted components have no effect on the translation.
     */
    func translatedBy(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) -> Self {
        translated(by: .init(x, y, z))
    }
    
    /**
     Returns a copy by translating the current transform by the given translation components.
     
     - Note: Omitted components have no effect on the translation.
     */
    func translated(by translation: CGPoint) -> Self {
        translated(by: .init(translation.x, translation.y, 0.0))
    }
    
    /// Translates the current transform by the given translation amount.
    mutating func translate(by translation: CGVector3) {
        self = CATransform3D(matrix.translated(by: translation.storage))
    }
    
    /// Translates the current transform by the given translation amount.
    mutating func translate(by translation: CGPoint) {
        translate(by: .init(translation.x, translation.y, 0.0))
    }
    
    /// The scale of the transform.
    var scale: CGVector3 {
        get { CGVector3(matrix.decomposed().scale) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.scale = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Scales the current transform by the given scale.
    mutating func scale(by scale: CGVector3) {
        self = CATransform3D(matrix.scaled(by: scale.storage))
    }
    
    /// Returns a copy by scaling the current transform by the given scale.
    func scaled(by scale: CGVector3) -> Self {
        var transform = self
        transform.scale(by: scale)
        return transform
    }
    
    /// Scales the current transform by the given scale.
    mutating func scale(by scale: Scale) {
        self.scale = scale.vector
    }
    
    /// Returns a copy by scaling the current transform by the given scale.
    func scaled(by scale: Scale) -> Self {
        var transform = self
        transform.scale = scale.vector
        return transform
    }
    
    /// Scales the current transform by the given scale.
    mutating func scale(by scale: CGPoint) {
        let scale = CGVector3(scale.x, scale.y, 0.0)
        self.scale(by: scale)
    }
    
    /// Returns a copy by scaling the current transform by the given scale.
    func scaled(by scale: CGPoint) -> Self {
        scaled(by: CGVector3(scale.x, scale.y, 0.0))
    }
    
    /// The rotation of the transform (expressed as a quaternion).
    var rotation: CGQuaternion {
        get { CGQuaternion(matrix.decomposed().rotation) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.rotation = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    var rotationAlt: RotationAlt {
        get { .init(quaternion: matrix.decomposed().rotation) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.rotation = newValue.quaternion
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Returns a copy by applying a rotation transform (expressed as a quaternion) to the current transform.
    func rotated(by rotation: CGQuaternion) -> Self {
        var transform = self
        transform.rotate(by: rotation)
        return transform
    }
    
    /// Rotates the current rotation by applying a rotation transform (expressed as a quaternion) to the current transform.
    mutating func rotate(by rotation: CGQuaternion) {
        self = CATransform3D(matrix.rotated(by: rotation.storage))
    }
    
    /// The rotation of the transform, expressed in radians.
    var eulerAngles: CGVector3 {
        get { CGVector3(matrix.decomposed().eulerAngles) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.eulerAngles = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Rotates the current rotation by applying a rotation transform (expressed as euler angles, expressed in radians) to the current transform.
    mutating func rotate(by eulerAngles: CGVector3) {
        self = CATransform3D(matrix.rotated(by: eulerAngles.storage))
    }
    
    /// Returns a copy by applying a rotation transform (expressed as euler angles, expressed in radians) to the current transform.
    func rotated(by eulerAngles: CGVector3) -> Self {
        CATransform3D(matrix.rotated(by: eulerAngles.storage))
    }
    
    var eulerAnglesDegrees: CGVector3 {
        get {
            let eulerAngles = eulerAngles
            return .init(eulerAngles.x.radiansToDegrees, eulerAngles.y.radiansToDegrees, eulerAngles.z.radiansToDegrees)
        }
        set { eulerAngles = .init(newValue.x.degreesToRadians, newValue.y.degreesToRadians, newValue.z.degreesToRadians) }
    }
    
    /// Rotates the current rotation by applying a rotation transform (expressed as euler angles, expressed in degrees) to the current transform.
    mutating func rotate(byDegrees eulerAngles: CGVector3) {
        self = CATransform3D(matrix.rotated(byDegrees: eulerAngles.storage))
    }
    
    /// Returns a copy by applying a rotation transform (expressed as euler angles in degrees) to the current transform.
    func rotated(byDegrees eulerAngles: CGVector3) -> Self {
        CATransform3D(matrix.rotated(byDegrees: eulerAngles.storage))
    }
    
    /// Rotates the current rotation by applying a rotation transform to the current transform.
    mutating func rotate(by rotation: Rotation) {
        eulerAngles = rotation.vector
    }
    
    /// Returns a copy by applying a rotation transform to the current transform.
    func rotated(by rotation: Rotation) -> Self {
        var transform = self
        transform.eulerAngles = rotation.vector
        return transform
    }
    
    /// The skew of the transform.
    var skew: CGVector3 {
        get { CGVector3(matrix.decomposed().skew) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.skew = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Returns a copy by skewing the current transform by a given skew.
    func skewed(by skew: CGVector3) -> Self {
        var transform = self
        transform.skew(by: skew)
        return transform
    }
    
    /**
     Returns a copy by skewing the current transform by the given skew components.
     
     - Note: Omitted components have no effect on the skew.
     */
    func skewedBy(xy: CGFloat? = nil, xz: CGFloat? = nil, yz: CGFloat? = nil) -> Self {
        skewed(by: .init(xy ?? skew.xy, xz ?? skew.xz, yz ?? skew.yz))
    }
    
    mutating func skew(by skew: CGVector3) {
        self = CATransform3D(matrix.skewed(by: skew.storage))
    }
    
    /// The perspective of the transform.
    var perspective: CGVector4 {
        get { CGVector4(matrix.decomposed().perspective) }
        set {
            var decomposed = matrix.decomposed()
            decomposed.perspective = newValue.storage
            self = CATransform3D(decomposed.recomposed())
        }
    }
    
    /// Returns a copy by changing the perspective of the current transform.
    func applyingPerspective(_ perspective: CGVector4) -> Self {
        var transform = self
        transform.applyPerspective(perspective)
        return transform
    }
    
    /**
     Returns a copy by changing the perspective of the current transform.
     
     - Note: Omitted components have no effect on the perspective.
     */
    func applyingPerspective(m14: CGFloat? = nil, m24: CGFloat? = nil, m34: CGFloat? = nil, m44: CGFloat? = nil) -> Self {
        applyingPerspective(.init(m14: m14 ?? self.m14, m24: m24 ?? self.m24, m34: m34 ?? self.m34, m44: m44 ?? self.m44))
    }
    
    /// Sets the perspective of the current transform.
    mutating func applyPerspective(_ perspective: CGVector4) {
        self = CATransform3D(matrix.applyingPerspective(perspective.storage))
    }

    /// Represents a decomposed `CATransform3D` in which the transform is broken down into its transform attributes (scale, translation, etc.).
    struct Decomposed {
        var storage: matrix_double4x4.Decomposed
        
        /// The translation of the transform.
        public var translation: CGVector3 {
            get { CGVector3(storage.translation) }
            set { storage.translation = newValue.storage }
        }
        
        /// The scale of the transform.
        public var scale: CGVector3 {
            get { CGVector3(storage.scale) }
            set { storage.scale = newValue.storage }
        }
        
        /// The rotation of the transform (exposed as a quaternion).
        public var rotation: CGQuaternion {
            get { CGQuaternion(storage.rotation) }
            set { storage.rotation = newValue.storage }
        }
        
        /// The skew of the transform.
        public var skew: CGVector3 {
            get { CGVector3(storage.skew) }
            set { storage.skew = newValue.storage }
        }
        
        /// The perspective of the transform.
        public var perspective: CGVector4 {
            get { CGVector4(storage.perspective) }
            set { storage.perspective = newValue.storage }
        }
        
        /**
         Designated initializer.
         
         - Note: You'll probably want to use `CATransform3D.decomposed()` instead.
         */
        public init(_ decomposed: CATransform3D) {
            storage = decomposed.matrix.decomposed()
        }
        
        /// Merges all the properties of the the decomposed transform into a `CATransform3D`.
        public func recomposed() -> CATransform3D {
            CATransform3D(storage.recomposed())
        }
    }
}

extension CATransform3D: Swift.Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }
}
#endif
