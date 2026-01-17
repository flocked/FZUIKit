//
//  CGPath+.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

#if canImport(CoreGraphics)
import CoreGraphics
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

//     convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat, cornerCurve: CornerCurve) {


extension CFType where Self == CGPath {
    public init(roundedRect rect: NSRect, cornerRadius: CGFloat, cornerCurve: CGPath.CornerCurve) {
        self = .init(roundedRect: rect, cornerRadius: (cornerRadius, cornerRadius, cornerRadius, cornerRadius), cornerCurve: cornerCurve)
    }
    
    /**
     Creates and returns a new path object with a rectangular path rounded at the specified corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
        - cornerCurve: The curve of the corners.

     - Returns: A new path object with the rounded rectangular path.
     */
    public init(roundedRect rect: NSRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat, cornerCurve: CGPath.CornerCurve = .circular) {
        self = .init(roundedRect: rect, cornerRadius: (corners.contains(.topLeft) ? cornerRadius : 0, corners.contains(.topRight) ? cornerRadius : 0, corners.contains(.bottomLeft) ? cornerRadius : 0, corners.contains(.bottomRight) ? cornerRadius : 0 ), cornerCurve: cornerCurve)
    }
    
    public init(roundedRect rect: NSRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat), cornerCurve: CGPath.CornerCurve = .circular) {
        if cornerCurve == .circular {
            self = CGPath.circularRoundedRect(rect, cornerRadius: cornerRadius)
        } else {
            self = CGPath.continuousRoundedRect(rect, cornerRadius: cornerRadius)
        }
    }
}

fileprivate extension CGPath {
    static func circularRoundedRect(_ rect: NSRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)) -> CGPath {
        let maxCorner = min(rect.width, rect.height) / 2
        
        let radiusTopLeft = min(maxCorner, max(0, cornerRadius.topLeft))
        let radiusTopRight = min(maxCorner, max(0, cornerRadius.topRight))
        let radiusBottomLeft = min(maxCorner, max(0, cornerRadius.bottomLeft))
        let radiusBottomRight = min(maxCorner, max(0, cornerRadius.bottomRight))
        
        guard !rect.isEmpty else { return CGMutablePath() }
        
        let path = CGMutablePath()
        
        // Define corner points
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
        
        // Start at top center
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        // Top-left corner
        if radiusTopLeft > 0 {
            path.addArc(tangent1End: topLeft, tangent2End: rect.origin, radius: radiusTopLeft)
        } else {
            path.addLine(to: topLeft)
            path.addLine(to: rect.origin)
        }
        
        // Bottom-left corner
        if radiusBottomLeft > 0 {
            path.addArc(tangent1End: rect.origin, tangent2End: bottomRight, radius: radiusBottomLeft)
        } else {
            path.addLine(to: bottomLeft)
            path.addLine(to: bottomRight)
        }
        
        // Bottom-right corner
        if radiusBottomRight > 0 {
            path.addArc(tangent1End: bottomRight, tangent2End: topRight, radius: radiusBottomRight)
        } else {
            path.addLine(to: bottomRight)
            path.addLine(to: topRight)
        }
        
        // Top-right corner
        if radiusTopRight > 0 {
            path.addArc(tangent1End: topRight, tangent2End: topLeft, radius: radiusTopRight)
        } else {
            path.addLine(to: topRight)
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        
        return path
    }
    
    static func continuousRoundedRect(_ rect: CGRect, cornerRadius: CGFloat) ->CGPath {
        .continuousRoundedRect(rect, cornerRadius: (cornerRadius, cornerRadius, cornerRadius, cornerRadius))
    }
    
    static func continuousRoundedRect(_ rect: CGRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)) -> CGPath {
        let cornerRadius = minimumCornerRadius(for: rect, cornerRadius: cornerRadius)

        let coefficients: [CGFloat] = [0.04641, 0.08715, 0.13357, 0.16296, 0.21505, 0.290086, 0.32461, 0.37801, 0.44576, 0.6074, 0.77037]
        let path = CGMutablePath()

        let topRightP1 = CGPoint(x: rect.width - cornerRadius.topRight * ellipseCoefficient, y: rect.origin.y)
        let topRightP1CP1 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[8], y: topRightP1.y)
        let topRightP1CP2 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[9], y: topRightP1.y + cornerRadius.topRight * coefficients[0])

        let topRightP2 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[10], y: topRightP1.y + cornerRadius.topRight * coefficients[2])
        let topRightP2CP1 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[3], y: topRightP2.y + cornerRadius.topRight * coefficients[1])
        let topRightP2CP2 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[5], y: topRightP2.y + cornerRadius.topRight * coefficients[4])

        let topRightP3 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[7], y: topRightP2.y + cornerRadius.topRight * coefficients[7])
        let topRightP3CP1 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[1], y: topRightP3.y + cornerRadius.topRight * coefficients[3])
        let topRightP3CP2 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[2], y: topRightP3.y + cornerRadius.topRight * coefficients[6])

        let topRightP4 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[2], y: topRightP3.y + cornerRadius.topRight * coefficients[10])

        let bottomRightP1 = CGPoint(x: rect.width, y: rect.height - cornerRadius.bottomRight * ellipseCoefficient)
        let bottomRightP1CP1 = CGPoint(x: bottomRightP1.x, y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[8])
        let bottomRightP1CP2 = CGPoint(x: bottomRightP1.x - cornerRadius.bottomRight * coefficients[0], y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[9])

        let bottomRightP2 = CGPoint(x: bottomRightP1.x - cornerRadius.bottomRight * coefficients[2], y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[10])
        let bottomRightP2CP1 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[1], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[3])
        let bottomRightP2CP2 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[4], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[5])

        let bottomRightP3 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[7], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[7])
        let bottomRightP3CP1 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[3], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[1])
        let bottomRightP3CP2 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[6], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[2])

        let bottomRightP4 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[10], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[2])

        let bottomLeftP1 = CGPoint(x: rect.origin.x + cornerRadius.bottomLeft * ellipseCoefficient, y: rect.height)
        let bottomLeftP1CP1 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[8], y: bottomLeftP1.y)
        let bottomLeftP1CP2 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[9], y: bottomLeftP1.y - cornerRadius.bottomLeft * coefficients[0])

        let bottomLeftP2 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[10], y: bottomLeftP1.y - cornerRadius.bottomLeft * coefficients[2])
        let bottomLeftP2CP1 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[3], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[1])
        let bottomLeftP2CP2 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[5], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[4])

        let bottomLeftP3 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[7], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[7])
        let bottomLeftP3CP1 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[1], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[3])
        let bottomLeftP3CP2 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[2], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[6])

        let bottomLeftP4 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[2], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[10])

        let topLeftP1 = CGPoint(x: rect.origin.x, y: rect.origin.y + cornerRadius.topLeft * ellipseCoefficient)
        let topLeftP1CP1 = CGPoint(x: topLeftP1.x, y: topLeftP1.y - cornerRadius.topLeft * coefficients[8])
        let topLeftP1CP2 = CGPoint(x: topLeftP1.x + cornerRadius.topLeft * coefficients[0], y: topLeftP1.y - cornerRadius.topLeft * coefficients[9])

        let topLeftP2 = CGPoint(x: topLeftP1.x + cornerRadius.topLeft * coefficients[2], y: topLeftP1.y - cornerRadius.topLeft * coefficients[10])
        let topLeftP2CP1 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[1], y: topLeftP2.y - cornerRadius.topLeft * coefficients[3])
        let topLeftP2CP2 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[4], y: topLeftP2.y - cornerRadius.topLeft * coefficients[5])

        let topLeftP3 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[7], y: topLeftP2.y - cornerRadius.topLeft * coefficients[7])
        let topLeftP3CP1 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[3], y: topLeftP3.y - cornerRadius.topLeft * coefficients[1])
        let topLeftP3CP2 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[6], y: topLeftP3.y - cornerRadius.topLeft * coefficients[2])

        let topLeftP4 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[10], y: topLeftP3.y - cornerRadius.topLeft * coefficients[2])

        path.move(to: CGPoint(x: rect.origin.x + cornerRadius.topLeft * ellipseCoefficient, y: rect.origin.y))

        // Top right
        path.addLine(to: topRightP1)
        path.addCurve(to: topRightP2, control1: topRightP1CP1, control2: topRightP1CP2)
        path.addCurve(to: topRightP2, control1: topRightP1CP1, control2: topRightP1CP2)
        path.addCurve(to: topRightP3, control1: topRightP2CP1, control2: topRightP2CP2)
        path.addCurve(to: topRightP4, control1: topRightP3CP1, control2: topRightP3CP2)

        // Bottom right
        path.addLine(to: bottomRightP1)
        path.addCurve(to: bottomRightP2, control1: bottomRightP1CP1, control2: bottomRightP1CP2)
        path.addCurve(to: bottomRightP3, control1: bottomRightP2CP1, control2: bottomRightP2CP2)
        path.addCurve(to: bottomRightP4, control1: bottomRightP3CP1, control2: bottomRightP3CP2)

        // Bottom left
        path.addLine(to: bottomLeftP1)
        path.addCurve(to: bottomLeftP2, control1: bottomLeftP1CP1, control2: bottomLeftP1CP2)
        path.addCurve(to: bottomLeftP3, control1: bottomLeftP2CP1, control2: bottomLeftP2CP2)
        path.addCurve(to: bottomLeftP4, control1: bottomLeftP3CP1, control2: bottomLeftP3CP2)

        // Top Left
        path.addLine(to: topLeftP1)
        path.addCurve(to: topLeftP2, control1: topLeftP1CP1, control2: topLeftP1CP2)
        path.addCurve(to: topLeftP3, control1: topLeftP2CP1, control2: topLeftP2CP2)
        path.addCurve(to: topLeftP4, control1: topLeftP3CP1, control2: topLeftP3CP2)

        path.closeSubpath()

        return path
    }

    static func minimumCornerRadius(for rect: CGRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)) -> (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let calculateMinimumRadius: (CGFloat, CGFloat, CGFloat) -> CGFloat = { width, height, radius in
            let minSide = min(width, height)
            let minRadius = min(radius * ellipseCoefficient, minSide)
            return minRadius / ellipseCoefficient
        }

        let w = rect.width
        let h = rect.height

        let minimumTopRight = calculateMinimumRadius(w, h, cornerRadius.topRight)
        let minimumBottomRight = calculateMinimumRadius(w, h - (minimumTopRight * ellipseCoefficient), cornerRadius.bottomRight)
        let minimumBottomLeft = calculateMinimumRadius(w - (minimumBottomRight * ellipseCoefficient), h, cornerRadius.bottomLeft)
        let minimumTopLeft = calculateMinimumRadius(w - (minimumTopRight * ellipseCoefficient), h - (minimumBottomLeft * ellipseCoefficient), cornerRadius.topLeft)

        return (minimumTopLeft, minimumTopRight, minimumBottomLeft, minimumBottomRight)
    }
    
    static let ellipseCoefficient: CGFloat = 1.28195
}

extension CGPath {
    /// The shape of a corner.
    public enum CornerCurve: Int {
        /// Quarter-circle rounded.
        case circular
        /// Continuous curvature rounded.
        case continuous
    }
}

extension CGPath {
    /// The `BezierPath` representation of the path.
    public var bezierPath: NSUIBezierPath {
        NSUIBezierPath(cgPath: self)
    }
    
    public func trimmedPath(from start: CGFloat, to end: CGFloat) -> CGPath {
        let mutablePath = CGMutablePath()
        let length = length()
        let trimStart = start * length
        let trimEnd = end * length
        var currentLength: CGFloat = 0

        applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                mutablePath.move(to: points[0])
            case .addLineToPoint:
                let segmentLength = points[0].distance(to: mutablePath.currentPoint)
                if currentLength + segmentLength > trimStart {
                    let startPoint = mutablePath.currentPoint.interpolate(to: points[0], by: (trimStart - currentLength) / segmentLength)
                    let endPoint = mutablePath.currentPoint.interpolate(to: points[0], by: (trimEnd - currentLength) / segmentLength)
                    mutablePath.move(to: startPoint)
                    mutablePath.addLine(to: endPoint)
                }
                currentLength += segmentLength
            default:
                break
            }
        }
        return mutablePath
    }

    private func length() -> CGFloat {
        var length: CGFloat = 0
        self.applyWithBlock { element in
            let points = element.pointee.points
            if element.pointee.type == .addLineToPoint {
                length += points[0].distance(to: currentPoint)
            }
        }
        return length
    }
    
    var reversed: CGPath {
        #if os(macOS)
        NSUIBezierPath(cgPath: self).reversed.cgPath
        #else
        NSUIBezierPath(cgPath: self).reversing().cgPath
        #endif
    }
}

fileprivate extension CGPoint {
    func interpolate(to: CGPoint, by amount: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + (to.x - self.x) * amount, y: self.y + (to.y - self.y) * amount)
    }

    func distance(to: CGPoint) -> CGFloat {
        return hypot(to.x - self.x, to.y - self.y)
    }
    
    static func minimumCornerRadius(for rect: CGRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)) -> (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let calculateMinimumRadius: (CGFloat, CGFloat, CGFloat) -> CGFloat = { width, height, radius in
            let minSide = min(width, height)
            let minRadius = min(radius * ellipseCoefficient, minSide)
            return minRadius / ellipseCoefficient
        }

        let w = rect.width
        let h = rect.height

        let minimumTopRight = calculateMinimumRadius(w, h, cornerRadius.topRight)
        let minimumBottomRight = calculateMinimumRadius(w, h - (minimumTopRight * ellipseCoefficient), cornerRadius.bottomRight)
        let minimumBottomLeft = calculateMinimumRadius(w - (minimumBottomRight * ellipseCoefficient), h, cornerRadius.bottomLeft)
        let minimumTopLeft = calculateMinimumRadius(w - (minimumTopRight * ellipseCoefficient), h - (minimumBottomLeft * ellipseCoefficient), cornerRadius.topLeft)

        return (minimumTopLeft, minimumTopRight, minimumBottomLeft, minimumBottomRight)
    }
    
    static let ellipseCoefficient: CGFloat = 1.28195
}
#endif

/*
 static func continuousRoundedRect(_ rect: CGRect, cornerRadius: CGFloat) ->CGPath {
     .continuousRoundedRect(rect, cornerRadius: (cornerRadius, cornerRadius, cornerRadius, cornerRadius))
 }
 
 static func continuousRoundedRect(_ rect: CGRect, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)) -> CGPath {
     let cornerRadius = minimumCornerRadius(for: rect, cornerRadius: cornerRadius)

     let coefficients: [CGFloat] = [0.04641, 0.08715, 0.13357, 0.16296, 0.21505, 0.290086, 0.32461, 0.37801, 0.44576, 0.6074, 0.77037]
     let path = CGMutablePath()

     let topRightP1 = CGPoint(x: rect.width - cornerRadius.topRight * ellipseCoefficient, y: rect.origin.y)
     let topRightP1CP1 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[8], y: topRightP1.y)
     let topRightP1CP2 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[9], y: topRightP1.y + cornerRadius.topRight * coefficients[0])

     let topRightP2 = CGPoint(x: topRightP1.x + cornerRadius.topRight * coefficients[10], y: topRightP1.y + cornerRadius.topRight * coefficients[2])
     let topRightP2CP1 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[3], y: topRightP2.y + cornerRadius.topRight * coefficients[1])
     let topRightP2CP2 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[5], y: topRightP2.y + cornerRadius.topRight * coefficients[4])

     let topRightP3 = CGPoint(x: topRightP2.x + cornerRadius.topRight * coefficients[7], y: topRightP2.y + cornerRadius.topRight * coefficients[7])
     let topRightP3CP1 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[1], y: topRightP3.y + cornerRadius.topRight * coefficients[3])
     let topRightP3CP2 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[2], y: topRightP3.y + cornerRadius.topRight * coefficients[6])

     let topRightP4 = CGPoint(x: topRightP3.x + cornerRadius.topRight * coefficients[2], y: topRightP3.y + cornerRadius.topRight * coefficients[10])

     let bottomRightP1 = CGPoint(x: rect.width, y: rect.height - cornerRadius.bottomRight * ellipseCoefficient)
     let bottomRightP1CP1 = CGPoint(x: bottomRightP1.x, y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[8])
     let bottomRightP1CP2 = CGPoint(x: bottomRightP1.x - cornerRadius.bottomRight * coefficients[0], y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[9])

     let bottomRightP2 = CGPoint(x: bottomRightP1.x - cornerRadius.bottomRight * coefficients[2], y: bottomRightP1.y + cornerRadius.bottomRight * coefficients[10])
     let bottomRightP2CP1 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[1], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[3])
     let bottomRightP2CP2 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[4], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[5])

     let bottomRightP3 = CGPoint(x: bottomRightP2.x - cornerRadius.bottomRight * coefficients[7], y: bottomRightP2.y + cornerRadius.bottomRight * coefficients[7])
     let bottomRightP3CP1 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[3], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[1])
     let bottomRightP3CP2 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[6], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[2])

     let bottomRightP4 = CGPoint(x: bottomRightP3.x - cornerRadius.bottomRight * coefficients[10], y: bottomRightP3.y + cornerRadius.bottomRight * coefficients[2])

     let bottomLeftP1 = CGPoint(x: rect.origin.x + cornerRadius.bottomLeft * ellipseCoefficient, y: rect.height)
     let bottomLeftP1CP1 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[8], y: bottomLeftP1.y)
     let bottomLeftP1CP2 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[9], y: bottomLeftP1.y - cornerRadius.bottomLeft * coefficients[0])

     let bottomLeftP2 = CGPoint(x: bottomLeftP1.x - cornerRadius.bottomLeft * coefficients[10], y: bottomLeftP1.y - cornerRadius.bottomLeft * coefficients[2])
     let bottomLeftP2CP1 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[3], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[1])
     let bottomLeftP2CP2 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[5], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[4])

     let bottomLeftP3 = CGPoint(x: bottomLeftP2.x - cornerRadius.bottomLeft * coefficients[7], y: bottomLeftP2.y - cornerRadius.bottomLeft * coefficients[7])
     let bottomLeftP3CP1 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[1], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[3])
     let bottomLeftP3CP2 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[2], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[6])

     let bottomLeftP4 = CGPoint(x: bottomLeftP3.x - cornerRadius.bottomLeft * coefficients[2], y: bottomLeftP3.y - cornerRadius.bottomLeft * coefficients[10])

     let topLeftP1 = CGPoint(x: rect.origin.x, y: rect.origin.y + cornerRadius.topLeft * ellipseCoefficient)
     let topLeftP1CP1 = CGPoint(x: topLeftP1.x, y: topLeftP1.y - cornerRadius.topLeft * coefficients[8])
     let topLeftP1CP2 = CGPoint(x: topLeftP1.x + cornerRadius.topLeft * coefficients[0], y: topLeftP1.y - cornerRadius.topLeft * coefficients[9])

     let topLeftP2 = CGPoint(x: topLeftP1.x + cornerRadius.topLeft * coefficients[2], y: topLeftP1.y - cornerRadius.topLeft * coefficients[10])
     let topLeftP2CP1 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[1], y: topLeftP2.y - cornerRadius.topLeft * coefficients[3])
     let topLeftP2CP2 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[4], y: topLeftP2.y - cornerRadius.topLeft * coefficients[5])

     let topLeftP3 = CGPoint(x: topLeftP2.x + cornerRadius.topLeft * coefficients[7], y: topLeftP2.y - cornerRadius.topLeft * coefficients[7])
     let topLeftP3CP1 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[3], y: topLeftP3.y - cornerRadius.topLeft * coefficients[1])
     let topLeftP3CP2 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[6], y: topLeftP3.y - cornerRadius.topLeft * coefficients[2])

     let topLeftP4 = CGPoint(x: topLeftP3.x + cornerRadius.topLeft * coefficients[10], y: topLeftP3.y - cornerRadius.topLeft * coefficients[2])

     path.move(to: CGPoint(x: rect.origin.x + cornerRadius.topLeft * ellipseCoefficient, y: rect.origin.y))

     // Top right
     path.addLine(to: topRightP1)
     path.addCurve(to: topRightP2, control1: topRightP1CP1, control2: topRightP1CP2)
     path.addCurve(to: topRightP2, control1: topRightP1CP1, control2: topRightP1CP2)
     path.addCurve(to: topRightP3, control1: topRightP2CP1, control2: topRightP2CP2)
     path.addCurve(to: topRightP4, control1: topRightP3CP1, control2: topRightP3CP2)

     // Bottom right
     path.addLine(to: bottomRightP1)
     path.addCurve(to: bottomRightP2, control1: bottomRightP1CP1, control2: bottomRightP1CP2)
     path.addCurve(to: bottomRightP3, control1: bottomRightP2CP1, control2: bottomRightP2CP2)
     path.addCurve(to: bottomRightP4, control1: bottomRightP3CP1, control2: bottomRightP3CP2)

     // Bottom left
     path.addLine(to: bottomLeftP1)
     path.addCurve(to: bottomLeftP2, control1: bottomLeftP1CP1, control2: bottomLeftP1CP2)
     path.addCurve(to: bottomLeftP3, control1: bottomLeftP2CP1, control2: bottomLeftP2CP2)
     path.addCurve(to: bottomLeftP4, control1: bottomLeftP3CP1, control2: bottomLeftP3CP2)

     // Top Left
     path.addLine(to: topLeftP1)
     path.addCurve(to: topLeftP2, control1: topLeftP1CP1, control2: topLeftP1CP2)
     path.addCurve(to: topLeftP3, control1: topLeftP2CP1, control2: topLeftP2CP2)
     path.addCurve(to: topLeftP4, control1: topLeftP3CP1, control2: topLeftP3CP2)

     path.closeSubpath()

     return path
 }
 */
