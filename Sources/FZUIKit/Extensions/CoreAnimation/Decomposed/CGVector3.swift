//
//  CGVector3.swift
//  
//
//  Created by Florian Zand on 14.02.25.
//

#if canImport(QuartzCore)

import Foundation
import QuartzCore
import simd
import FZSwiftUtils

/// A three-dimensional vector.
public struct CGVector3: Codable, Hashable, ExpressibleByArrayLiteral, Interpolatable {
    var storage: simd_double3
    
    /// The x-component of the vector.
    public var x: CGFloat {
        get { CGFloat(storage.x) }
        set { storage.x = Double(newValue) }
    }
    
    /// The y-component of the vector.
    public var y: CGFloat {
        get { CGFloat(storage.y) }
        set { storage.y = Double(newValue) }
    }
    
    /// The z-component of the vector.
    public var z: CGFloat {
        get { CGFloat(storage.z) }
        set { storage.z = Double(newValue) }
    }
    
    /**
     Creates a vector from `Double` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) {
        self.init(simd_double3(x, y, z))
    }
    
    /**
     Creates a vector from `Float` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    @_disfavoredOverload
    public init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0) {
        self.init(simd_double3(Double(x), Double(y), Double(z)))
    }
    
    /**
     Creates a vector from `CGFloat` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    @_disfavoredOverload
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
        self.init(simd_double3(Double(x), Double(y), Double(z)))
    }
    
    /**
     Creates a vector from a SIMD double-precision vector.

     - Parameter vector: The SIMD vector to use as the storage backing this value.
     */
    public init(_ vector: simd_double3) {
        storage = vector
    }
    
    /**
     Creates a vector from a SIMD single-precision vector.

     - Parameter vector: The SIMD vector to convert.
     */
    public init(_ vector: simd_float3) {
        self.init(simd_double3(vector))
    }
    
    /**
     Creates a vector from `Double` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(x: x, y: y, z: z)
    }
    
    /**
     Creates a vector from `Float` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    @_disfavoredOverload
    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
    
    /**
     Creates a vector from `CGFloat` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
     */
    @_disfavoredOverload
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.init(x: x, y: y, z: z)
    }
    
    public init(arrayLiteral elements: CGFloat...) {
        self.init(x: elements[safe: 0] ?? .zero, y: elements[safe: 1] ?? .zero, z: elements[safe: 2] ?? .zero)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.storage = try .init(x: container.decode(.x), y: container.decode(.y), z: container.decode(.z))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage.x, forKey: .x)
        try container.encode(storage.y, forKey: .y)
        try container.encode(storage.z, forKey: .z)
    }
    
    public enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
    }
    
    /// A vector whose components are all zero.
    public static let zero = CGVector3(0, 0, 0)
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
    public func interpolated(to: Self, fraction: CGFloat) -> Self {
        Self(storage.interpolated(to: to.storage, fraction: Double(fraction)))
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

private let accuracy: Double = 0.0001

extension CGVector3: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
            abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
            abs(rhs.storage[2] - lhs.storage[2]) < accuracy
    }
}

/// The Objective-C class for ``CGVector3``.
public class __CGVector3: NSObject, NSCopying, NSCoding {
    let storage: CGVector3
    
    init(_ storage: CGVector3) {
        self.storage = storage
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(storage.storage.x, forKey: "x")
        coder.encode(storage.storage.y, forKey: "y")
        coder.encode(storage.storage.z, forKey: "z")
    }
    
    public required init?(coder: NSCoder) {
        storage = .init(coder.decodeDouble(forKey: "x"), coder.decodeDouble(forKey: "y"), coder.decodeDouble(forKey: "z"))
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

extension CGVector3: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __CGVector3
    
    public func _bridgeToObjectiveC() -> ReferenceType {
        return __CGVector3(self)
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
            var result: CGVector3?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return CGVector3(0, 0, 0)
    }
    
    public var description: String { "" }
    public var debugDescription: String { description }
}

extension CGVector3 {
    var scale: Scale {
        .init(x, y, z)
    }
}

extension Scale {
    var vector: CGVector3 {
        .init(x, y, z)
    }
}

extension Rotation {
    var vector: CGVector3 {
        .init(x, y, z)
    }
}

extension CGVector3 {
    var rotation: Rotation {
        .init(x, y, z)
    }
    
    var degrees: CGVector3 {
        .init(x.radiansToDegrees, y.radiansToDegrees, z.radiansToDegrees)
    }
    
    var radians: CGVector3 {
        .init(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians)
    }
}

#endif
