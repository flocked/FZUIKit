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
import Accelerate.vImage

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
    
    /// A Boolean value that determines if the image is lazily loaded.
    var isLazyLoaded: Bool {
        if let match = cfDescription.firstMatch(pattern: "\\((IP|DP)\\)")?.string {
            switch match {
            case "(IP)": return true
            case "(DP)": return false
            default: break
            }
        }
        return utType != nil
    }
    
    /// A Boolean value that determines if the image has alpha information.
    var hasAlpha: Bool {
        switch alphaInfo {
        case .premultipliedFirst, .premultipliedLast, .last, .first, .alphaOnly: return true
        default: return false
        }
    }
}

extension CGImage {
    /**
     Returns a Boolean value indicating whether image is equal to the specified other image.

     - Parameter image: The image to comapare.
     - Returns: `true` if the images are equal, otherwise `false`.
     */
    public func isEqual(to image: CGImage) -> Bool {
        guard size == image.size,
              colorSpace?.name == image.colorSpace?.name,
              bitsPerPixel == image.bitsPerPixel,
              bitsPerComponent == image.bitsPerComponent,
              bitmapInfo == image.bitmapInfo,
              byteOrderInfo == image.byteOrderInfo,
              alphaInfo == image.alphaInfo,
              bytesPerRow == image.bytesPerRow,
              utType == image.utType,
              isMask == image.isMask,
              renderingIntent == image.renderingIntent,
              shouldInterpolate == image.shouldInterpolate
        else { return false }
        guard let data1 = dataProvider?.data, let data2 = image.dataProvider?.data else { return false }
        let dataCount1 = data1.count
        let dataCount2 = data2.count
        guard dataCount1 == dataCount2 else { return false }
        return data1.withBytes { ptr1 in
            data2.withBytes { ptr2 in
                memcmp(ptr1, ptr2, dataCount1) == 0
            }
        }
    }
    
    fileprivate func hash() -> Int {
        Hasher.hash([dataProvider?.data as Data?, size, colorSpace?.name, bitsPerPixel, bitsPerComponent, bitmapInfo, byteOrderInfo, alphaInfo, bytesPerRow, utType, isMask, renderingIntent, shouldInterpolate])
    }
}

extension Sequence where Element == CGImage {
    /// An array of unique images.
    public func uniqueImages() -> [Element] {
        let hashedImages = enumerated().map { (image: $0.element, hash: $0.element.hash(), index: $0.offset) }.sorted(by: \.hash)
        return hashedImages.grouped(by: \.hash).values.flatMap({ $0.uniqueImages() }).sorted(by: \.index).map { $0.image }
    }
}

fileprivate extension Array<(image: CGImage, hash: Int, index: Int)> {
    func uniqueImages() -> [Element] {
        reduce(into: []) { result, entry in
            if !result.contains(where: { $0.image.isEqual(to: entry.image) }) {
                result.append(entry)
            }
        }
    }
}

extension CFType where Self == CGImage {
    /**
     Creates a new image with the specified size and color space.
     
     - Parameters:
       - size: The size of the image.
       - colorSpace: The color space to use.
       - hasAlpha: A Boolean value indicating whether the image should include an alpha channel.
     */
    public init(size: CGSize, colorSpace: CGColorSpaceName = .genericRGB, hasAlpha: Bool = true) {
        let context = CGContext(size: size, space: colorSpace, hasAlpha: hasAlpha)!
        context.clear(CGRect(.zero, size))
        self = context.makeImage()!
    }
    
    /**
     Creates a new image filled with the specified color.
     
     - Parameters:
       - size: The size of the image.
       - colorSpace: The color space to use.
       - color: The fill color of the image.
     */
    public init(size: CGSize, colorSpace: CGColorSpaceName = .genericRGB, color: CGColor) {
        let context = CGContext(size: size, space: colorSpace, hasAlpha: color.alpha < 1.0)!
        context.saveGState()
        context.fill(color, in: CGRect(origin: .zero, size: size))
        context.restoreGState()
        self = context.makeImage()!
    }
    
    /**
     Creates an image whose contents are drawn using the specified block.
     
     - Parameters:
        - size: The size of the image.
        - colorSpace: The name of the color space.
        - hasAlpha: A Boolean value indicating whether the image has an alpha channel.
        - drawingHandler: A block that draws the contents of the image representation.
     */
    public init(size: CGSize, colorSpace: CGColorSpaceName = .genericRGB, hasAlpha: Bool = true, drawingHandler: ((CGContext) -> Void)) {
        let context = CGContext(size: size, space: colorSpace, hasAlpha: hasAlpha)!
        context.saveGState()
        drawingHandler(context)
        context.restoreGState()
        self = context.makeImage()!
    }
    
    /**
     Creates an image whose contents are drawn using the specified block.
     
     - Parameters:
        - size: The size of the image.
        - colorSpace: The name of the color space.
        - color: The background color of the image.
        - drawingHandler: A block that draws the contents of the image representation.
     */
    public init(size: CGSize, colorSpace: CGColorSpaceName = .genericRGB, color: CGColor, drawingHandler: ((CGContext) -> Void)) {
        let context = CGContext(size: size, space: colorSpace, hasAlpha: color.alpha < 1.0)!
        context.saveGState()
        context.fill(color, in: CGRect(origin: .zero, size: size))
        drawingHandler(context)
        context.restoreGState()
        self = context.makeImage()!
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension CGImage {
    /**
     Convert an image to a `vImage` buffer of the specified given pixel format.

     - Parameters:
        - pixelFormat: The pixel format.
        - premultiplyAlpha: A Boolean value indicating whether the alpha channel should be premultiplied.
     */
    public func toVImageBuffer(pixelFormat: PixelFormat, premultiplyAlpha: Bool) throws -> vImage.PixelBuffer<vImage.Interleaved8x4> {
        guard var imageFormat = vImage_CGImageFormat(bitsPerComponent: vImage.Interleaved8x4.bitCountPerComponent, bitsPerPixel: vImage.Interleaved8x4.bitCountPerPixel, colorSpace: CGColorSpaceCreateDeviceRGB(), bitmapInfo: pixelFormat.toBitmapInfo(premultiplyAlpha: premultiplyAlpha), renderingIntent: .perceptual)
        else {
            throw NSError("Could not initialize vImage_CGImageFormat")
        }

        return try vImage.PixelBuffer(cgImage: self, cgImageFormat: &imageFormat, pixelFormat: vImage.Interleaved8x4.self)
    }
    
    public enum PixelFormat {
        /// Big-endian, alpha first.
        case argb
        /// Big-endian, alpha last.
        case rgba
        /// Little-endian, alpha first.
        case bgra
        /// Little-endian, alpha last.
        case abgr
                
        func toBitmapInfo(premultiplyAlpha: Bool) -> CGBitmapInfo {
            let alphaFirst = premultiplyAlpha ? CGImageAlphaInfo.premultipliedFirst : .first
            let alphaLast = premultiplyAlpha ? CGImageAlphaInfo.premultipliedLast : .last
            let byteOrder: CGBitmapInfo = self == .argb || self == .rgba ? .byteOrder32Big : .byteOrder32Little
            let alphaInfo: CGImageAlphaInfo = self == .argb || self == .bgra ? alphaFirst : alphaLast
            return CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)
        }
    }
}

fileprivate enum CGImageError: Error {
    case unableToCreateImageFromContext
    case invalidContext
}
