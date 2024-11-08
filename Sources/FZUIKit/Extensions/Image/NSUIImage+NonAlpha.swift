//
//  File.swift
//  
//
//  Created by Florian Zand on 03.11.24.
//

import CoreGraphics
import Accelerate
import FZSwiftUtils
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension CGImage {
    /**
     Returns the rectangle bounding the non-alpha area of the image.
     
     - Parameter maximumAlphaChannel: he maximum alpha value to consider as transparent. Any alpha value strictly greater than this is considered opaque.
     */
    public func nonAlphaRect(maximumAlphaChannel: UInt8 = 0) -> CGRect {
        var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)
        
        var sourceBuffer = vImage_Buffer()
        defer { sourceBuffer.data.deallocate() }
        
        // Initialize the buffer with the CGImage
        let error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, self, vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return CGRect(.zero, size) }
        
        // Create a buffer for the alpha channel
        var alphaBuffer = vImage_Buffer(data: malloc(width * height),
                                        height: vImagePixelCount(height),
                                        width: vImagePixelCount(width),
                                        rowBytes: width)
        defer { alphaBuffer.data.deallocate() }
        
        // Extract the alpha channel
        vImageExtractChannel_ARGB8888(&sourceBuffer, &alphaBuffer, 3, vImage_Flags(kvImageNoFlags))
        
        // Find the bounding box of non-alpha pixels
        var minX = width
        var maxX = 0
        var minY = height
        var maxY = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelAlpha = alphaBuffer.data.load(fromByteOffset: y * alphaBuffer.rowBytes + x, as: UInt8.self)

                // Only consider pixels with alpha strictly greater than the threshold as opaque
                if pixelAlpha > maximumAlphaChannel {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        
        // Check if we found a valid bounding box
        guard minX < maxX, minY < maxY else { return CGRect(.zero, size) }
        
        // Define the crop rect
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }
    
    
    /**
     Returns a cropped image to the bounding rect of the non-alpha area.
     
     - Parameter maximumAlphaChannel: he maximum alpha value to consider as transparent. Any alpha value strictly greater than this is considered opaque.
     */
    public func croppedToNonTransparent(maximumAlphaChannel: UInt8 = 0) -> CGImage {
        let rect = nonAlphaRect(maximumAlphaChannel: maximumAlphaChannel)
        guard rect.size != size else { return self }
        return self.cropping(to: rect) ?? self
    }
}

extension NSUIImage {
    /**
     Returns the rectangle bounding the non-alpha area of the image.
     
     - Parameter maximumAlphaChannel: he maximum alpha value to consider as transparent. Any alpha value strictly greater than this is considered opaque.
     */
    public func nonAlphaRect(maximumAlphaChannel: UInt8 = 0) -> CGRect {
        if let alphaRect = nonAlphaRect[maximumAlphaChannel] {
            return alphaRect
        }
        let rect = cgImage?.nonAlphaRect(maximumAlphaChannel: maximumAlphaChannel) ?? CGRect(.zero, size)
        nonAlphaRect[maximumAlphaChannel] = rect
        return rect
    }
    
    var nonAlphaRect: [UInt8: CGRect] {
        get { getAssociatedValue("nonAlphaRect", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "nonAlphaRect") }
    }
    
    /**
     Returns a cropped image to the bounding rect of the non-alpha area.
     
     - Parameter maximumAlphaChannel: he maximum alpha value to consider as transparent. Any alpha value strictly greater than this is considered opaque.
     */
    public func croppedToNonTransparent(maximumAlphaChannel: UInt8 = 0) -> NSUIImage {
        cgImage?.croppedToNonTransparent(maximumAlphaChannel: maximumAlphaChannel).nsUIImage ?? self
    }
}
