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

/**
 A transformer that generates a modified output image from an input image.
 */
public struct ImageTransformer: ContentTransform {
    /// The transform closure of the image transformer.
    public let transform: (NSUIImage) -> NSUIImage
    /// The identifier of the transformer.
    public let id: String

    /// Creates a image transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (NSUIImage) -> NSUIImage) {
        self.transform = transform
        id = identifier
    }

    public static func tintColor(_ color: NSUIColor) -> Self {
        Self("tintColor: \(color)") { $0.withTintColor(color) }
    }

    #if os(macOS) || os(iOS) || os(tvOS)
        public static func color(_ color: NSUIColor) -> Self {
            Self("tintColor: \(color)") { _ in NSUIImage(color: color, size: CGSize(1, 1)) }
        }

        public static func opacity(_ value: CGFloat) -> Self {
            Self("opacity: \(value)") { $0.withOpacity(value) }
        }

        @available(macOS 10.15, iOS 15.0, tvOS 15.0, *)
        public static func thumbnail(size: CGSize) -> Self {
            Self("thumbnail: \(size)") { $0.preparingThumbnail(of: size) ?? $0 }
        }

        @available(macOS 10.15, iOS 15.0, tvOS 15.0, *)
        public static var preparedForDisplay: Self {
            Self("preparedForDisplay") { $0.preparingForDisplay() ?? $0 }
        }

        public static func rounded(radius: CGFloat) -> Self {
            Self("roundedCorners: \(radius)") { $0.rounded(cornerRadius: radius) }
        }

        public static var rounded: Self {
            Self("rounded") { $0.rounded() }
        }
    #endif

    public static func rotated(degrees: Float) -> Self {
        Self("rotated: \(degrees)") { $0.rotated(degrees: degrees) }
    }

    @available(macOS 11.0, iOS 14.0, *)
    public static func symbolConfiguration(_ value: NSUIImage.SymbolConfiguration) -> Self {
        #if os(macOS)
            return Self { $0.withSymbolConfiguration(value) ?? $0 }
        #elseif canImport(UIKit)
            return Self { $0.applyingSymbolConfiguration(value) ?? $0 }
        #endif
    }

    public static func resized(to size: CGSize) -> Self {
        #if os(macOS)
            return Self("resizedTo: \(size)") { $0.resized(to: size) }
        #elseif canImport(UIKit)
            return Self("resizedTo: \(size)") { $0.resized(to: size) ?? $0 }
        #endif
    }

    public static func resized(toFit size: CGSize) -> Self {
        #if os(macOS)
            return Self("resizedToFit: \(size)") { $0.resized(toFit: size) }
        #elseif canImport(UIKit)
            return Self("resizedToFit: \(size)") { $0.resized(toFit: size) ?? $0 }
        #endif
    }

    public static func resized(toFill size: CGSize) -> Self {
        #if os(macOS)
            return Self("resizedToFill: \(size)") { $0.resized(toFill: size) }
        #elseif canImport(UIKit)
            return Self("resizedToFill: \(size)") { $0.resized(toFill: size) ?? $0 }
        #endif
    }
}
