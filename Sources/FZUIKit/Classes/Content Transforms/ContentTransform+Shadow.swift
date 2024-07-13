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

/**
 A transformer that generates a modified output shadow from an input shadow.
 */
public struct ShadowTransformer: ContentTransform {
    /// The transform closure of the shadow transformer.
    public let transform: (ShadowConfiguration) -> ShadowConfiguration
    /// The identifier of the transformer.
    public let id: String

    /// Creates a shadow transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (ShadowConfiguration) -> ShadowConfiguration) {
        self.transform = transform
        id = identifier
    }
}
#endif
