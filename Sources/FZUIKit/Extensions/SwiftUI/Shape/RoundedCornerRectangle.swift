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
public struct RoundedCornerRectangle: Shape {
    private let radius: CGFloat
    private let corners: NSUIRectCorner

    /**
     Creates a new rounded corner rectangle shape.

     - Parameters:
        - cornerRadius: The radius of the rounded corners.
        - corners: The corners that are rounded.
     */
    public init(cornerRadius: CGFloat, corners: NSUIRectCorner) {
        radius = cornerRadius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> SwiftUI.Path {
        let bezierpath = NSUIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadius: radius)
        return SwiftUI.Path(bezierpath)
    }
}
