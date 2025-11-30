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
    @available(macOS 10.15, iOS 15.0, tvOS 15.0, *)
    public static func thumbnail(size: CGSize) -> Self {
        Self("thumbnail: \(size)") { $0.preparingThumbnail(of: size) ?? $0 }
    }
    
    /// Creates a image transformer that generates a version of the image prepared for display.
    @available(macOS 10.15, iOS 15.0, tvOS 15.0, *)
    public static let preparedForDisplay = Self("preparedForDisplay") { $0.preparingForDisplay() ?? $0 }

    /// Creates a image transformer that generates a rounded version of the image with the specified radius.
    public static func rounded(radius: CGFloat) -> Self {
        Self("roundedCorners: \(radius)") { $0.rounded(cornerRadius: radius) }
    }


    /// Creates a image transformer that generates a version of the image in a circle.
    public static let rounded = Self("rounded") { $0.rounded() }
    
    
    /// Creates a image transformer that generates a elipsed version of the image.
    public static let elipsed = Self("elipsed") { $0.elipsed() }
    #endif

    /// Creates a image transformer that generates a rounded version of the image with the specified degrees.
    public static func rotated(degrees: Float) -> Self {
        Self("rotated: \(degrees)") { $0.rotated(degrees: degrees) }
    }

    /// Creates a image transformer that generates a version of the image with the specified symbol configuration.
    @available(macOS 11.0, iOS 14.0, *)
    public static func symbolConfiguration(_ value: NSUIImage.SymbolConfiguration) -> Self {
        #if os(macOS)
        return Self { $0.withSymbolConfiguration(value) ?? $0 }
        #elseif canImport(UIKit)
        return Self { $0.applyingSymbolConfiguration(value) ?? $0 }
        #endif
    }

    /// Creates a image transformer that generates a version of the image resized to the specified size.
    public static func resized(to size: CGSize) -> Self {
        Self("resized: \(size)") { $0.resized(to: size) }
    }

    /// Creates a image transformer that generates a version of the image resized to fit the specified size.
    public static func resized(toFit size: CGSize) -> Self {
        Self("resizedToFit: \(size)") { $0.resized(toFit: size) }
    }

    /// Creates a image transformer that generates a version of the image resized to fill the specified size.
    public static func resized(toFill size: CGSize) -> Self {
        Self("resizedToFill: \(size)") { $0.resized(toFill: size) }
    }
    
    /// Creates a image transformer that generates a version of the image resized to the specified width while maintaining the aspect ratio.
    public static func resized(toWidth width: CGFloat)  -> Self {
        Self("resizedToWidth: \(width)") { $0.resized(toWidth: width) }
    }
    
    /// Creates a image transformer that generates a version of the image resized to the specified height while maintaining the aspect ratio.
    public static func resized(toHeight height: CGFloat)  -> Self {
        Self("resizedToHeight: \(height)") { $0.resized(toHeight: height) }
    }
}
