//
//  CGColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

public extension CGColor {
    /**
     Creates a new color in the specified color space.

     - Parameters:
        - colorSpaceName: The name of the destination color space.
        - intent: The mechanism to use to match the color when the color is outside the gamut of the new color space.
     - Returns: A new color in the destination color space that matches (or closely approximates) the current color.
     */
    @_disfavoredOverload
    func converted(to colorSpaceName: CGColorSpaceName, intent: CGColorRenderingIntent = .defaultIntent) -> CGColor? {
        guard let colorSpace = CGColorSpace(name: colorSpaceName) else { return nil }
        return converted(to: colorSpace, intent: intent, options: nil)
    }
    
    /**
     Creates a new color in the specified color space.

     - Parameters:
        - colorSpace: The destination color space.
        - intent: The mechanism to use to match the color when the color is outside the gamut of the new color space.
     - Returns: A new color in the destination color space that matches (or closely approximates) the source color.
     */
    func converted(to colorSpace: CGColorSpace, intent: CGColorRenderingIntent = .defaultIntent) -> CGColor? {
        guard self.colorSpace != colorSpace else { return self }
        return converted(to: colorSpace, intent: intent, options: nil)
    }

    /// A Boolean value indicating whether the color is visible (alpha value isn't zero).
    var isVisible: Bool {
        alpha != 0.0
    }

    /**
     A Boolean value indicating whether the color is light.

     It is useful when you need to know whether you should display the text in black or white.
     */
    var isLight: Bool {
        rgb().isLight
    }

    /**
     Creates a color object with the specified alpha component.

     - Parameter alpha: The opacity value of the new color object, specified as a value from `0.0` to `1.0`. Alpha values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new `CGColor` object.
     */
    func withAlpha(_ alpha: CGFloat) -> CGColor {
        copy(alpha: alpha) ?? self
    }

    #if os(macOS)
    /// Returns a `NSColor` representation of the color.
    var nsColor: NSColor? {
        NSColor(cgColor: self)
    }

    /// Returns a `Color` representation of the color.
    var swiftUI: Color? {
        nsColor?.swiftUI
    }

    #elseif canImport(UIKit)
    /// Returns a `UIColor` representation of the color.
    var uiColor: UIColor {
        UIColor(cgColor: self)
    }

    /// Returns a `Color` representation of the color.
    var swiftUI: Color {
        uiColor.swiftUI
    }

    /// The clear color in the Generic gray color space.
    static var clear: CGColor {
        CGColor(gray: 0, alpha: 0)
    }

    /// The black color in the Generic gray color space.
    static var black: CGColor {
        CGColor(gray: 1, alpha: 1)
    }

    /// The white color in the Generic gray color space.
    static var white: CGColor {
        CGColor(gray: 0, alpha: 1)
    }
    #endif
}

public extension CFType where Self == CGColor {
    /**
     Creates a color with the specified color space and components.
     
     - Parameters:
        - colorSpace: A color space for the new color.
        - components: An array of intensity values describing the color. The array should contain n+1 values that correspond to the n color components in the specified color space, followed by the alpha component. Each component value should be in the range appropriate for the color space. Values outside this range will be clamped to the nearest correct value.
     - Returns: A new color.
     */
    init?(colorSpace: CGColorSpace, components: [CGFloat]) {
        guard components.count >= colorSpace.numberOfComponents else { return nil }
        var components = components.count == colorSpace.numberOfComponents ? components + 1.0 : components
        guard let color = CGColor(colorSpace: colorSpace, components: &components) else { return nil }
        self = color
    }

    /**
     Creates a color with the specified color space and components.
     
     - Parameters:
        - colorSpace: A color space for the new color.
        - components: An array of intensity values describing the color. The array should contain n+1 values that correspond to the n color components in the specified color space, followed by the alpha component. Each component value should be in the range appropriate for the color space. Values outside this range will be clamped to the nearest correct value.
     - Returns: A new color.
     */
    @_disfavoredOverload
    init?(colorSpace: CGColorSpaceName, components: [CGFloat]) {
        guard let colorSpace = CGColorSpace(name: colorSpace) else { return nil }
        guard let color = Self(colorSpace: colorSpace, components: components) else { return nil }
        self = color
    }
    
    /**
     Creates a color in the extended sRGB color space.
     
     - Parameters:
        - red: The red component value.
        - green: The green component value.
        - blue: The blue component value.
        - alpha: The alpha value (between `0.0` - `1.0`).
     */
    init(extendedSRGBRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(colorSpace: .extendedSRGB, components: [red, green, blue, alpha])!
    }
    
    /**
     Creates a `CGColor` from a `CGImage`, using the image as a repeating pattern.

     The color can be used to fill shapes, strokes, or layers with the image pattern.
     
     - Parameter patternImage: The image to use as a pattern.
     */
    init(patternImage: CGImage) {
        let drawPattern: CGPatternDrawPatternCallback = { info, context in
            let image = Unmanaged<CGImage>.fromOpaque(info!).takeUnretainedValue()
            context.draw(image, in: CGRect(origin: .zero, size: image.size))
        }
        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)
        let pattern = CGPattern(info: Unmanaged.passUnretained(patternImage).toOpaque(), bounds: patternImage.size.rect, matrix: .identity, xStep: CGFloat(patternImage.width), yStep: CGFloat(patternImage.height), tiling: .constantSpacing, isColored: true, callbacks: &callbacks)!
        self = CGColor(patternSpace: CGColorSpace(patternBaseSpace: nil)!, pattern: pattern, components: [1.0])!
    }
    
    internal var nsUIColor: NSUIColor? {
        NSUIColor(cgColor: self)
    }
}

extension Swift.Decodable where Self: CGColor {
    public init(from decoder: any Decoder) throws {
        self = try NSUIColor(from: decoder).cgColor as! Self
    }
    
}

extension CGColor: Swift.Encodable, Swift.Decodable {
    public func encode(to encoder: any Encoder) throws {
        try nsUIColor.encode(to: encoder)
    }
}
