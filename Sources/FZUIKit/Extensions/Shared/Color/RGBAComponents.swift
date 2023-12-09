//
//  RGBAComponents.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// The RGBA (red, green, blue, alpha) components of a color.
public struct RGBAComponents: Codable, Hashable {
    
    /// The red component of the color.
    public var red: CGFloat {
        didSet { red = red.clamped(max: 1.0) }
    }
    
    /// The green component of the color.
    public var green: CGFloat {
        didSet { green = green.clamped(max: 1.0) }
    }
    
    /// The blue component of the color.
    public var blue: CGFloat {
        didSet { blue = blue.clamped(max: 1.0) }
    }
    
    /// The alpha value of the color.
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(max: 1.0) }
    }
    
    #if os(macOS)
    /// Returns the `NSColor`.
    public func nsColor() -> NSUIColor {
        NSUIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #else
    /// Returns the `UIColor`.
    public func uiColor() -> NSUIColor {
        NSUIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #endif
    
    /// Returns the `CGColor`.
    public func cgColor() -> CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Returns the SwiftUI `Color`.
    public func color() -> Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    internal static let zero = RGBAComponents(0.0, 0.0, 0.0, 0.0)
    
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    internal init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public extension NSUIColor {
    convenience init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}

extension AnimatableProperty where Self: CGColor {
    public init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}

public extension Color {
    init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, opacity: rgbaComponents.alpha)
    }
}
