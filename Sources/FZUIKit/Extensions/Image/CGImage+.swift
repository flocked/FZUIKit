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

    /// A `Image` representation of the image.
    var swiftUI: Image {
        #if os(macOS)
            return Image(nsImage)
        #elseif canImport(UIKit)
            return Image(uiImage: uiImage)
        #endif
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
}
