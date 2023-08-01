//
//  NSonfigurationTextAttributesTransformer.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

/*
import Foundation

#if os(macOS)
@available(macOS 12.0, *)
/**
 Defines a text transformation that can affect the visual appearance of a string.
 */
public struct NSConfigurationTextAttributesTransformer: ContentTransform {
    /// A closure that defines the text transformation.
    public let transform: (AttributeContainer) -> AttributeContainer
    /// The identifier of the transformer.
    public let id: String
    
    /// Creates a text attributes transformer with the specified identifier and closure.
    public init(_ identifier: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        self.id = identifier
    }
}

#elseif canImport(UIKit)

@available(iOS 15, tvOS 15, watchOS 8, *)
/**
 Defines a text transformation that can affect the visual appearance of a string.
 */
public struct UIConfigurationHashingTextAttributesTransformer: ContentTransform {
    /// A closure that defines the text transformation.
    public let transform: (AttributeContainer) -> AttributeContainer
    /// The identifier of the transformer.
    public let id: String
    
    /// Creates a text attributes transformer with the specified closure.
    public init(_ id: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        self.id = id
    }
}

#endif
*/
