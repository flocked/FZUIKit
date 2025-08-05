//
//  MorphableShape.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

import SwiftUI

/// A shape that can be animated morphing.
public struct MorphableShape: Shape {
    fileprivate var controlPoints: VectorArray<Double>

    public var animatableData: VectorArray<Double> {
        set { self.controlPoints = newValue }
        get { return self.controlPoints }
    }
    
    public init(controlPoints: VectorArray<Double>) {
        self.controlPoints = controlPoints
    }

    fileprivate func point(x: Double, y: Double, rect: CGRect) -> CGPoint {
        CGPoint(x: Double(rect.width)*x, y: Double(rect.height)*y)
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: point(x: controlPoints[0], y: controlPoints[1], rect: rect))
            var i = 2;
            while i < controlPoints.count-1 {
                path.addLine(to:  point(x: controlPoints[i], y: controlPoints[i+1], rect: rect))
                i += 2;
            }
            path.addLine(to:  point(x: controlPoints[0], y: controlPoints[1], rect: rect))
        }
    }
}

extension Shape {
    /// Returns a morphable and animatable version of the shape.
    public func morphable(controlPoints count: Int = 100) -> MorphableShape {
        MorphableShape(controlPoints: path(in: CGRect(0, 0, 1, 1)).controlPoints(count: count))
    }
}

fileprivate extension Path {
    func point(at offset: CGFloat) -> CGPoint {
        let limitedOffset = min(max(offset, 0), 1)
        guard limitedOffset > 0 else { return cgPath.currentPoint }
        return trimmedPath(from: 0, to: limitedOffset).cgPath.currentPoint
    }

    func controlPoints(count: Int) -> VectorArray<Double> {
        var retPoints = [Double]()
        for index in 0..<count {
            let pathOffset = Double(index)/Double(count)
            let pathPoint = self.point(at: CGFloat(pathOffset))
            retPoints.append(Double(pathPoint.x))
            retPoints.append(Double(pathPoint.y))
        }
        return VectorArray(retPoints)
    }
}
