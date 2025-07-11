//
//  DeepShadowShape.swift
//
//
//  Created by Florian Zand on 20.12.23.
//

import Foundation
import SwiftUI


/// A deep shadow shape.
public struct DeepShadowShape: Shape, InsettableShape {
    /// The width of the shape relative to the rectangle.
    public var width: CGFloat = 1.2
    /// The height of the shape relative to the rectangle.
    public var height: CGFloat = 0.5
    /// The radius of the shape.
    public var radius: CGFloat = 5.0
    /// The horizontal offset of the shape.
    public var offset: CGFloat = -50
    
    var inset: CGFloat = 0.0

    /**
     Creates a deep shadow shape.
     
     - Parameters:
        - width: The width of the shape relative to the rectangle.
        - height: The height of the shape relative to the rectangle.
        - radius: The radius of the shape.
        - offset: The horizontal offset of the shape.
     */
    public init(width: CGFloat = 1.2, height: CGFloat = 0.5, radius: CGFloat = 5.0, offset: CGFloat = -50) {
        self.width = width
        self.height = height
        self.radius = radius
        self.offset = offset
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        return Path { path in
            path.move(to: CGPoint(x: radius / 2, y: rect.height - radius / 2))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius / 2))
            path.addLine(to: CGPoint(x: rect.width * width + offset, y: rect.height + (rect.height * height)))
            path.addLine(to: CGPoint(x: rect.width * -(width - 1) + offset, y: rect.height + (rect.height * height)))
        }
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(AnimatablePair(width, height), AnimatablePair(radius, offset)) }
        set {
            width = newValue.first.first
            height = newValue.first.second
            radius = newValue.second.first
            offset = newValue.second.second
        }
    }
}

extension Shape where Self == DeepShadowShape {
    /**
     Creates a deep shadow shape.
     
     - Parameters:
        - width: The width of the shape relative to the rectangle.
        - height: The height of the shape relative to the rectangle.
        - radius: The radius of the shape.
        - offset: The horizontal offset of the shape.
     */
    public static func deepShadow(width: CGFloat = 1.2, height: CGFloat = 0.5, radius: CGFloat = 5.0, offset: CGFloat = -50) -> Self {
        Self(width: width, height: height, radius: radius, offset: offset)
    }
}
