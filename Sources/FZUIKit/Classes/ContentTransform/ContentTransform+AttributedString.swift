//
//  ContentTransform+AttributedString.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

import Foundation
import FZSwiftUtils

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/**
 A transformer that generates a modified output attributed string from an input attributed string.
 */
public struct AttributedStringTransformer: ContentTransform {
    /// The transform closure of the text transformer.
    public let transform: (AttributedString) -> AttributedString
    /// The identifier of the transformer.
    public let id: String

    /// Creates a text transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (AttributedString) -> AttributedString) {
        self.transform = transform
        id = identifier
    }

    /// Creates a color transformer that generates a capitalized version of the attributed string.
    public static func capitalized() -> Self {
        Self("capitalized") { $0.capitalized() }
    }

    /// Creates a color transformer that generates a lowercased version of the attributed string.
    public static func lowercased() -> Self {
        Self("lowercased") { $0.lowercased() }
    }

    /// Creates a color transformer that generates a uppercased version of the attributed string.
    public static func uppercased() -> Self {
        Self("uppercased") { $0.uppercased() }
    }
}

/**
 A transformer that generates a modified output attributed string from an input attributed string.
 */
public struct NSAttributedStringTransformer: ContentTransform {
    /// The transform closure of the text transformer.
    public let transform: (NSAttributedString) -> NSAttributedString
    /// The identifier of the transformer.
    public let id: String

    /// Creates a text transformer with the specified identifier and closure.
    public init(_ id: String, _ transform: @escaping (NSAttributedString) -> NSAttributedString) {
        self.transform = transform
        self.id = id
    }

    /// Creates a color transformer that generates a capitalized version of the attributed string.
    public static func capitalized() -> Self {
        Self("capitalized") { $0.capitalized() }
    }

    /// Creates a color transformer that generates a lowercased version of the attributed string.
    public static func lowercased() -> Self {
        Self("lowercased") { $0.lowercased() }
    }

    /// Creates a color transformer that generates a uppercased version of the attributed string.
    public static func uppercased() -> Self {
        Self("uppercased") { $0.uppercased() }
    }
}
