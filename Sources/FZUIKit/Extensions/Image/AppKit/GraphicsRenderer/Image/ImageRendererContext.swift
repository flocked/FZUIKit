//
//  ImageGraphicsRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

public final class ImageGraphicsRendererContext: GraphicsRendererContext {
    private let bitmapRep: NSBitmapImageRep
    private var previousContext: NSGraphicsContext?

    /**
     The format used to create the associated graphics renderer.
     
     If you specified a format object when you initialized the current renderer (`NSGraphicsImageRenderer`) object, then this property provides access to that object. Otherwise, a default format object was created for you using the renderer initialization parameters, tuned to the current device.
     */
    public let context: NSGraphicsContext
    
    /// The drawing configuration of the context.
    public let format: ImageGraphicsRendererFormat
    
    /**
     The current state of the drawing context, expressed as an object that manages image data in your app.
     
     Use this property to access the current Core Graphics context as a `NSImage` object while providing drawing instructions for one of the drawing methods in `NSGraphicsImageRenderer`.
     */
    public var currentImage: NSImage {
        let image = NSImage(size: format.bounds.size)
        image.addRepresentation(bitmapRep)
        // return cgContext.makeImage()!.nsImage
        return image
    }
    
    func beginRendering() {
        format.isRendering = true
        previousContext = NSGraphicsContext.current
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func endRendering() {
        format.isRendering = false
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.current = previousContext
        previousContext = nil
    }
    
    init?(format: ImageGraphicsRendererFormat) {
        self.format = format
        let size = format.renderingBounds.size
        let hasAlpha = !format.isOpaque
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * format.scale), pixelsHigh: Int(size.height * format.scale), bitsPerSample: 8, samplesPerPixel: hasAlpha ? 4 : 3, hasAlpha: hasAlpha, isPlanar: false, colorSpaceName: .deviceRGB, bitmapFormat: [], bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        bitmapRep = rep.converting(to: format.preferredRange.colorSpace, renderingIntent: .default) ?? rep
        guard let context = NSGraphicsContext(bitmapImageRep: bitmapRep) else { return nil }
        self.context = context
        if format.scale != 1.0 {
            cgContext.scaleBy(x: format.scale, y: format.scale)
        }
        if format.isOpaque {
            cgContext.setFillColor(NSColor.white.cgColor)
            cgContext.fill(NSRect(origin: .zero, size: size))
        }
        if format.isFlipped {
            cgContext.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        }
    }
}

#endif
