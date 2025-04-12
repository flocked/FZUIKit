//
//  ContentTransform+TextAttributes.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/// A transformer that generates modified text attributes from input text attributes.
public struct TextAttributesTransformer: ContentTransform {
    /// The block that transforms text attributes.
    public let transform: (AttributeContainer) -> AttributeContainer
    /// The identifier of the transformer.
    public let id: String

    /// Creates a text transformer with the specified identifier and block that transforms text attributes.
    public init(_ identifier: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        id = identifier
    }
}
