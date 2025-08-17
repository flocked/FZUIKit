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

private let accuracy: Double = 0.0001

extension CGQuaternion: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.axis == rhs.axis &&
            abs(rhs.storage.angle - lhs.storage.angle) < accuracy
    }
}

public extension simd_quatf {
    init(_ quaternion: CGQuaternion) {
        self.init(angle: Float(quaternion.angle), axis: simd_float3(quaternion.axis))
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

/// The Objective-C class for ``CGQuaternion``.
public class __CGQuaternion: NSObject, NSCopying {
    var storage: CGQuaternion
    
    public init(_ storage: CGQuaternion) {
        self.storage = storage
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __CGQuaternion(storage)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        storage == (object as? __CGQuaternion)?.storage
    }
}

extension CGQuaternion: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __CGQuaternion
    
    public func _bridgeToObjectiveC() -> __CGQuaternion {
        return __CGQuaternion(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __CGQuaternion, result: inout CGQuaternion?) {
        result = source.storage
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __CGQuaternion, result: inout CGQuaternion?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __CGQuaternion?) -> CGQuaternion {
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

#endif
