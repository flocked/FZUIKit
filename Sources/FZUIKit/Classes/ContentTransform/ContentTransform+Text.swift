//
//  ContentTransform+Text.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

/// A transformer that generates a modified output string from an input string.
public struct TextTransformer: ContentTransform {
    /// The transform closure of the text transformer.
    public let transform: (String) -> String
    /// The identifier of the transformer.
    public let id: String

    /// Creates a text transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (String) -> String) {
        self.transform = transform
        id = identifier
    }
}
