//
//  NSUIImage+.swift
//
//
//  Created by Florian Zand on 18.05.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIImage {
    #if os(macOS)
    /**
     Creates an system symbol image with the specified name.
     
     To look up the names of system symbol images, download the SF Symbols app from [Apple Design Resources](https://developer.apple.com/design/resources/).

     - Parameters:
        - systemName: The name of the system symbol image.
        - description: The accessibility description for the symbol image, if any.
     */
    @available(macOS 11.0, *)
    static func symbol(_ systemName: String, accessibilityDescription description: String? = nil) -> NSUIImage? {
        NSImage(systemSymbolName: systemName, accessibilityDescription: description)
    }
    
    /**
     Creates an system symbol image with the specified name and configuration.
     
     To look up the names of system symbol images, download the SF Symbols app from [Apple Design Resources](https://developer.apple.com/design/resources/).
     
     - Parameters:
        - systemName: The name of the system symbol image.
        - description: The accessibility description for the symbol image, if any.
        - configuration: The image configuration the system applies to the image.
     */
    static func symbol(_ systemName: String, withConfiguration configuration: SymbolConfiguration) -> NSImage? {
        NSImage(systemSymbolName: systemName)?.withSymbolConfiguration(configuration)
    }
    
    /**
     Creates an system symbol image with the specified name, variable value and configuration.
     
     The `value` parameter is valid for symbols that support variable rendering.
     
     To look up the names of system symbol images, download the SF Symbols app from [Apple Design Resources](https://developer.apple.com/design/resources/).

     - Parameters:
        - systemName: The name of the system symbol image.
        - variableValue: The value the system uses to customize the symbol’s content, between `0` and `1`.
        - description: The accessibility description for the symbol image, if any.
        - configuration: The image configuration the system applies to the image.
     */
    @available(macOS 13.0, *)
    static func symbol(_ systemName: String, variableValue: Double, accessibilityDescription description: String? = nil, configuration: SymbolConfiguration? = nil) -> NSUIImage? {
        let image = NSImage(systemSymbolName: systemName, variableValue: variableValue, accessibilityDescription: description)
        if let configuration = configuration {
            return image?.withSymbolConfiguration(configuration)
        }
        return image
    }
    #else
    /**
     Creates an system symbol image with the specified name.

     - Parameter systemName: The name of the system symbol image.
     */
    static func symbol(_ systemName: String) -> UIImage? {
        UIImage(systemName: systemName)
    }
    
    /**
     Creates an system symbol image with the specified name and configuration.
     
     - Parameters:
        - systemName: The name of the system symbol image.
        - configuration: The image configuration the system applies to the image.
     */
    static func symbol(_ systemName: String, withConfiguration configuration: Configuration) -> UIImage? {
        UIImage(systemName: systemName, withConfiguration: configuration)
    }
    
    /**
     Creates an system symbol image with the specified name, variable value and configuration.
     
     - Parameters:
        - systemName: The name of the system symbol image.
        - variableValue: The value the system uses to customize the symbol’s content, between `0` and `1`.
        - configuration: The image configuration the system applies to the image.
     */
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func symbol(_ systemName: String, variableValue: Double, configuration: Configuration) -> UIImage? {
        UIImage(systemName: systemName, variableValue: variableValue, configuration: configuration)
    }
    #endif
    
    /// The symbol name of the image.
    var symbolName: String? {
        guard isSymbolImage else { return nil }
        #if os(macOS)
        return representations.first?.value(forKeyPathSafely: "vectorGlyph.name") as? String
        #else
        return value(forKeyPathSafely: "content.vectorGlyph.name") as? String
        #endif
    }
    
    /// The outline bézier path of a symbol image.
    var symbolPath: NSUIBezierPath? {
        #if os(macOS)
        representations.first?.value(forKey: "outlinePath")
        #else
        value(forKey: "outlinePath")
        #endif
    }
    
    /// The sRGB color components at the specified pixel location.
    func rgb(at point: CGPoint) -> ColorModels.SRGB? {
        cgImage?.rgb(at: point)
    }

    /// The color at the specified pixel location.
    func color(at location: CGPoint) -> NSUIColor? {
        cgImage?.color(at: location)?.nsUIColor
    }
    
    /// A Boolean value that indicates whether the image has alpha information.
    var hasAlpha: Bool {
        #if os(macOS)
        cgImage?.hasAlpha ?? bitmapImageRep?.hasAlpha ?? false
        #else
        cgImage?.hasAlpha ?? false
        #endif
    }

    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Creates an image object with the specified color and size.

     - Parameters:
        - color: The color of the image.
        - size: The size of the image.

     - Returns: The image object with the specified color.
     */
    convenience init(color: NSUIColor, size: CGSize) {
        #if os(macOS)
        self.init(size: size, flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
        capInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        #else
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(context.format.bounds)
        }.resizableImage(withCapInsets: .zero)
        self.init(cgImage: image.cgImage!)
        #endif
    }
    
    #if os(iOS) || os(tvOS)
    convenience init(size: CGSize, flipped: Bool = false, drawingHandler: (UIGraphicsImageRendererContext) -> Void) {
        let image = UIGraphicsImageRenderer(size: size).image { context in
            if flipped {
                context.cgContext.flipVertically()
            }
            drawingHandler(context)
        }
        self.init(cgImage: image.cgImage!)
    }
    #endif
    
    /**
     Creates an image object with the specified color and size.

     - Parameters:
        - color: The color of the image.
        - size: The size of the image.
     */
    static func color(_ color: NSUIColor, size: CGSize) -> NSUIImage {
        NSUIImage(color: color, size: size)
    }
    #endif
    
    /**
     Creates a resizable mask image with the specified corner radius.

     - Parameter cornerRadius: The corner radius.

     - Returns: A black-filled image with transparent corners, suitable for use as a resizable mask.
     */
    static func maskImage(cornerRadius: CGFloat) -> NSUIImage {
        let size = CGSize(width: cornerRadius * 2, height: cornerRadius * 2)
        
        func draw(in rect: CGRect) {
            let path = NSUIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            NSUIColor.black.setFill()
            path.fill()
        }

        #if os(macOS)

        let image = NSImage(size: size, flipped: false) { rect in
            draw(in: rect)
            return true
        }
        image.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image

        #elseif os(watchOS)

        let rect = CGRect(origin: .zero, size: size)
        let scale = 1.0

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return NSUIImage()
        }

        context.scaleBy(x: scale, y: scale)

        UIGraphicsPushContext(context)
        draw(in: rect)
        UIGraphicsPopContext()

        guard let cgImage = context.makeImage() else { return NSUIImage() }
        let image = NSUIImage(cgImage: cgImage, scale: scale, orientation: .up)

        let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)

        #else   // iOS / tvOS

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }

        let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)

        #endif
    }
    
    /**
     Creates a resizable mask image with the specified rounded corners.

     - Parameters:
       - roundedCorners: The corners to round.
       - cornerRadius: The radius to apply to the specified corners.

     - Returns: A black-filled image with transparent corners, suitable for use as a resizable mask.
     */

    static func maskImage(roundedCorners: NSUIRectCorner, cornerRadius: CGFloat) -> NSUIImage {
        if roundedCorners == .allCorners {
            return maskImage(cornerRadius: cornerRadius)
        }

        let size = CGSize(width: cornerRadius * 2, height: cornerRadius * 2)

        func draw(in rect: CGRect) {
            let path = NSUIBezierPath(
                roundedRect: rect,
                byRoundingCorners: roundedCorners,
                cornerRadius: cornerRadius
            )
            NSUIColor.black.setFill()
            path.fill()
        }

        #if os(macOS)

        let image = NSImage(size: size, flipped: false) { rect in
            draw(in: rect)
            return true
        }
        image.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image

        #elseif os(watchOS)

        let rect = CGRect(origin: .zero, size: size)
        let scale = 1.0

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return NSUIImage()
        }

        context.scaleBy(x: scale, y: scale)

        UIGraphicsPushContext(context)
        draw(in: rect)
        UIGraphicsPopContext()

        guard let cgImage = context.makeImage() else { return NSUIImage() }
        let image = NSUIImage(cgImage: cgImage, scale: scale, orientation: .up)

        let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)

        #else   // iOS / tvOS

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }

        let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)

        #endif
    }
    
    /// Returns a Boolean value indicating whether image is equal to the specified other image.
    func isEqual(to image: NSUIImage) -> Bool {
        #if os(macOS)
        if framesCount == 1, let cgImage = cgImage, let other = image.cgImage {
            return cgImage.isEqual(to: other)
        }
        return tiffData() == image.tiffData()
        #else
        if let cgImage = cgImage, let other = image.cgImage {
            return cgImage.isEqual(to: other)
        }
        return pngData() == image.pngData()
        #endif
    }
    
    /// The memory size of the image.
    var memorySize: DataSize {
        guard let cgImage = cgImage else { return .zero }
        let instanceSize = MemoryLayout.size(ofValue: self)
        let pixmapSize = cgImage.height * cgImage.bytesPerRow
        let totalSize = instanceSize + pixmapSize
        return .bytes(totalSize)
    }
    
    /// Draws the entire image.
    func draw() {
        draw(in: CGRect(.zero, size))
    }
}

extension NSUIImage: Swift.Encodable, Swift.Decodable { }

extension Collection where Element == NSUIImage {
    /// An array of unique images.
    public func uniqueImages() -> [Element] {
        reduce(into: []) { images, image in
            if let last = images.last, !last.isEqual(to: image) {
                images.append(image)
            } else if images.isEmpty {
                images.append(image)
            }
        }
    }
}
