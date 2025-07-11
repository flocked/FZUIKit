//
//  RoundedCornerRectangle.swift
//
//
//  Created by Florian Zand on 02.10.22.
//

import Foundation
import SwiftUI
import FZSwiftUtils

/// A rectangular shape with specific corners that are rounded, aligned inside the frame of the view containing it.
public struct RoundedCornerRectangle: Shape, InsettableShape {
    /// The radius of the rounded corners.
    public var cornerRadius: CGFloat
    
    /// The corners that are rounded.
    public var corners: NSUIRectCorner
    var inset: CGFloat = 0.0

    /**
     Creates a new rounded corner rectangle shape.

     - Parameters:
        - cornerRadius: The radius of the rounded corners.
        - corners: The corners that are rounded.
     */
    public init(cornerRadius: CGFloat, corners: NSUIRectCorner) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        Path(NSUIBezierPath(roundedRect: rect.insetBy(dx: inset, dy: inset), byRoundingCorners: corners, cornerRadius: cornerRadius))
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
}
