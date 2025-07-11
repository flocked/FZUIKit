//
//  UnevenRelativeRoundedRectangle.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

import Foundation
import SwiftUI
import FZSwiftUtils

/**
 A rectangular shape with rounded corners with different relative values, aligned inside the frame of the view containing it.

 The corner radius of each corner is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.
 
 A value of `0.0` represents no rounding and `1.0` the maximum.
 */
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct UnevenRelativeRoundedRectangle: Shape, InsettableShape {
    /**
     The relative radii of each corner of the rounded rectangle.
     
     The corner radius of each corner is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.
     
     A value of `0.0` represents no rounding and `1.0` the maximum.
     */
    public var cornerRadii: RectangleCornerRadii {
        didSet { cornerRadii = cornerRadii.clamped() }
    }
    
    /// The style of corners drawn by the rounded rectangle.
    public var style: RoundedCornerStyle
    
    var inset: CGFloat = 0.0
    
    /// Creates a new relative rounded rectangle shape with uneven corners.
    public init(topLeadingRadius: CGFloat = 0.0, bottomLeadingRadius: CGFloat = 0.0, bottomTrailingRadius: CGFloat = 0.0, topTrailingRadius: CGFloat = 0.0, style: RoundedCornerStyle = .continuous) {
        self.style = style
        self.cornerRadii = .init(topLeading: topLeadingRadius, bottomLeading: bottomLeadingRadius, bottomTrailing: bottomTrailingRadius, topTrailing: topTrailingRadius).clamped()
    }
    
    public func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(cornerRadii: cornerRadii * min(rect.width, rect.height)).path(in: rect.insetBy(dx: inset, dy: inset))
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: RectangleCornerRadii.AnimatableData {
        get { cornerRadii.animatableData }
        set { cornerRadii.animatableData = newValue }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Shape where Self == UnevenRelativeRoundedRectangle {
    /**
     A rectangular shape with rounded corners with different relative values, aligned inside the frame of the view containing it.

     The corner radius of each corner is defined as a fraction of the smaller dimension of the rectangle, ensuring proportional rounding regardless of the rectangle's size.
     
     A value of `0.0` represents no rounding and `1.0` the maximum.

     - Parameters:
        - topLeadingRadius: The relative radius of the top-leading corner.
        - bottomLeadingRadius: The relative radius of the bottom-leading corner.
        - topLeadingRadius: The relative radius of the bottom-trailing corner.
        - topTrailingRadius: The relative radius of the top-trailing corner.
        - style: The style of corners drawn by the rounded rectangle.
     */
    public static func relativeRoundedRect(topLeadingRadius: CGFloat = 0.0, bottomLeadingRadius: CGFloat = 0.0, bottomTrailingRadius: CGFloat = 0.0, topTrailingRadius: CGFloat = 0.0, style: RoundedCornerStyle = .continuous) -> UnevenRelativeRoundedRectangle {
        .init(topLeadingRadius: topLeadingRadius, bottomLeadingRadius: bottomLeadingRadius, bottomTrailingRadius: bottomTrailingRadius, topTrailingRadius: topTrailingRadius, style: style)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
fileprivate extension RectangleCornerRadii {
    func clamped() -> Self {
        Self(topLeading: topLeading.clamped(max: 1.0), bottomLeading: bottomLeading.clamped(max: 1.0), bottomTrailing: bottomTrailing.clamped(max: 1.0), topTrailing: topTrailing.clamped(max: 1.0))
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> Self {
        Self(topLeading: lhs.topLeading * rhs, bottomLeading: lhs.bottomLeading * rhs, bottomTrailing: lhs.bottomTrailing * rhs, topTrailing: lhs.topTrailing * rhs)
    }
}
