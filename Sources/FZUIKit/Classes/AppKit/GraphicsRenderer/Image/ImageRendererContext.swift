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
    
    func render(_ actions: (_ context: GraphicsImageRendererContext) -> Void) -> NSImage? {
        var image: NSImage?
        beginRendering()
        actions(self)
        image = currentImage
        endRendering()
        return image
    }
    
    func beginRendering() {
        format.isRendering = true
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func endRendering() {
        format.isRendering = false
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
    }
    
    init?(format: GraphicsImageRendererFormat) {
        let size = (format.renderingBounds.size * format.scale).rounded(.up)
        format.renderingBounds.size.rounded(.up)
        let range = format.preferredRange.resolved
        let bitmapInfo = format.bitmapInfo ?? range.bitmapInfo(opaque: format.isOpaque)
        let bitsPerComponent = format.bitsPerComponent ?? bitmapInfo.bitsPerComponent
        let colorSpace = format.cgColorSpace ?? range.cgColorSpace
        guard let cgContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        self.context = NSGraphicsContext(cgContext: cgContext, flipped: format.isFlipped)
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
