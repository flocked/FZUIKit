//
//  CGVector4.swift
//
//
//  Created by Florian Zand on 14.02.25.
//

#if canImport(QuartzCore)
import Foundation
import FZSwiftUtils
import QuartzCore
import simd

/// A four-dimensional vector.
public struct CGVector4: Codable, Hashable, ExpressibleByArrayLiteral, Interpolatable {
    var storage: simd_double4
    
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
    
    /// The w-component of the vector.
    public var w: CGFloat {
        get { CGFloat(storage.w) }
        set { storage.w = Double(newValue) }
    }
    
    /// The m14-component of the vector.
    public var m14: CGFloat {
        get { CGFloat(storage[0]) }
        set { storage[0] = Double(newValue) }
    }

    /// The m24-component of the vector.
    public var m24: CGFloat {
        get { CGFloat(storage[1]) }
        set { storage[1] = Double(newValue) }
    }

    /// The m34-component of the vector.
    public var m34: CGFloat {
        get { CGFloat(storage[2]) }
        set { storage[2] = Double(newValue) }
    }

    /// The m44-component of the vector.
    public var m44: CGFloat {
        get { CGFloat(storage[3]) }
        set { storage[3] = Double(newValue) }
    }
    
    /**
     Creates a vector from `Double` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, w: Double = 0.0) {
        self.init(simd_double4(x, y, z, w))
    }
    
    /**
     Creates a vector from `Float` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    @_disfavoredOverload
    public init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0, w: Float = 0.0) {
        self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
    }
    
    /**
     Creates a vector from `CGFloat` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    @_disfavoredOverload
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0, w: CGFloat = 0.0) {
        self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
    }
    
    /**
     Creates a vector from a SIMD double-precision vector.

     - Parameter vector: The SIMD vector to use as the storage backing this value.
     */
    public init(_ vector: simd_double4) {
        storage = vector
    }
    
    /**
     Creates a vector from a SIMD single-precision vector.

     - Parameter vector: The SIMD vector to convert.
     */
    public init(_ vector: simd_float4) {
        self.init(simd_double4(vector))
    }
    
    public init(arrayLiteral elements: CGFloat...) {
        self.init(x: elements[safe: 0] ?? .zero, y: elements[safe: 1] ?? .zero, z: elements[safe: 2] ?? .zero, w: elements[safe: 3] ?? .zero)
    }
    
    /**
     Creates a vector from `Double` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    public init(_ x: Double, _ y: Double, _ z: Double, _ w: Double) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
    /**
     Creates a vector from `Float` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    @_disfavoredOverload
    public init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
    /**
     Creates a vector from `CGFloat` component values.

     - Parameters:
       - x: The x-component.
       - y: The y-component.
       - z: The z-component.
       - w: The w-component.
     */
    @_disfavoredOverload
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, _ w: CGFloat) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
    /**
     Creates a vector from the specified components.

     - Parameters:
       - m14: The m14-component.
       - m24: The m24-component.
       - m34: The m34-component.
       - m44: The m44-component.
     */
    public init(m14: Double = 0.0, m24: Double = 0.0, m34: Double = 0.0, m44: Double = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m44))
    }

    /**
     Creates a vector from the specified components.

     - Parameters:
       - m14: The m14-component.
       - m24: The m24-component.
       - m34: The m34-component.
       - m44: The m44-component.
     */
    @_disfavoredOverload
    public init(m14: Float = 0.0, m24: Float = 0.0, m34: Float = 0.0, m44 _: Float = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m34))
    }
    
    /**
     Creates a vector from the specified components.

     - Parameters:
       - m14: The m14-component.
       - m24: The m24-component.
       - m34: The m34-component.
       - m44: The m44-component.
     */
    @_disfavoredOverload
    public init(m14: CGFloat = 0.0, m24: CGFloat = 0.0, m34: CGFloat = 0.0, m44: CGFloat = 1.0) {
        self.init(m14, m24, m34, m44)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.storage = try .init(x: container.decode(.x), y: container.decode(.y), z: container.decode(.z), w: container.decode(.w))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage.x, forKey: .x)
        try container.encode(storage.y, forKey: .y)
        try container.encode(storage.z, forKey: .z)
        try container.encode(storage.w, forKey: .w)
    }
    
    public enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
        case w
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
        hasher.combine(w)
    }
    
    public func interpolated(to: Self, fraction: CGFloat) -> Self {
        Self(storage.interpolated(to: to.storage, fraction: Double(fraction)))
    }
    
    /// A vector whose components are all zero.
    public static let zero = Self(0, 0, 0, 0)
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
            abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
            abs(rhs.storage[2] - lhs.storage[2]) < accuracy &&
            abs(rhs.storage[3] - lhs.storage[3]) < accuracy
    }
}

private let accuracy: Double = 0.0001

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

extension CGVector4: ReferenceConvertible {
    /// The Objective-C type for the four-dimensional vector.
    public typealias ReferenceType = __CGVector4
    
    public func _bridgeToObjectiveC() -> ReferenceType {
        return __CGVector4(self)
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
            var result: CGVector4?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return CGVector4(0, 0, 0, 0)
    }
    
    public var description: String {
        ""
    }

    public var debugDescription: String {
        description
    }
}

/// The Objective-C class for ``CGVector4``.
public class __CGVector4: NSObject, NSCopying, NSCoding {
    let storage: CGVector4
    
    init(_ storage: CGVector4) {
        self.storage = storage
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(storage.storage.x, forKey: "x")
        coder.encode(storage.storage.y, forKey: "y")
        coder.encode(storage.storage.z, forKey: "z")
        coder.encode(storage.storage.w, forKey: "w")
    }
    
    public required init?(coder: NSCoder) {
        storage = .init(coder.decodeDouble(forKey: "x"), coder.decodeDouble(forKey: "y"), coder.decodeDouble(forKey: "z"), coder.decodeDouble(forKey: "w"))
    }
    
    public func copy(with _: NSZone? = nil) -> Any {
        self
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || storage == other.storage
    }
    
    override public var hash: Int {
        Hasher.hash(storage)
    }
}

#endif
