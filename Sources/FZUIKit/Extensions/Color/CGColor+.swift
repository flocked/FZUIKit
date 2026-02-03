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
        alpha > 0.0
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
    
    /// Returns the color components for the color in the specified color space.
    @_disfavoredOverload
    func components(for colorSpace: CGColorSpaceName) -> [CGFloat]? {
        guard let colorSpace = colorSpace.colorSpace else { return nil }
        return components(for: colorSpace)
    }
    
    /// Returns the color components for the color in the specified color space.
    func components(for colorSpace: CGColorSpace) -> [CGFloat]? {
        (self.colorSpace == colorSpace ? self : converted(to: colorSpace))?.components
    }
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
            guard let info else { return }
            let image = Unmanaged<CGImage>.fromOpaque(info).takeUnretainedValue()
            context.draw(image, in: image.size.rect)
        }
        let releasePattern: CGPatternReleaseInfoCallback = { info in
            guard let info else { return }
            Unmanaged<CGImage>.fromOpaque(info).release()
        }
        let info = Unmanaged.passRetained(patternImage).toOpaque()
        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: releasePattern)
        let bounds = CGRect(x: 0, y: 0, width: patternImage.width, height: patternImage.height)
        let pattern = CGPattern(info: info, bounds: bounds, matrix: .identity, xStep: bounds.width, yStep: bounds.height, tiling: .constantSpacing, isColored: true, callbacks: &callbacks)!
        self = CGColor(patternSpace: CGColorSpace(patternBaseSpace: nil)!, pattern: pattern, components: [1.0])!
    }
    
    /**
     Creates a `CGColor` representing a repeating pattern tile drawn by a custom closure.

     The drawing handler is called each time the pattern tile needs to be drawn.

     - Parameters:
       - patternSize: The size of one tile in the pattern. This determines how the pattern
         repeats.
       - drawingHandler: A closure that takes a `CGContext` and draws one tile of the pattern.

     - Returns: A `CGColor` representing a repeating pattern.
     
     - Note: The drawingHandler closure cannot capture local variables from outside directly for the C callback. All state should be captured inside the closure or via objects stored in the closure.
    */
    init(patternSize: CGSize, drawingHandler: @escaping (CGContext) -> Void) {
        let drawBox = PatternDrawBox(drawingHandler)
        let info = Unmanaged.passRetained(drawBox).toOpaque()
        let drawCallback: CGPatternDrawPatternCallback = { info, ctx in
            guard let info else { return }
            let box = Unmanaged<PatternDrawBox>.fromOpaque(info).takeUnretainedValue()
            box.block(ctx)
        }
        let releaseCallback: CGPatternReleaseInfoCallback = { info in
            guard let info else { return }
            Unmanaged<PatternDrawBox>.fromOpaque(info).release()
        }
        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawCallback, releaseInfo: releaseCallback)
        let pattern = CGPattern(info: info, bounds: CGRect(origin: .zero, size: patternSize), matrix: .identity, xStep: patternSize.width, yStep: patternSize.height, tiling: .constantSpacing, isColored: true, callbacks: &callbacks)!
        let colorSpace = CGColorSpace(patternBaseSpace: nil)!
        self = CGColor(patternSpace: colorSpace, pattern: pattern, components: [1.0])!
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

fileprivate class PatternDrawBox {
    let block: (CGContext) -> Void
    init(_ block: @escaping (CGContext) -> Void) { self.block = block }
}
