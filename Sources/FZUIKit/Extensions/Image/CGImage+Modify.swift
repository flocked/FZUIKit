//
//  CGImage+Modify.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

import Foundation
import FZSwiftUtils
import CoreGraphics
#if os(macOS) || os(iOS) || os(tvOS)
import CoreImage
#endif


public extension CGImage {
    /**
     Returns the image resized to the specified size.

     - Parameters:
        - targetSize: The size of the resized image.
        - quality: The quality of resizing the image.

     - Returns: The resized image, or `nil` if resizing failed.
     */
    func resized(to targetSize: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        guard targetSize != size else { return self }
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        guard width > 0, height > 0 else { return nil }
        guard let colorSpace = colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        context.interpolationQuality = quality
        context.draw(self, in: CGRect(origin: .zero, size: targetSize))
        return context.makeImage()
    }

    /**
     Returns the image resized to fit the specified size.

     - Parameters:
        - targetSize: The size of the resized image.
        - quality: The quality of resizing the image.

     - Returns: The resized image, or `nil` if resizing failed.
     */
    func resized(toFit targetSize: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        resized(to: size.scaled(toFit: targetSize), quality: quality)
    }

    /**
     Returns the image resized to fill the specified size.

     - Parameters:
        - targetSize: The size of the resized image.
        - quality: The quality of resizing the image.

     - Returns: The resized image, or `nil` if resizing failed.
     */
    func resized(toFill targetSize: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        guard width > 0, height > 0 else { return nil }
        guard let colorSpace = colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        context.interpolationQuality = quality
        let drawRect = size.scaled(toFill: targetSize).rect.center(targetSize.rect.center)
        context.draw(self, in: drawRect)
        return context.makeImage()
    }
    
    /**
     Returns the image resized to the specified width while maintaining the aspect ratio.

     - Parameters:
        - width: The width of the resized image.
        - quality: The quality of resizing the image.

     - Returns: The resized image, or `nil` if resizing failed.
     */
    func resized(toWidth width: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage? {
        resized(to: size.scaled(toWidth: width), quality: quality)
    }

    /**
     Returns the image resized to the specified height while maintaining the aspect ratio.

     - Parameters:
        - height: The height of the resized image.
        - quality: The quality of resizing the image.

     - Returns: The resized image, or `nil` if resizing failed.
     */
    func resized(toHeight height: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage? {
        resized(to: size.scaled(toHeight: height), quality: quality)
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
        filter.setValue(safely: ciImage, forKey: kCIInputImageKey)
        if filterName == "CIColorControls" {
            filter.setValue(safely: 0.0, forKey: kCIInputSaturationKey)
        }
        let context = CIContext()
        return filter.outputImage.flatMap {
            context.createCGImage($0, from: $0.extent)
        }
    }
    #endif
}
