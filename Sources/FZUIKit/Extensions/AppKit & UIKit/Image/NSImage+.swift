//
//  NSImage+.swift
//  FZCollection
//
//  Created by Florian Zand on 25.04.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import UniformTypeIdentifiers

// isSymbolImage
public extension NSUIImage {
    /// The symbol name of the image.
    var symbolName: String? {
        #if os(macOS)
        let description = String(describing: self)
        return description.substrings(between: "symbol = ", and: ">").first
        #else
        guard isSystemSymbol, let strSeq = "\(String(describing: self))".split(separator: ")").first else { return nil }
        let str = String(strSeq)
        guard let name = str.split(separator: ":").last else { return nil }
        return String(name)
        #endif
    }
}

#if os(macOS)
public extension NSImage {
    /// A Boolean value that indicates whether the image is a symbol.
    var isSymbolImage: Bool {
        return (symbolName != nil)
    }
    
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: .zero)
    }

    convenience init?(size: CGSize, actions: (CGContext) -> Void) {
        if let currentCGContext = NSGraphicsContext.current?.cgContext {
            self.init(size: size)
            lockFocusFlipped(false)
            actions(currentCGContext)
            unlockFocus()
        } else {
            return nil
        }
    }

    convenience init(color: NSUIColor, size: CGSize = .init(width: 1.0, height: 1.0)) {
        self.init(size: size, flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
        resizingMode = .stretch
        capInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    var cgImage: CGImage? {
        guard let imageData = tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }

    var cgImageSource: CGImageSource? {
        if let data = tiffRepresentation {
            return CGImageSourceCreateWithData(data as CFData, nil)
        }
        return nil
    }

    var dataSize: DataSize? {
        if let bytes = tiffData?.count {
            return DataSize(bytes)
        }
        return nil
    }

    typealias ImageOrientation = ImageProperties.Orientation
    var orientation: ImageOrientation {
        ImageSource(image: self)?.properties()?.orientation ?? .up
    }
}

public extension NSImage {
    func withTintColor(_ color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()
        color.set()
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }

    func roundedCorners(radius: CGFloat) -> NSImage {
        let rect = NSRect(origin: NSPoint.zero, size: size)
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
            context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
            context.closePath()
            context.clip()
            context.draw(cgImage, in: rect)

            if let composedImage = context.makeImage() {
                return NSImage(cgImage: composedImage, size: size)
            }
        }
        return self
    }

    func rounded() -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let frame = NSRect(origin: .zero, size: size)
        NSBezierPath(ovalIn: frame).addClip()
        draw(at: .zero, from: frame, operation: .sourceOver, fraction: 1)

        image.unlockFocus()
        return image
    }

    static func maskImage(cornerRadius: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: cornerRadius * 2, height: cornerRadius * 2), flipped: false) { rectangle in
            let bezierPath = NSBezierPath(roundedRect: rectangle, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.black.setFill()
            bezierPath.fill()
            return true
        }
        image.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image
    }

    func rotated(degrees: Float) -> NSImage {
        let degrees = CGFloat(degrees)
        var imageBounds = NSZeroRect; imageBounds.size = size
        let pathBounds = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
        let rotatedBounds: NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, pathBounds.bounds.size.width, pathBounds.bounds.size.height)
        let rotatedImage = NSImage(size: rotatedBounds.size)

        // Center the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2)
        imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2)

        // Start a new transform
        transform = NSAffineTransform()
        // Move coordinate system to the center (since we want to rotate around the center)
        transform.translateX(by: +(NSWidth(rotatedBounds) / 2), yBy: +(NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
        // Move the coordinate system bak to normal
        transform.translateX(by: -(NSWidth(rotatedBounds) / 2), yBy: -(NSHeight(rotatedBounds) / 2))
        // Draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        draw(in: imageBounds, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()

        return rotatedImage
    }

    func opacity(_ value: CGFloat) -> NSUIImage {
        let opacityImage = NSImage(size: size)
        opacityImage.cacheMode = .never
        opacityImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .default
        draw(in: CGRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: value)
        opacityImage.unlockFocus()
        return opacityImage
    }

    func resized(to size: CGSize) -> NSImage {
        let scaledImage = NSImage(size: size)
        scaledImage.cacheMode = .never
        scaledImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .default
        draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height), from: .zero, operation: .copy, fraction: 1.0)
        scaledImage.unlockFocus()
        return scaledImage
    }

    func resized(toFit size: CGSize) -> NSImage {
        let size = self.size.scaled(toFit: size)
        return resized(to: size)
    }

    func resized(toFill size: CGSize) -> NSImage {
        let size = self.size.scaled(toFill: size)
        return resized(to: size)
    }
}

public extension NSBitmapImageRep {
    var jpegData: Data? { representation(using: .jpeg, properties: [:]) }
    var pngData: Data? { representation(using: .png, properties: [:]) }
    var tiffData: Data? { representation(using: .tiff, properties: [:]) }
}

public extension NSImage {
    var bitmapImageRep: NSBitmapImageRep? {
        if let cgImage = cgImage {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = size
            return imageRep
        }
        return nil
    }

    var tiffData: Data? { tiffRepresentation }
    var pngData: Data? { bitmapImageRep?.pngData }
    var jpegData: Data? { bitmapImageRep?.jpegData }

    func jpegData(compressionFactor factor: Double) -> Data? {
        bitmapImageRep?.representation(using: .jpeg, properties: [.compressionFactor: NSNumber(factor.clamped(max: 1.0))])
    }
}

public extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
#endif
