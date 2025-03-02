//
//  ImageRenderer.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A graphics renderer for creating Core Graphics-backed images.
public class ImageGraphicsRenderer: GraphicsRenderer {
    public typealias Context = ImageGraphicsRendererContext
    
    /// The format used to create the graphics renderer.
    public let format: ImageGraphicsRendererFormat
    private var bitmapRep: NSBitmapImageRep?
    
    /**
     Returns a new image with the specified drawing actions applied
     
     - parameter actions: The drawing actions to apply
     
     - returns: A new image
     */
    public func image(actions: (_ context: Context) -> Void) -> NSImage? {
        var image: NSImage?
        if let context = ImageGraphicsRendererContext(format: format) {
            context.beginRendering()
            actions(context)
            image = context.currentImage
            context.endRendering()
        }
        return image
    }
    
    /**
     Creates a JPEG-encoded image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting image as a JPEG-encoded `Data` object, or `nil` if the image couldn't be rendered.
     
     The JPEG format does not support transparency, so this method is only appropriate for use with opaque images.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameters:
        - compressionQuality: A value between `0.0` and `1.0`, representing the compression level the JPEG encoder should use. A value of `1.0` specifies lossless compression, and a value of `0.0 specifies maximum compression.
        - actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     
     - Returns: A `Data` object representing a JPEG-encoded representation of the image created by the supplied drawing actions, or `nil` if the image couldn't be rendered.
     */
    public func jpegData(withCompressionQuality quality: CGFloat, actions: (_ context: Context) -> Void) -> Data? {
        image(actions: actions)?.jpegData(compressionFactor: quality)
    }
    
    /**
     Creates a PNG-encoded image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting image as a PNG-encoded `Data` object, or `nil` if the image couldn't be rendered.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameter actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     - Returns: A `Data` object representing a PNG-encoded representation of the image created by the supplied drawing actions, or `nil` if the image couldn't be rendered.
     */
    public func pngData(actions: (_ context: Context) -> Void) -> Data? {
        image(actions: actions)?.pngData()
    }
    
    /**
     Creates a TIFF-encoded image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting image as a PNG-encoded `Data` object, or `nil` if the image couldn't be rendered.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameters:
        - compression: The type of compression to use. The default value is `none` and isn'g using any compression.
        - actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     - Returns: A `Data` object representing a TIFF-encoded representation of the image created by the supplied drawing actions, or `nil` if the image couldn't be rendered.
     */
    public func tiffData(withCompression compression: NSBitmapImageRep.TIFFCompression = .none,  actions: (_ context: Context) -> Void) -> Data? {
        image(actions: actions)?.tiffRepresentation(using: compression, factor: 1.0)
    }
    
    public required init(bounds: CGRect) {
        self.format = .default()
        format.bounds = bounds
    }
    
    /**
     Creates an image renderer with the specified bounds and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device. Provide the size of the images you want to create, and an instance of ``NSGraphicsImageGraphicsRendererFormat`` with the required configuration.
     
     - Parameters:
        - bounds: The bounds of the image context the image renderer creates and subsequently draws upon. Specify values in points in the Core Graphics coordinate space.
        - format: A ``NSGraphicsImageGraphicsRendererFormat`` object that encapsulates the format used to create the renderer context.
     - Returns: An initialized image renderer.
     */
    public init(bounds: NSRect, format: ImageGraphicsRendererFormat) {
        self.format = format
        format.bounds = bounds
    }
    
    /**
     Creates an image renderer for drawing images of the specified size.
     
     Use this initializer to create an image renderer that will draw images of a given size. This renderer uses the ``NSGraphicsImageGraphicsRendererFormat/default()`` static method on ``NSGraphicsImageGraphicsRendererContext`` to create its context, thereby selecting parameters that are the most appropriate for the current device.
     
     - Parameter size: The size of images output from the renderer, specified in points.
     - Returns: An initialized image renderer.
     
     */
    public convenience init(size: NSSize) {
        self.init(size: size, format: .default())
    }
    
    /**
     Creates an image renderer with the specified size and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device.
     
     - Parameters:
        - size: The size of images output from the renderer, specified in points.
        - format: A ``NSGraphicsImageGraphicsRendererFormat`` object that encapsulates the format used to create the renderer context.
     - Returns: An initialized image renderer.
     */
    public init(size: NSSize, format: ImageGraphicsRendererFormat) {
        self.format = format
        format.bounds = CGRect(.zero, size)
    }
}

#endif
