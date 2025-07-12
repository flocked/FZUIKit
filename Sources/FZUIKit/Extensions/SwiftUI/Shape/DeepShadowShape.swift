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
    /// The offset of the shape.
    public var offset: CGPoint = CGPoint(x: 5.0, y: 5.0)
    /// The horizontal shift of the shape.
    public var shift: CGFloat = -0.15
    /// A Boolean value indicating whether the shift is relative to the rectangle or absolute.
    public var shiftIsRelative = true
        
    var inset: CGFloat = 0.0

    /**
     Creates a deep shadow shape.
     
     - Parameters:
        - width: The width of the shape relative to the rectangle.
        - height: The height of the shape relative to the rectangle.
        - offset: The offset of the shape.
        - shift: The horizontal shift of the shape.
        - shiftIsRelative: A Boolean value indicating whether the shift is relative to the rectangle or absolute.
     */
    public init(width: CGFloat = 1.2, height: CGFloat = 0.5, offset: CGPoint = CGPoint(x: 5.0, y: 5.0), shift: CGFloat = -0.15, shiftIsRelative: Bool = true) {
        self.width = width
        self.height = height
        self.offset = offset
        self.shift = shift
        self.shiftIsRelative = shiftIsRelative
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        let horizontalOffset = shift * rect.width
        return Path { path in
           // path.move(to: CGPoint(x: offset.x, y: rect.height - offset.y))
            path.move(to: CGPoint(x: offset.x / 2, y: rect.height - offset.y / 2))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - offset.y / 2))
            if shiftIsRelative {
                path.addLine(to: CGPoint(x: rect.width * width + horizontalOffset, y: rect.height + (rect.height * height)))
                path.addLine(to: CGPoint(x: rect.width * -(width - 1) + horizontalOffset, y: rect.height + (rect.height * height)))
            } else {
                path.addLine(to: CGPoint(x: rect.width * width + shift, y: rect.height + (rect.height * height)))
                path.addLine(to: CGPoint(x: rect.width * -(width - 1) + shift, y: rect.height + (rect.height * height)))
            }
        }
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: VectorArray<CGFloat> {
        get { [width, height, offset.x, offset.y, shift] }
        set {
            guard !newValue.isEmpty else { return }
            width = newValue[0]
            height = newValue[1]
            offset = CGPoint(newValue[2], newValue[3])
            shift = newValue[4]
        }
    }
}

extension Shape where Self == DeepShadowShape {
    /**
     Creates a deep shadow shape.
     
     - Parameters:
        - width: The width of the shape relative to the rectangle.
        - height: The height of the shape relative to the rectangle.
        - offset: The offset of the shape.
        - shift: The horizontal shift of the shape.
        - shiftIsRelative: A Boolean value indicating whether the shift is relative to the rectangle or absolute.
     */
    public static func deepShadow(width: CGFloat = 1.2, height: CGFloat = 0.5, offset: CGPoint = CGPoint(x: 5.0, y: 5.0), shift: CGFloat = -0.15, shiftIsRelative: Bool = true) -> Self {
        Self(width: width, height: height, offset: offset, shift: shift, shiftIsRelative: shiftIsRelative)
    }
}
