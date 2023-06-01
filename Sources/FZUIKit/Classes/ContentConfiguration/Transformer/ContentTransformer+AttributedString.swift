//
//  ContentTransformer+Color.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

import Foundation
import FZSwiftUtils

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct AttributedStringTransformer: ContentTransformer {
    /// The transform closure of the color transformer.
    public let transform: (AttributedString) -> AttributedString
    public let id: String

    /// Creates a color transformer with the specified closure.
    public init(_ id: String, _ transform: @escaping (AttributedString) -> AttributedString) {
        self.transform = transform
        self.id = id
    }
    
    /// Creates a color transformer that generates a capitalized version of the attributed string.
    public static func capitalized() -> Self {
        return Self("capitalized") { $0.capitalized() }
    }

    /// Creates a color transformer that generates a lowercased version of the attributed string.
    public static func lowercased() -> Self {
        return Self("lowercased") { $0.lowercased() }
    }

    /// Creates a color transformer that generates a uppercased version of the attributed string.
    public static func uppercased() -> Self {
        return Self("uppercased") { $0.uppercased() }
    }
}



public struct NSAttributedStringTransformer: ContentTransformer {
    /// The transform closure of the color transformer.
    public let transform: (NSAttributedString) -> NSAttributedString
    public let id: String

    /// Creates a color transformer with the specified closure.
    public init(_ id: String, _ transform: @escaping (NSAttributedString) -> NSAttributedString) {
        self.transform = transform
        self.id = id
    }
    
    /// Creates a color transformer that generates a capitalized version of the attributed string.
    public static func capitalized() -> Self {
        return Self("capitalized") { $0.capitalized() }
    }

    /// Creates a color transformer that generates a lowercased version of the attributed string.
    public static func lowercased() -> Self {
        return Self("lowercased") { $0.lowercased() }
    }

    /// Creates a color transformer that generates a uppercased version of the attributed string.
    public static func uppercased() -> Self {
        return Self("uppercased") { $0.uppercased() }
    }
}
