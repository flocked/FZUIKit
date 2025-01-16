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
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    // MARK: - Text suite parameterized attributes
    /// Represents the line corresponding to a specific index in the text.
    public static let lineForIndex = AXParameterizedAttribute(rawValue: kAXLineForIndexParameterizedAttribute)
    /// Represents the range of characters that form a specific line in the text.
    public static let rangeForLine = AXParameterizedAttribute(rawValue: kAXRangeForLineParameterizedAttribute)
    /// Represents the string corresponding to a specific character range.
    public static let stringForRange = AXParameterizedAttribute(rawValue: kAXStringForRangeParameterizedAttribute)
    /// Represents the character range corresponding to a specific position in the text.
    public static let rangeForPosition = AXParameterizedAttribute(rawValue: kAXRangeForPositionParameterizedAttribute)
    /// Represents the character range corresponding to a specific index in the text.
    public static let rangeForIndex = AXParameterizedAttribute(rawValue: kAXRangeForIndexParameterizedAttribute)
    /// Represents the bounds (position and size) of a specific character range.
    public static let boundsForRange = AXParameterizedAttribute(rawValue: kAXBoundsForRangeParameterizedAttribute)
    /// Represents the RTF content corresponding to a character range.
    public static let rtfForRange = AXParameterizedAttribute(rawValue: kAXRTFForRangeParameterizedAttribute)
    /// Represents the attributed string corresponding to a specific character range.
    public static let attributedStringForRange = AXParameterizedAttribute(rawValue: kAXAttributedStringForRangeParameterizedAttribute)
    /// Represents the style range for a specific index in the text.
    public static let styleRangeForIndex = AXParameterizedAttribute(rawValue: kAXStyleRangeForIndexParameterizedAttribute)

    // MARK: - Cell-based table parameterized attributes
    /// Represents a specific cell based on its column and row indices.
    public static let cellForColumnAndRow = AXParameterizedAttribute(rawValue: kAXCellForColumnAndRowParameterizedAttribute)

    // MARK: - Layout area parameterized attributes
    /// Represents the layout point corresponding to a specific screen point.
    public static let layoutPointForScreenPoint = AXParameterizedAttribute(rawValue: kAXLayoutPointForScreenPointParameterizedAttribute)
    /// Represents the layout size corresponding to a specific screen size.
    public static let layoutSizeForScreenSize = AXParameterizedAttribute(rawValue: kAXLayoutSizeForScreenSizeParameterizedAttribute)
    /// Represents the screen point corresponding to a specific layout point.
    public static let screenPointForLayoutPoint = AXParameterizedAttribute(rawValue: kAXScreenPointForLayoutPointParameterizedAttribute)
    /// Represents the screen size corresponding to a specific layout size.
    public static let screenSizeForLayoutSize = AXParameterizedAttribute(rawValue: kAXScreenSizeForLayoutSizeParameterizedAttribute)
    
}

extension AXParameterizedAttribute: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
#endif
