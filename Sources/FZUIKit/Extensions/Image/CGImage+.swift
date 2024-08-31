//
//  CGImage+.swift
//
//
//  Created by Florian Zand on 05.05.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import SwiftUI

public extension CGImage {
    #if os(macOS)
        /// A `NSImage` representation of the image.
        var nsImage: NSImage {
            NSImage(cgImage: self)
        }

    #elseif canImport(UIKit)
        /// A `UIImage` representation of the image.
        var uiImage: UIImage {
            UIImage(cgImage: self)
        }
    #endif

    /// An `Image` representation of the image.
    var swiftUI: Image {
        #if os(macOS)
            return Image(nsImage)
        #elseif canImport(UIKit)
            return Image(uiImage: uiImage)
        #endif
    }
    
    /// A `CIImage` representation of the image.
    var ciImage: CIImage {
        CIImage(cgImage: self)
    }

    /// The size of the image.
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    internal var nsUIImage: NSUIImage {
        NSUIImage(cgImage: self)
    }

    static func create(size: CGSize, backgroundColor: CGColor? = nil, _ drawBlock: ((CGContext, CGSize) -> Void)? = nil) throws -> CGImage {
        // Make the context. For the moment, always work in RGBA (CGColorSpace.sRGB)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard
            let space = CGColorSpace(name: CGColorSpace.sRGB),
            let ctx = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: space,
                bitmapInfo: bitmapInfo.rawValue
            )
        else {
            throw ImageError.invalidContext
        }

        // Drawing defaults
        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.interpolationQuality = .high

        // If a background color is set, fill it here
        if let backgroundColor = backgroundColor {
            ctx.saveGState()
            ctx.setFillColor(backgroundColor)
            ctx.fill([CGRect(origin: .zero, size: size)])
            ctx.restoreGState()
        }

        // Perform the draw block
        if let block = drawBlock {
            ctx.saveGState()
            block(ctx, size)
            ctx.restoreGState()
        }

        guard let result = ctx.makeImage() else {
            throw ImageError.unableToCreateImageFromContext
        }
        return result
    }

    enum ImageError: Error {
        case unableToCreateImageFromContext
        case invalidContext
    }
    
    /*
    internal static func create(size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, bitmapInfo: CGBitmapInfo? = nil, colorSpace: CGColorSpace? = nil, backgroundColor: CGColor? = nil, _ drawBlock: ((CGContext, CGSize) -> Void)? = nil) throws -> CGImage {
        guard
            let space = colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
            let ctx = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: space,
                bitmapInfo: (bitmapInfo ?? CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)).rawValue
            )
        else {
            throw ImageError.invalidContext
        }

        // Drawing defaults
        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.interpolationQuality = .high

        // If a background color is set, fill it here
        if let backgroundColor = backgroundColor {
            ctx.saveGState()
            ctx.setFillColor(backgroundColor)
            ctx.fill([CGRect(origin: .zero, size: size)])
            ctx.restoreGState()
        }

        // Perform the draw block
        if let block = drawBlock {
            ctx.saveGState()
            block(ctx, size)
            ctx.restoreGState()
        }

        guard let result = ctx.makeImage() else {
            throw ImageError.unableToCreateImageFromContext
        }
        return result
    }
    */
    
    /**
     Returns the image resized to the specified size.
     
     - Parameters:
        - size: The size of the resized image.
        - quality: The quality of resizing the image.
     
     - Returns: The resized image, or the image itself if resizing fails.
     */
    func resized(to size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage {
        guard width != self.width || height != self.height else { return self }
        guard let colorSpace = colorSpace else { return self }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: alphaInfo.rawValue) else { return self }
        
        context.interpolationQuality = quality
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage() ?? self
    }
    
    /**
     Returns the image resized to fit the specified size.
     
     - Parameters:
        - size: The size of the resized image.
        - quality: The quality of resizing the image.
     
     - Returns: The resized image, or the image itself if resizing fails.
     */
    func resized(toFit size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage {
        let size = self.size.scaled(toFit: size)
        return resized(to: size, quality: quality)
    }

    /**
     Returns the image resized to fill the specified size.
     
     - Parameters:
        - size: The size of the resized image.
        - quality: The quality of resizing the image.
     
     - Returns: The resized image, or the image itself if resizing fails.
     */
    func resized(toFill size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage {
        let size = self.size.scaled(toFill: size)
        return resized(to: size, quality: quality)
    }

    /**
     Returns the image resized to the specified width while maintaining the aspect ratio.
     
     - Parameters:
        - width: The width of the resized image.
        - quality: The quality of resizing the image.
     
     - Returns: The resized image, or the image itself if resizing fails.
     */
    func resized(toWidth width: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage {
        let size = size.scaled(toWidth: width)
        return resized(to: size, quality: quality)
    }

    /**
     Returns the image resized to the specified height while maintaining the aspect ratio.
     
     - Parameters:
        - height: The height of the resized image.
        - quality: The quality of resizing the image.
     
     - Returns: The resized image, or the image itself if resizing fails.
     */
    func resized(toHeight height: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage {
        let size = size.scaled(toHeight: height)
        return resized(to: size, quality: quality)
    }
}

extension CGImage {
    /**
     Returns a Boolean value that indicates whether image is equal to the specified other image.
     
     - Parameter image: The image to comapare.
     - Returns: `true` if the images are equal, otherwise `false`.
     */
    public func isEqual(to image: CGImage) -> Bool {
        guard size == image.size else { return false }
        guard let context = self.context else { return false }
        guard let newContext = image.context else { return false }
        guard let data = context.data else { return false }
        guard let newData = newContext.data else { return false }
        return memcmp(data, newData, context.height * context.bytesPerRow) == 0
    }
    
    var context: CGContext? {
        guard let space = colorSpace, let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.draw(self, in: CGRect(.zero, size))
        return context
    }
}
