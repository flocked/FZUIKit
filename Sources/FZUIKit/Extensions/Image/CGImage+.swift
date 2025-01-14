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
import FZSwiftUtils

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
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// A `CIImage` representation of the image.
    var ciImage: CIImage {
        CIImage(cgImage: self)
    }
    #endif

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
        guard let space = CGColorSpace(name: CGColorSpace.sRGB), let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo.rawValue) else { throw ImageError.invalidContext }

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

extension Collection where Element == CGImage {
    /// An array of unique images.
    public func uniqueImages() -> [Element] {
        reduce(into: [CGImage]()) { images, image in
            if let last = images.last, !last.isEqual(to: image) {
                images.append(image)
            } else if images.isEmpty {
                images.append(image)
            }
        }
    }
}

extension CGImage {
    enum PixelFormat {
        /// Big-endian, alpha first.
        case argb
        /// Big-endian, alpha last.
        case rgba
        /// Little-endian, alpha first.
        case bgra
        /// Little-endian, alpha last.
        case abgr

        var title: String {
            switch self {
            case .argb:
                "ARGB"
            case .rgba:
                "RGBA"
            case .bgra:
                "BGRA"
            case .abgr:
                "ABGR"
            }
        }
    }
}

import Accelerate.vImage

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension CGImage {
    /**
    Convert an image to a `vImage` buffer of the given pixel format.

    - Parameter premultiplyAlpha: Whether the alpha channel should be premultiplied.
    */
    func toVImageBuffer(
        pixelFormat: PixelFormat,
        premultiplyAlpha: Bool
    ) throws -> vImage.PixelBuffer<vImage.Interleaved8x4> {
        guard
            var imageFormat = vImage_CGImageFormat(
                bitsPerComponent: vImage.Interleaved8x4.bitCountPerComponent,
                bitsPerPixel: vImage.Interleaved8x4.bitCountPerPixel,
                colorSpace: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: pixelFormat.toBitmapInfo(premultiplyAlpha: premultiplyAlpha),
                renderingIntent: .perceptual
            )
        else {
            throw NSError("Could not initialize vImage_CGImageFormat")
        }

        return try vImage.PixelBuffer(
            cgImage: self,
            cgImageFormat: &imageFormat,
            pixelFormat: vImage.Interleaved8x4.self
        )
    }
}

extension CGImage.PixelFormat: CustomDebugStringConvertible {
    var debugDescription: String { "CGImage.PixelFormat(\(title)" }
}

extension CGImage.PixelFormat {
    func toBitmapInfo(premultiplyAlpha: Bool) -> CGBitmapInfo {
        let alphaFirst = premultiplyAlpha ? CGImageAlphaInfo.premultipliedFirst : .first
        let alphaLast = premultiplyAlpha ? CGImageAlphaInfo.premultipliedLast : .last

        let byteOrder: CGBitmapInfo
        let alphaInfo: CGImageAlphaInfo
        switch self {
        case .argb:
            byteOrder = .byteOrder32Big
            alphaInfo = alphaFirst
        case .rgba:
            byteOrder = .byteOrder32Big
            alphaInfo = alphaLast
        case .bgra:
            byteOrder = .byteOrder32Little
            alphaInfo = alphaFirst // This might look wrong, but the order is inverse because of little endian.
        case .abgr:
            byteOrder = .byteOrder32Little
            alphaInfo = alphaLast
        }

        return CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)
    }
}


extension CGImage {
    /// The mode of grayscaling an image.
    public enum GrayscalingMode {
        /// Grayscales by using the device's native grayscale color space.
        case deviceGray
        /// Grayscales by using a weighted luminance formula for perceptual accuracy.
        case weightedLuminance
        /// Grayscales by by averaging the red, green, and blue color components.
        case desaturation
        /// Grayscales by by using the maximum intensity of the red, green, or blue channels.
        case maxIntensity
        /// Grayscales by by using the minimum intensity of the red, green, or blue channels.
        case minIntensity
#if os(macOS) || os(iOS) || os(tvOS)
        /// Grayscales by using the `CIPhotoEffectMono` Core Image filter for a monochrome effect.
        case ciPhotoEffectMono
        /// Grayscales by using the `CIColorControls` Core Image filter by reducing saturation to zero.
        case ciColorControls
        #endif
    }

    /// Returns a grayscale version of the image.
    public func grayscaled(mode: GrayscalingMode = .deviceGray) -> CGImage? {
        switch mode {
        case .deviceGray:
            return convertToDeviceGray()
        case .weightedLuminance:
            return processPixels { (r, g, b) -> UInt8 in
                let redWeight = 0.299 * Float(r)
                let greenWeight = 0.587 * Float(g)
                let blueWeight = 0.114 * Float(b)
                return UInt8(redWeight + greenWeight + blueWeight)
            }
        case .desaturation:
            return processPixels { (r, g, b) -> UInt8 in
                return UInt8((Float(r) + Float(g) + Float(b)) / 3.0)
            }
        case .maxIntensity:
            return processPixels { (r, g, b) -> UInt8 in
                return max(r, g, b)
            }
        case .minIntensity:
            return processPixels { (r, g, b) -> UInt8 in
                return min(r, g, b)
            }
        #if os(macOS) || os(iOS) || os(tvOS)
        case .ciPhotoEffectMono:
            return applyCoreImageFilter(filterName: "CIPhotoEffectMono")
        case .ciColorControls:
            return applyCoreImageFilter(filterName: "CIColorControls")
        #endif
        }
    }
    
    private func convertToDeviceGray() -> CGImage? {
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else {  return nil }
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }

    private func processPixels(_ transform: @escaping (UInt8, UInt8, UInt8) -> UInt8) -> CGImage? {
        guard let dataProvider = self.dataProvider, let data = dataProvider.data as Data? else { return nil }
        var pixelData = [UInt8](data)
        let bytesPerPixel = 4
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = pixelData[i]
            let g = pixelData[i + 1]
            let b = pixelData[i + 2]
            let gray = transform(r, g, b)
            pixelData[i] = gray
            pixelData[i + 1] = gray
            pixelData[i + 2] = gray
        }
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue) else { return nil }
        return context.makeImage()
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    private func applyCoreImageFilter(filterName: String) -> CGImage? {
        let ciImage = CIImage(cgImage: self)
        guard let filter = CIFilter(name: filterName) else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        if filterName == "CIColorControls" {
            filter.setValue(0.0, forKey: kCIInputSaturationKey)
        }
        let context = CIContext()
        return filter.outputImage.flatMap {
            context.createCGImage($0, from: $0.extent)
        }
    }
    #endif
}
