//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

import Foundation

#if os(macOS)
@available(macOS 12.0, *)
public struct NSConfigurationTextAttributesTransformer {
    public let transform: (AttributeContainer) -> AttributeContainer
    internal let uuid: UUID = UUID()
    
    public func callAsFunction(_ input: AttributeContainer) -> AttributeContainer {
        return transform(input)
    }
    
    public init(_ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
    }
}


@available(macOS 12.0, *)
extension NSConfigurationTextAttributesTransformer: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

#elseif canImport(UIKit)

@available(iOS 15, tvOS 15, watchOS 8, *)
public struct HashableUIConfigurationTextAttributesTransformer {
    public let transform: (AttributeContainer) -> AttributeContainer
    internal let uuid: UUID = UUID()
    
    public func callAsFunction(_ input: AttributeContainer) -> AttributeContainer {
        return transform(input)
    }
    
    public init(_ transform: @escaping (AttributeContainer) -> AttributeContainer) {
        self.transform = transform
    }
}

@available(iOS 15, tvOS 15, watchOS 8, *)
extension HashableUIConfigurationTextAttributesTransformer: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

#endif
