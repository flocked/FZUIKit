//
//  Perspective.swift
//
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation
import simd

/**
 3D PerspectiveAlt represented on 2D by 4 corners polygon
 */
public final class PerspectiveAlt {
    let vectors: [Vector3]
    
    init(_ quad: Quadrilateral) {
        vectors = quad.corners.map {$0.homogeneous3dvector}
    }
    
    internal lazy var basisVectorsToPointsMap = calculateBasisVectorsToPointsMap()
    internal lazy var pointsToBasisVectorsMap = basisVectorsToPointsMap.inverse
    
    internal func projection(to destination: PerspectiveAlt) -> Matrix3x3 {
        return destination.basisVectorsToPointsMap * pointsToBasisVectorsMap
    }
    
    private func calculateBasisVectorsToPointsMap() -> Matrix3x3 {
        let baseVectors = Matrix3x3(Array(vectors[Vector3.indexSlice]))
        let solution = baseVectors.inverse * vectors[Vector3.lastIndex + 1]
        let scale = Matrix3x3(diagonal: solution)
        let basisToPoints = baseVectors * scale
        return basisToPoints
    }
}

extension CGPoint {
    var homogeneous3dvector: Vector3 {
        return .init(.init(x), .init(y), 1.0)
    }
}

final class Quadrilateral {
    var corners: [CGPoint] {
        return [topLeft, topRight, bottomLeft, bottomRight]
    }
    
    private let topLeft: CGPoint
    private let topRight: CGPoint
    private let bottomLeft: CGPoint
    private let bottomRight: CGPoint
    
    init(_ topLeft: CGPoint, _ topRight: CGPoint, _ bottomLeft: CGPoint, _ bottomRight: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    convenience init(_ points: [CGPoint]) {
        self.init(points[0], points[1], points[2], points[3])
    }
    
    convenience init(_ origin: CGPoint, _ size: CGSize) {
        let stayPut = CGAffineTransform.identity
        let shiftRight = CGAffineTransform(translationX: size.width, y: 0)
        let shiftDown = CGAffineTransform(translationX: 0, y: size.height)
        let shiftRightAndDown = shiftRight.concatenating(shiftDown)
        let originToCornerTransform = [
            stayPut,
            shiftRight,
            shiftDown,
            shiftRightAndDown
        ]
        self.init(originToCornerTransform.map{origin.applying($0)})
    }
    
    convenience init(_ rect: CGRect) {
        self.init(rect.origin, rect.size)
    }
}

extension Vector3 {
    static let one = Vector3(repeating: 1.0)
    static let lastIndex = Vector3().scalarCount - 1
    static let indexSlice = 0...Vector3.lastIndex
}

typealias Scalar = Double
typealias Vector3 = SIMD3<Double>
typealias Matrix3x3 = double3x3
typealias Matrix4x4 = double4x4
