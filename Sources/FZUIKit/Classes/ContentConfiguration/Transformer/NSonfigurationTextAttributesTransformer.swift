//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

import Foundation

#if os(macOS)
@available(macOS 12.0, *)
public struct NSConfigurationTextAttributesTransformer: ContentTransformer {
    public let transform: (AttributeContainer) -> AttributeContainer
    public let id: String
    
    /// Creates a text attributes transformer with the specified closure.
    public init(_ id: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        self.id = id
    }
}

#elseif canImport(UIKit)

@available(iOS 15, tvOS 15, watchOS 8, *)
public struct UIConfigurationHashingTextAttributesTransformer: ContentTransformer {
    public let transform: (AttributeContainer) -> AttributeContainer
    public let id: String
    
    /// Creates a text attributes transformer with the specified closure.
    public init(_ id: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
        self.id = id
    }
}

#endif
