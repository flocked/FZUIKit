//
//  NSContentUnavailableConfiguration+TextProperties.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 12.0, *)
    public extension NSContentUnavailableConfiguration {
        /// Properties that affect the cell content configuration’s text.
        struct TextProperties: Hashable {
            /// The font of the text.
            public var font: NSFont = .body

            /// The color of the text.
            public var color: NSColor = .labelColor
            
            /// The color transformer of the color.
            public var colorTransformer: ColorTransformer?
            
            ///  Generates the resolved color, using the color and color transformer.
            public func resolvedColor() -> NSColor {
                return colorTransformer?(color) ?? color
            }

            /// The line break mode to use for the text.
            public var lineBreakMode: NSLineBreakMode = .byWordWrapping

            /**
             The maximum number of lines.

             The default value of `0` indicates no limit to the number of lines.
             */
            public var maxNumberOfLines: Int = 0

            
            /// The minimum scale factor for the text.
            public var minimumScaleFactor: CGFloat = 0.0

            /// A default configuration for a primary text.
            public static var primary: Self { TextProperties(font: .body.weight(.semibold)) }

            /// A default configuration for a secondary text.
            public static var secondary: Self { TextProperties(font: .callout, color: .secondaryLabelColor) }
        }
    }
#endif
