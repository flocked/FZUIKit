//
//  ContentTransform+Shadow.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// A transformer that generates a modified output shadow from an input shadow.
public struct ShadowTransformer: ContentTransform {
    /// The block that transforms a shadow.
    public let transform: (ShadowConfiguration) -> ShadowConfiguration
    /// The identifier of the transformer.
    public let id: String

    /// Creates a shadow transformer with the specified identifier and block that transforms a shadow.
    public init(_ identifier: String, _ transform: @escaping (ShadowConfiguration) -> ShadowConfiguration) {
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
}
#endif
