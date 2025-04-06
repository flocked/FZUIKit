//
//  File.swift
//  
//
//  Created by Florian Zand on 16.03.25.
//

import Foundation
import SwiftUI
import FZSwiftUtils

/**
 A shape that represents a rectangle with a relative corner radius.

 The corner radius is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.

 - A `cornerRadius` of `0.0` results in a standard rectangle with no rounded corners.
 - A `cornerRadius` of `1.0` makes the corners fully rounded, effectively turning the shape into a capsule if the width and height differ, or a circle if they are equal.
 */
public struct RelativeRoundedRectangle: Shape {
    /**
     A value between `0.0` and `1.0` representing the relative corner radius.
     
     - `0.0`: No rounded corners (regular rectangle).
     - `1.0`: Maximum rounding (capsule or circle, depending on aspect ratio).
     */
    public var cornerRadius: CGFloat {
        didSet { cornerRadius = cornerRadius.clamped(to: 0...1) }
    }
    
    /// The style of corners drawn by the rounded rectangle.
    public var style: RoundedCornerStyle
    
    var inset: CGFloat = 0.0
    
    /// Creates a new relative rounded rectangle shape.
    public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) {
        self.cornerRadius = cornerRadius.clamped(max: 1.0)
        self.style = style
    }
    
    init(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous, inset: CGFloat) {
        self.cornerRadius = cornerRadius.clamped(max: 1.0)
        self.style = style
        self.inset = inset
    }
    
    public func path(in rect: CGRect) -> Path {
        let minDimension = min(rect.width, rect.height)
        let radius = minDimension * cornerRadius
        return Path(roundedRect: rect.insetBy(dx: inset, dy: inset), cornerRadius: radius, style: style)
    }
    
    public var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
}

extension RelativeRoundedRectangle: InsettableShape {
    public func inset(by amount: CGFloat) -> RelativeRoundedRectangle {
        RelativeRoundedRectangle.init(cornerRadius: cornerRadius, style: style, inset: inset + amount)
    }
    
    public typealias InsetShape = RelativeRoundedRectangle
}

extension Shape where Self == RelativeRoundedRectangle {
    /**
     A rectangular shape with relative corner radius.
     
     The corner radius is defined as a fraction of the smaller dimension of the rectangle,
     ensuring proportional rounding regardless of the rectangle's size.

     - A `cornerRadius` of `0.0` results in a standard rectangle with no rounded corners.
     - A `cornerRadius` of `1.0` makes the corners fully rounded, effectively turning the shape
       into a capsule if the width and height differ, or a circle if they are equal.
     */
    public static func relativeRoundedRect(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) -> RelativeRoundedRectangle {
        RelativeRoundedRectangle(cornerRadius: cornerRadius, style: style)
    }
}
