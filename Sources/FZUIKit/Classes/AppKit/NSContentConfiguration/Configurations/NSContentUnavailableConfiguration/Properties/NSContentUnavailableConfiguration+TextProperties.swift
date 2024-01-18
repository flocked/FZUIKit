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

            /// The line break mode to use for the text.
            public var lineBreakMode: NSLineBreakMode = .byWordWrapping

            /**
             The maximum number of lines.

             The default value of `0 indicates no limit to the number of lines.
             */
            public var maxNumberOfLines: Int = 0
            
            var _maxNumberOfLines: Int? {
                maxNumberOfLines == 0 ? nil : maxNumberOfLines
            }
            
            /// The minimum scale factor for the text.
            public var minimumScaleFactor: CGFloat = 0.0

            /// A default configuration for a primary text.
            public static func primary() -> Self { TextProperties(font: .body.weight(.semibold)) }

            /// A default configuration for a secondary text.
            public static func secondary() -> Self { TextProperties(font: .callout, color: .secondaryLabelColor) }

            /// A configuration with a font for captions.
            public static func caption2() -> Self { TextProperties(font: .caption2) }
            
            /// A configuration with a font for captions.
            public static func caption() -> Self { TextProperties(font: .caption) }
            
            /// A configuration with a font for footnotes.
            public static func footnote() -> Self { TextProperties(font: .footnote) }
            
            /// A configuration with a font for callouts.
            public static func callout() -> Self { TextProperties(font: .callout) }
            
            /// A configuration with a font for body.
            public static func body() -> Self { TextProperties(font: .body) }
            
            /// A configuration with a font for subheadlines.
            public static func subheadline() -> Self { TextProperties(font: .subheadline) }
            
            /// A configuration with a font for headlines.
            public static func headline() -> Self { TextProperties(font: .headline) }
            
            /// A configuration with a font for titles.
            public static func title() -> Self { TextProperties(font: .title) }
            
            /// A configuration with a font for titles.
            public static func title2() -> Self { TextProperties(font: .title2) }
            
            /// A configuration with a font for titles.
            public static func title3() -> Self { TextProperties(font: .title3) }
            
            /// A configuration with a font for large titles.
            public static func largeTitle() -> Self { TextProperties(font: .largeTitle) }
        }
    }
#endif
