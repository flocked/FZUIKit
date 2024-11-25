//
//  FractionalPoint.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

import Foundation

/// A fractional 2D point.
public struct FractionalPoint: Hashable, Codable, ExpressibleByFloatLiteral, CustomStringConvertible {
    
    /// The x-coordinate of the fractional point.
    public var x: CGFloat = 0.0
    
    /// The y-coordinate of the fractional point.
    public var y: CGFloat = 0.0
    
    /**
     Creates a fractional point with the specified x- and y-coordinates.
     
     - Parameters:
        - x: The x-coordinate of the fractional point.
        - y: The y-coordinate of the fractional point.
     */
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinates.
     
     - Parameters:
        - x: The x-coordinate of the fractional point.
        - y: The y-coordinate of the fractional point.
     */
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinate.
     
     - Parameter xy: The x- and y-coordinate of the fractional point.
     */
    public init(_ xy: CGFloat) {
        self.x = xy
        self.y = xy
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinate.
     
     - Parameter value: The x- and y-coordinate of the fractional point.
     */
    public init(floatLiteral value: Double) {
        self.x = value
        self.y = value
    }
    
    public var description: String {
        "FractionalPoint(x: \(x), y: \(y))"
    }
    
    /// A point that’s centered vertically on the left edge
    public static let left = FractionalPoint(0.0, 0.5)
    
    /// A point that’s centered.
    public static let center = FractionalPoint(0.5, 0.5)
    
    /// A point that’s centered vertically on the right edge.
    public static let right = FractionalPoint(1.0, 0.5)
    
    /// A point that’s in the bottom, left corner.
    public static let bottomLeft = FractionalPoint(0.0, 0.0)
    
    /// A point that’s centered horizontally on the bottom edge.
    public static let bottom = FractionalPoint(0.5, 0.0)
    
    /// A point that’s in the bottom, right corner.
    public static let bottomRight = FractionalPoint(1.0, 0.0)
    
    /// A point that’s in the top, left corner.
    public static let topLeft = FractionalPoint(0.0, 1.0)
    
    /// A point that’s centered horizontally on the top edge.
    public static let top = FractionalPoint(0.5, 1.0)
    
    /// A point that’s in the top, right corner.
    public static let topRight = FractionalPoint(1.0, 1.0)
    
    /// A point that’s in the bottom, left corner.
    public static let zero = FractionalPoint(0.0, 0.0)
    
    var point: CGPoint {
        .init(x, y)
    }
}

extension CGPoint {
    var fractional: FractionalPoint {
        .init(x, y)
    }
}

/// The Objective-C class for ``FractionalPoint``.
public class __FractionalPoint: NSObject, NSCopying {
    let point: FractionalPoint
    
    public init(point: FractionalPoint) {
        self.point = point
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __FractionalPoint(point: point)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        point == (object as? __FractionalPoint)?.point
    }
}

extension FractionalPoint: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __FractionalPoint
    
    public func _bridgeToObjectiveC() -> __FractionalPoint {
        return __FractionalPoint(point: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __FractionalPoint, result: inout FractionalPoint?) {
        result = source.point
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __FractionalPoint, result: inout FractionalPoint?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __FractionalPoint?) -> FractionalPoint {
        if let source = source {
            var result: FractionalPoint?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return FractionalPoint()
    }
    
    public var debugDescription: String {
        description
    }
}
