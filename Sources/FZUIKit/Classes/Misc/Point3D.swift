//
//  Point3D.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

import Foundation
import FZSwiftUtils

public struct Point3D: Hashable, Codable, CustomStringConvertible {
    /// The x-coordinate of the point.
    public var x: CGFloat = 0.0
    
    /// The y-coordinate of the point.
    public var y: CGFloat = 0.0
    
    /// The z-coordinate of the point.
    public var z: CGFloat = 0.0
    
    public static let zero = Point3D()
    
    /**
     Creates a point with the specified coordinates.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
        - z: The z-coordinate of the point.
     */
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a point with the specified coordinates.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
        - z: The z-coordinate of the point.
     */
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a point with the specified x- and y-coordinate.
     
     - Parameter xy: The x- and y-coordinate of the point.
     */
    public init(_ xy: CGFloat) {
        self.x = xy
        self.y = xy
    }
    
    /**
     Creates a point with the specified x- and y-coordinate.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
     */
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a point with the specified `CGPoint`.
     
     - Parameter point: The `CGPoint` point.
     */
    public init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
        point.scaledIntegralhs
    }
    
    public var description: String {
        "Point3D(x: \(x), y: \(y), z: \(z))"
    }
}
