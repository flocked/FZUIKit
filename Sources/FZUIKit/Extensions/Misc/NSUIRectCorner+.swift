//
//  NSUIRectCorner+.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils

public extension NSUIRectCorner {
    /// The bottom-left and bottom-right corner of the rectangle.
    static var bottomCorners: NSUIRectCorner = [.bottomLeft, .bottomRight]
    
    /// The top-left and top-right corner of the rectangle.
    static var topCorners: NSUIRectCorner = [.topLeft, .topRight]
    
    /// The bottom-left and top-left corner of the rectangle.
    static var leftCorners: NSUIRectCorner = [.topLeft, .bottomLeft]
    
    /// The bottom-right and top-right corner of the rectangle.
    static var rightCorners: NSUIRectCorner = [.topRight, .bottomRight]
    
    /// Creates a structure that represents the corners of a rectangle.
    init(_ cornerMask: CACornerMask) {
        var corner = NSUIRectCorner()
        if cornerMask.contains(.bottomLeft) {
            corner.insert(.bottomLeft)
        }
        if cornerMask.contains(.bottomRight) {
            corner.insert(.bottomRight)
        }
        if cornerMask.contains(.topLeft) {
            corner.insert(.topLeft)
        }
        if cornerMask.contains(.topRight) {
            corner.insert(.topRight)
        }
        self.init(rawValue: corner.rawValue)
    }

    /// The `CACornerMask` representation of the value.
    var caCornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        if contains(.bottomLeft) {
            cornerMask.insert(.bottomLeft)
        }
        if contains(.bottomRight) {
            cornerMask.insert(.bottomRight)
        }
        if contains(.topLeft) {
            cornerMask.insert(.topLeft)
        }
        if contains(.topRight) {
            cornerMask.insert(.topRight)
        }
        return cornerMask
    }
}

extension NSUIRectCorner: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
#endif
