//
//  AXParameterizedAttribute.swift
//  
//
//  Created by Florian Zand on 16.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/// Values that describe parameterized attributes of an accessibility object.
public struct AXParameterizedAttribute: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    // MARK: - Text suite parameterized attributes
    /// Represents the line corresponding to a specific index in the text.
    public static let lineForIndex = AXParameterizedAttribute(kAXLineForIndexParameterizedAttribute)
    /// Represents the range of characters that form a specific line in the text.
    public static let rangeForLine = AXParameterizedAttribute(kAXRangeForLineParameterizedAttribute)
    /// Represents the string corresponding to a specific character range.
    public static let stringForRange = AXParameterizedAttribute(kAXStringForRangeParameterizedAttribute)
    /// Represents the character range corresponding to a specific position in the text.
    public static let rangeForPosition = AXParameterizedAttribute(kAXRangeForPositionParameterizedAttribute)
    /// Represents the character range corresponding to a specific index in the text.
    public static let rangeForIndex = AXParameterizedAttribute(kAXRangeForIndexParameterizedAttribute)
    /// Represents the bounds (position and size) of a specific character range.
    public static let boundsForRange = AXParameterizedAttribute(kAXBoundsForRangeParameterizedAttribute)
    /// Represents the RTF content corresponding to a character range.
    public static let rtfForRange = AXParameterizedAttribute(kAXRTFForRangeParameterizedAttribute)
    /// Represents the attributed string corresponding to a specific character range.
    public static let attributedStringForRange = AXParameterizedAttribute(kAXAttributedStringForRangeParameterizedAttribute)
    /// Represents the style range for a specific index in the text.
    public static let styleRangeForIndex = AXParameterizedAttribute(kAXStyleRangeForIndexParameterizedAttribute)

    // MARK: - Cell-based table parameterized attributes
    /// Represents a specific cell based on its column and row indices.
    public static let cellForColumnAndRow = AXParameterizedAttribute(kAXCellForColumnAndRowParameterizedAttribute)

    // MARK: - Layout area parameterized attributes
    /// Represents the layout point corresponding to a specific screen point.
    public static let layoutPointForScreenPoint = AXParameterizedAttribute(kAXLayoutPointForScreenPointParameterizedAttribute)
    /// Represents the layout size corresponding to a specific screen size.
    public static let layoutSizeForScreenSize = AXParameterizedAttribute(kAXLayoutSizeForScreenSizeParameterizedAttribute)
    /// Represents the screen point corresponding to a specific layout point.
    public static let screenPointForLayoutPoint = AXParameterizedAttribute(kAXScreenPointForLayoutPointParameterizedAttribute)
    /// Represents the screen size corresponding to a specific layout size.
    public static let screenSizeForLayoutSize = AXParameterizedAttribute(kAXScreenSizeForLayoutSizeParameterizedAttribute)
}

extension AXParameterizedAttribute: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
#endif
