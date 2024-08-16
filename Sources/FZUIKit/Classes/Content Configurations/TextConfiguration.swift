//
//  TextConfiguration.swift
//
//
//  Created by Florian Zand on 02.06.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import FZSwiftUtils
import SwiftUI

/**
 A configuration that specifies the layout and appearance of text.
 
 `NSTextField`, `NSTextView`, `UILabel` and `UITextField` can be configurated by applying the configuration to the receiver's `textConfiguration`.
 */
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public struct TextConfiguration {
    /// The font of the text.
    public var font: NSUIFont = .body
    
    /// The line limit of the text, or 0 if no line limit applies.
    public var numberOfLines: Int = 0
    
    /// The alignment of the text.
    public var alignment: NSTextAlignment = .left
    
    /// The technique for wrapping and truncating the text.
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping
    
    #if os(macOS)
    /// The number formatter of the text.
    public var numberFormatter: NumberFormatter?
    #endif
    
    /// A Boolean value that determines whether the text’s font size reduces to fit the string into the bounding rectangle.
    public var adjustsFontSizeToFitWidth: Bool = false
    
    /// The minimum scale factor for the text.
    public var minimumScaleFactor: CGFloat = 0.0
    
    /// A Boolean value that determines whether the text tightens before truncating.
    public var allowsDefaultTighteningForTruncation: Bool = false
    
    #if canImport(UIKit)
    /// A Boolean value that indicates whether the object automatically updates its font when the device’s content size category changes.
    public var adjustsFontForContentSizeCategory: Bool = false
    
    /// A Boolean value that determines whether the full text displays when the pointer hovers over the truncated text.
    public var showsExpansionTextWhenTruncated: Bool = false
    #endif
    
    /**
     A Boolean value that determines whether the user can select the content of the text field.
     
     If true, the text field becomes selectable but not editable. Use `isEditable` to make the text field selectable and editable. If false, the text is neither editable nor selectable.
     */
    public var isSelectable: Bool = false
    /**
     A Boolean value that controls whether the user can edit the value in the text field.
     
     If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of `isSelectable`.
     */
    public var isEditable: Bool = false
    /**
     The edit handler that gets called when editing of the text ended.
     
     It only gets called, if `isEditable` is true.
     */
    public var onEditEnd: ((String) -> Void)?
    
    /**
     Handler that determines whether the edited string is valid.
     
     It only gets called, if `isEditable` is true.
     */
    public var stringValidation: ((String) -> (Bool))?
    
    #if os(macOS)
    /// The color of the text.
    public var color: NSUIColor = .labelColor
    #elseif canImport(UIKit)
    /// The color of the text.
    public var color: NSUIColor = .label
    #endif
    
    /// The color transformer of the text color.
    public var colorTansform: ColorTransformer?
    
    /// Generates the resolved text color, using the text color and color transformer.
    public func resolvedColor() -> NSUIColor {
        colorTansform?(color) ?? color
    }
    
    /// Initalizes a text configuration.
    public init() { }
    
    /**
     A text configuration with a system font for the specified point size, weight and design.
     
     - Parameters:
     - size: The size of the font.
     - weight: The weight of the font.
     - design: The design of the font.
     */
    public static func system(size: CGFloat, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        var properties = Self()
        properties.font = .systemFont(ofSize: size, weight: weight, design: design)
        return properties
    }
    
    /**
     A text configuration with a system font for the specified text style, weight and design.
     
     - Parameters:
     - style: The style of the font.
     - weight: The weight of the font.
     - design: The design of the font.
     */
    public static func system(_ style: NSUIFont.TextStyle = .body, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        var properties = Self()
        properties.font = .systemFont(style, design: design).weight(weight)
        return properties
    }
    
    /// A text configuration for a primary text.
    public static var primary: Self {
        var text = Self()
        text.numberOfLines = 1
        return text
    }
    
    /// A text configuration for a secondary text.
    public static var secondary: Self {
        var text = Self()
        text.font = .callout
    #if os(macOS)
        text.color = .secondaryLabelColor
    #elseif canImport(UIKit)
        text.color = .secondaryLabel
    #endif
        return text
    }
    
    /// A text configuration for a tertiary text.
    public static var tertiary: Self {
        var text = Self()
        text.font = .callout
    #if os(macOS)
        text.color = .secondaryLabelColor
    #elseif canImport(UIKit)
        text.color = .tertiaryLabel
    #endif
        return text
    }
    
    /// A text configurationn with a font for bodies.
    public static var body: Self {
        return .system(.body)
    }
    
    /// A text configurationn with a font for callouts.
    public static var callout: Self {
        return .system(.callout)
    }
    
    /// A text configurationn with a font for captions.
    public static var caption1: Self {
        return .system(.caption1)
    }
    
    /// A text configurationn with a font for alternate captions.
    public static var caption2: Self {
        return .system(.caption2)
    }
    
    /// A text configurationn with a font for footnotes.
    public static var footnote: Self {
        return .system(.footnote)
    }
    
    /// A text configurationn with a font for headlines.
    public static var headline: Self {
        return .system(.headline)
    }
    
    /// A text configurationn with a font for subheadlines.
    public static var subheadline: Self {
        return .system(.subheadline)
    }
    
    #if os(macOS) || os(iOS)
    /// A text configurationn with a font for large titles.
    public static var largeTitle: Self {
        return .system(.largeTitle)
    }
    #endif
    /// A text configurationn with a font for titles.
    public static var title1: Self {
        return .system(.title1)
    }
    
    /// A text configurationn with a font for alternate titles.
    public static var title2: Self {
        return .system(.title2)
    }
    
    /// A text configurationn with a font for alternate titles.
    public static var title3: Self {
        return .system(.title3)
    }
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 6.0, *)
extension TextConfiguration: Hashable {
    public static func == (lhs: TextConfiguration, rhs: TextConfiguration) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(numberOfLines)
        hasher.combine(alignment)
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(color)
        hasher.combine(colorTansform)
    }
}

extension NSTextAlignment {
    var swiftUI: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }
    
    var swiftUIMultiline: SwiftUI.TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 6.0, *)
public extension Text {
    @ViewBuilder
    func configurate(using properties: TextConfiguration) -> some View {
        font(Font(properties.font))
            .foregroundColor(Color(properties.resolvedColor()))
            .lineLimit(properties.numberOfLines == 0 ? nil : properties.numberOfLines)
            .multilineTextAlignment(properties.alignment.swiftUIMultiline)
            .frame(alignment: properties.alignment.swiftUI)
    }
}

#if os(macOS)
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension NSTextField {
    /// The text configuration of the text field.
    var textConfiguration: TextConfiguration {
        get {
            var configuration = TextConfiguration()
            configuration.numberOfLines = maximumNumberOfLines
            configuration.color = textColor ?? .labelColor
            configuration.font = font ?? .systemFont
            configuration.alignment = alignment
            configuration.lineBreakMode = lineBreakMode
            configuration.isEditable = isEditable
            configuration.isSelectable = isSelectable
            configuration.numberFormatter = numberFormatter
            configuration.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            configuration.minimumScaleFactor = minimumScaleFactor
            configuration.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
            return configuration
        }
        set {
            maximumNumberOfLines = newValue.numberOfLines
            textColor = newValue.resolvedColor()
            font = newValue.font
            alignment = newValue.alignment
            lineBreakMode = newValue.lineBreakMode
            isEditable = newValue.isEditable
            isSelectable = newValue.isSelectable
            numberFormatter = newValue.numberFormatter
            adjustsFontSizeToFitWidth = newValue.adjustsFontSizeToFitWidth
            minimumScaleFactor = newValue.minimumScaleFactor
            allowsDefaultTighteningForTruncation = newValue.allowsDefaultTighteningForTruncation
        }
    }
    
    /// Sets the text configuration of the text field.
    @discardableResult
    func textConfiguration(_ configuration: TextConfiguration) -> Self {
        self.textConfiguration = configuration
        return self
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension NSTextView {
    /// The text configuration of the text view.
    var textConfiguration: TextConfiguration {
        get {
            var configuration = TextConfiguration()
            configuration.color = textColor ?? .labelColor
            configuration.font = font ?? .systemFont
            configuration.alignment = alignment
            configuration.isEditable = isEditable
            configuration.isSelectable = isSelectable
            configuration.lineBreakMode = textContainer?.lineBreakMode ?? .byWordWrapping
            configuration.numberOfLines = textContainer?.maximumNumberOfLines ?? 0
            return configuration
        }
        set {
            textColor = newValue.resolvedColor()
            font = newValue.font
            alignment = newValue.alignment
            isEditable = newValue.isEditable
            isSelectable = newValue.isSelectable
            textContainer?.maximumNumberOfLines = newValue.numberOfLines
            textContainer?.lineBreakMode = newValue.lineBreakMode
        }
    }
    
    /// Sets the text configuration of the text view.
    @discardableResult
    func textConfiguration(_ configuration: TextConfiguration) -> Self {
        self.textConfiguration = configuration
        return self
    }
}

#elseif canImport(UIKit)
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension UILabel {
    /// The text configuration of the label.
    var textConfiguration: TextConfiguration {
        get {
            var configuration = TextConfiguration()
            configuration.color = textColor
            configuration.font = font
            configuration.alignment = textAlignment
            configuration.lineBreakMode = lineBreakMode
            configuration.numberOfLines = numberOfLines
            configuration.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            configuration.minimumScaleFactor = minimumScaleFactor
            configuration.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
            configuration.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
            configuration.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            return configuration
        }
        set {
            numberOfLines = newValue.numberOfLines
            textColor = newValue.resolvedColor()
            font = newValue.font
            lineBreakMode = newValue.lineBreakMode
            textAlignment = newValue.alignment
            adjustsFontSizeToFitWidth = newValue.adjustsFontSizeToFitWidth
            minimumScaleFactor = newValue.minimumScaleFactor
            allowsDefaultTighteningForTruncation = newValue.allowsDefaultTighteningForTruncation
            adjustsFontForContentSizeCategory = newValue.adjustsFontForContentSizeCategory
            showsExpansionTextWhenTruncated = newValue.showsExpansionTextWhenTruncated
        }
    }
    
    /// Sets the text configuration of the text label.
    @discardableResult
    func textConfiguration(_ configuration: TextConfiguration) -> Self {
        self.textConfiguration = configuration
        return self
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension UITextField {
    /// The text configuration of the text field.
    var textConfiguration: TextConfiguration {
        get {
            var configuration = TextConfiguration()
            configuration.color = textColor ?? .label
            configuration.font = font ?? .systemFont
            configuration.alignment = textAlignment
            configuration.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            configuration.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            return configuration
        }
        set {
            textColor = newValue.resolvedColor()
            font = newValue.font
            textAlignment = newValue.alignment
            adjustsFontSizeToFitWidth = newValue.adjustsFontSizeToFitWidth
            adjustsFontForContentSizeCategory = newValue.adjustsFontForContentSizeCategory
        }
    }
    
    /// Sets the text configuration of the text field.
    @discardableResult
    func textConfiguration(_ configuration: TextConfiguration) -> Self {
        self.textConfiguration = configuration
        return self
    }
}

public extension UITextView {
    /// The text configuration of the text view.
    var textConfiguration: TextConfiguration {
        get {
            var configuration = TextConfiguration()
            configuration.font = font ?? .systemFont
            configuration.color = textColor ?? .label
            configuration.lineBreakMode = textContainer.lineBreakMode
            configuration.alignment = textAlignment
            configuration.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            configuration.isSelectable = isSelectable
            configuration.numberOfLines = textContainer.maximumNumberOfLines
            #if os(iOS)
            configuration.isEditable = isEditable
            #endif
            return configuration
        }
        set {
            textAlignment = newValue.alignment
            font = newValue.font
            textContainer.maximumNumberOfLines = newValue.numberOfLines
            isSelectable = newValue.isSelectable
            textColor = newValue.resolvedColor()
            textContainer.lineBreakMode = newValue.lineBreakMode
            adjustsFontForContentSizeCategory = newValue.adjustsFontForContentSizeCategory
            #if os(iOS)
            isEditable = newValue.isEditable
            #endif
        }
    }
    
    /// Sets the text configuration of the text view.
    @discardableResult
    func textConfiguration(_ configuration: TextConfiguration) -> Self {
        self.textConfiguration = configuration
        return self
    }
}
#endif
#endif
