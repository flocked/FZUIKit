//
//  NSBezierpath+.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)
public extension NSBezierPath {
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSRectCorner, cornerRadii: CGSize) {
        self.init()
        defer { close() }

        let topLeft = rect.origin
        let topRight = NSPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY)

        if corners.contains(.topLeft) {
            move(to: CGPoint(x: topLeft.x + cornerRadii.width,
                             y: topLeft.y))
        } else {
            move(to: topLeft)
        }

        if corners.contains(.topRight) {
            line(to: CGPoint(x: topRight.x - cornerRadii.width,
                             y: topRight.y))
            curve(to: topRight,
                  controlPoint1: CGPoint(x: topRight.x,
                                         y: topRight.y + cornerRadii.height),
                  controlPoint2: CGPoint(x: topRight.x,
                                         y: topRight.y + cornerRadii.height))
        } else {
            line(to: topRight)
        }

        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: bottomRight.x,
                             y: bottomRight.y - cornerRadii.height))
            curve(to: bottomRight,
                  controlPoint1: CGPoint(x: bottomRight.x - cornerRadii.width,
                                         y: bottomRight.y),
                  controlPoint2: CGPoint(x: bottomRight.x - cornerRadii.width,
                                         y: bottomRight.y))
        } else {
            line(to: bottomRight)
        }

        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: bottomLeft.x + cornerRadii.width,
                             y: bottomLeft.y))
            curve(to: bottomLeft,
                  controlPoint1: CGPoint(x: bottomLeft.x,
                                         y: bottomLeft.y - cornerRadii.height),
                  controlPoint2: CGPoint(x: bottomLeft.x,
                                         y: bottomLeft.y - cornerRadii.height))
        } else {
            line(to: bottomLeft)
        }

        if corners.contains(.topLeft) {
            line(to: CGPoint(x: topLeft.x,
                             y: topLeft.y + cornerRadii.height))
            curve(to: topLeft,
                  controlPoint1: CGPoint(x: topLeft.x + cornerRadii.width,
                                         y: topLeft.y),
                  controlPoint2: CGPoint(x: topLeft.x + cornerRadii.width,
                                         y: topLeft.y))
        } else {
            line(to: topLeft)
        }
    }

    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadius: cornerRadius)
    }

    convenience init(cgPath: CGPath) {
        self.init()
        cgPath.applyWithBlock { elementPointer in
            let element: CGPathElement = elementPointer.pointee
            let point: CGPoint = element.points.pointee
            switch element.type {
            case .moveToPoint:
                move(to: point)
            case .addLineToPoint:
                line(to: point)
            case .addQuadCurveToPoint:
                let currentPoint: CGPoint = cgPath.currentPoint
                // TODO: - Double check `/ 3`
                let x: CGFloat = (currentPoint.x + 2 * point.x) / 3
                let y: CGFloat = (currentPoint.y + 2 * point.y) / 3
                let interpolatedPoint = CGPoint(x: x, y: y)
                let endPoint: CGPoint = element.points.successor().pointee
                curve(to: endPoint,
                      controlPoint1: interpolatedPoint,
                      controlPoint2: interpolatedPoint)
            case .addCurveToPoint:
                let midPoint: CGPoint = element.points.successor().pointee
                let endPoint: CGPoint = element.points.successor().successor().pointee
                curve(to: endPoint,
                      controlPoint1: point,
                      controlPoint2: midPoint)
            case .closeSubpath:
                close()
            @unknown default:
                break
            }
        }
    }
/**
 The Core Graphics representation of the path.

 This property contains a snapshot of the path at any given point in time. Getting this property returns an immutable path object that you can pass to Core Graphics functions. The path object itself is owned by the UIBezierPath object and is valid only until you make further modifications to the path.
 You can set the value of this property to a path you built using the functions of the Core Graphics framework. When setting a new path, this method makes a copy of the path you provide.
 */
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo:
                path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo:
                path.addCurve(
                    to: CGPoint(x: points[2].x, y: points[2].y),
                    control1: CGPoint(x: points[0].x, y: points[0].y),
                    control2: CGPoint(x: points[1].x, y: points[1].y)
                )
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }
        return path
    }
    
    /**
    Returns a new Bézier path object with a rounded rectangular path.

     - Parameters rect: The rectangle that defines the basic shape of the path.
     - Parameters cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     - Returns: A new path object with the rounded rectangular path.
    */
    static func superellipse(in rect: CGRect, cornerRadius: Double) -> Self {
        let minSide = min(rect.width, rect.height)
        let radius = min(cornerRadius, minSide / 2)

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

        // Top side (clockwise)
        let point1 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX - radius, y: rect.minY)

        // Right side (clockwise)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let point4 = CGPoint(x: rect.maxX, y: rect.maxY - radius)

        // Bottom side (clockwise)
        let point5 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let point6 = CGPoint(x: rect.minX + radius, y: rect.maxY)

        // Left side (clockwise)
        let point7 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        let point8 = CGPoint(x: rect.minX, y: rect.minY + radius)

        let path = self.init()
        path.move(to: point1)
        path.line(to: point2)
        path.curve(to: point3, controlPoint1: topRight, controlPoint2: topRight)
        path.line(to: point4)
        path.curve(to: point5, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.line(to: point6)
        path.curve(to: point7, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.line(to: point8)
        path.curve(to: point1, controlPoint1: topLeft, controlPoint2: topLeft)
        return path
    }

    /**
    Returns a new Bézier path object with a squircle rectangular path.

     - Parameters rect: The rectangle that defines the basic shape of the path.
     - Returns: A new path object with the squircle rectangular path.
    */
    static func squircle(rect: CGRect) -> Self {
        assert(rect.width == rect.height)
        return superellipse(in: rect, cornerRadius: rect.width / 2)
    }
}
#endif

public extension NSUIBezierPath {
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }

    func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> AffineTransform {
        var transform = AffineTransform()
        transform.translate(x: point.x, y: point.y)
        transform.rotate(byRadians: radians)
        transform.translate(x: -point.x, y: -point.y)
        return transform
    }

    func rotating(byRadians radians: Double, centerPoint point: CGPoint) -> Self {
        let path = self.copy() as! Self

        guard radians != 0 else {
            return path
        }

        let transform = rotationTransform(byRadians: radians, centerPoint: point)
        path.transform(using: transform)
        return path
    }
}

public extension NSUIRectCorner {
    init(_ cornerMask: CACornerMask) {
        var corner = NSUIRectCorner()
        if cornerMask.contains(.bottomLeft) {
            corner.insert(.bottomLeft)
        }
        if cornerMask.contains(.bottomRight) {
            corner.insert(.bottomRight)
        }
        if cornerMask.contains(.topLeft) {
            corner.insert(.topLeft)
        }
        if cornerMask.contains(.topRight) {
            corner.insert(.topRight)
        }
        self.init(rawValue: corner.rawValue)
    }

    var caCornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        if contains(.bottomLeft) {
            cornerMask.insert(.bottomLeft)
        }
        if contains(.bottomRight) {
            cornerMask.insert(.bottomRight)
        }
        if contains(.topLeft) {
            cornerMask.insert(.topLeft)
        }
        if contains(.topRight) {
            cornerMask.insert(.topRight)
        }
        return cornerMask
    }
}

#if os(macOS)
public extension NSBezierPath {
    static func contactShadow(rect: CGRect, shadowSize: CGFloat = 20, shadowDistance: CGFloat = 0) -> NSBezierPath {
        let contactRect = CGRect(x: -shadowSize, y: (rect.height - (shadowSize * 0.4)) + shadowDistance, width: rect.width + shadowSize * 2, height: shadowSize)
        return NSBezierPath(ovalIn: contactRect)
    }

    static func depthShadow(rect: CGRect, shadowWidth: CGFloat = 1.2, shadowHeight: CGFloat = 0.5, shadowRadius: CGFloat = 5, shadowOffsetX: CGFloat = 0) -> NSBezierPath {
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: shadowRadius / 2, y: rect.height - shadowRadius / 2))
        shadowPath.line(to: CGPoint(x: rect.width, y: rect.height - shadowRadius / 2))
        shadowPath.line(to: CGPoint(x: rect.width * shadowWidth + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        shadowPath.line(to: CGPoint(x: rect.width * -(shadowWidth - 1) + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        return shadowPath
    }

    static func flatShadow(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.line(to: CGPoint(x: rect.width, y: rect.height))

        // make the bottom of the shadow finish a long way away, and pushed by our X offset
        shadowPath.line(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.line(to: CGPoint(x: shadowOffsetX, y: 2000))
        return shadowPath
    }

    static func flatShadowBehind(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.line(to: CGPoint(x: rect.width, y: 0))
        shadowPath.line(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.line(to: CGPoint(x: shadowOffsetX, y: 2000))
        return shadowPath
    }
}
#endif
