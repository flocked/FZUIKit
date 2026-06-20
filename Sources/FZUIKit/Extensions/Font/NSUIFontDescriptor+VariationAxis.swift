//
//  NSUIFontDescriptor+VariationAxis.swift
//  
//
//  Created by Florian Zand on 20.06.26.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIFontDescriptor {
    /// The current values of the font's variation axes.
    var variationValues: [VariationAxis.Tag: CGFloat] {
        guard let variation = object(forKey: .variation) else { return [:] }
        if let variation = variation as? [String: Any] {
            return variation.mapKeys { .init(rawValue: $0) }.compactMapValues { ($0 as? Double)?.cgFloat }
        } else if let variation = variation as? [UInt32: Any] {
            return variation.mapKeys { .init($0) }.compactMapValues { ($0 as? Double)?.cgFloat }
        }
        return [:]
    }
    
    /**
     Returns a font descriptor by replacing its variation axis values with the specified values.

     - Parameter variationValues: The variation axis values keyed by axis tag, or `nil` to remove variation settings.
     - Returns: A font descriptor with the specified variation axis values.
     */
    func withVariationValues(_ variationValues: [VariationAxis.Tag: Double]?) -> NSUIFontDescriptor {
        let variationValues = variationValues?.mapKeys({ $0.nsNumber }).mapValues({NSNumber(value: $0)}) ?? [:]
        var fontAttributes = fontAttributes
        fontAttributes[.variation] = variationValues.isEmpty ? nil : variationValues
       return NSUIFontDescriptor(fontAttributes: fontAttributes)
    }

    /// The variation axes supported by the font.
    var variationAxes: [VariationAxis] {
        (object(forKey: .variationAxes) as? [[CFString: Any]] ?? []).compactMap { VariationAxis($0) }.sorted(by: \.name)
    }

    /// Describes a variation axis supported by a variable font.
    struct VariationAxis: Hashable, Codable, CustomStringConvertible, Sendable {
        /// The localized display name of the axis.
        public let name: String
        /**
         The identifier of the variation axis.

         The tag uniquely identifies the axis within the font.
         
         Common tags include `.weight`, `.width`, `.opticalSize`, `.slant`, and `.italic`.
         */
        public let tag: Tag
        /// The minimum value supported by the axis.
        public let minimumValue: CGFloat
        /// The maximum value supported by the axis.
        public let maximumValue: CGFloat
        /// The default value of the axis.
        public let defaultValue: CGFloat
        /// A Boolean value indicating whether the axis should be hidden from user interfaces.
        public let isHidden: Bool
        
        public var description: String {
            "\(tag) \"\(name)\" [\(minimumValue)...\(maximumValue)] default=\(defaultValue)\(isHidden ? " hidden" : "")"
        }
        
        /// An font variation axis tag.
        public struct Tag: RawRepresentable, Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral, Codable, Sendable {
            /// The weight axis controlling the thickness of glyph strokes.
            public static let weight = Self(rawValue: "wght")
            /// The width axis controlling the horizontal expansion or compression of glyphs.
            public static let width = Self(rawValue: "wdth")
            /// The optical size axis controlling design adjustments for different point sizes.
            public static let opticalSize = Self(rawValue: "opsz")
            /// The slant axis controlling the angle of glyphs.
            public static let slant = Self(rawValue: "slnt")
            /// The italic axis controlling whether italic glyph forms are used.
            public static let italic = Self(rawValue: "ital")
            
            public let rawValue: String
            
            public var description: String { rawValue }

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            init(_ rawValue: UInt32) {
                self.rawValue = FourCharCode(rawValue).string
            }
            
            public init(stringLiteral value: String) {
                self.rawValue = value
            }
            
            var nsNumber: NSNumber {
                NSNumber(value: FourCharCode(rawValue))
            }
        }
        
        init?(_ axis: [CFString: Any]) {
            guard
                let name = axis[kCTFontVariationAxisNameKey] as? String,
                let identifier = axis[kCTFontVariationAxisIdentifierKey] as? NSNumber,
                let minimum = axis[kCTFontVariationAxisMinimumValueKey] as? CGFloat,
                let maximum = axis[kCTFontVariationAxisMaximumValueKey] as? CGFloat,
                let defaultValue = axis[kCTFontVariationAxisDefaultValueKey] as? CGFloat
            else { return nil
            }
            self.name = name
            self.tag = .init(identifier.uint32Value)
            self.defaultValue = defaultValue
            self.minimumValue = minimum
            self.maximumValue = maximum
            self.isHidden = axis[typed: kCTFontVariationAxisHiddenKey] ?? false
            // axis["NSCTVariationAxisFlags" as CFString] as? Int
        }
    }
}

fileprivate extension Double {
    var cgFloat: CGFloat {
        CGFloat(self)
    }
}
