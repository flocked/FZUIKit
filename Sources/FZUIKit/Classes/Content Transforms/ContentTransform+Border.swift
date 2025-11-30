//
//  ContentTransform+Border.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A transformer that generates a modified output border from an input border.
public struct BorderTransformer: ContentTransform {
    /// The block that transforms a border.
    public let transform: (BorderConfiguration) -> BorderConfiguration
    /// The identifier of the transformer.
    public let id: String

    /// Creates a border transformer with the specified identifier and block that transforms a border.
    public init(_ identifier: String, _ transform: @escaping (BorderConfiguration) -> BorderConfiguration) {
        self.transform = transform
        id = identifier
    }
    
    /// Creates a border transformer that generates a version of the border with the specified color transformer.
    public static func color(_ colorTransformer: ColorTransformer) -> Self {
        Self("colorTransform: \(colorTransformer.id)") { border in
            var border = border
            border.colorTransformer = colorTransformer
            return border
        }
    }

    /// Creates a border transformer that generates a version of the border with the specified color.
    public static func color(_ color: NSUIColor) -> Self {
        Self("color: \(color)") { border in
            var border = border
            border.color = color
            border.colorTransformer = nil
            return border
        }
    }
    
    /// Creates a border transformer that generates a version of the border with the specified width.
    public static func width(_ width: CGFloat) -> Self {
        Self("width: \(width)") { border in
            var border = border
            border.width =  width
            return border
        }
    }
}
#endif
