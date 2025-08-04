//
//  NSGraphicsImageRenderer.swift
//
//
//  Created by Florian Zand on 04.08.25.
//

#if os(macOS)
import AppKit

/**
 A set of drawing attributes that represents the configuration of an image renderer context.
  
 The image renderer format contains properties that determine the attributes of the underlying Core Graphics contexts that the image renderer creates. Use ``default()`` to create an image renderer format instance optimized for the current device.
 */
struct NSGraphicsImageRendererFormat {
    /// A Boolean value that indicates whether the underlying Core Graphics context has an alpha channel.
    public var opaque: Bool = false
    
    /**
     The display scale of the image renderer context.
     
     The display scale determines the number of pixels per point.
     
     The default value is equal to the scale of the main screen.
     */
    public var scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 1.0
    
    /// The color space to use for the image. Defaults to the main display’s color space.
    public var colorSpace: CGColorSpace?
    
    /**
     The Core Graphics bitmap info to use for the image context.
     
     If ``opaque`` is `true`, this typically should not include alpha.
     */
    public var bitmapInfo: CGBitmapInfo = []
    
    /**
     Returns a format that represents the highest fidelity that the current device supports.
     
     The returned format object always represents the device’s highest fidelity, regardless of the actual fidelity currently employed by the device. A graphics renderer uses this method to create a format at initialization time if you use an initializer that does not have a format argument.
     
     This property doesn’t always return a format that’s optimized for the current configuration of the main screen. If you’re rendering content for immediate display, it’s recommended that you use preferred() instead of this property.
     
     */
    public static func `default`() -> Self {
        NSGraphicsImageRendererFormat(colorSpace: CGColorSpace(name: CGColorSpace.sRGB), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))
    }
    
    /// Returns the most suitable format for the main screen’s current configuration.
    public static func preferred() -> Self {
        NSGraphicsImageRendererFormat(colorSpace: CGColorSpace(name: CGColorSpace.sRGB), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))
    }
}

/**
 A graphics renderer for creating Core Graphics-backed images.
 
 */
class NSGraphicsImageRenderer {
    
    let format: NSGraphicsImageRendererFormat
    let bounds: CGRect
    
    /**
     Creates an image renderer with the specified size and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device. Provide the size of the images you want to create, and an instance of UIGraphicsImageRendererFormat with the required configuration.
     
     - Parameters:
        - size: The size of images output from the renderer, specified in points.
        - format: A UIGraphicsImageRendererFormat object that encapsulates the format used to create the renderer context.
     */
    public init(size: CGSize, format: NSGraphicsImageRendererFormat = .default()) {
        self.format = format
        self.bounds = CGRect(origin: .zero, size: size)
    }
    
    /**
     Creates an image renderer with the specified bounds and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device.
     
     - Parameters:
        - bounds: The bounds of the image context the image renderer creates and subsequently draws upon. Specify values in points in the Core Graphics coordinate space.
        - format: A UIGraphicsImageRendererFormat object that encapsulates the format used to create the renderer context.
     */
    public init(bounds: CGRect, format: NSGraphicsImageRendererFormat = .default()) {
        self.format = format
        self.bounds = bounds
    }
    
    /**
     Creates an image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method will return the resultant UIImage object.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameter actions: A UIGraphicsImageRenderer.DrawingActions block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     - Returns: A UIImage object created by the supplied drawing actions.
     */
    public func image(actions: (NSGraphicsContext) -> Void) -> NSImage {
        let width = Int(bounds.size.width * format.scale)
        let height = Int(bounds.size.height * format.scale)
        let colorSpace = format.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = format.bitmapInfo.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Unable to create CGContext")
        }

        context.scaleBy(x: format.scale, y: format.scale)

        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        actions(graphicsContext)
        NSGraphicsContext.restoreGraphicsState()

        guard let cgImage = context.makeImage() else {
            fatalError("Failed to create CGImage from context")
        }
        let image = NSImage(cgImage: cgImage, size: bounds.size)
        return image
    }
    
    /**
     Creates a PNG-encoded image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting image as a PNG-encoded Data object.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameter actions: A UIGraphicsImageRenderer.DrawingActions block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     - Returns: A Data object representing a PNG-encoded representation of the image created by the supplied drawing actions.
     */
    public func pngData(actions: (NSGraphicsContext) -> Void) -> Data {
        guard let pngData = image(actions: actions).pngData() else {
            fatalError("Failed to create PNG data from the image")
        }
        return pngData
    }
    
    /**
     Creates a JPEG-encoded image from a set of drawing instructions.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting image as a JPEG-encoded Data object.
     
     The JPEG format does not support transparency, so this method is only appropriate for use with opaque images.
     
     You can call this method repeatedly to create multiple images, each of which has identical dimensions and format.
     
     - Parameters:
        - compressionQuality: A value between `0.0` and `1.0`, representing the compression level the JPEG encoder should use. A value of `1.0` specifies lossless compression, and a value of `0.0` specifies maximum compression.
        - actions: A UIGraphicsImageRenderer.DrawingActions block that, when invoked by the renderer, executes a set of drawing instructions to create the output image.
     - Returns: A Data object representing a JPEG-encoded representation of the image created by the supplied drawing actions.
     */
    public func jpegData(withCompressionQuality compressionQuality: CGFloat, actions: (NSGraphicsContext) -> Void) -> Data {
        guard let jpegData = image(actions: actions).jpegData(compressionQuality: compressionQuality) else {
            fatalError("Failed to create JPEG data from the image")
        }
        return jpegData
    }
}
#endif
