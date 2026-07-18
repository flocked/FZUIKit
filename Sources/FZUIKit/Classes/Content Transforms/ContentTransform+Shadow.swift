//
//  ContentTransform+Shadow.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A transformer that generates a modified output shadow from an input shadow.
public struct ShadowTransformer: ContentTransform {
    /// The block that transforms a shadow.
    public let transform: @Sendable (ShadowConfiguration) -> ShadowConfiguration
    /// The identifier of the transformer.
    public let id: String

    /// Creates a shadow transformer with the specified identifier and block that transforms a shadow.
    public init(_ identifier: String, _ transform: @escaping @Sendable (ShadowConfiguration) -> ShadowConfiguration) {
        self.transform = transform
        id = identifier
    }
    
    /// Creates a shadow transformer that generates a version of the shadow with the specified color transformer.
    public static func color(_ colorTransformer: ColorTransformer) -> Self {
        Self("colorTransform: \(colorTransformer.id)") { shadow in
            var shadow = shadow
            shadow.colorTransformer = colorTransformer
            return shadow
        }
    }
    
    /// Creates a shadow transformer that generates a version of the shadow with the specified color.
    public static func color(_ color: NSUIColor) -> Self {
        Self("color: \(color)") { shadow in
            var shadow = shadow
            shadow.color = color
            shadow.colorTransformer = nil
            return shadow
        }
    }
    
    /// Creates a shadow transformer that generates a version of the shadow with the specified opacity.
    public static func opacity(_ opacity: CGFloat) -> Self {
        Self("opacity: \(opacity)") { shadow in
            var shadow = shadow
            shadow.opacity = opacity
            return shadow
        }
    }
    
    /// Creates a shadow transformer that generates a version of the shadow with the specified radius.
    public static func radius(_ radius: CGFloat) -> Self {
        Self("radius: \(radius)") { shadow in
            var shadow = shadow
            shadow.radius = radius
            return shadow
        }
    }
    
    /// Creates a shadow transformer that generates a version of the shadow with the specified offset.
    public static func offset(_ offset: CGPoint) -> Self {
        Self("offset: \(offset)") { shadow in
            var shadow = shadow
            shadow.offset = offset
            return shadow
        }
    }
}
#endif
