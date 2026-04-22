//
//  NSUIImage+Modify.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIImage {
    /// Returns the image cropped to the specified rect.
    func cropped(to rect: CGRect) -> NSUIImage? {
        cgImage?.cropping(to: rect)?.nsUIImage
    }

    /**
     Creates a bitmap image from an existing image and an image mask.
     
     */
    func masked(with mask: NSUIImage) -> NSUIImage? {
        guard let mask = mask.cgImage else { return nil }
        return cgImage?.masking(mask)?.nsUIImage
    }
    
    /// Returns the image resized to fit the specified size.
    func resized(toFit targetSize: CGSize) -> NSUIImage {
        resized(to: size.scaled(toFit: targetSize))
    }

    /// Returns the image resized to fill the specified size.
    func resized(toFill targetSize: CGSize) -> NSUIImage {
        let drawRect = size.scaled(toFill: targetSize).rect.center(targetSize.rect.center)
        #if os(macOS)
        let newImage = NSImage(size: targetSize)
        newImage.cacheMode = .never
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .default
        defer { newImage.unlockFocus() }
        draw(in: drawRect, from: .zero, operation: .copy, fraction: 1.0, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
        return newImage
        #elseif os(iOS) || os(tvOS)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: drawRect)
        }
        #else
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        draw(in: drawRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
        #endif
    }

    /// Returns the image resized to the specified width while maintaining the aspect ratio.
    func resized(toWidth width: CGFloat) -> NSUIImage {
        resized(to: size.scaled(toWidth: width))
    }

    /// Returns the image resized to the specified height while maintaining the aspect ratio.
    func resized(toHeight height: CGFloat) -> NSUIImage {
        resized(to: size.scaled(toHeight: height))
    }

    /// Returns the image grayscaled.
    func grayscaled(mode: CGImage.GrayscalingMode = .deviceGray) -> NSUIImage? {
        guard let cgImage = cgImage?.grayscaled(mode: mode) else { return nil }
        let image = NSUIImage(cgImage: cgImage)
        #if os(macOS)
        image.isTemplate = true
        #endif
        return image
    }
}

#if os(macOS)
public extension NSUIImage {
    /// Returns the image resized to the specified size.
    func resized(to size: CGSize) -> NSImage {
        let scaledImage = NSImage(size: size)
        scaledImage.cacheMode = .never
        scaledImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .default
        draw(in: size.rect, from: .zero, operation: .copy, fraction: 1.0)
        scaledImage.unlockFocus()
        return scaledImage
    }

    /// Returns the image elipsed.
    func elipsed() -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let frame = size.rect
        NSBezierPath(ovalIn: frame).addClip()
        draw(at: .zero, from: frame, operation: .sourceOver, fraction: 1)

        image.unlockFocus()
        return image
    }
    
    /// Returns the image as circle.
    func rounded() -> NSUIImage {
        rounded(cornerRadius: size.min)
    }

    /// Returns the image rounded with the specified corner radius.
    func rounded(cornerRadius: CGFloat) -> NSImage {
        let rect = size.rect
        if
            let cgImage = cgImage,
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 4 * Int(size.width),
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        {
            context.beginPath()
            context.addPath(CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
            context.closePath()
            context.clip()
            context.draw(cgImage, in: rect)

            if let composedImage = context.makeImage() {
                return NSImage(cgImage: composedImage, size: size)
            }
        }
        return self
    }

    /// Returns the image rotated to the specified degree.
    func rotated(degrees: Float) -> NSImage {
        let degrees = CGFloat(degrees)
        var imageBounds = NSRect.zero; imageBounds.size = size
        let pathBounds = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
        let rotatedBounds = NSRect(x: NSPoint.zero.x, y: NSPoint.zero.y, width: pathBounds.bounds.size.width, height: pathBounds.bounds.size.height)
        let rotatedImage = NSImage(size: rotatedBounds.size)

        imageBounds.origin.x = rotatedBounds.midX - (imageBounds.width / 2)
        imageBounds.origin.y = rotatedBounds.midY - (imageBounds.height / 2)

        transform = NSAffineTransform()
        transform.translateX(by: +(rotatedBounds.width / 2), yBy: +(rotatedBounds.height / 2))
        transform.rotate(byDegrees: degrees)
        transform.translateX(by: -(rotatedBounds.width / 2), yBy: -(rotatedBounds.height / 2))
        rotatedImage.lockFocus()
        transform.concat()
        draw(in: imageBounds, from: NSRect.zero, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        return rotatedImage
    }

    /// Returns the image with the specified opacity value.
    func withOpacity(_ value: CGFloat) -> NSUIImage {
        let opacityImage = NSImage(size: size)
        opacityImage.cacheMode = .never
        opacityImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .default
        draw(in: size.rect, from: .zero, operation: .sourceOver, fraction: value)
        opacityImage.unlockFocus()
        return opacityImage
    }

    /**
     Creates a new image by masking the current image to the area defined by a `NSBezierPath`.

     This method uses the provided `NSBezierPath` as a mask to retain only the area inside the path and discard everything outside of it.

     - Parameters:
        - path: The `NSBezierPath` that defines the mask for the image. Only the area inside the path will remain visible.
        - size: The size of the resulting image. The image will be scaled to fit this size.

     - Returns: A new `NSImage` masked by the given path, or `nil` if the operation fails.
     */
    func image(maskedBy path: NSBezierPath, size: CGSize) -> NSImage? {
        guard let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        guard let context = NSGraphicsContext(bitmapImageRep: bitmapRep) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        path.addClip()
        draw(at: .zero, from: size.rect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        let finalImage = NSImage(size: size)
        finalImage.addRepresentation(bitmapRep)
        return finalImage
    }
}

#elseif canImport(UIKit)

public extension NSUIImage {
    /// Returns the image resized to the specified size.
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: size.rect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// Returns the image rotated to the specified degree.
    func rotated(degrees: CGFloat) -> NSUIImage {
        rotated(radians: degrees * .pi / 180)
    }
    
    /// Returns the image rotated to the specified radians.
    func rotated(radians: CGFloat) -> UIImage {
        let newSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radians)).integral.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        draw(in: CGRect(x: -size.width / 2,  y: -size.height / 2, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    #if os(iOS) || os(tvOS)
    /**
     Creates a new image by masking the current image to the area defined by a `UIBezierPath`.

     This method uses the provided `UIBezierPath` as a mask to retain only the area inside the path and discard everything outside of it.

     - Parameters:
        - path: The `UIBezierPath` that defines the mask for the image. Only the area inside the path will remain visible.
        - size: The size of the resulting image. The image will be scaled to fit this size.

     - Returns: A new `UIImage` masked by the given path, or `nil` if the operation fails.
     */
    func image(maskedBy path: NSUIBezierPath, size: CGSize) -> NSUIImage {
        UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { context in
            path.addClip()
            draw(at: .zero)
        }
    }

    /// Returns the image as circle.
    func rounded() -> NSUIImage {
        rounded(cornerRadius: size.min)
    }
    
    /// Returns the image elipsed.
    func elipsed() -> UIImage {
        image(maskedBy: UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)), size: size)
    }

    /// Returns the image rounded with the specified corner radius.
    func rounded(cornerRadius: CGFloat) -> UIImage {
        image(maskedBy: UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius), size: size)
     }

    /// Returns the image with the specified opacity value.
    func withOpacity(_ value: CGFloat) -> NSUIImage {
        UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
            draw(in: size.rect, blendMode: .normal, alpha: value)
        }
    }
    
    /// Returns a vertically flipped copy of the image.
    func verticallyFlipped() -> NSUIImage {
        _flipped(scaleX: 1, y: -1, translateX: 0, y: size.height)
    }

    /// Returns a horizontally flipped copy of the image.
    func horizontallyFlipped() -> NSUIImage {
        _flipped(scaleX: -1, y: 1, translateX: size.width, y: 0)
    }

    /// Internal helper that applies a transform and redraws the image.
    private func _flipped(scaleX sx: CGFloat, y sy: CGFloat, translateX tx: CGFloat, y ty: CGFloat) -> NSUIImage {
        NSUIGraphicsImageRenderer(size: size).image { context in
            let cg = context.cgContext
            cg.translateBy(x: tx, y: ty)
            cg.scaleBy(x: sx, y: sy)
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    #endif
}
#endif
