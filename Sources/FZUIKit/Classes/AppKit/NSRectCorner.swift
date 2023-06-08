//
//  File.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import Foundation

public struct NSRectCorner: OptionSet {
    public let rawValue: UInt
    public static let topLeft = NSRectCorner(rawValue: 1 << 0)
    public static let topRight = NSRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
    public static var allCorners: NSRectCorner {
        return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
#endif
