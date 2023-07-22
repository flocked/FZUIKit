//
//  NSUIEdgeInset+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension NSDirectionalRectEdge: Hashable {}

public extension CGRect {
    func inset(by edgeInsets: EdgeInsets) -> CGRect {
        return inset(by: NSUIEdgeInsets(edgeInsets))
    }

    func inset(by edgeInsets: NSUIEdgeInsets) -> CGRect {
        return inset(by: edgeInsets.directional)
    }

    func inset(by edgeInsets: NSDirectionalEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += edgeInsets.leading
        result.origin.y += edgeInsets.top
        result.size.width -= edgeInsets.leading - edgeInsets.trailing
        result.size.height -= edgeInsets.top - edgeInsets.bottom
        return result
    }
}

extension NSUIEdgeInsets: Hashable {
    public static func == (lhs: NSUIEdgeInsets, rhs: NSUIEdgeInsets) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(left)
        hasher.combine(right)
    }
}

public extension NSUIEdgeInsets {
    #if os(macOS)
    static var zero = NSEdgeInsets(0)
    #endif

    var directional: NSDirectionalEdgeInsets {
        return .init(top: top, leading: left, bottom: bottom, trailing: right)
    }

    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    init(_ edgeInsets: EdgeInsets) {
        self.init(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
    }

    init(width: CGFloat = 0.0, height: CGFloat = 0.0) {
        let wValue = width / 2.0
        let hValue = height / 2.0
        self.init(top: hValue, left: wValue, bottom: hValue, right: wValue)
    }

    var width: CGFloat {
        get { return left + right }
        set {
            let value = newValue / 2.0
            left = value
            right = value
        }
    }

    var height: CGFloat {
        get { return top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }

    var edgeInsets: EdgeInsets {
        return EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public extension NSDirectionalEdgeInsets {
    static var zero = NSDirectionalEdgeInsets(0)

    init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    init(width: CGFloat = 0.0, height: CGFloat = 0.0) {
        self.init()
        self.width = width
        self.height = height
    }

    var width: CGFloat {
        get { return leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    var height: CGFloat {
        get { return top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }

    var edgeInsets: EdgeInsets {
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    #if os(macOS)
    var nsEdgeInsets: NSEdgeInsets {
        return .init(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
    }

    #elseif canImport(UIKit)
    var uiEdgeInsets: NSUIEdgeInsets {
        return .init(top: top, left: leading, bottom: bottom, right: trailing)
    }
    #endif
}

extension NSDirectionalEdgeInsets: Hashable {
    public static func == (lhs: NSDirectionalEdgeInsets, rhs: NSDirectionalEdgeInsets) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(trailing)
        hasher.combine(leading)
    }
}

public extension Edge.Set {
    static var width: Self {
        return [.trailing, .trailing]
    }

    static var height: Self {
        return [.top, .bottom]
    }
}

extension EdgeInsets: Hashable {
    public static var zero: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)

    public init(_ edges: Edge.Set, _ value: CGFloat) {
        self.init(top: edges.contains(.top) ? value : 0, leading: edges.contains(.leading) ? value : 0, bottom: edges.contains(.bottom) ? value : 0, trailing: edges.contains(.trailing) ? value : 0)
    }

    public init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    public init(width: CGFloat, height: CGFloat) {
        self.init()
        self.width = width
        self.height = height
    }

    public var width: CGFloat {
        get { return leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    public var height: CGFloat {
        get { return top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(leading)
        hasher.combine(trailing)
    }
}
