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
     Returns a Boolean value that indicates whether image is equal to the specified other image.
     
     - Parameter image: The image to comapare.
     - Returns: `true` if the images are equal, otherwise `false`.
     */
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
        return value(forKey: "_symbolDescription") as? String
        #else
        return getAssociatedValue("symbolName", initialValue: _symbolName)
        #endif
    }

    internal var _symbolName: String? {
        #if os(macOS)
        return String(describing: self).matches(between: "symbol = ", and: ">").first?.string
        #else
        guard isSymbolImage else { return nil }
        return String(describing: self).matches(between: "system: ", and: ") {").first?.string
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
