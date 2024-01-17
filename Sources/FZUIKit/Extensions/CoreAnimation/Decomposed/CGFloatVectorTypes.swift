//
//  CGFloatVectorTypes.swift
//
//
//  Created by Adam Bell on 5/18/20.
//

#if canImport(QuartzCore)

    import Foundation
    import QuartzCore
    import simd

    /**
     This whole file exists basically because SIMD doesn't support CGFloat and without this file, you'd be doing things like `transform.position.x = Double(value)` :(
     So everything here just bridges CGFloats to Doubles and uses their simd equivalents.
     Technically CGFloat can be Float or Double (32bit or 64bit) but everything is 64bit nowadays so, if it's really necessary it can be added later.
     */

    public struct CGVector3 {
        var storage: simd_double3

        public var x: CGFloat {
            get { CGFloat(storage.x) }
            set { storage.x = Double(newValue) }
        }

        public var y: CGFloat {
            get { CGFloat(storage.y) }
            set { storage.y = Double(newValue) }
        }

        public var z: CGFloat {
            get { CGFloat(storage.z) }
            set { storage.z = Double(newValue) }
        }

        public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
            self.init(simd_double3(Double(x), Double(y), Double(z)))
        }

        public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) {
            self.init(simd_double3(x, y, z))
        }

        public init(x: Float = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
            self.init(simd_double3(Double(x), Double(y), Double(z)))
        }

        public init(_ vector: simd_double3) {
            storage = vector
        }

        public init(_ vector: simd_float3) {
            self.init(simd_double3(vector))
        }
    }

extension CGVector3:  Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
    public static var zero: CGVector3 {
        CGVector3(0, 0, 0)
    }
}


    // MARK: - ExpressibleByArrayLiteral

    extension CGVector3: ExpressibleByArrayLiteral {
        public init(arrayLiteral elements: CGFloat...) {
            self.init(x: elements[0], y: elements[1], z: elements[2])
        }

        public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
            self.init(x: x, y: y, z: z)
        }
    }

    public extension simd_double3 {
        init(_ vector: CGVector3) {
            self.init(Double(vector.x), Double(vector.y), Double(vector.z))
        }
    }

    public extension simd_float3 {
        init(_ vector: CGVector3) {
            self.init(Float(vector.x), Float(vector.y), Float(vector.z))
        }
    }

    public struct CGVector4 {
        var storage: simd_double4

        var x: CGFloat {
            get { CGFloat(storage.x) }
            set { storage.x = Double(newValue) }
        }

        var y: CGFloat {
            get { CGFloat(storage.y) }
            set { storage.y = Double(newValue) }
        }

        var z: CGFloat {
            get { CGFloat(storage.z) }
            set { storage.z = Double(newValue) }
        }

        var w: CGFloat {
            get { CGFloat(storage.w) }
            set { storage.w = Double(newValue) }
        }

        public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0, w: CGFloat = 0.0) {
            self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
        }

        public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, w: Double = 0.0) {
            self.init(simd_double4(x, y, z, w))
        }

        public init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0, w: Float = 0.0) {
            self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
        }

        public init(_ vector: simd_double4) {
            storage = vector
        }

        public init(_ vector: simd_float4) {
            self.init(simd_double4(vector))
        }
    }

    // MARK: - ExpressibleByArrayLiteral

    extension CGVector4: ExpressibleByArrayLiteral {
        public init(arrayLiteral elements: CGFloat...) {
            self.init(x: elements[0], y: elements[1], z: elements[2], w: elements[3])
        }

        public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, _ w: CGFloat) {
            self.init(x: x, y: y, z: z, w: w)
        }
    }

    public extension simd_double4 {
        init(_ vector: CGVector4) {
            self.init(Double(vector.x), Double(vector.y), Double(vector.z), Double(vector.w))
        }
    }

    public extension simd_float4 {
        init(_ vector: CGVector4) {
            self.init(Float(vector.x), Float(vector.y), Float(vector.z), Float(vector.w))
        }
    }

    public struct CGQuaternion: Hashable {
        var storage: simd_quatd

        public var axis: CGVector3 {
            get { CGVector3(storage.axis) }
            set { storage = simd_quatd(angle: storage.angle, axis: normalize(simd_double3(newValue))) }
        }

        /// The angle of rotation (specified in radians).
        public var angle: CGFloat {
            get { CGFloat(storage.angle) }
            set { storage = simd_quatd(angle: Double(newValue), axis: storage.axis) }
        }

        /// The angle of rotation (specified in degree).
        public var degree: CGFloat {
            get { CGFloat(storage.angle.radiansToDegrees) }
            set { storage = simd_quatd(angle: Double(newValue.degreesToRadians), axis: storage.axis) }
        }

        /**
         Default initializer.

         - Parameter angle: The angle of rotation (specified in radians).
         - Parameter axis: The axis of rotation (this will be normalized automatically).
         */
        public init(angle: CGFloat, axis: CGVector3) {
            storage = simd_quatd(angle: Double(angle), axis: normalize(simd_double3(axis)))
        }

        /**
         Default initializer.

         - Parameter degree: The angle of rotation (specified in degree).
         - Parameter axis: The axis of rotation (this will be normalized automatically).
         */
        public init(degree: CGFloat, axis: CGVector3) {
            storage = simd_quatd(angle: Double(degree.degreesToRadians), axis: normalize(simd_double3(axis)))
        }

        public init(_ quaternion: simd_quatd) {
            storage = quaternion
        }
    }

    public extension simd_quatd {
        init(_ quaternion: CGQuaternion) {
            self.init(angle: Double(quaternion.angle), axis: simd_double3(quaternion.axis))
        }
    }

    @available(macOS, obsoleted: 14.0, message: "macOS 14 provides Hashable")
    @available(watchOS, obsoleted: 10.0, message: "watchOS 10 provides Hashable")
    @available(iOS, obsoleted: 17.0, message: "iOS 17 provides Hashable")
    @available(tvOS, obsoleted: 17.0, message: "tvOS 17 provides Hashable")
    extension simd_quatd: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(vector)
        }

        public var hashValue: Int {
            vector.hashValue
        }
    }

    public extension simd_quatf {
        init(_ quaternion: CGQuaternion) {
            self.init(angle: Float(quaternion.angle), axis: simd_float3(quaternion.axis))
        }
    }

    // MARK: - Interpolatable

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

    extension CGQuaternion: Interpolatable {
        public func lerp(to: CGQuaternion, fraction: CGFloat) -> CGQuaternion {
            CGQuaternion(storage.lerp(to: to.storage, fraction: Double(fraction)))
        }
    }

    // MARK: - Equatable

    private let accuracy: Double = 0.0001

    extension CGVector3: Equatable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
                abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
                abs(rhs.storage[2] - lhs.storage[2]) < accuracy
        }
    }

    extension CGVector4: Equatable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
                abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
                abs(rhs.storage[2] - lhs.storage[2]) < accuracy &&
                abs(rhs.storage[3] - lhs.storage[3]) < accuracy
        }
    }

    extension CGQuaternion: Equatable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.axis == rhs.axis &&
                abs(rhs.storage.angle - lhs.storage.angle) < accuracy
        }
    }

#endif
