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
    public struct NSRectCorner: OptionSet {
        public let rawValue: UInt
        public static let topLeft = NSRectCorner(rawValue: 1 << 0)
        public static let topRight = NSRectCorner(rawValue: 1 << 1)
        public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
        public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
        public static var allCorners: NSRectCorner {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

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
    }
#endif

public extension NSUIBezierPath {
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
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
