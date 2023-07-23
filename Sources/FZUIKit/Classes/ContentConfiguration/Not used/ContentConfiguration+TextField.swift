//
//  ContentConfiguration+TextField.swift
//
//
//  Created by Florian Zand on 04.04.23.
//

/*
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a text.
    struct TextField: Hashable {
        #if os(macOS)
        public var bezelStyle: NSTextField.BezelStyle? = nil
        #endif
        
        public var font: NSUIFont = .systemFont(ofSize: NSUIFont.systemFontSize)
        public var textColor: NSUIColor = .black {
            didSet { if oldValue != textColor {
                    self.updateResolvedColors() } } }
        public var textColorTransform: NSUIConfigurationColorTransformer? = nil {
            didSet { if oldValue != textColorTransform {
                    self.updateResolvedColors() } } }
        public func resolvedTextColor() -> NSUIColor {
            return textColorTransform?(textColor) ?? textColor
        }
        
        public var alignment: NSTextAlignment = .left
        public var lineBreakMode: NSLineBreakMode = .byTruncatingTail
        public var numberOfLines: Int = 0
        public var adjustsFontSizeToFitWidth: Bool = false
        public var minimumScaleFactor: CGFloat = 1.0
        public var allowsDefaultTighteningForTruncation: Bool = false
        public var adjustsFontForContentSizeCategory: Bool = false
        public var showsExpansionTextWhenTruncated: Bool = false
        
        public var isSelectable: Bool = false
        public var isEditable: Bool = false
        
        public var backgroundColor: NSUIColor? = nil {
            didSet { if oldValue != backgroundColor {
                    self.updateResolvedColors() } } }
        public var backgroundColorTransform: NSUIConfigurationColorTransformer? = nil {
            didSet { if oldValue != backgroundColorTransform {
                    self.updateResolvedColors() } } }
        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
#if os(macOS)
        public init(bezelStyle: NSTextField.BezelStyle? = nil,
                    font: NSUIFont = .body,
                    textColor: NSUIColor = .labelColor,
                    textColorTransform: NSUIConfigurationColorTransformer? = nil,
                    alignment: NSTextAlignment = .left,
                    lineBreakMode: NSLineBreakMode = .byWordWrapping,
                    numberOfLines: Int = 0,
                    adjustsFontSizeToFitWidth: Bool = false,
                    minimumScaleFactor: CGFloat = 1.0,
                    allowsDefaultTighteningForTruncation: Bool = false,
                    adjustsFontForContentSizeCategory: Bool = false,
                    showsExpansionTextWhenTruncated: Bool = false,
                    isSelectable: Bool = false,
                    isEditable: Bool = false,
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransform: NSUIConfigurationColorTransformer? = nil) {
            self.bezelStyle = bezelStyle
            self.font = font
            self.textColor = textColor
            self.textColorTransform = textColorTransform
            self.alignment = alignment
            self.lineBreakMode = lineBreakMode
            self.numberOfLines = numberOfLines
            self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            self.minimumScaleFactor = minimumScaleFactor
            self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
            self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            self.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
            self.isSelectable = isSelectable
            self.isEditable = isEditable
            self.backgroundColor = backgroundColor
            self.backgroundColorTransform = backgroundColorTransform
            self.updateResolvedColors()
        }
        #else
        public init(font: NSUIFont = .body,
                    textColor: NSUIColor = .label,
                    textColorTransform: NSUIConfigurationColorTransformer? = nil,
                    alignment: NSTextAlignment = .left,
                    lineBreakMode: NSLineBreakMode = .byWordWrapping,
                    numberOfLines: Int = 0,
                    adjustsFontSizeToFitWidth: Bool = false,
                    minimumScaleFactor: CGFloat = 1.0,
                    allowsDefaultTighteningForTruncation: Bool = false,
                    adjustsFontForContentSizeCategory: Bool = false,
                    showsExpansionTextWhenTruncated: Bool = false,
                    isSelectable: Bool = false,
                    isEditable: Bool = false,
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransform: NSUIConfigurationColorTransformer? = nil) {
            self.font = font
            self.textColor = textColor
            self.textColorTransform = textColorTransform
            self.alignment = alignment
            self.lineBreakMode = lineBreakMode
            self.numberOfLines = numberOfLines
            self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            self.minimumScaleFactor = minimumScaleFactor
            self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
            self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            self.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
            self.isSelectable = isSelectable
            self.isEditable = isEditable
            self.backgroundColor = backgroundColor
            self.backgroundColorTransform = backgroundColorTransform
            self.updateResolvedColors()
        }
        #endif

        internal var _resolvedBackgroundColor: NSUIColor? = nil
        internal var _resolvedTextColor: NSUIColor = .black
        internal mutating func updateResolvedColors() {
            _resolvedBackgroundColor = resolvedBackgroundColor()
            _resolvedTextColor = resolvedTextColor()
        }
    }
}

#if os(macOS)
public extension NSTextField {
    /**
     Configurates the text and apperance of the textfield.

     - Parameters:
        - configuration:The configuration for configurating the textfield.
     */
    func configurate(using configuration: ContentConfiguration.TextField) {
        font = configuration.font
        textColor = configuration._resolvedTextColor
        backgroundColor = configuration._resolvedBackgroundColor
        drawsBackground = (backgroundColor != nil)
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
        bezelStyle = configuration.bezelStyle ?? .squareBezel
        isBezeled = (configuration.bezelStyle != nil)
        lineBreakMode = configuration.lineBreakMode
        alignment = configuration.alignment
        maximumNumberOfLines = configuration.numberOfLines
    }
}

public extension NSTextView {
    func configurate(using configuration: ContentConfiguration.TextField) {
        font = configuration.font
        textColor = configuration._resolvedTextColor
        backgroundColor = configuration._resolvedBackgroundColor
        drawsBackground = (backgroundColor != nil)
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
        alignment = configuration.alignment
    }
}

#elseif canImport(UIKit)
public extension UILabel {
    func configurate(using configuration: ContentConfiguration.TextField) {
        font = configuration.font
        textColor = configuration._resolvedTextColor
        backgroundColor = configuration._resolvedBackgroundColor
        numberOfLines = configuration.numberOfLines
        textAlignment = configuration.alignment
        lineBreakMode = configuration.lineBreakMode
    }
}

public extension UITextField {
    /**
     Configurates the text and apperance of the textfield.

     - Parameters:
        - configuration:The configuration for configurating the textfield.
     */
    func configurate(using configuration: ContentConfiguration.TextField) {
        font = configuration.font
        textColor = configuration._resolvedTextColor
        backgroundColor = configuration._resolvedBackgroundColor
        textAlignment = configuration.alignment
        //    self.lineBreakMode = configuration.lineBreakMode
    }
}

public extension UITextView {
    /**
     Configurates the text and apperance of the textview.

     - Parameters:
        - configuration:The configuration for configurating the textview.
     */
    func configurate(using configuration: ContentConfiguration.TextField) {
        font = configuration.font
        textColor = configuration._resolvedTextColor
        backgroundColor = configuration._resolvedBackgroundColor
        textAlignment = configuration.alignment
    }
}
#endif
*/
