//
//  ContentTransform+Text.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/**
 A transformer that generates a modified output string from an input string.
 */
    public struct TextTransformer: ContentTransform {
        /// The transform closure of the text transformer.
        public let transform: (String) -> String
        /// The identifier of the transformer.
        public let id: String
        
        /// Creates a text transformer with the specified identifier and closure.
        public init(_ id: String, _ transform: @escaping (String) -> String) {
            self.transform = transform
            self.id = id
        }
    }

