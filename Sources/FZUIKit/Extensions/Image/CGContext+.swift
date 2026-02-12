//
//  CGContext+.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics
import FZSwiftUtils
import QuartzCore

extension CGContext {
    /// Returns the size of a bitmap context.
    public var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    /// Returns the rectangle representing the entire drawable area of a bitmap context.
    public var bounds: CGRect {
        size.rect
    }
    
    /// Executes the specified block while preserving graphics state.
    public func withSavedGState(_ block: ()->()) {
        saveGState()
        block()
        restoreGState()
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
    
    /// Fills the specified path with the provided color.
    public func fill(_ color: CGColor, at path: CGPath) {
        saveGState()
        setFillColor(color)
        addPath(path)
        fillPath()
        restoreGState()
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
    
    /// Strokes the specified path with the provided color.
    public func stroke(_ color: CGColor, in path: CGPath) {
        saveGState()
        setStrokeColor(color)
        addPath(path)
        strokePath()
        restoreGState()
    }
    
    /// Sets the current fill color in a graphics context.
    @_disfavoredOverload
    public func setFillColor(_ color: NSUIColor) {
        setFillColor(color.cgColor)
    }
    
    /// Sets the current stroke color in a context.
    @_disfavoredOverload
    public func setStrokeColor(_ color: NSUIColor) {
        setStrokeColor(color.cgColor)
    }
    
    /**
     Draws an image at the specified point.
     
     When the byTiling parameter is `true`, the image is tiled in user space—thus, unlike when drawing with patterns, the current transformation (see the [ctm](https://developer.apple.com/documentation/coregraphics/cgcontext/ctm) property) affects the final result.
     
     - Parameters:
        - location: The location at which to draw the image.
        - byTiling:
            - If `true`, this method fills the context’s entire clipping region by tiling many copies of the image, and the rect parameter defines the origin and size of the tiling pattern.
            - If `false` (the default), this method draws a single copy of the image in the area defined by the rect parameter.
     
     */
    public func draw(_ image: CGImage, at location: CGPoint = .zero, byTiling: Bool = false) {
        draw(image, in: CGRect(origin: location, size: image.size), byTiling: byTiling)
    }
    
    /// Flips the entire drawable area of the context vertically.
    public func flipVertically() {
        translateBy(x: 0, y: CGFloat(height))
        scaleBy(x: 1, y: -1)
    }
        
    /// Flips the entire drawable area of the context horizontally.
    public func flipHorizontally() {
        translateBy(x: CGFloat(width), y: 0)
        scaleBy(x: -1, y: 1)
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Enables shadowing with color a graphics context.
    public func setShadow(_ configuration: ShadowConfiguration) {
        setShadow(offset: configuration.offset.size, blur: configuration.opacity, color: configuration.resolvedColor()?.cgColor)
    }
    
    /// Strokes the entire context bounds using the provided configuration.
    public func stroke(_ configuration: BorderConfiguration) {
        stroke(configuration, in: bounds)
    }
    
    /// Strokes the specified rectangle using the provided configuration.
    public func stroke(_ configuration: BorderConfiguration, in rect: CGRect) {
        stroke(configuration) {
            stroke(rect)
        }
    }
    
    /// Strokes the specified path using the provided configuration.
    public func stroke(_ configuration: BorderConfiguration, in path: CGPath) {
        stroke(configuration) {
            addPath(path)
            strokePath()
        }
    }
    
    /// Strokes an ellipse that fits inside the entire context bounds using the provided configuration.
    public func strokeElipse(_ configuration: BorderConfiguration) {
        strokeElipse(configuration, in: bounds)
    }
    
    /// Strokes an ellipse that fits inside the specified rectangle using the provided configuration.
    public func strokeElipse(_ configuration: BorderConfiguration, in rect: CGRect) {
        stroke(configuration) {
            strokeEllipse(in: rect)
        }
    }
    
    fileprivate func stroke(_ configuration: BorderConfiguration, block: ()->()) {
        guard configuration.width > 0.0, let color = configuration.resolvedColor()?.cgColor, color.alpha > 0.0 else { return }
        saveGState()
        setLineWidth(configuration.width)
        setLineCap(configuration.dash.lineCap)
        setLineJoin(configuration.dash.lineJoin)
        setMiterLimit(configuration.dash.mitterLimit)
        setLineDash(phase: configuration.dash.phase, lengths: configuration.dash.pattern)
        setStrokeColor(color)
        block()
        restoreGState()
    }
    
    /// Draws the specified gradient in the entire context bounds.
    public func drawGradient(_ gradient: Gradient) {
        drawGradient(gradient, in: bounds)
    }
    
    /// Draws the specified gradient in the given rect.
    public func drawGradient(_ gradient: Gradient, in rect: CGRect) {
        guard let cgGradient = gradient.cgGradient() else { return }
        switch gradient.type {
        case .linear:
            drawLinearGradient(cgGradient, start: gradient.startPoint.point(in: rect), end: gradient.endPoint.point(in: rect), options: [])
        case .radial:
            let start = gradient.startPoint.point(in: rect)
            let end = gradient.endPoint.point(in: rect)
            let radius = hypot(rect.width, rect.height) / 2
            drawRadialGradient(cgGradient, startCenter: start, startRadius: 0.0, endCenter: end, endRadius: radius, options: [])
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
    /**
     Draws a conic (angular) gradient into the graphics context.

     A conic gradient transitions colors around a central point, rotating clockwise beginning at the specified angle.
     
     - Parameters:
        - gradient: A gradient object.
        - center: The center point of the gradient.
        - angle: The starting angle of the gradient, in radians. The gradient sweeps clockwise from this angle.
     */
    public func drawConicGradient(_ gradient: CGGradient, center: CGPoint, angle: CGFloat) {
        CGContextDrawConicGradient(self, gradient, center, angle)
    }
}

public extension CFType where Self == CGContext {
    /**
     Creates a new bitmap graphics context with the specified size.
          
     - Parameters:
        - size: The size of the context's bitmap.
        - bitmapInfo: The bitmap information.
        - space: The color space of the context's bitmap.
     */
    init?(size: CGSize, scale: CGFloat = 1.0, bitmapInfo: CGBitmapInfo, space: CGColorSpace = CGColorSpaceCreateDeviceRGB()) {
        let size = size * scale
        guard let context = CGContext(data: nil, width: Int(size.width.rounded(.up)), height: Int(size.height.rounded(.up)), bitsPerComponent: bitmapInfo.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo) else { return nil }
        if scale != 1.0 {
            context.scaleBy(x: scale, y: scale)
        }
        self = context
    }
    
    /**
     Creates a new bitmap graphics context with the specified size.
          
     - Parameters:
        - size: The size of the context's bitmap.
        - bitmapInfo: The bitmap information.
        - space: The color space of the context's bitmap.
     */
    @_disfavoredOverload
    init?(size: CGSize, scale: CGFloat = 1.0, bitmapInfo: CGBitmapInfo, space: CGColorSpaceName) {
        guard let space = space.colorSpace else { return nil }
        self.init(size: size, scale: scale, bitmapInfo: bitmapInfo, space: space)
    }
    
    /**
     Creates a new bitmap graphics context with the specified size.
          
     - Parameters:
        - size: The size of the context's bitmap.
        - includeAlpha: A Boolean value indicating whether the bitmap should include an alpha channel.
        - space: The color space of the context's bitmap.
     */
    init?(size: CGSize, scale: CGFloat = 1.0, includeAlpha: Bool = true, space: CGColorSpace = CGColorSpaceCreateDeviceRGB()) {
        let size = size * scale
        guard let context = CGContext(data: nil, width: Int(size.width.rounded(.up)), height: Int(size.height.rounded(.up)), bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: CGBitmapInfo(alpha: includeAlpha ? .premultipliedLast : .noneSkipFirst))
        else { return nil }
        if scale != 1.0 {
            context.scaleBy(x: scale, y: scale)
        }
        self = context
    }
    
    /**
     Creates a new bitmap graphics context with the specified size.
          
     - Parameters:
        - size: The size of the context's bitmap.
        - includeAlpha: A Boolean value indicating whether the bitmap should include an alpha channel.
        - space: The color space of the context's bitmap.
     */
    @_disfavoredOverload
    init?(size: CGSize, scale: CGFloat = 1.0, includeAlpha: Bool = true, space: CGColorSpaceName) {
        guard let space = space.colorSpace else { return nil }
        self.init(size: size, scale: scale, includeAlpha: includeAlpha, space: space)
    }
    
    /**
     Creates a PDF graphics context that writes to the specified data.
     
     - Parameters:
        - data: The data to write to.
        - mediabox: The rectangle that defines the size and location of the PDF page.
        - auxiliaryInfo: A dictionary that specifies any additional information to be used by the PDF context when generating the PDF file.
     
     This function creates a PDF drawing environment to your specifications. When you draw into the new context, Core Graphics renders your drawing as a sequence of PDF drawing commands that are passed to the data consumer object.
     */
    init?(data: NSMutableData, mediaBox: CGRect, auxiliaryInfo: [CFString: Any]? = nil) {
        guard let consumer =  CGDataConsumer(data: data) else { return nil }
        var mediaBox = mediaBox
        self.init(consumer: consumer, mediaBox: &mediaBox, auxiliaryInfo as CFDictionary?)
    }
    
    /**
     Creates a PDF graphics context that writes data to the location at the specified URL.
     
     - Parameters:
        - data: The URL of the location to write the data to.
        - mediabox: The rectangle that defines the size and location of the PDF page.
        - auxiliaryInfo: A dictionary that specifies any additional information to be used by the PDF context when generating the PDF file.
     */
    init?(url: URL, mediaBox: CGRect, auxiliaryInfo: [CFString: Any]? = nil) {
        guard let consumer =  CGDataConsumer(url: url as CFURL) else { return nil }
        var mediaBox = mediaBox
        self.init(consumer: consumer, mediaBox: &mediaBox, auxiliaryInfo as CFDictionary?)
    }
}


/*
 CGDataConsumer(data: data), let context = CGContext(consumer: consumer, mediaBox: &bounds, format.documentInfo.dictionary)
 */


#endif
