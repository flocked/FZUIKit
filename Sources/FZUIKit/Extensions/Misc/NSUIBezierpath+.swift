//
//  NSUIBezierpath+.swift
//
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
    /**
     Creates and returns a new Bézier path object with a rounded rectangular path.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadius: cornerRadius)
    }

    /**
     Creates and returns a new Bézier path object with a rectangular path rounded at the specified corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: The corners to round.
        - cornerRadii: The radius of each corner oval. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSRectCorner, cornerRadii: CGSize) {
        self.init()

        let maxRadius = min(rect.width, rect.height) / 2
        let radius = CGSize(width: min(cornerRadii.width, maxRadius), height: min(cornerRadii.height, maxRadius))
        let (minX, maxX, minY, maxY) = (rect.minX, rect.maxX, rect.minY, rect.maxY)
        let topLeft = NSPoint(x: minX, y: maxY), topRight = NSPoint(x: maxX, y: maxY)
        let bottomRight = NSPoint(x: maxX, y: minY), bottomLeft = NSPoint(x: minX, y: minY)

        corners.contains(.bottomLeft) ? move(to: NSPoint(x: minX + radius.width, y: minY)) : move(to: bottomLeft)
        if corners.contains(.bottomRight) {
            line(to: NSPoint(x: maxX - radius.width, y: minY))
            appendArc(withCenter: NSPoint(x: maxX - radius.width, y: minY + radius.height), radius: radius.width, startAngle: 270, endAngle: 0, clockwise: false)
        } else { line(to: bottomRight) }

        if corners.contains(.topRight) {
            line(to: NSPoint(x: maxX, y: maxY - radius.height))
            appendArc(withCenter: NSPoint(x: maxX - radius.width, y: maxY - radius.height), radius: radius.width, startAngle: 0, endAngle: 90, clockwise: false)
        } else { line(to: topRight) }

        if corners.contains(.topLeft) {
            line(to: NSPoint(x: minX + radius.width, y: maxY))
            appendArc(withCenter: NSPoint(x: minX + radius.width, y: maxY - radius.height), radius: radius.width, startAngle: 90, endAngle: 180, clockwise: false)
        } else { line(to: topLeft) }

        if corners.contains(.bottomLeft) {
            line(to: NSPoint(x: minX, y: minY + radius.height))
            appendArc(withCenter: NSPoint(x: minX + radius.width, y: minY + radius.height), radius: radius.width, startAngle: 180, endAngle: 270, clockwise: false)
        } else { line(to: bottomLeft) }

        close()
    }

    /**
     Creates and returns a new Bézier path object with an arc of a circle.

     This method creates an open subpath. The created arc lies on the perimeter of the specified circle. When drawn in the default coordinate system, the start and end angles are based on the unit circle shown in the following image. For example, specifying a start angle of `0` radians, an end angle of `π` radians, and setting the `clockwise` parameter to `true` draws the bottom half of the circle. However, specifying the same start and end angles but setting the `clockwise` parameter to `false` draws the top half of the circle.

     After calling this method, the current point is set to the point on the arc at the end angle of the circle.

     - Parameters:
        - center: Specifies the center point of the circle (in the current coordinate system) used to define the arc.
        - radius: Specifies the radius of the circle used to define the arc.
        - startAngle: Specifies the starting angle of the arc (measured in radians).
        - endAngle: Specifies the end angle of the arc (measured in radians).
        - clockwise: The direction in which to draw the arc.
     */
    convenience init(arcCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        self.init()
        move(to: CGPoint(x: center.x + cos(startAngle) * radius, y: center.y + sin(startAngle) * radius))
        appendArc(withCenter: center, radius: radius, startAngle: startAngle * 180 / .pi, endAngle: endAngle * 180 / .pi, clockwise: !clockwise)
    }

    /**
     Creates and returns a new Bézier path object with the contents of a Core Graphics path.

     - Parameter cgPath: The Core Graphics path from which to obtain the initial path information. If this parameter is nil, the method raises an exception.
     - Returns: A new path object with the specified path information.
     */
    @available(macOS, introduced: 10.10, obsoleted: 14.0)
    convenience init(cgPath: CGPath) {
        self.init()
        cgPath.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            let points = element.points
            switch element.type {
            case .moveToPoint:
                move(to: points[0])
            case .addLineToPoint:
                line(to: points[0])
            case .addQuadCurveToPoint:
                let qp0 = currentPoint
                let qp1 = points[0]
                let qp2 = points[1]
                let m = CGFloat(2.0 / 3.0)
                let cp1 = NSPoint(x: qp0.x + ((qp1.x - qp0.x) * m), y: qp0.y + ((qp1.y - qp0.y) * m))
                let cp2 = NSPoint(x: qp2.x + ((qp1.x - qp2.x) * m), y: qp2.y + ((qp1.y - qp2.y) * m))
                curve(to: qp2, controlPoint1: cp1, controlPoint2: cp2)
            case .addCurveToPoint:
                curve(to: points[2], controlPoint1: points[0], controlPoint2: points[1])
            case .closeSubpath:
                close()
            @unknown default:
                break
            }
        }
    }

    /**
     Creates a Bézier path for the specified symbol image, point size, font weight, and symbol scale.

     - Parameters:
        - symbolName: The name of the system symbol image.
        - pointSize: The point size of the symbol.
        - weight: The font weight of the symbol.
        - scale: The scale of the symbol.
     */
    @available(macOS 11.0, *)
    convenience init?(symbolName: String, pointSize: CGFloat, weight: NSFont.Weight = .regular, scale: NSImage.SymbolScale = .default) {
        self.init(symbolName: symbolName, symbolConfiguration: .init(pointSize: pointSize, weight: weight, scale: scale))

    }

    /**
     Creates a Bézier path for the specified symbol image, text style, font weight, and symbol scale.

     - Parameters:
        - symbolName: The name of the system symbol image.
        - textStyle: The text style of the symbol.
        - weight: The font weight of the symbol.
        - scale: The scale of the symbol.
     */
    @available(macOS 11.0, *)
    convenience init?(symbolName: String, textStyle: NSFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSImage.SymbolScale = .default) {
        self.init(symbolName: symbolName, symbolConfiguration: .init(textStyle: textStyle, weight: weight, scale: scale))
    }

    /**
     Creates a Bézier path for the specified symbol image and symbol configuration.

     - Parameters:
        - symbolName: The name of the system symbol image.
        - symbolConfiguration: The symbol configuration.
     */
    @available(macOS 11.0, *)
    private convenience init?(symbolName: String, symbolConfiguration: NSImage.SymbolConfiguration) {
        guard let representation = NSImage(systemSymbolName: symbolName)?.withSymbolConfiguration(symbolConfiguration)?.representations.first, representation.responds(to: NSSelectorFromString("outlinePath")), let path = representation.value(forKeySafely: "outlinePath") as? NSBezierPath else { return nil }
        self.init(cgPath: path.cgPath)
    }

    /**
     The Core Graphics representation of the path.

     This property contains a snapshot of the path at any given point in time. Getting this property returns an immutable path object that you can pass to Core Graphics functions. The path object itself is owned by the `NSBezierPath` object and is valid only until you make further modifications to the path.

     You can set the value of this property to a path you built using the functions of the Core Graphics framework. When setting a new path, this method makes a copy of the path you provide.
     */
    @available(macOS, introduced: 10.10, obsoleted: 14.0)
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
                path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y), control1: CGPoint(x: points[0].x, y: points[0].y), control2: CGPoint(x: points[1].x, y: points[1].y))
            case .closePath:
                path.closeSubpath()
            default:
                break
            }
        }
        return path
    }
}
#endif

public extension NSUIBezierPath {
    /// The shape of a corner.
    enum CornerCurve: Int {
        /// Quarter-circle rounded.
        case circular
        /// Continuous curvature rounded.
        case continuous
    }
    
    /**
     Creates and returns a new Bézier path object with a rounded rectangular path.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
        - cornerCurve: The curve of the corners.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat, cornerCurve: CornerCurve) {
        if cornerCurve == .circular {
            self.init(roundedRect: rect, cornerRadius: cornerRadius)
        } else {
            self.init(cgPath: .continuousRoundedRect(rect, cornerRadius: cornerRadius))
        }
    }
    
    /**
     Creates and returns a new Bézier path object with a rectangular path rounded at the specified corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    /**
     Creates and returns a new Bézier path object with a rectangular path rounded at the specified corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
        - cornerCurve: The curve of the corners.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat, cornerCurve: CornerCurve) {
        if cornerCurve == .circular {
            self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadius: cornerRadius)
            return
        }
        self.init(roundedRect: rect, topLeft: corners.contains(.topLeft) ? cornerRadius : 0.0, topRight: corners.contains(.topRight) ? cornerRadius : 0.0, bottomLeft: corners.contains(.bottomLeft) ? cornerRadius : 0.0, bottomRight: corners.contains(.bottomRight) ? cornerRadius : 0.0, cornerCurve: cornerCurve)
    }

    /**
     Creates and returns a new Bézier path object with a rectangular path with variable rounded corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - topLeft: The top left corner radius.
        - topRight: The top right corner radius.
        - bottomLeft: The bottom left corner radius.
        - bottomRight: The bottom right corner radius.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.init()
        var pt = CGPoint.zero

        // top-left corner plus top-left radius
        pt.x = topLeft
        pt.y = 0
        move(to: pt)
        pt.x = rect.maxX - topRight
        pt.y = 0

        // add "top line"
        addLine(to: pt)
        pt.x = rect.maxX - topRight
        pt.y = topRight

        // add "top-right corner"
        addArc(withCenter: pt, radius: topRight, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
        pt.x = rect.maxX
        pt.y = rect.maxY - bottomRight

        // add "right-side line"
        addLine(to: pt)
        pt.x = rect.maxX - bottomRight
        pt.y = rect.maxY - bottomRight

        // add "bottom-right corner"
        addArc(withCenter: pt, radius: bottomRight, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        pt.x = bottomLeft
        pt.y = rect.maxY

        // add "bottom line"
        addLine(to: pt)
        pt.x = bottomLeft
        pt.y = rect.maxY - bottomLeft

        // add "bottom-left corner"
        addArc(withCenter: pt, radius: bottomLeft, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        pt.x = 0
        pt.y = topLeft

        // add "left-side line"
        addLine(to: pt)
        pt.x = topLeft
        pt.y = topLeft

        // add "top-left corner"
        addArc(withCenter: pt, radius: topLeft, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)

        close()
    }
    
    /**
     Creates and returns a new Bézier path object with a rectangular path with variable rounded corners.

     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - topLeft: The top left corner radius.
        - topRight: The top right corner radius.
        - bottomLeft: The bottom left corner radius.
        - bottomRight: The bottom right corner radius.
        - cornerCurve: The curve of the corners.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat, cornerCurve: CornerCurve) {
        if cornerCurve == .circular {
            self.init(roundedRect: rect, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        } else {
            self.init(cgPath: .continuousRoundedRect(rect, cornerRadius: (topLeft, topRight, bottomLeft, bottomRight)))
        }
    }

    /**
     Returns a new Bézier path object with a rounded rectangular path.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.

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

        let path = Self()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addCurve(to: point3, controlPoint1: topRight, controlPoint2: topRight)
        path.addLine(to: point4)
        path.addCurve(to: point5, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.addLine(to: point6)
        path.addCurve(to: point7, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.addLine(to: point8)
        path.addCurve(to: point1, controlPoint1: topLeft, controlPoint2: topLeft)
        return path
    }

    /**
     Returns a new Bézier path object with a squircle rectangular path.

     - Parameter rect: The rectangle that defines the basic shape of the path.
     - Returns: A new path object with the squircle rectangular path.
     */
    static func squircle(rect: CGRect) -> Self {
        assert(rect.width == rect.height)
        return superellipse(in: rect, cornerRadius: rect.width / 2.0)
    }

    /**
     Creates and returns a new Bézier path object for a contact shadow with the specified shadow size and distance.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.

     - Returns: A new path object for a contact shadow.
     */
    static func contactShadow(rect: CGRect, shadowSize: CGFloat = 20, shadowDistance: CGFloat = 0) -> NSUIBezierPath {
        let contactRect = CGRect(x: -shadowSize, y: (rect.height - (shadowSize * 0.4)) + shadowDistance, width: rect.width + shadowSize * 2, height: shadowSize)
        return NSUIBezierPath(ovalIn: contactRect)
    }

    /**
     Creates and returns a new Bézier path object for a depth shadow with the specified shadow size and distance.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.

     - Returns: A new path object for a depth shadow.
     */
    static func depthShadow(rect: CGRect, shadowWidth: CGFloat = 1.2, shadowHeight: CGFloat = 0.5, shadowRadius: CGFloat = 5, shadowOffsetX: CGFloat = 0) -> NSUIBezierPath {
        let shadowPath = NSUIBezierPath()
        shadowPath.move(to: CGPoint(x: shadowRadius / 2, y: rect.height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: rect.width, y: rect.height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: rect.width * shadowWidth + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        shadowPath.addLine(to: CGPoint(x: rect.width * -(shadowWidth - 1) + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        shadowPath.close()
        return shadowPath
    }

    /**
     Creates and returns a new Bézier path object for a flat shadow with the specified shadow size and distance.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.

     - Returns: A new path object for a flat shadow.
     */
    static func flatShadow(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSUIBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSUIBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.addLine(to: CGPoint(x: rect.width, y: rect.height))

        // make the bottom of the shadow finish a long way away, and pushed by our X offset
        shadowPath.addLine(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.addLine(to: CGPoint(x: shadowOffsetX, y: 2000))
        shadowPath.close()
        return shadowPath
    }

    /**
     Creates and returns a new Bézier path object for a flat behind shadow with the specified shadow size and distance.

     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.

     - Returns: A new path object for a flat behind shadow.
     */
    static func flatShadowBehind(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSUIBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSUIBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.addLine(to: CGPoint(x: rect.width, y: 0))
        shadowPath.addLine(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.addLine(to: CGPoint(x: shadowOffsetX, y: 2000))
        shadowPath.close()
        return shadowPath
    }

    /**
     Returns a new path which is rotated by the specified radians.

     - Parameters:
        - radians: The radians of rotation.
        - centerPoint: The center point of the rotation.
     - Returns: A new path rotated path.
     */
    func rotating(byRadians radians: Double, centerPoint point: CGPoint) -> Self {
        let path = copy() as! Self
        guard radians != 0 else {return path}
        #if os(macOS)
        path.transform(using: rotationTransform(byRadians: radians, centerPoint: point))
        #else
        path.apply(rotationTransform(byRadians: radians, centerPoint: point))
        #endif
        return path
    }

    #if os(macOS)
    private func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> AffineTransform {
        var transform = AffineTransform()
        transform.translate(x: point.x, y: point.y)
        transform.rotate(byRadians: radians)
        transform.translate(x: -point.x, y: -point.y)
        return transform
    }
    #else
    func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> CGAffineTransform {
        var transform = CGAffineTransform()
        transform = transform.translatedBy(x: point.x, y: point.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -point.x, y: -point.y)
        return transform
    }
    #endif
    
    static func + (lhs: NSUIBezierPath, rhs: NSUIBezierPath) -> NSUIBezierPath {
        [lhs, rhs].combined()
    }
    
    static func += (lhs: inout NSUIBezierPath, rhs: NSUIBezierPath) {
        lhs.append(rhs)
    }
}

#if os(macOS)
fileprivate extension NSBezierPath {
    func addArc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    }

    func addLine(to point: CGPoint) {
        line(to: point)
    }

    func addCurve(to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

}
#endif

fileprivate extension CGPath {
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

extension Sequence where Element: NSUIBezierPath {
    /// A bezier path from all elements of the sequence.
    public func combined() -> NSUIBezierPath {
        reduce(into: .init()) { $0.append($1) }
    }
}
