//
//  PathShape.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

#if canImport(CoreGraphics)
import CoreGraphics
import SwiftUI

/// A 2D shape represented as `CGPath`.
public struct PathShape {
    let handler: (CGRect)->(CGPath)
    
    /// Creates a shape with the specified handler that provides the path of the shape.
    public init(handler: @escaping (CGRect) -> CGPath) {
        self.handler = handler
    }
    
    /// Creates a shape from the specified `SwiftUI`shape.
    public init<S: Shape>(_ shape: S) {
        handler = { shape.path(in: $0).cgPath }
    }
    
    /// Describes this shape as a path within a rectangular frame of reference.
    public func path(in rect: CGRect) -> CGPath {
        handler(rect)
    }
    
    /// Trims this shape by a fractional amount based on its representation as a path.
    public func trim(from start: CGFloat, to end: CGFloat) -> PathShape {
        PathShape { rect in
            let path = path(in: rect)
            return path.trimmedPath(start: start, end: end)
        }
    }

    /// Applies an affine transform to this shape.
    public func transform(_ transform: CGAffineTransform) -> PathShape {
        var transform = transform
        return PathShape { rect in
            path(in: rect).copy(using: &transform) ?? CGPath(rect: rect, transform: nil)
        }
    }

    /// Returns a new version of self representing the same shape, but that will ask it to create its path from a rect of size. This does not affect the layout properties of any views created from the shape (e.g. by filling it).
    public func size(_ size: CGSize) -> PathShape {
        self.size(width: size.width, height: size.height)
    }

    /// Returns a new version of self representing the same shape, but that will ask it to create its path from a rect of size (width, height). This does not affect the layout properties of any views created from the shape (e.g. by filling it).
    public func size(width: CGFloat, height: CGFloat) -> PathShape {
        PathShape { _ in
            path(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        }
    }
    
    /// Scales this shape without changing its bounding frame.
    public func scale(_ scale: CGFloat, anchor: CGPoint = .init(x: 0.5, y: 0.5)) -> PathShape {
        self.scale(x: scale, y: scale, anchor: anchor)
    }

    /// Scales this shape without changing its bounding frame.
    public func scale(x: CGFloat, y: CGFloat, anchor: CGPoint = .init(x: 0.5, y: 0.5)) -> PathShape {
        PathShape { rect in
            let path = path(in: rect)
            let anchorPoint = CGPoint(x: rect.width * anchor.x, y: rect.height * anchor.y)
            var transform = CGAffineTransform.identity
                   .translatedBy(x: anchorPoint.x, y: anchorPoint.y)
                   .scaledBy(x: x, y: y)
                   .translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
            return path.copy(using: &transform) ?? path
        }
    }
    
    /// Rotates this shape around an anchor point at the angle you specify.
    public func rotation(_ angle: CGFloat, anchor: CGPoint = .init(x: 0.5, y: 0.5)) -> PathShape {
        PathShape { rect in
            let path = path(in: rect)
            let anchorPoint = CGPoint(x: rect.width * anchor.x, y: rect.height * anchor.y)
            var transform = CGAffineTransform.identity
                   .translatedBy(x: anchorPoint.x, y: anchorPoint.y)
                   .rotated(by: angle)
                   .translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
            return path.copy(using: &transform) ?? path
        }
    }

    /// Changes the relative position of this shape using the specified size.
    public func offset(_ offset: CGSize) -> PathShape {
        self.offset(x: offset.width, y: offset.height)
    }
    
    /// Changes the relative position of this shape using the specified point.
    public func offset(_ offset: CGPoint) -> PathShape {
        self.offset(x: offset.x, y: offset.y)
    }

    /// Changes the relative position of this shape using the specified point.
    public func offset(x: CGFloat, y: CGFloat) -> PathShape {
        PathShape { rect in
            var transform = CGAffineTransform(translationX: x, y: y)
            return path(in: rect).copy(using: &transform) ?? self.path(in: rect)
        }
    }
    
    public func fill(rect: CGRect) {
        #if os(macOS)
        NSBezierPath(cgPath: path(in: rect)).fill()
        #else
        UIGraphicsGetCurrentContext()?.addPath(path(in: rect))
        UIGraphicsGetCurrentContext()?.fillPath()
        #endif
    }
    
    public func stroke(rect: CGRect) {
        #if os(macOS)
        NSBezierPath(cgPath: path(in: rect)).stroke()
        #else
        UIGraphicsGetCurrentContext()?.addPath(path(in: rect))
        UIGraphicsGetCurrentContext()?.strokePath()
        #endif
    }
}

extension PathShape {
    /// A rectangular shape.
    public static var rect: PathShape { PathShape(.rect) }
    
    /// A rectangular shape with rounded corners.
    public static func rect(cornerSize: CGSize, style: RoundedCornerStyle = .continuous) -> PathShape { PathShape(.rect(cornerSize: cornerSize, style: style)) }
    
    /// A rectangular shape with rounded corners.
    public static func rect(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) -> PathShape { PathShape(.rect(cornerRadius: cornerRadius, style: style)) }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    /// A rectangular shape with rounded corners with different values.
    public static func rect(topLeadingRadius: CGFloat = 0, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0, topTrailingRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous) -> PathShape {
        PathShape(.rect(topLeadingRadius: topLeadingRadius, bottomLeadingRadius: bottomLeadingRadius, bottomTrailingRadius: bottomTrailingRadius, topTrailingRadius: topTrailingRadius, style: style))
    }
    
    /// A circle centered on the frame.
    public static var circle: PathShape { PathShape(.circle) }
    
    /// A capsule shape.
    public static var capsule: PathShape { PathShape(.capsule) }
    
    /// A capsule shape.
    public static func capsule(style: RoundedCornerStyle) -> PathShape { PathShape(.capsule(style: style)) }
    
    /// An ellipse shape.
    public static var ellipse: PathShape { PathShape(.ellipse) }
    
    /// A star shape.
    public static func star(points: Int = 5, cutout: Bool = false, rounded: Bool = false) -> PathShape { PathShape(Star(points: points, cutout: cutout, rounded: rounded)) }
}
#endif
