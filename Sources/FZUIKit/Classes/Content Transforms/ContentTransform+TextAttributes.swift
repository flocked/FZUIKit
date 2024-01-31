//
//  ContentTransform+TextAttributes.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/// Defines a text transformation that can affect the visual appearance of a string.
public struct TextAttributesTransformer: ContentTransform {
    /// A closure that defines the text transformation.
    public let transform: (AttributeContainer) -> AttributeContainer
    /// The identifier of the transformer.
    public let id: String

    /// Creates a new text attributes transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        id = identifier
    }
}
