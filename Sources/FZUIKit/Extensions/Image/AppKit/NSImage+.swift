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
        @available(macOS 11.0, *)
        var isSymbolImage: Bool {
            (self.value(forKey: "_isSymbolImage") as? Bool) ??
                (symbolName != nil)
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
        
        /// Returns the image types supported by `NSImage`.
        @available(macOS 11.0, *)
        static var imageContentTypes: [UTType] {
            imageTypes.compactMap({UTType($0)})
        }

        var cgImage: CGImage? {
            if let image = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                return image
            }
            guard let imageData = tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
        }

        var ciImage: CIImage? {
            tiffRepresentation(using: .none, factor: 0).flatMap(CIImage.init)
        }

        var cgImageSource: CGImageSource? {
            if let data = tiffRepresentation {
                return CGImageSourceCreateWithData(data as CFData, nil)
            }
            return nil
        }

        typealias ImageOrientation = ImageSource.ImageProperties.Orientation
        var orientation: ImageOrientation {
            ImageSource(image: self)?.properties()?.orientation ?? .up
        }
    }

    public extension NSImage {
        /**
         Returns a new version of the current image with the specified tint color.

         For bitmap images, this method draws the background tint color followed by the image contents using the `CGBlendMode.destinationIn mode. For symbol images, this method returns an image that always uses the specified tint color.

         The new image uses the same rendering mode as the original image.

         - Parameter color: The tint color to apply to the image.
         - Returns: A new version of the image that incorporates the specified tint color.
         */
        func withTintColor(_ color: NSColor) -> NSImage {
            if #available(macOS 12.0, *) {
                if self.isSymbolImage {
                    return self.withSymbolConfiguration(.init(paletteColors: [color])) ?? self
                }
            }

            if let cgImage = cgImage {
                let rect = CGRect(.zero, cgImage.size)
                if let tintedImage = try? CGImage.create(size: rect.size, { ctx, _ in

                    // draw black background to preserve color of transparent pixels
                    ctx.setBlendMode(.normal)
                    ctx.setFillColor(CGColor.black)
                    ctx.fill([rect])

                    // Draw the image
                    ctx.setBlendMode(.normal)
                    ctx.draw(cgImage, in: rect)

                    // tint image (losing alpha) - the luminosity of the original image is preserved
                    ctx.setBlendMode(.color)
                    ctx.setFillColor(color.cgColor)
                    ctx.fill([rect])

                    //   if keepingAlpha {
                    // mask by alpha values of original image
                    ctx.setBlendMode(.destinationIn)
                    ctx.draw(cgImage, in: rect)
                    //  }
                }).nsImage {
                    return tintedImage
                }
            }
            return self
        }

        /// Returns an object scaled to the curren screen that may be used as the contents of a layer.
        var scaledLayerContents: Any {
            let scale = recommendedLayerContentsScale(0.0)
            return layerContents(forContentsScale: scale)
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
        func jpegData(compressionFactor _: Double) -> Data? { representation(using: .tiff, properties: [:]) }

        /// The number of frames in an animated GIF image, or `0` if the image isn't a GIF.
        var frameCount: Int {
            value(forProperty: .frameCount) as? Int ?? 0
        }
        
        /// Returns the image frame at the specified index.
        func frame(at index: Int) -> ImageFrame? {
            currentFrame = index
            guard let image = cgImage?.nsUIImage else { return nil }
            return ImageFrame(image, currentFrameDuration)
        }
        
        /// Returns the frame at the specified index.
        subscript(index: Int) -> ImageFrame? {
            frame(at: index)
        }
        
        /// The total duration (in seconds) of all frames for an animated GIF image, or `0` if the image isn't a GIF.
        var duration: TimeInterval {
            get {
                let current = currentFrame
                var duration: TimeInterval = 0.0
                (0..<frameCount).forEach({
                    currentFrame = $0
                    duration += currentFrameDuration
                })
                currentFrame = current
                return duration
            }
            set {
                let count = frameCount
                let duration = newValue / Double(count)
                let current = currentFrame
                (0..<count).forEach({
                    currentFrame = $0
                    currentFrameDuration = duration
                })
                currentFrame = current
            }
        }

        /// The the current frame for an animated GIF image, or `0` if the image isn't a GIF.
        var currentFrame: Int {
            get { (value(forProperty: .currentFrame) as? Int) ?? 0 }
            set { setProperty(.currentFrame, withValue: newValue.clamped(to: 0...frameCount-1)) }
        }

        /// The duration (in seconds) of the current frame for an animated GIF image, or `0` if the image isn't a GIF.
        var currentFrameDuration: TimeInterval {
            get { value(forProperty: .currentFrameDuration) as? TimeInterval ?? 0.0 }
            set {
                guard value(forProperty: .currentFrameDuration) != nil else { return }
                setProperty(.currentFrameDuration, withValue: newValue)
            }
        }

        /// The number of loops to make when animating a GIF image, or `0` if the image isn't a GIF.
        var loopCount: Int {
            get { value(forProperty: .loopCount) as? Int ?? 0 }
            set {
                guard value(forProperty: .loopCount) != nil else { return }
                setProperty(.loopCount, withValue: newValue)
            }
        }
    }

    public extension NSImage {
        /// The bitmap representation of the image
        var bitmapImageRep: NSBitmapImageRep? {
            if let representation = representations.compactMap({$0 as? NSBitmapImageRep}).first {
                return representation
            }
            
            if let cgImage = cgImage {
                let imageRep = NSBitmapImageRep(cgImage: cgImage)
                imageRep.size = size
                return imageRep
            }
            return nil
        }

        /**
         Returns a data object that contains the specified image in TIFF format.

         - Returns: A data object containing the TIFF data, or `nil` if there was a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
         */
        func tiffData() -> Data? { tiffRepresentation }

        /**
         Returns a data object that contains the specified image in PNG format.

         - Returns: A data object containing the PNG data, or `nil` if there was a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
         */
        func pngData() -> Data? { bitmapImageRep?.pngData }

        /**
         Returns a data object that contains the image in JPEG format.

         - Returns: A data object containing the JPEG data, or `nil` if there’s a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
         */
        func jpegData() -> Data? { bitmapImageRep?.jpegData }

        /**
         Returns a data object that contains the image in JPEG format.

         - Parameter compressionFactor: The quality of the resulting JPEG image, expressed as a value from `0.0` to `1.0`. The value `0.0` represents the maximum compression (or lowest quality) while the value `1.0` represents the least compression (or best quality).

         - Returns: A data object containing the JPEG data, or `nil` if there’s a problem generating the data. This function may return `nil` if the image has no data or if the underlying `CGImageRef` contains data in an unsupported bitmap format.
         */
        func jpegData(compressionFactor factor: Double) -> Data? {
            bitmapImageRep?.jpegData(compressionFactor: factor)
        }
    }

    extension Data {
        var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
    }
#endif
