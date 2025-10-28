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

    /// A Boolean value indicating whether the image is a symbol.
    @available(macOS 11.0, *)
    var isSymbolImage: Bool {
        value(forKeySafely: "_isSymbolImage") as? Bool ?? (symbolName != nil)
    }

    /// Returns the image types supported by `NSImage`.
    @available(macOS 11.0, *)
    static var imageContentTypes: [UTType] {
        imageTypes.compactMap({ UTType($0) })
    }

    /// A `cgImage` represenation of the image.
    var cgImage: CGImage? {
        if let image = cgImage(forProposedRect: nil, context: nil, hints: nil) {
            return image
        }
        guard let imageData = tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }

    /// A `CIImage` represenation of the image.
    var ciImage: CIImage? {
        tiffRepresentation(using: .none, factor: 0).flatMap(CIImage.init)
    }

    /**
     Creates an image source that reads the image.

     - Note: Loading an animated image takes time as each image frame is loaded initially. It's recommended to parse the animation properties and frames via the image's `NSBitmapImageRep` representation.
     */
    var cgImageSource: CGImageSource? {
        let images = representations.compactMap({$0 as? NSBitmapImageRep}).flatMap({$0.getImages()})
        guard !images.isEmpty else { return nil }
        let types = Set(images.compactMap { $0.utType })
        let outputType = types.first ?? kUTTypeTIFF
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, outputType, images.count, nil) else { return nil }
        images.forEach { CGImageDestinationAddImage(destination, $0, nil) }
        guard CGImageDestinationFinalize(destination) else { return nil }
        return CGImageSourceCreateWithData(mutableData, nil)
    }
    
    private func bestImages(for size: CGSize? = nil) -> CGImageSource? {
        let bitmapImageReps = representations.compactMap({ $0 as? NSBitmapImageRep })
        if let cgImages = bitmapImageReps.first(where: { $0.isAnimated })?.cgImages {
            let mutableData = NSMutableData()
            let outputType = cgImages.lazy.compactMap({$0.utType}).first ?? kUTTypeGIF
            guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, outputType, cgImages.count, nil) else { return nil }
            cgImages.forEach { CGImageDestinationAddImage(destination, $0, nil) }
            guard CGImageDestinationFinalize(destination) else { return nil }
            return CGImageSourceCreateWithData(mutableData, nil)
        } else if let data = bitmapImageReps.lazy.compactMap({$0.tiffRepresentation}).first {
            return CGImageSourceCreateWithData(data as CFData, nil)
        } else if let cgImage = bitmapImageReps.lazy.compactMap({$0.cgImage}).first {
            let mutableData = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, cgImage.utType ?? kUTTypeTIFF, 1, nil) else { return nil }
            CGImageDestinationAddImage(destination, cgImage, nil)
            guard CGImageDestinationFinalize(destination) else { return nil }
            return CGImageSourceCreateWithData(mutableData, nil)
        }
        return nil
    }

    /// The image orientation.
    var orientation: CGImagePropertyOrientation {
        ImageSource(image: self)?.properties()?.orientation ?? .up
    }
}

public extension NSImage {
    /**
     Returns a new version of the current image with the specified tint color.

     For bitmap images, this method draws the background tint color followed by the image contents using the [CGBlendMode.destinationIn](https://developer.apple.com/documentation/CoreGraphics/CGBlendMode/destinationIn) mode. For symbol images, this method returns an image that always uses the specified tint color.

     The new image uses the same rendering mode as the original image.

     - Parameter color: The tint color to apply to the image.
     - Returns: A new version of the image that incorporates the specified tint color.
     */
    func withTintColor(_ color: NSUIColor) -> NSUIImage {
        if #available(macOS 12.0, *), isSymbolImage {
            return applyingSymbolConfiguration(.init(paletteColors: [color])) ?? self
        }
        return NSImage(size: size, flipped: false) { rect in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }

    /// Returns an object scaled to the current main screen that may be used as the contents of a layer.
    var scaledLayerContents: Any {
        layerContents(forContentsScale: recommendedLayerContentsScale(0.0))
    }
    
    /// Returns an object scaled to the specified screen that can be used as the contents of a layer.
    func scaledLayerContents(for screen: NSScreen) -> Any {
        layerContents(forContentsScale: recommendedLayerContentsScale(screen.backingScaleFactor))
    }
    
    /// Returns an object scaled to the specified window that can be used as the contents of a layer.
    func scaledLayerContents(for window: NSWindow) -> Any {
        layerContents(forContentsScale: recommendedLayerContentsScale(window.backingScaleFactor))
    }
    
    /// Returns an object scaled to the specified view window that can be used as the contents of a layer.
    func scaledLayerContents(for view: NSView) -> Any {
        layerContents(forContentsScale: recommendedLayerContentsScale(view.window?.backingScaleFactor ?? 0.0))
    }
    
    /// An image object scaled to the specified layer that can be used as the contents of the layer.
    func scaledLayerContents(for layer: CALayer) -> Any {
        layerContents(forContentsScale: recommendedLayerContentsScale(layer.parentView?.window?.backingScaleFactor ?? 0.0))
    }
}

public extension NSImage {
    /// The bitmap representation of the image
    var bitmapImageRep: NSBitmapImageRep? {
        if let representation = representations.lazy.compactMap({$0 as? NSBitmapImageRep}).first {
            return representation
        } else if let cgImage = cgImage {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = size
            return imageRep
        }
        return nil
    }
    
    /**
     Returns a data object that contains the specified image in TIFF format.
     
     - Parameter compression: The compression method to use.

     - Returns: A data object containing the TIFF data, or `nil` if there was a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func tiffData(compression: NSBitmapImageRep.TIFFCompression = .none) -> Data? { compression == .none ? tiffRepresentation : bitmapImageRep?.tiffData(compression: compression)
    }

    /**
     Returns a data object that contains the specified image in PNG format.

     - Returns: A data object containing the PNG data, or `nil` if there was a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func pngData() -> Data? { bitmapImageRep?.pngData() }
    
    /**
     Returns a data object that contains the specified image in BMP format.

     - Returns: A data object containing the PNG data, or `nil` if there was a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func bmpData() -> Data? { bitmapImageRep?.bmpData() }

    /**
     Returns a data object that contains the image in JPEG format.

     - Parameter compressionFactor: The quality of the resulting JPEG image, expressed as a value from `0.0` to `1.0`. The value `0.0` represents the maximum compression (or lowest quality) while the value `1.0` represents the least compression (or best quality).

     - Returns: A data object containing the JPEG data, or `nil` if there’s a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
     */
    func jpegData(compressionQuality: Double = 1.0) -> Data? {
        bitmapImageRep?.jpegData(compressionFactor: compressionQuality)
    }

    /**
     Returns the image flipped.

     - Parameter shouldFlip: A Boolean value indicating whether the image should be flipped.
     - Returns: The flipped image.
     */
    func flipped(_ shouldFlip: Bool = true) -> NSImage {
        let newImage = NSImage(size: size, flipped: shouldFlip) { rect in
            self.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0, respectFlipped: false, hints: nil)
            return true
        }
        return newImage
    }
}
#endif
