//
//  ContentTransform+Border.swift
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
 A transformer that generates a modified output border from an input border.
 */
public struct BorderTransformer: ContentTransform {
    /// The transform closure of the border transformer.
    public let transform: (BorderConfiguration) -> BorderConfiguration
    /// The identifier of the transformer.
    public let id: String

    /// Creates a border transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (BorderConfiguration) -> BorderConfiguration) {
        self.transform = transform
        id = identifier
    }
}
#endif
