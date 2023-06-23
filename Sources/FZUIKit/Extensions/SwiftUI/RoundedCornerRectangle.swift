//
//  RoundedCornerRectangle.swift
//
//
//  Created by Florian Zand on 02.10.22.
//

import Foundation
import SwiftUI

public struct RoundedCornerRectangle: Shape {
    public let radius: CGFloat
    public let corners: NSUIRectCorner

    public init(radius: CGFloat, corners: NSUIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> SwiftUI.Path {
        let bezierpath = NSUIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadius: radius)
        return SwiftUI.Path(bezierpath)
    }
}
