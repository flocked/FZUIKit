//
//  CGQuaternion.swift
//  
//
//  Created by Florian Zand on 14.02.25.
//

#if canImport(QuartzCore)
import Foundation
import QuartzCore
import simd
import FZSwiftUtils

/// A quaternion that represents a three-dimensional rotation.
public struct CGQuaternion: Hashable, Codable, ExpressibleByArrayLiteral, Interpolatable {
    var storage: simd_quatd
    
    /// The axis of rotation.
    public var axis: CGVector3 {
        get { CGVector3(storage.axis) }
        set { storage = simd_quatd(angle: storage.angle, axis: normalize(simd_double3(newValue))) }
    }
    
    /// The angle of rotation, specified in radians.
    public var angle: CGFloat {
        get { CGFloat(storage.angle) }
        set { storage = simd_quatd(angle: Double(newValue), axis: storage.axis) }
    }
    
    /// The angle of rotation, specified in degrees.
    public var degree: CGFloat {
        get { CGFloat(storage.angle.radiansToDegrees) }
        set { storage = simd_quatd(angle: Double(newValue.degreesToRadians), axis: storage.axis) }
    }
    
    /**
     Creates a quaternion from a rotation angle and axis.

     - Parameters:
       - angle: The angle of rotation, specified in radians.
       - axis: The axis of rotation, which is normalized automatically.
     */
    public init(angle: CGFloat, axis: CGVector3) {
        storage = simd_quatd(angle: Double(angle), axis: normalize(simd_double3(axis)))
    }
    
    /**
     Creates a quaternion from double-precision component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    public init(x: Double, y: Double, z: Double, r: Double) {
        storage = .init(ix: x, iy: y, iz: z, r: r)
    }
    
    /**
     Creates a quaternion from single-precision component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    @_disfavoredOverload
    public init(x: Float, y: Float, z: Float, r: Float) {
        storage = .init(ix: Double(x), iy: Double(y), iz: Double(z), r: Double(r))
    }
    
    /**
     Creates a quaternion from `CGFloat` component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    @_disfavoredOverload
    public init(x: CGFloat, y: CGFloat, z: CGFloat, r: CGFloat) {
        storage = .init(ix: x, iy: y, iz: z, r: r)
    }
    
    /**
     Creates a quaternion from double-precision component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    public init(_ x: Double, _ y: Double, _ z: Double, _ r: Double) {
        self.init(x: x, y: y, z: z, r: r)
    }
    
    /**
     Creates a quaternion from single-precision component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    @_disfavoredOverload
    public init(_ x: Float, _ y: Float, _ z: Float, _ r: Float) {
        self.init(x: x, y: y, z: z, r: r)
    }
    
    /**
     Creates a quaternion from `CGFloat` component values.

     - Parameters:
       - x: The x-component of the imaginary vector.
       - y: The y-component of the imaginary vector.
       - z: The z-component of the imaginary vector.
       - r: The real component.
     */
    @_disfavoredOverload
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, _ r: CGFloat) {
        self.init(x: x, y: y, z: z, r: r)
    }
    
    public init(arrayLiteral elements: CGFloat...) {
        self.init(elements[safe: 0] ?? 0.0, elements[safe: 1] ?? 0.0, elements[safe: 2] ?? 0.0, elements[safe: 3] ?? 0.0)
    }
    
    /**
     Creates a quaternion from a rotation angle in degrees and axis.

     - Parameters:
       - degree: The angle of rotation, specified in degrees.
       - axis: The axis of rotation, which is normalized automatically.
     */
    public init(degree: CGFloat, axis: CGVector3) {
        storage = simd_quatd(angle: Double(degree.degreesToRadians), axis: normalize(simd_double3(axis)))
    }
    
    /**
     Creates a quaternion from a SIMD double-precision quaternion.

     - Parameter quaternion: The SIMD quaternion to use as storage.
     */
    public init(_ quaternion: simd_quatd) {
        storage = quaternion
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storage = try .init(angle: container.decode(.angle), axis: container.decode(.axis))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(axis, forKey: .axis)
        try container.encode(angle, forKey: .angle)
    }
    
    public enum CodingKeys: String, CodingKey {
        case axis
        case angle
    }
    
    /// A quaternion with a zero rotation angle and zero axis.
    public static let zero = Self(angle: .zero, axis: .zero)
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(angle)
        hasher.combine(axis)
    }
    
    public func interpolated(to: Self, fraction: CGFloat) -> Self {
        Self(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.axis == rhs.axis &&
            abs(rhs.storage.angle - lhs.storage.angle) < 0.0001
    }
}

public extension simd_quatd {
    init(_ quaternion: CGQuaternion) {
        self.init(angle: Double(quaternion.angle), axis: simd_double3(quaternion.axis))
    }
}

public extension simd_quatf {
    init(_ quaternion: CGQuaternion) {
        self.init(angle: Float(quaternion.angle), axis: simd_float3(quaternion.axis))
    }
}

extension CGQuaternion: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __CGQuaternion
    
    public func _bridgeToObjectiveC() -> ReferenceType {
        return __CGQuaternion(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) {
        result = source.storage
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: ReferenceType?) -> Self {
        if let source = source {
            var result: CGQuaternion?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return CGQuaternion(angle: 0, axis: .init(0, 0, 0))
    }
    
    public var description: String { "" }
    public var debugDescription: String { description }
}

/// The Objective-C class for ``CGQuaternion``.
public class __CGQuaternion: NSObject, NSCopying, NSCoding {
    var storage: CGQuaternion
    
    init(_ storage: CGQuaternion) {
        self.storage = storage
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(storage.axis, forKey: "axis")
        coder.encode(storage.storage.angle, forKey: "angle")
    }
    
    public required init?(coder: NSCoder) {
        storage = .init(angle: coder.decodeDouble(forKey: "angle"), axis: coder.decode("axis") ?? .zero)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || storage == other.storage
    }
    
    public override var hash: Int {
        Hasher.hash(storage)
    }
}


#endif
