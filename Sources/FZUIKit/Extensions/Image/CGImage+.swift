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
        Image(nsImage: nsImage)
        #elseif canImport(UIKit)
        Image(uiImage: uiImage)
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
    
    /// Returns the data for a bitmap image or image mask.
    var data: Data? {
        dataProvider?.data as Data?
    }
    
    /// Returns the pointer to the bytes for a bitmap image or image mask.
    var bytePointer: UnsafePointer<UInt8>? {
        dataProvider?.data?.bytes()
    }
    
    internal var nsUIImage: NSUIImage {
        NSUIImage(cgImage: self)
    }
    
    /// A Boolean value that indicates whether the image is lazily loaded.
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
    
    /// A Boolean value that indicates whether the image has alpha information.
    var hasAlpha: Bool {
        switch alphaInfo {
        case .premultipliedFirst, .premultipliedLast, .last, .first, .alphaOnly: return true
        default: return false
        }
    }
    
    #if !os(watchOS)
    func masked(by mask: CGImage, invertMask: Bool = false) -> CGImage? {
        mask.grayScaled(invert: invertMask).flatMap(masking)
    }
    
    func grayScaled(invert: Bool = false, includeAlpha: Bool = false) -> CGImage? {
        let ciImage = CIImage(cgImage: self)
        guard let grayFilter = CIFilter(name: "CIColorControls") else { return nil }
        grayFilter.setValue(ciImage, forKey: kCIInputImageKey)
        grayFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        guard var outputImage = grayFilter.outputImage else { return nil }
        if invert, let invertFilter = CIFilter(name: "CIColorInvert") {
            invertFilter.setValue(outputImage, forKey: kCIInputImageKey)
            if let inverted = invertFilter.outputImage {
                outputImage = inverted
            }
        }
        return CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent, format: includeAlpha ? .LA8 : .L8, colorSpace: CGColorSpaceCreateDeviceGray())
    }
    #endif
    
    func masked(by mask: CGImage, invertMask: Bool = false, shouldInterpolate: Bool) -> CGImage? {
        mask.asMask(invert: invertMask, shouldInterpolate: shouldInterpolate).flatMap(masking)
    }
    
    func asMask(invert: Bool = false, shouldInterpolate: Bool = false) -> CGImage? {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        if invert {
            context.setFillColor(gray: 1, alpha: 1)
            context.fill(rect)
            context.setBlendMode(.difference)
        } else {
            context.setBlendMode(.copy)
        }
        context.draw(self, in: rect)
        guard let img = context.makeImage(), let provider = img.dataProvider else { return nil }
        return CGImage(maskWidth: img.width, height: img.height, bitsPerComponent: img.bitsPerComponent, bitsPerPixel: img.bitsPerPixel, bytesPerRow: img.bytesPerRow, provider: provider, decode: nil, shouldInterpolate: shouldInterpolate)
    }
    
    func asMaskAlt(invert: Bool = false, shouldInterpolate: Bool = false) -> CGImage? {
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        context.flipVertically()
        if invert {
            context.setFillColor(gray: 1, alpha: 1)
            context.fill(size.rect)
            context.setBlendMode(.difference)
        }
        context.draw(self)
        guard let img = context.makeImage(), let provider = img.dataProvider else { return nil }
        return CGImage(maskWidth: img.width, height: img.height, bitsPerComponent: img.bitsPerComponent, bitsPerPixel: img.bitsPerPixel, bytesPerRow: img.bytesPerRow, provider: provider, decode: nil, shouldInterpolate: shouldInterpolate)
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
              shouldInterpolate == image.shouldInterpolate,
              let data1 = dataProvider?.data, let data2 = image.dataProvider?.data,
              data1.count == data2.count
        else { return false }
        return data1.withBytes { ptr1 in
            data2.withBytes { ptr2 in
                memcmp(ptr1, ptr2, data1.count) == 0
            }
        }
    }
}

extension CFType where Self == CGImage {
    /**
     Creates a new image filled with the specified color.
     
     - Parameters:
       - size: The size of the image.
       - color: The fill color of the image.
     */
    public init(size: CGSize, color: CGColor) {
        self.init(size: size, colorSpace: color.colorSpace ?? .deviceRGB, color: color, drawingHandler: { _ in })
    }
    
    /**
     Creates an image whose contents are drawn using the specified block.
     
     - Parameters:
        - size: The size of the image.
        - colorSpace: The name of the color space.
        - hasAlpha: A Boolean value indicating whether the image has an alpha channel.
        - drawingHandler: A block that draws the contents of the image representation.
     */
    public init(size: CGSize, colorSpace: CGColorSpaceName = .sRGB, hasAlpha: Bool = true, drawingHandler: ((CGContext) -> Void)) {
        self.init(size: size, colorSpace: colorSpace.colorSpace ?? .deviceRGB, hasAlpha: hasAlpha, drawingHandler: drawingHandler)
    }
    
    /**
     Creates an image whose contents are drawn using the specified block.
     
     - Parameters:
        - size: The size of the image.
        - colorSpace: The name of the color space.
        - hasAlpha: A Boolean value indicating whether the image has an alpha channel.
        - drawingHandler: A block that draws the contents of the image representation.
     */
    @_disfavoredOverload
    public init(size: CGSize, colorSpace: CGColorSpace, hasAlpha: Bool = true, drawingHandler: ((CGContext) -> Void)) {
        let context = CGContext(size: size, space: colorSpace, hasAlpha: hasAlpha)!
        drawingHandler(context)
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
    public init(size: CGSize, colorSpace: CGColorSpaceName = .sRGB, color: CGColor, drawingHandler: ((CGContext) -> Void)) {
        self.init(size: size, colorSpace: colorSpace.colorSpace ?? .deviceRGB, color: color, drawingHandler: drawingHandler)
    }
    
    /**
     Creates an image whose contents are drawn using the specified block.
     
     - Parameters:
        - size: The size of the image.
        - colorSpace: The name of the color space.
        - color: The background color of the image.
        - drawingHandler: A block that draws the contents of the image representation.
     */
    @_disfavoredOverload
    public init(size: CGSize, colorSpace: CGColorSpace, color: CGColor, drawingHandler: ((CGContext) -> Void)) {
        self.init(size: size, colorSpace: colorSpace, hasAlpha: color.alpha < 1.0) { context in
            context.withSavedGState {
                context.fill(color)
            }
            drawingHandler(context)
        }
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
            CGBitmapInfo(alpha: self == .argb || self == .bgra ? (premultiplyAlpha ? .premultipliedFirst : .first) : (premultiplyAlpha ? .premultipliedLast : .last), byteOrder: self == .argb || self == .rgba ?  .order32Big : .order32Little)
        }
    }
}

extension CGImage {
    /// The sRGB color components at the specified pixel location.
    func rgb(at point: CGPoint) -> ColorModels.SRGB? {
        guard let pixelData = dataProvider?.data, let data = pixelData.bytes() else {
            return nil
        }
        let layout = bitmapInfo.pixelByteOrder
        let x = Int(point.x)
        let y = Int(point.y)
        let index = width * y + x
        let numBytes = pixelData.count
        let numComponents = layout.count
        if numBytes != width * height * numComponents {
            return nil
        }
        switch numComponents {
        case 1:
            return .init(red: 0, green: 0, blue: 0, alpha: CGFloat(data[index])/255.0)
        case 3:
            let c0 = CGFloat((data[3*index])) / 255
            let c1 = CGFloat((data[3*index+1])) / 255
            let c2 = CGFloat((data[3*index+2])) / 255
            if layout == .bgr {
                return .init(red: c2, green: c1, blue: c0, alpha: 1.0)
            }
            return .init(red: c0, green: c1, blue: c2, alpha: 1.0)
        case 4:
            let c0 = CGFloat((data[4*index])) / 255
            let c1 = CGFloat((data[4*index+1])) / 255
            let c2 = CGFloat((data[4*index+2])) / 255
            let c3 = CGFloat((data[4*index+3])) / 255
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            switch layout {
            case .abgr:
                a = c0; b = c1; g = c2; r = c3
            case .argb:
                a = c0; r = c1; g = c2; b = c3
            case .bgra:
                b = c0; g = c1; r = c2; a = c3
            case .rgba:
                r = c0; g = c1; b = c2; a = c3
            default:
                break
            }
            if bitmapInfo.isAlphaPremultiplied && a > 0 {
                r = r / a
                g = g / a
                b = b / a
            }
            return .init(red: r, green: g, blue: b, alpha: a)
        default:
            return nil
        }
    }
    
    /// The color at the specified pixel location.
    func color(at point: CGPoint) -> CGColor? {
        rgb(at: point)?.cgColor
    }
}

fileprivate enum CGImageError: Error {
    case unableToCreateImageFromContext
    case invalidContext
}

public extension Sequence where Element == CGImage {
    /// An array of unique images.
    func uniqueImages() -> [CGImage] {
        var seenHashes = Set<Int>()
        var seenDataCounts = Set<Int>()
        var seenDataHashes = Set<Int>()
        var seenOSHashes = Set<Int>()
        var result: [CGImage] = []
        for image in self {
            if seenHashes.insert(image.imageHash).inserted {
                result.append(image)
            } else {
                guard let data = image.dataProvider?.data as Data? else { continue }
                if seenDataCounts.insert(data.count).inserted {
                    result.append(image)
                } else if seenOSHashes.insert(OSHash(data: data).hashValue).inserted {
                    result.append(image)
                } else if seenDataHashes.insert(data.hashValue).inserted {
                    result.append(image)
                }
            }
        }
        return result
    }
}

fileprivate extension CGImage {
    var imageHash: Int {
        Hasher.hash([size, bitsPerPixel, bitsPerComponent, colorSpace?.name, bitmapInfo, byteOrderInfo, alphaInfo, bytesPerRow, utType, isMask, renderingIntent, shouldInterpolate])
    }
}
