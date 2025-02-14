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

extension CGVector3: Interpolatable {
    public func lerp(to: CGVector3, fraction: CGFloat) -> CGVector3 {
        CGVector3(storage.lerp(to: to.storage, fraction: Double(fraction)))
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
public class __CGVector3: NSObject, NSCopying {
    let storage: CGVector3
    
    public init(_ storage: CGVector3) {
        self.storage = storage
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __CGVector3(storage)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        storage == (object as? __CGVector3)?.storage
    }
}

extension CGVector3: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __CGVector3
    
    public func _bridgeToObjectiveC() -> __CGVector3 {
        return __CGVector3(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __CGVector3, result: inout CGVector3?) {
        result = source.storage
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __CGVector3, result: inout CGVector3?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __CGVector3?) -> CGVector3 {
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
