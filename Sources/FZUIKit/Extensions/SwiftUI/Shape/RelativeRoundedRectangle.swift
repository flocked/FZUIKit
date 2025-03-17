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

 The corner radius is defined as a fraction of the smaller dimension of the rectangle,
 ensuring proportional rounding regardless of the rectangle's size.

 - A `cornerRadius` of `0.0` results in a standard rectangle with no rounded corners.
 - A `cornerRadius` of `1.0` makes the corners fully rounded, effectively turning the shape
   into a capsule if the width and height differ, or a circle if they are equal.
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
    public var style: RoundedCornerStyle = .circular
    
    public func path(in rect: CGRect) -> Path {
        let minDimension = min(rect.width, rect.height)
        let radius = minDimension * cornerRadius
        return Path(roundedRect: rect, cornerRadius: radius, style: style)
    }
    
    public var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
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
    public static func rect(relativeCornerRadius cornerRadius: CGFloat, style: RoundedCornerStyle = .circular) -> RelativeRoundedRectangle {
        RelativeRoundedRectangle(cornerRadius: cornerRadius, style: style)
    }
}
