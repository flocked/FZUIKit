//
//  Shape+Star.swift
//
//
//  Created by Florian Zand on 20.12.23.
//

import Foundation
import SwiftUI

public struct Star: Shape {
    /// The number of points of the star.
    public var points = 5

    /// A Boolean value that indicates whether the star is a cutout.
    public var cutout = false

    /// A Boolean value that indicates whether star is rounded.
    public var rounded = false

    func Cartesian(length: Double, angle: Double) -> CGPoint {
        return CGPoint(x: length * cos(angle),
                       y: length * sin(angle))
    }

    public func path(in rect: CGRect) -> Path {
        // centre of the containing rect
        var center = CGPoint(x: rect.width/2.0, y: rect.height/2.0)
        // Adjust center down for odd number of sides less than 8
        if points%2 == 1 && points < 8 && !rounded {
            center = CGPoint(x: center.x, y: center.y * ((Double(points) * (-0.04)) + 1.3))
        }

        // radius of a rounded that will fit in the rect
        let outerRadius = (Double(min(rect.width, rect.height)) / 2.0) * 0.9
        let innerRadius = outerRadius * 0.4
        let offsetAngle = (Double.pi / Double(points)) + Double.pi/2.0

        var vertices: [CGPoint] = []
        for i in 0..<points {
            // Calculate the angle in Radians
            let angle1 = (2.0 * Double.pi/Double(points)) * Double(i)  + offsetAngle
            let outerPoint = Cartesian(length: outerRadius, angle: angle1)
            vertices.append(CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))

            let angle2 = (2.0 * Double.pi/Double(points)) * (Double(i) + 0.5)  + offsetAngle
            let innerPoint = Cartesian(length: (innerRadius),
                                       angle: (angle2))
            vertices.append(CGPoint(x: innerPoint.x + center.x, y: innerPoint.y + center.y))
        }

        let path = Path { path in
            if cutout {
                if rounded {
                    path.addPath(Circle().path(in: rect))
                } else {
                    path.addPath(Rectangle().path(in: rect))
                }
            }
            for (n, pt) in vertices.enumerated() {
                n == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
        }
        return path
    }
}
