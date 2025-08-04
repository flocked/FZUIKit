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
    /**
     Creates an image object that contains a system symbol image.
     
     - Parameter systemName: The name of the system symbol image.
     */
    @available(macOS 11.0, *)
    static func symbol(_ systemName: String) -> NSUIImage? {
        #if os(macOS)
        NSUIImage(systemSymbolName: systemName)
        #else
        NSUIImage(systemName: systemName)
        #endif
    }
    
    /// The symbol name of the image.
    @available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var symbolName: String? {
        #if os(macOS)
        getAssociatedValue("symbolName", initialValue: String(describing: self).matches(between: "symbol = ", and: ">").first?.string)
        #else
        getAssociatedValue("symbolName", initialValue: String(describing: self).matches(between: "system: ", and: ") {").first?.string)
        #endif
    }

    /// The color at the specified pixel location.
    func color(at location: CGPoint) -> NSUIColor? {
        guard location.x >= 0, location.x < size.width, location.y >= 0, location.y < size.height, let cgImage = cgImage, let provider = cgImage.dataProvider, let providerData = provider.data, let data = CFDataGetBytePtr(providerData) else {
            return nil
        }

        let numberOfComponents = 4
        let pixelData = Int((size.width * location.y) + location.x) * numberOfComponents

        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0

        return NSUIColor(red: r, green: g, blue: b, alpha: a)
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
            resizingMode = .stretch
            capInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            #else
            let image = UIGraphicsImageRenderer(size: size).image { context in
                color.setFill()
                context.fill(context.format.bounds)
            }.resizableImage(withCapInsets: .zero)
            self.init(cgImage: image.cgImage!)
            #endif
        }
    
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
            path.close()
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
        #else
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
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
            let path = NSUIBezierPath(roundedRect: rect, byRoundingCorners: roundedCorners, cornerRadius: cornerRadius)
            path.close()
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
        #else
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
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
}

extension Collection where Element == NSUIImage {
    /// An array of unique images.
    public func uniqueImages() -> [Element] {
        reduce(into: [NSUIImage]()) { images, image in
            if let last = images.last, !last.isEqual(to: image) {
                images.append(image)
            } else if images.isEmpty {
                images.append(image)
            }
        }
    }
}
