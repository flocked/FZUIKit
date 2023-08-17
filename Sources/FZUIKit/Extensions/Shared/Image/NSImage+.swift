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
    /**
     Returns a new version of the image with a tint color.
     
     For bitmap images, this method draws the background tint color followed by the image contents using the `NSCompositingOperation.sourceAtop` mode. For symbol images, this method returns an image that always uses the specified tint color.
     
     - Parameters color: The tint color to apply to the image.
     - Returns: A new version of the image that incorporates the specified tint color.
     */
    func withTintColor(_ color: NSColor) -> NSImage {
        if #available(macOS 12.0, *) {
        if self.isSymbolImage {
             return self.withSymbolConfiguration(.init(paletteColors: [color])) ?? self
            }
        }
            
        let image = copy() as! NSImage
        image.lockFocus()
        color.set()
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        image.unlockFocus()
        image.isTemplate = false
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
    /// A data object that contains the representation in JPEG format.
    var pngData: Data? { representation(using: .png, properties: [:]) }
    
    /// A data object that contains the representation in JPEG format.
    var tiffData: Data? { representation(using: .tiff, properties: [:]) }
    
    /// A data object that contains the representation in JPEG format.
    var jpegData: Data? { representation(using: .jpeg, properties: [:]) }
    
    /// A data object that contains the representation in JPEG format with the specified compressio factor.
    func jpegData(compressionFactor factor: Double) -> Data? { representation(using: .tiff, properties: [:]) }
}

public extension NSImage {
    
    /// The bitmap representation of the image
    var bitmapImageRep: NSBitmapImageRep? {
        if let cgImage = cgImage {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = size
            return imageRep
        }
        return nil
    }

    /**
     Returns a data object that contains the specified image in TIFF format.
     
     - Returns: A data object containing the TIFF data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
     */
    func tiffData() -> Data? { tiffRepresentation }
    
    /**
     Returns a data object that contains the specified image in PNG format.
     
     - Returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
     */
    func pngData() -> Data? { bitmapImageRep?.pngData }
    
    /**
     Returns a data object that contains the image in JPEG format.
     
     - Returns: A data object containing the JPEG data, or nil if there’s a problem generating the data. This function may return nil if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func jpegData() -> Data? { bitmapImageRep?.jpegData }

    /**
     Returns a data object that contains the image in JPEG format.
     
     - Parameters compressionFactor:  The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).

     - Returns: A data object containing the JPEG data, or nil if there’s a problem generating the data. This function may return nil if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func jpegData(compressionFactor factor: Double) -> Data? {
        bitmapImageRep?.jpegData(compressionFactor: factor)
    }
}

internal extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
#endif
