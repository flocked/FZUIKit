//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
/**
 A transformer that generates a modified output attributed container from an input attributed container.
 */
    public struct AttributeContainerTransformer: ContentTransformer {
        /// The transform closure of the attribute container transformer.
        public let transform: (AttributeContainer) -> AttributeContainer
        /// The identifier of the transformer.
        public let id: String
        
        /// Creates a attribute container transformer with the specified identifier and closure.
        public init(_ id: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
            self.transform = transform
            self.id = id
        }
    }

