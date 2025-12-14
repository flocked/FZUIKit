//
//  GraphicsImageRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 The drawing environment for an image renderer.
 
 When using the ``GraphicsImageRenderer`` drawing methods, you must pass a block which provides a ``GraphicsImageRendererContext`` instance as an argument. Use the context object to access high-level drawing functions and the underlying Core Graphics context.
 */
public final class GraphicsImageRendererContext: GraphicsRendererContext {
    private let bitmapRep: NSBitmapImageRep

    /**
     The format used to create the associated graphics renderer.
     
     If you specified a format object when you initialized the current renderer (`NSGraphicsImageRenderer`) object, then this property provides access to that object. Otherwise, a default format object was created for you using the renderer initialization parameters, tuned to the current device.
     */
    public let context: NSGraphicsContext
    
    /// The drawing configuration of the context.
    public let format: GraphicsImageRendererFormat
    
    /**
     The current state of the drawing context, expressed as an object that manages image data in your app.
     
     Use this property to access the current Core Graphics context as a `NSImage` object while providing drawing instructions for one of the drawing methods in ``GraphicsImageRenderer``.
     */
    public var currentImage: NSImage {
        let image = NSImage(size: format.bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
    
    func beginRendering() {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func endRendering() {
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
    }
    
    init?(format: GraphicsImageRendererFormat) {
        self.format = format
        let size = format.bounds.size * format.scale
        let hasAlpha = !format.isOpaque
        let range = format.preferredRange.resolved
        let bitmapFormat = range.bitmapFormat
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: bitmapFormat.bitsPerSample, samplesPerPixel: hasAlpha ? 4 : 3, hasAlpha: hasAlpha, isPlanar: false, colorSpaceName: range.colorSpace, bitmapFormat: bitmapFormat, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        bitmapRep = rep
        guard let context = NSGraphicsContext(bitmapImageRep: bitmapRep) else { return nil }
        
        self.context = context
        if format.scale != 1.0 {
            cgContext.scaleBy(x: format.scale, y: format.scale)
        }
        if format.isOpaque {
            cgContext.fill(.white)
        }
        if format.isFlipped {
            cgContext.flipVertically()
        }
    }
}

/**
 The drawing environment for an image renderer.
 
 When using the ``GraphicsImageRenderer`` drawing methods, you must pass a block which provides a ``GraphicsImageRendererContext`` instance as an argument. Use the context object to access high-level drawing functions and the underlying Core Graphics context.
 */
public final class GraphicsImageRendererContextAlt: GraphicsRendererContext {
    /**
     The format used to create the associated graphics renderer.
     
     If you specified a format object when you initialized the current renderer (`NSGraphicsImageRenderer`) object, then this property provides access to that object. Otherwise, a default format object was created for you using the renderer initialization parameters, tuned to the current device.
     */
    public let context: NSGraphicsContext
    
    /// The drawing configuration of the context.
    public let format: GraphicsImageRendererFormat
    
    /**
     The current state of the drawing context, expressed as an object that manages image data in your app.
     
     Use this property to access the current Core Graphics context as a `NSImage` object while providing drawing instructions for one of the drawing methods in ``GraphicsImageRenderer``.
     */
    public var currentImage: NSImage {
        guard let cgImage = context.cgContext.makeImage() else {
            return NSImage(size: format.bounds.size)
        }
        let image = NSImage(cgImage: cgImage, size: format.bounds.size)
        return image
    }
    
    func render(_ actions: (_ context: GraphicsImageRendererContextAlt) -> Void) -> NSImage? {
        var image: NSImage?
        beginRendering()
        actions(self)
        image = currentImage
        endRendering()
        return image
    }
    
    func beginRendering() {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func endRendering() {
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
    }
    
    init?(format: GraphicsImageRendererFormat) {
        let size = format.bounds.size * format.scale
        let range = format.preferredRange.resolved
        let bitmapInfo = range.bitmapInfo(opaque: format.isOpaque)
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitmapInfo.bitsPerComponent, bytesPerRow: 0, space: range.cgColorSpace, bitmapInfo: bitmapInfo) else { return nil }
        self.context = NSGraphicsContext(cgContext: context, flipped: format.isFlipped)
        self.format = format
        if format.scale != 1.0 {
            cgContext.scaleBy(x: format.scale, y: format.scale)
        }
        if format.isOpaque {
            cgContext.fill(.white)
        }
    }
}

#endif
