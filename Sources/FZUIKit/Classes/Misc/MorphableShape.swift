//
//  MorphableShape.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

import SwiftUI

// MARK: MorphableShape

struct MorphableShape {
    var controlPoints: AnimatableVector

    var animatableData: AnimatableVector {
        set { controlPoints = newValue }
        get { controlPoints }
    }

    func point(x: Double, y: Double, rect: CGRect) -> CGPoint {
        CGPoint(x: Double(rect.width) * x, y: Double(rect.height) * y)
    }

    func path(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        path.move(to: point(x: controlPoints.values[0], y: controlPoints.values[1], rect: rect))
        var i = 2
        while i < controlPoints.values.count - 1 {
            path.addLine(to: point(x: controlPoints.values[i], y: controlPoints.values[i + 1], rect: rect))
            i += 2
        }
        return path
    }
}

extension PathShape {
    /// Returns a morphable and animatable version of the shape.
    func morphable(controlPoints count: Int = 100) -> MorphableShape {
        MorphableShape(controlPoints: path(in: CGRect(0, 0, 1, 1)).controlPoints(count: count))
    }
}

/// Return points at a given offset and create AnimatableVector for control points
extension CGPath {
    /// Returns a point at the curve.
    func point(at offset: CGFloat) -> CGPoint {
        let limitedOffset = min(max(offset, 0), 1)
        guard limitedOffset > 0 else { return currentPoint }
        return trimmedPath(from: 0, to: limitedOffset).currentPoint
    }

    /// Returns a control point along the path.
    func controlPoints(count: Int) -> AnimatableVector {
        var retPoints = [Double]()
        for index in 0 ..< count {
            let pathOffset = Double(index) / Double(count)
            let pathPoint = point(at: CGFloat(pathOffset))
            retPoints.append(Double(pathPoint.x))
            retPoints.append(Double(pathPoint.y))
        }
        return AnimatableVector(with: retPoints)
    }
}

// MARK: AnimatableVector

struct AnimatableVector: VectorArithmetic {
    var values: [Double]

    init(count: Int = 1) {
        values = [Double](repeating: 0.0, count: count)
    }

    init(with values: [Double]) {
        self.values = values
        recomputeMagnitude()
    }

    mutating func recomputeMagnitude() {
        var sum = 0.0
        for index in 0 ..< values.count {
            sum += values[index] * values[index]
        }
        magnitudeSquared = Double(sum)
    }

    // MARK: VectorArithmetic

    var magnitudeSquared: Double = 0.0

    mutating func scale(by rhs: Double) {
        for index in 0 ..< values.count {
            values[index] *= rhs
        }
        recomputeMagnitude()
    }

    // MARK: AdditiveArithmetic

    static var zero = AnimatableVector()

    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var retValues = [Double]()
        for index in 0 ..< min(lhs.values.count, rhs.values.count) {
            retValues.append(lhs.values[index] + rhs.values[index])
        }
        return AnimatableVector(with: retValues)
    }

    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var retValues = [Double]()
        for index in 0 ..< min(lhs.values.count, rhs.values.count) {
            retValues.append(lhs.values[index] - rhs.values[index])
        }
        return AnimatableVector(with: retValues)
    }
}
