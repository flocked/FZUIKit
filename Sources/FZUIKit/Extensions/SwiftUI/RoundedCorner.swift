//
//  File.swift
//
//
//  Created by Florian Zand on 02.10.22.
//

import Foundation
import SwiftUI

public struct RectCorner: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let topLeft = RectCorner(rawValue: 1 << 0)
    public static let topRight = RectCorner(rawValue: 1 << 1)
    public static let bottomLeft = RectCorner(rawValue: 1 << 2)
    public static let bottomRight = RectCorner(rawValue: 1 << 3)
    public static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]

    public init(_ rectCorner: NSUIRectCorner) {
        var corner = RectCorner()
        if rectCorner.contains(.bottomLeft) {
            corner.insert(.bottomLeft)
        }
        if rectCorner.contains(.bottomRight) {
            corner.insert(.bottomRight)
        }
        if rectCorner.contains(.topLeft) {
            corner.insert(.topLeft)
        }
        if rectCorner.contains(.topRight) {
            corner.insert(.topRight)
        }
        self.init(rawValue: corner.rawValue)
    }

    internal var rectCorner: NSUIRectCorner {
        var corner = NSUIRectCorner()
        if contains(.bottomLeft) {
            corner.insert(.bottomLeft)
        }
        if contains(.bottomRight) {
            corner.insert(.bottomRight)
        }
        if contains(.topLeft) {
            corner.insert(.topLeft)
        }
        if contains(.topRight) {
            corner.insert(.topRight)
        }
        return corner
    }
}

public struct RoundedCorner: Shape {
    public let radius: CGFloat
    public let corners: RectCorner

    public init(radius: CGFloat, corners: RectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> SwiftUI.Path {
        let bezierpath = NSUIBezierPath(roundedRect: rect, byRoundingCorners: corners.rectCorner, cornerRadius: radius)
        return SwiftUI.Path(bezierpath)
    }
}
