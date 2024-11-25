//
//  Rotation.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

#if canImport(QuartzCore)
import Foundation

/// Rotation in a three-dimensional space.
public struct Rotation: Hashable, Codable, ExpressibleByFloatLiteral, CustomStringConvertible {

    /// The rotation angle around the x-axis.
    public var x: CGFloat = .zero
    
    /// The rotation angle around the y-axis.
    public var y: CGFloat = .zero
    
    /// The rotation angle around the z-axis.
    public var z: CGFloat = .zero
    
    /// No rotation.
    public static var zero: Rotation = .init()
    
    /**
     Creates a `Rotation` with the specified rotation angles.
     
     - Parameters:
       - x: The rotation angle around the x-axis.
       - y: The rotation angle around the y-axis.
       - z: The rotation angle around the z-axis.
     */
    public init(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Rotation` with the specified rotation angles.
     
     - Parameters:
       - x: The rotation angle around the x-axis.
       - y: The rotation angle around the y-axis.
       - z: The rotation angle around the z-axis.
     */
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Rotation` with a rotation around the z-axis.
     
     - Parameter z: The rotation angle around the z-axis.
     */
    public init(_ z: CGFloat) {
        self.z = z
    }
    
    /**
     Creates a `Rotation` with a rotation around the z-axis.
     
     - Parameter value: The rotation angle around the z-axis.
     */
    public init(floatLiteral value: Double) {
        self.z = value
    }
    
    public var description: String {
        "Rotation(x: \(x), y: \(y), z: \(z))"
    }
    
    public var fractional: FractionalPoint {
        get { .init(x/90.0, y/90.0) }
        set {
            // newValue.x.interpolated(from: -90...90, to: -90...90)
            x = newValue.x.interpolated(from: 0...1, to: -90...90)
            y = newValue.y.interpolated(from: 0...1, to: -90...90)
        }
    }
    
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

/// The Objective-C class for ``Rotation``.
public class __Rotation: NSObject, NSCopying {
    let rotation: Rotation
    
    public init(rotation: Rotation) {
        self.rotation = rotation
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __Rotation(rotation: rotation)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        rotation == (object as? __Rotation)?.rotation
    }
}

extension Rotation: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __Rotation
    
    public func _bridgeToObjectiveC() -> __Rotation {
        return __Rotation(rotation: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __Rotation, result: inout Rotation?) {
        result = source.rotation
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __Rotation, result: inout Rotation?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __Rotation?) -> Rotation {
        if let source = source {
            var result: Rotation?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return Rotation()
    }
    
    public var debugDescription: String {
        description
    }
}
#endif
