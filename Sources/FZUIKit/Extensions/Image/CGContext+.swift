//
//  CGContext+.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

#if canImport(CoreImage)
import Foundation
import CoreImage
import FZSwiftUtils

extension CGContext {
    /// Returns the size of the bitmap context.
    public var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    /// Returns the rectangle representing the entire drawable area of the context.
    public var bounds: CGRect {
        CGRect(origin: .zero, size: size)
    }
    
    /// Fills the specified rectangle with the provided color.
    public func fill(_ color: CGColor, in rect: CGRect) {
        saveGState()
        setFillColor(color)
        fill(rect)
        restoreGState()
    }
    
    /// Fills the entire context bounds with the specified color.
    public func fill(_ color: CGColor) {
        fill(color, in: bounds)
    }
    
    /// Strokes the specified rectangle with the provided color.
    public func stroke(_ color: CGColor, in rect: CGRect) {
        saveGState()
        setStrokeColor(color)
        stroke(rect)
        restoreGState()
    }
    
    /// Strokes the entire context bounds using the specified stroke color.
    public func stroke(_ color: CGColor) {
        stroke(color, in: bounds)
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Enables shadowing with color a graphics context.
    public func setShadow(_ configuration: ShadowConfiguration) {
        setShadow(offset: configuration.offset.size, blur: configuration.opacity, color: configuration.resolvedColor()?.cgColor)
    }
    
    /// Configurates the stroke with the specified border configuration.
    public func setStroke(_ configuration: BorderConfiguration) {
        guard configuration.width > 0.0, let color = configuration.resolvedColor()?.cgColor, color.alpha > 0.0 else { return }
        setLineWidth(configuration.width)
        setLineCap(configuration.dash.lineCap)
        setLineJoin(configuration.dash.lineJoin)
        setMiterLimit(configuration.dash.mitterLimit)
        setLineDash(phase: configuration.dash.phase, lengths: configuration.dash.pattern)
        setStrokeColor(color)
    }
    
    public func setGradient(_ gradient: Gradient, in rect: CGRect) {
        guard let cgGradient = gradient.cgGradient() else { return }
        switch gradient.type {
        case .linear:
            drawLinearGradient(cgGradient, start: .zero, end: .zero, options: [])
        case .radial:
            let radius = hypot(rect.width, rect.height) / 2
            drawRadialGradient(cgGradient, startCenter: <#T##CGPoint#>, startRadius: 0.0, endCenter: <#T##CGPoint#>, endRadius: radius, options: [])
        case .conic:
            if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
                drawConicGradient(cgGradient, center: rect.center, angle: 0.0)
            }
        }
    }
    #endif
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension CGContext {
    public func drawConicGradient(_ gradient: CGGradient, center: CGPoint, angle: CGFloat) {
        CGContextDrawConicGradient(self, gradient, center, angle)
    }
}

public extension CFType where Self == CGContext {
    /**
     Creates a new bitmap graphics context with the size.
     
     - Parameters:
       - data: A pointer to memory for the bitmap. If `nil`, the system allocates memory automatically.
       - size: The size of the bitmap context.
       - bitsPerComponent: The number of bits for each color component.
       - bytesPerRow: The number of bytes per row of the bitmap. Default is `0`, which lets Core Graphics calculate it automatically.
       - space: A color space name for the bitmap. If `nil` the default color space is used.
       - bitmapInfo: Bitmap information flags specifying alpha info, byte order, etc.
     
     - Returns: A new `CGContext` if creation succeeds, otherwise `nil`.
     */
    init?(data: UnsafeMutableRawPointer? = nil, size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, space: CGColorSpaceName? = nil, bitmapInfo: CGBitmapInfo) {
        guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space != nil ? CGColorSpace(name: space!) : nil, bitmapInfo: bitmapInfo) else { return nil }
        self = context
    }
    
    /**
     Creates a new bitmap graphics context with the specified size.

     - Parameters:
        - data: A pointer to memory for the bitmap. If `nil`, the system allocates memory automatically.
        - size: The size of the bitmap context.
        - bitsPerComponent: The number of bits for each color component.
        - bytesPerRow: The number of bytes per row of the bitmap. Default is `0`, which lets Core Graphics calculate it automatically.
        - space: A color space name for the bitmap. If `nil` the default color space is used.
        - hasAlpha: A Boolean value indicating whether the bitmap should include an alpha channel.
     
     - Returns: A new `CGContext` if creation succeeds, otherwise `nil`.
     */
    init?(data: UnsafeMutableRawPointer? = nil, size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, space: CGColorSpaceName? = nil, hasAlpha: Bool = true) {
        guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space != nil ? CGColorSpace(name: space!) : nil, bitmapInfo: hasAlpha ? .rgba : .rgb) else { return nil }
        self = context
    }
}
#endif
