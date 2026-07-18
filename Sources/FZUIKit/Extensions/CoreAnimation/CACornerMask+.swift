//
//  CACornerMask+.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
import QuartzCore.CoreAnimation
import FZSwiftUtils

public extension CACornerMask {
    /// All corners.
    static let all: Self = [.bottomLeft, .bottomRight, .topLeft, .topRight]
    /// No ocrners.
    static let none: Self = []

    internal var toAll: CACornerMask {
        self == .none ? .all : self
    }

    #if os(macOS)
    /// The bottom-left corner.
    static let bottomLeft: CACornerMask = .layerMinXMinYCorner
    /// The bottom-right corner.
    static let bottomRight: CACornerMask = .layerMaxXMinYCorner
    /// The top-left corner.
    static let topLeft: CACornerMask = .layerMinXMaxYCorner
    /// The top-right corner.
    static let topRight: CACornerMask = .layerMaxXMaxYCorner

    /// The Bottom-left and bottom-right corner.
    static let bottomCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    /// The top-left and top-right corner.
    static let topCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    #elseif canImport(UIKit)
    /// The bottom-left corner.
    static let bottomLeft: CACornerMask = .layerMinXMaxYCorner
    /// The bottom-right corner.
    static let bottomRight: CACornerMask = .layerMaxXMaxYCorner
    /// The top-left corner.
    static let topLeft: CACornerMask = .layerMinXMinYCorner
    /// The top-right corner.
    static let topRight: CACornerMask = .layerMaxXMinYCorner

    /// The Bottom-left and bottom-right corner.
    static let bottomCorners: CACornerMask = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

    /// The top-left and top-right corner.
    static let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    #endif

    /// The Bottom-left and top-left corner.
    static let leftCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

    /// The Bottom-right and top-right corner.
    static let rightCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
}

extension CACornerMask: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension CACornerMask: Swift.CustomStringConvertible {
    public var description: String {
        var strings: [String] = []
        if contains(.layerMinXMinYCorner) { strings += ".minXMinY" }
        if contains(.layerMaxXMinYCorner) { strings += ".maxXMinY" }
        if contains(.layerMaxXMinYCorner) { strings += ".maxXMinY" }
        if contains(.layerMaxXMaxYCorner) { strings += ".maxXMaxY" }
        return "[\(strings.joined(separator: ", "))]"
    }
}
#endif
