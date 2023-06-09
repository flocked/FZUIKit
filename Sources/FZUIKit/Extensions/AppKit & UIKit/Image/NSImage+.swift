//
//  NSImage+.swift
//  
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
