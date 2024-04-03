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

extension NSDirectionalRectEdge: Hashable { }

public extension CGRect {
    func inset(by edgeInsets: EdgeInsets) -> CGRect {
        inset(by: NSUIEdgeInsets(edgeInsets))
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
        /// An edge insets struct whose top, left, bottom, and right fields are all set to 0.
        static var zero = NSEdgeInsets(0)
    #endif

    /// Creates an edge insets structure with the specified value for top, bottom, left and right.
    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    /// Creates an edge insets from a `EdgeInsets`.
    init(_ edgeInsets: EdgeInsets) {
        self.init(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
    }

    /// Creates an edge insets structure with the specified width (left + right) and height (top + bottom) values.
    init(width: CGFloat = 0.0, height: CGFloat = 0.0) {
        let wValue = width / 2.0
        let hValue = height / 2.0
        self.init(top: hValue, left: wValue, bottom: hValue, right: wValue)
    }
    
    /// Creates an edge insets structure with the specified shared bottom/top and left/right values.
    init(bottomTop: CGFloat, leftRight: CGFloat) {
        self.init(top: bottomTop, left: leftRight, bottom: bottomTop, right: leftRight)
    }
    
    /// Creates an edge insets structure with the specified shared bottom and top values.
    init(bottomTop: CGFloat) {
        self.init(bottomTop: bottomTop, leftRight: 0.0)
    }
    
    /// Creates an edge insets structure with the specified shared left and right values.
    init(leftRight: CGFloat) {
        self.init(bottomTop: 0.0, leftRight: leftRight)
    }

    /// The width (left + right) of the insets.
    var width: CGFloat {
        get { left + right }
        set {
            let value = newValue / 2.0
            left = value
            right = value
        }
    }

    /// The height (top + bottom) of the insets.
    var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }
    
    /// The bottom and top value.
    var bottomTop: CGFloat {
        get { max(bottom, top) }
        set {
            bottom = newValue
            top = newValue
        }
    }
    
    /// The left and right value.
    var leftRight: CGFloat {
        get { max(left, right) }
        set {
            left = newValue
            right = newValue
        }
    }

    /// The insets as `NSDirectionalEdgeInsets`.
    var directional: NSDirectionalEdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
    }

    /// The insets as `EdgeInsets`.
    var edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public extension NSDirectionalEdgeInsets {
    #if os(macOS)
        /// A directional edge insets structure whose top, leading, bottom, and trailing fields all have a value of ´0´.
        static var zero = NSDirectionalEdgeInsets(0)
    #endif

    /// Creates an edge insets structure with the specified value for top, bottom, leading and trailing.
    init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Creates an edge insets structure with the specified width (leading + trailing) and height (top + bottom) values.
    init(width: CGFloat = 0.0, height: CGFloat = 0.0) {
        self.init()
        self.width = width
        self.height = height
    }
    
    /// Creates an edge insets structure with the specified shared bottom/top and leading/trailing values.
    init(bottomTop: CGFloat, leadingTrailing: CGFloat) {
        self.init(top: bottomTop, leading: leadingTrailing, bottom: bottomTop, trailing: leadingTrailing)
    }
    
    /// Creates an edge insets structure with the specified shared bottom and top values.
    init(bottomTop: CGFloat) {
        self.init(bottomTop: bottomTop, leadingTrailing: 0.0)
    }
    
    /// Creates an edge insets structure with the specified shared leading and trailing values.
    init(leadingTrailing: CGFloat) {
        self.init(bottomTop: 0.0, leadingTrailing: leadingTrailing)
    }

    /// The width (leading + trailing) of the insets.
    var width: CGFloat {
        get { leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    /// The height (top + bottom) of the insets.
    var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }
    
    /// The bottom and top value.
    var bottomTop: CGFloat {
        get { max(bottom, top) }
        set {
            bottom = newValue
            top = newValue
        }
    }
    
    /// The leading and trailing value.
    var leadingTrailing: CGFloat {
        get { max(leading, trailing) }
        set {
            leading = newValue
            trailing = newValue
        }
    }

    /// The insets as `EdgeInsets`.
    var edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    #if os(macOS)
        /// The insets as `NSEdgeInsets`.
        var nsEdgeInsets: NSEdgeInsets {
            .init(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
        }

    #elseif canImport(UIKit)
        /// The insets as `UIEdgeInsets`.
        var uiEdgeInsets: UIEdgeInsets {
            .init(top: top, left: leading, bottom: bottom, right: trailing)
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

extension Edge.Set {
    static var width: Self {
        [.trailing, .trailing]
    }

    static var height: Self {
        [.top, .bottom]
    }
}

extension EdgeInsets: Hashable {
    /// An edge insets struct whose top, leading, bottom, and trailing fields are all set to 0.
    public static var zero: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)

    /// Creates an edge insets structure whose specified edges have the value.
    public init(_ edges: Edge.Set, _ value: CGFloat) {
        self.init(top: edges.contains(.top) ? value : 0, leading: edges.contains(.leading) ? value : 0, bottom: edges.contains(.bottom) ? value : 0, trailing: edges.contains(.trailing) ? value : 0)
    }

    /// Creates an edge insets structure with the specified value for top, bottom, leading and right.
    public init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Creates an edge insets structure with the specified width (leading + trailing) and height (top + bottom) values.
    public init(width: CGFloat, height: CGFloat) {
        self.init()
        self.width = width
        self.height = height
    }
    
    /// Creates an edge insets structure with the specified shared bottom/top and leading/trailing values.
    init(bottomTop: CGFloat, leadingTrailing: CGFloat) {
        self.init(top: bottomTop, leading: leadingTrailing, bottom: bottomTop, trailing: leadingTrailing)
    }
    
    /// Creates an edge insets structure with the specified shared bottom and top values.
    init(bottomTop: CGFloat) {
        self.init(bottomTop: bottomTop, leadingTrailing: 0.0)
    }
    
    /// Creates an edge insets structure with the specified shared leading and trailing values.
    init(leadingTrailing: CGFloat) {
        self.init(bottomTop: 0.0, leadingTrailing: leadingTrailing)
    }

    /// The width (leading + trailing) of the insets.
    public var width: CGFloat {
        get { leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    /// The height (top + bottom) of the insets.
    public var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }
    
    /// The bottom and top value.
    public var bottomTop: CGFloat {
        get { max(bottom, top) }
        set {
            bottom = newValue
            top = newValue
        }
    }
    
    /// The leading and trailing value.
    public var leadingTrailing: CGFloat {
        get { max(leading, trailing) }
        set {
            leading = newValue
            trailing = newValue
        }
    }
    
    /// The insets as `NSDirectionalEdgeInsets`.
    var directional: NSDirectionalEdgeInsets {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
    
    #if os(macOS)
    /// The insets as `NSEdgeInsets`.
    var nsEdgeInsets: NSEdgeInsets {
        .init(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
    }
    #elseif canImport(UIKit)
    /// The insets as `UIEdgeInsets`.
    var uiEdgeInsets: UIEdgeInsets {
        .init(top: top, left: leading, bottom: bottom, right: trailing)
    }
    #endif

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(leading)
        hasher.combine(trailing)
    }
}
