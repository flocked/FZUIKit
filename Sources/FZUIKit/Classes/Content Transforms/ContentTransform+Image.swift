//
//  ContentTransform+Image.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A transformer that generates a modified output image from an input image.
public struct ImageTransformer: ContentTransform {
    /// The block that transforms a image.
    public let transform: (NSUIImage) -> NSUIImage
    /// The identifier of the transformer.
    public let id: String

    /// Creates a image transformer with the specified identifier and block that transforms a image.
    public init(_ identifier: String, _ transform: @escaping (NSUIImage) -> NSUIImage) {
        self.transform = transform
        id = identifier
    }

    /// Creates a image transformer that generates a tinted version of the image with the specified color.
    public static func tintColor(_ color: NSUIColor) -> Self {
        Self("tintColor: \(color)") { $0.withTintColor(color) }
    }

    /// Creates a image transformer that generates a image with the specified color.
    #if os(macOS) || os(iOS) || os(tvOS)
    public static func color(_ color: NSUIColor) -> Self {
        Self("color: \(color)") { NSUIImage(color: color, size: $0.size) }
    }

    /// Creates a image transformer that generates a version of the image with the specified opacity value.
    public static func opacity(_ value: CGFloat) -> Self {
        Self("opacity: \(value)") { $0.withOpacity(value) }
    }
    
    /// Creates a image transformer that generates a thumbnail of the image at the specified size.
    public static func thumbnail(size: CGSize) -> Self {
        Self("thumbnail: \(size)") { $0.preparingThumbnail(of: size) ?? $0 }
    }
    
    /// Creates a image transformer that generates a version of the image prepared for display.
    public static let preparedForDisplay = Self("preparedForDisplay") { $0.preparingForDisplay() ?? $0 }

    /// Creates a image transformer that generates a rounded version of the image with the specified radius.
    public static func rounded(radius: CGFloat) -> Self {
        Self("roundedCorners: \(radius)") { image in image.rounded(cornerRadius: radius) }
    }


    /// Creates a image transformer that generates a version of the image in a circle.
    public static let rounded = Self("rounded") { image in image.rounded() }
    
    
    /// Creates a image transformer that generates a elipsed version of the image.
    public static let elipsed = Self("elipsed") { image in image.elipsed() }
    #endif

    /// Creates a image transformer that generates a rounded version of the image with the specified degrees.
    public static func rotated(degrees: CGFloat) -> Self {
        let transform: (NSUIImage) -> NSUIImage = { image in
            image.rotated(degrees: degrees)
        }
        return Self("rotated: \(degrees)", transform)
    }

    /// Creates a image transformer that generates a version of the image with the specified symbol configuration.
    public static func symbolConfiguration(_ value: NSUIImage.SymbolConfiguration) -> Self {
        #if os(macOS)
        return Self("symbolConfiguration: \(value)") { image in image.withSymbolConfiguration(value) ?? image }
        #elseif canImport(UIKit)
        return Self("symbolConfiguration: \(value)") { image in image.applyingSymbolConfiguration(value) ?? image }
        #endif
    }

    /// Creates a image transformer that generates a version of the image resized to the specified size.
    public static func resized(to size: CGSize) -> Self {
        Self("resized: \(size)") { image in image.resized(to: size) }
    }

    /// Creates a image transformer that generates a version of the image resized to fit the specified size.
    public static func resized(toFit size: CGSize) -> Self {
        Self("resizedToFit: \(size)") { image in image.resized(toFit: size) }
    }

    /// Creates a image transformer that generates a version of the image resized to fill the specified size.
    public static func resized(toFill size: CGSize) -> Self {
        Self("resizedToFill: \(size)") { image in image.resized(toFill: size) }
    }
    
    /// Creates a image transformer that generates a version of the image resized to the specified width while maintaining the aspect ratio.
    public static func resized(toWidth width: CGFloat)  -> Self {
        Self("resizedToWidth: \(width)") { image in image.resized(toWidth: width) }
    }
    
    /// Creates a image transformer that generates a version of the image resized to the specified height while maintaining the aspect ratio.
    public static func resized(toHeight height: CGFloat)  -> Self {
        Self("resizedToHeight: \(height)") { image in image.resized(toHeight: height) }
    }
}
