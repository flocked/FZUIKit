//
//  CGVector4.swift
//  
//
//  Created by Florian Zand on 14.02.25.
//

#if canImport(QuartzCore)
import Foundation
import QuartzCore
import simd

/// A vector with `x`, `y`, `z` and `w` value.
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

private let accuracy: Double = 0.0001

extension CGVector4: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
            abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
            abs(rhs.storage[2] - lhs.storage[2]) < accuracy &&
            abs(rhs.storage[3] - lhs.storage[3]) < accuracy
    }
}

/// The Objective-C class for ``CGVector4``.
public class __CGVector4: NSObject, NSCopying {
    let storage: CGVector4
    
    public init(_ storage: CGVector4) {
        self.storage = storage
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __CGVector4(storage)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        storage == (object as? __CGVector4)?.storage
    }
}

extension CGVector4: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __CGVector4
    
    public func _bridgeToObjectiveC() -> __CGVector4 {
        return __CGVector4(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __CGVector4, result: inout CGVector4?) {
        result = source.storage
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __CGVector4, result: inout CGVector4?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __CGVector4?) -> CGVector4 {
        if let source = source {
            var result: CGVector4?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return CGVector4(0, 0, 0, 0)
    }
    
    public var description: String { "" }
    public var debugDescription: String { description }
}

#endif
