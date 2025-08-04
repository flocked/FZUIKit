//
//  NSUIBezierPath+Shape.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/*
extension NSUIBezierPath {
    static func ellipse(_ size: CGSize) -> NSUIBezierPath {
        NSUIBezierPath(ovalIn: CGRect(.zero, size))
    }
    
    static func circle(_ size: CGSize) -> NSUIBezierPath {
        let value = min(size.width, size.height)
        let xValue = (size.width - value) / 2.0
        let yValue = (size.height - value) / 2.0
        return NSUIBezierPath(roundedRect: CGRect(CGPoint(xValue, yValue), CGSize(value, value)), cornerRadius: value / 2.0)
    }
        
    static func rect(_ size: CGSize) -> NSUIBezierPath {
        NSUIBezierPath(rect: CGRect(.zero, size))
    }
    
    static func roundedRect(_ size: CGSize, cornerRadius: CGFloat) -> NSUIBezierPath {
        NSUIBezierPath(roundedRect: CGRect(.zero, size), cornerRadius: cornerRadius)
    }
    
    static func roundedRect(_ size: CGSize, cornerRadius: CGFloat, byRoundingCorners corners: NSUIRectCorner) -> NSUIBezierPath {
        NSUIBezierPath(roundedRect: CGRect(.zero, size), byRoundingCorners: corners, cornerRadius: cornerRadius)
    }
    
    static func roundedRect(_ size: CGSize, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> NSUIBezierPath {
        NSUIBezierPath(roundedRect: CGRect(.zero, size), topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }
    
    static func star(rect: CGRect, points: Int = 5, rounded: Bool = false, cutout: Bool = false) -> NSUIBezierPath {
        func Cartesian(length: Double, angle: Double) -> CGPoint {
            CGPoint(x: length * cos(angle),
                    y: length * sin(angle))
        }
        let bezierPath = NSUIBezierPath()
        
        // centre of the containing rect
        var center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        // Adjust center down for odd number of sides less than 8
        if points % 2 == 1, points < 8, !rounded {
            center = CGPoint(x: center.x, y: center.y * ((Double(points) * -0.04) + 1.3))
        }
        
        let outerRadius = (Double(min(rect.width, rect.height)) / 2.0) * 0.9
        let innerRadius = outerRadius * 0.4
        let offsetAngle = (Double.pi / Double(points)) + Double.pi / 2.0
        
        var vertices: [CGPoint] = []
        for i in 0 ..< points {
            // Calculate the angle in Radians
            let angle1 = (2.0 * Double.pi / Double(points)) * Double(i) + offsetAngle
            let outerPoint = Cartesian(length: outerRadius, angle: angle1)
            vertices.append(CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))
            
            let angle2 = (2.0 * Double.pi / Double(points)) * (Double(i) + 0.5) + offsetAngle
            let innerPoint = Cartesian(length: innerRadius,
                                       angle: angle2)
            vertices.append(CGPoint(x: innerPoint.x + center.x, y: innerPoint.y + center.y))
        }
        
        /*
         if cutout {
         if rounded {
         path.addPath(Circle().path(in: rect))
         } else {
         path.addPath(Rectangle().path(in: rect))
         }
         }
         */
        for (n, pt) in vertices.enumerated() {
            #if os(macOS)
            n == 0 ? bezierPath.move(to: pt) : bezierPath.line(to: pt)
            #else
            n == 0 ? bezierPath.move(to: pt) : bezierPath.addLine(to: pt)
            #endif
        }
        bezierPath.close()
        return bezierPath
    }
    
    static func starAlt(rect: CGRect, points: Int = 5, rounded: Bool = false, cutout: Bool = false) -> NSUIBezierPath {
        func Cartesian(length: Double, angle: Double) -> CGPoint {
            CGPoint(x: length * cos(angle),
                    y: length * sin(angle))
        }
        let bezierPath = NSUIBezierPath()
        
        // centre of the containing rect
        var center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        // Adjust center down for odd number of sides less than 8
        if points % 2 == 1, points < 8, !rounded {
            center = CGPoint(x: center.x, y: center.y * ((Double(points) * -0.04) + 1.3))
        }
        
        // radius of a rounded that will fit in the rect
        let outerRadius = (Double(min(rect.width, rect.height)) / 2.0) * 0.9
        let innerRadius = outerRadius * 0.4
        let offsetAngle = (Double.pi / Double(points)) + Double.pi / 2.0
        
        for i in 0 ..< points {
            // Calculate the angle in Radians
            let angle1 = (2.0 * Double.pi / Double(points)) * Double(i) + offsetAngle
            let outerPoint = Cartesian(length: outerRadius, angle: angle1)
            
            if i == 0 {
                bezierPath.move(to: CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))
            } else {
                #if os(macOS)
                bezierPath.line(to: CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))
                #else
                bezierPath.addLine(to: CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))
                #endif
            }
            
            let angle2 = (2.0 * Double.pi / Double(points)) * (Double(i) + 0.5) + offsetAngle
            let innerPoint = Cartesian(length: innerRadius,
                                       angle: angle2)
            #if os(macOS)
            bezierPath.line(to: CGPoint(x: innerPoint.x + center.x, y: innerPoint.y + center.y))
            #else
            bezierPath.addLine(to: CGPoint(x: innerPoint.x + center.x, y: innerPoint.y + center.y))
            #endif
        }
        
        bezierPath.close()
        return bezierPath
    }
    
    static func starRounded(rect: CGRect, cornerRadius: CGFloat = 4, rotation: CGFloat = 54) -> NSUIBezierPath {
        let path = NSUIBezierPath()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let r = rect.width / 2
        let rc = cornerRadius
        let rn = r * 0.95 - rc
        var cangle = rotation
        
        for i in 1 ... 5 {
            // compute center point of tip arc
            let cc = CGPoint(x: center.x + rn * cos(cangle * .pi / 180), y: center.y + rn * sin(cangle * .pi / 180))
            
            // compute tangent point along tip arc
            let p = CGPoint(x: cc.x + rc * cos((cangle - 72) * .pi / 180), y: cc.y + rc * sin((cangle - 72) * .pi / 180))
            
            if i == 1 {
                path.move(to: p)
            } else {
                #if os(macOS)
                path.line(to: p)
                #else
                path.addLine(to: p)
                #endif
            }
           
            // add 144 degree arc to draw the corner
            #if os(macOS)
            path.appendArc(withCenter: cc, radius: rc, startAngle: (cangle - 72) * .pi / 180, endAngle: (cangle + 72) * .pi / 180, clockwise: true)
            #else
            path.addArc(withCenter: cc, radius: rc, startAngle: (cangle - 72) * .pi / 180, endAngle: (cangle + 72) * .pi / 180, clockwise: true)
            #endif
            cangle += 144
        }
        
        path.close()
        return path
    }
}
*/

#endif
