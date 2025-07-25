//
//  PathShape.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

#if canImport(CoreGraphics)
import CoreGraphics
import SwiftUI
import FZSwiftUtils

/// A 2D shape represented as `CGPath`.
public struct PathShape {
    let id: String
    let handler: (CGRect)->(CGPath)
    var insettableShape: (any InsettableShape)?
    
    /// Creates a shape with the specified handler that provides the path of the shape.
    public init(handler: @escaping (_ rect: CGRect) -> CGPath) {
        self.handler = handler
        self.id = UUID().uuidString
    }
        
    public init(_ shape: some InsettableShape) {
        insettableShape = shape
        handler = {
            #if os(macOS)
            return shape.path(in: $0).cgPath.verticallyFlipped(in: $0)
            #else
            return shape.path(in: $0).cgPath
            #endif
        }
        id = String(describing: shape)
    }
    
    /// Creates a shape from the specified `SwiftUI`shape.
    public init<S: Shape>(_ shape: S) {
        handler = {
            #if os(macOS)
            return shape.path(in: $0).cgPath.verticallyFlipped(in: $0)
            #else
            return shape.path(in: $0).cgPath
            #endif
        }
        id = String(describing: shape)
    }
    
    /// Describes this shape as a path within a rectangular frame of reference.
    public func path(in rect: CGRect) -> CGPath {
        handler(rect)
    }
    
    /// Trims this shape by a fractional amount based on its representation as a path.
    public func trim(from start: CGFloat, to end: CGFloat) -> PathShape {
        PathShape { rect in
            path(in: rect).trimmedPath(from: start, to: end)
        }
    }

    /// Applies an affine transform to this shape.
    public func transform(_ transform: CGAffineTransform) -> PathShape {
        PathShape { rect in
            var transform = transform
            return path(in: rect).copy(using: &transform) ?? CGPath(rect: rect, transform: nil)
        }
    }

    /// Returns a new version of self representing the same shape, but that will ask it to create its path from a rect of size.
    public func size(_ size: CGSize) -> PathShape {
        self.size(width: size.width, height: size.height)
    }

    /// Returns a new version of self representing the same shape, but that will ask it to create its path from a rect of size (width, height).
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
    
    /// Insets the shape.
    public func inset(by amount: CGFloat) -> PathShape {
        if let insettableShape = insettableShape {
            return PathShape(insettableShape.inset(by: amount))
        }
        return PathShape { rect in
            path(in: rect.insetBy(dx: amount, dy: amount))
        }
    }
    
    /// Fills the shape using the current fill color and drawing attributes.
    public func fill(rect: CGRect) {
        #if os(macOS)
        NSBezierPath(cgPath: path(in: rect)).fill()
        #else
        UIGraphicsGetCurrentContext()?.addPath(path(in: rect))
        UIGraphicsGetCurrentContext()?.fillPath()
        #endif
    }
    
    /// Draws a line along the shape using the current stroke color and drawing attributes.
    public func stroke(rect: CGRect) {
        #if os(macOS)
        NSBezierPath(cgPath: path(in: rect)).stroke()
        #else
        UIGraphicsGetCurrentContext()?.addPath(path(in: rect))
        UIGraphicsGetCurrentContext()?.strokePath()
        #endif
    }
}

@available(macOS 14.0, iOS 16.0, tvOS 16.0, watchOS 10.0, *)
extension PathShape {
    /// Rules for determining which regions are interior to a shape.
    public typealias FileRule = CGPathFillRule
    
    /// Returns the shape inverted.
    public var inverted: PathShape {
        PathShape { rect in
            CGPath(rect: rect, transform: nil).subtracting(path(in: rect))
        }
    }
        
    /// Returns a new shape with filled regions common to both shapes.
    public func intersection(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).intersection(other.path(in: rect), using: rule)
        }
    }

    /// Returns a new shape with a line from this shape that overlaps the filled regions of the given shape.
    public func lineIntersection(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).lineIntersection(other.path(in: rect), using: rule)
        }
    }

    /// Returns a new shape with a line from this shape that does not overlap the filled region of the given shape.
    public func lineSubtraction(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).lineSubtracting(other.path(in: rect), using: rule)
        }
    }
    
    /// Returns a new shape with filled regions from this shape that are not in the given shape.
    public func subtracting(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).subtracting(other.path(in: rect), using: rule)
        }
    }

    /// Returns a new shape with filled regions either from this shape or the given shape, but not in both.
    public func symmetricDifference(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).symmetricDifference(other.path(in: rect), using: rule)
        }
    }

    /// Returns a new shape with filled regions in either this shape or the given shape.
    public func union(_ other: PathShape, using rule: FileRule = .evenOdd) -> PathShape {
        PathShape { rect in
            path(in: rect).union(other.path(in: rect), using: rule)
        }
    }
}

extension PathShape {
    /// A rectangular shape.
    public static let rect = PathShape(.rect)
    
    /// A rectangular shape with rounded corners.
    public static func rect(cornerSize: CGSize, style: RoundedCornerStyle = .continuous) -> PathShape {
        PathShape(.rect(cornerSize: cornerSize, style: style))
    }
    
    /// A rectangular shape with rounded corners.
    public static func rect(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) -> PathShape {
        PathShape(.rect(cornerRadius: cornerRadius, style: style))
    }

    /// A rectangular shape with rounded corners with different values.
    public static func rect(topLeadingRadius: CGFloat = 0, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0, topTrailingRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous) -> PathShape {
        if topLeadingRadius == bottomLeadingRadius && topLeadingRadius == bottomTrailingRadius && topLeadingRadius == topTrailingRadius {
            return  .rect(cornerRadius: topLeadingRadius, style: style)
        }
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return PathShape(.rect(topLeadingRadius: topLeadingRadius, bottomLeadingRadius: bottomLeadingRadius, bottomTrailingRadius: bottomTrailingRadius, topTrailingRadius: topTrailingRadius, style: style))
        } else {
            return PathShape { rect in
                CGPath(roundedRect: rect, topLeftRadius: topLeadingRadius, bottomLeftRadius: bottomLeadingRadius, bottomRightRadius: bottomTrailingRadius, topRightRadius: topTrailingRadius, style: style == .circular ? .circular : .continuous)
            }
        }
    }
    
    /**
     A rectangular shape with relative corner radius.
     
     The corner radius is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.
     */
    public static func relativeRoundedRect(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) -> PathShape {
        PathShape(.relativeRoundedRect(cornerRadius: cornerRadius, style: style))
    }
    
    /**
     A rectangular shape with rounded corners with different relative values.

     The corner radius of each corner is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.
     
     A corner radius of `0.0` represents no rounding and `1.0` the maximum.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static func relativeRoundedRect(topLeadingRadius: CGFloat = 0.0, bottomLeadingRadius: CGFloat = 0.0, bottomTrailingRadius: CGFloat = 0.0, topTrailingRadius: CGFloat = 0.0, style: RoundedCornerStyle = .continuous) -> PathShape { PathShape(.relativeRoundedRect(topLeadingRadius: topLeadingRadius, bottomLeadingRadius: bottomLeadingRadius, bottomTrailingRadius: bottomTrailingRadius, topTrailingRadius: topTrailingRadius, style: style)) }

    
    /// A circlular shape centered on the frame.
    public static let circle = PathShape(.circle)
    
    /// A capsule shape.
    public static let capsule = PathShape(.capsule)

    /// A capsule shape.
    public static func capsule(style: RoundedCornerStyle) -> PathShape { PathShape(.capsule(style: style)) }
    
    /// An ellipse shape.
    public static let ellipse = PathShape(.ellipse)
    
    /// A star shape.
    public static func star(points: Int = 5, cutout: Bool = false, rounded: Bool = false) -> PathShape { PathShape(Star(points: points, cutout: cutout, rounded: rounded)) }
    
    /**
     A contact shadow shape.
     
     - Parameters:
        - height: The height of the shape.
        - distance: The vertical offset of the shape.
     */
    public static func contactShadow(height: CGFloat = 20.0, distance: CGFloat = 0.0) -> PathShape {
        PathShape(.contactShadow(height: height, distance: distance))
    }
    
    /**
     A deep shadow shape.
     
     - Parameters:
        - width: The width of the shape relative to the rectangle.
        - height: The height of the shape relative to the rectangle.
        - offset: The offset of the shape.
        - shift: The horizontal shift of the shape.
        - shiftIsRelative: A Boolean value indicating whether the shift is relative to the rectangle or absolute.
     */
    public static func deepShadow(width: CGFloat = 1.2, height: CGFloat = 0.5, offset: CGPoint = CGPoint(5.0), shift: CGFloat = -0.15, shiftIsRelative: Bool = true) -> PathShape {
        PathShape(.deepShadow(width: width, height: height, offset: offset, shift: shift, shiftIsRelative: shiftIsRelative))
    }
    
    /**
     A flat long shadow shape.
     
     - Parameters:
        - offset: The horizontal offset of the shape.
        - alternative: A Boolean value indicating whether to use an alternative shape style.
     */
    public static func flatLongShadow(offset: CGFloat = 2000.0, alternative: Bool = false) -> PathShape {
        PathShape(.flatLongShadow(offset: offset, alternative: alternative))
    }
    
    /**
     A curved shadow shape.

     - Parameters:
        - radius: The radius of the shape.
        - curveAmount: The curve amunt.
     */
    public static func curvedShadow(radius: CGFloat = 5.0, curveAmount: CGFloat = 20) -> PathShape {
        PathShape(.curvedShadow(radius: radius, curveAmount: curveAmount))
    }
}

/// The Objective-C class for ``PathShape``.
public class __PathShape: NSObject, NSCopying {
    let shape: PathShape
    
    public init(shape: PathShape) {
        self.shape = shape
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __PathShape(shape: shape)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        shape.id == (object as? __PathShape)?.shape.id
    }
}

extension PathShape: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> __PathShape {
        return __PathShape(shape: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __PathShape, result: inout PathShape?) {
        result = source.shape
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __PathShape, result: inout PathShape?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __PathShape?) -> PathShape {
        if let source = source {
            var result: PathShape?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return PathShape.rect
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension CAShapeLayer {
    /// Creates a shape layer with the specified shape.
    public convenience init(shape: PathShape) {
        self.init()
        pathShape = shape
    }
    
    /// The shape of the path.
    public var pathShape: PathShape? {
        get { getAssociatedValue("pathShape") }
        set {
            setAssociatedValue(newValue, key: "pathShape")
            if let newValue = newValue {
                if boundsObservation == nil {
                    boundsObservation = observeChanges(for: \.bounds) { [weak self] old, new in
                        guard old.size != new.size, let self = self, let pathShape = self.pathShape else { return }
                        self.path = pathShape.path(in: new)
                    }
                }
                path = newValue.path(in: bounds)
            } else {
                boundsObservation = nil
            }
        }
    }
    
    var boundsObservation: KeyValueObservation? {
        get { getAssociatedValue("boundsObservation") }
        set { setAssociatedValue(newValue, key: "boundsObservation") }
    }
}

fileprivate extension CGPath {
    func verticallyFlipped(in rect: CGRect) -> CGPath {
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -rect.height)
        return copy(using: &transform) ?? self
    }
}
#endif
#endif
