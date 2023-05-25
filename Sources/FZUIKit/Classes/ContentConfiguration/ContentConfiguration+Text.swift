//
//  ContentConfiguration+Text.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

#if os(macOS)
    public extension ContentConfiguration.Text.BezelStyle {
        var textfield: NSTextField.BezelStyle {
            switch self {
            case .rounded:
                return .roundedBezel
            case .square:
                return .squareBezel
            }
        }
    }
#endif

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a text.
    struct Text: Hashable {
        public enum TextTransform: Hashable {
            case none
            case capitalized
            case lowercase
            case uppercase
        }

        public enum BezelStyle: Hashable {
            case rounded
            case square
        }

        public var font: NSUIFont = .systemFont(ofSize: NSUIFont.systemFontSize)
        public var textColor: NSUIColor = .black
        public var textColorTransform: NSUIConfigurationColorTransformer? = nil
        public func resolvedTextColor() -> NSUIColor {
            return textColorTransform?(textColor) ?? textColor
        }

        public var alignment: NSTextAlignment = .left
        public var lineBreakMode: NSLineBreakMode = .byTruncatingTail
        public var numberOfLines: Int = 1
        public var adjustsFontSizeToFitWidth: Bool = false
        public var minimumScaleFactor: CGFloat = 1.0
        public var allowsDefaultTighteningForTruncation: Bool = false
        public var adjustsFontForContentSizeCategory: Bool = false
        public var transform: TextTransform = .none
        public var showsExpansionTextWhenTruncated: Bool = false

        public var isSelectable: Bool = false
        public var isEditable: Bool = false

        public var bezelStyle: BezelStyle? = nil
        public var backgroundColor: NSUIColor? = nil
        public var backgroundColorTransform: NSUIConfigurationColorTransformer? = nil
        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        public init(font _: NSUIFont = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize),
                    textColor: NSUIColor = .label,
                    textColorTransform: NSUIConfigurationColorTransformer? = nil,
                    alignment: NSTextAlignment = .left,
                    lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                    numberOfLines: Int = 1,
                    adjustsFontSizeToFitWidth: Bool = false,
                    minimumScaleFactor: CGFloat = 1.0,
                    allowsDefaultTighteningForTruncation: Bool = false,
                    adjustsFontForContentSizeCategory _: Bool = false,
                    transform: TextTransform = .none,
                    showsExpansionTextWhenTruncated: Bool = false,
                    isSelectable: Bool = false,
                    isEditable: Bool = false,
                    bezelStyle: BezelStyle? = nil,
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransform: NSUIConfigurationColorTransformer? = nil)
        {
            self.textColor = textColor
            self.textColorTransform = textColorTransform
            self.alignment = alignment
            self.lineBreakMode = lineBreakMode
            self.numberOfLines = numberOfLines
            self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            self.minimumScaleFactor = minimumScaleFactor
            self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
            self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            self.transform = transform
            self.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
            self.isSelectable = isSelectable
            self.isEditable = isEditable
            self.bezelStyle = bezelStyle
            self.backgroundColor = backgroundColor
            self.backgroundColorTransform = backgroundColorTransform
        }

        #if os(macOS)
            public static func `default`() -> Self {
                if #available(macOS 11.0, iOS 10.0, *) {
                    return .textStyle(.body)
                } else {
                    return .system(size: NSUIFont.systemFontSize)
                }
            }

            public static func system(size: CGFloat, weight: NSUIFont.Weight? = nil) -> Self {
                var property = Self()
                property.font = .system(size: size, weight: weight ?? .regular)
                return property
            }

            @available(macOS 11.0, *)
            public static func textStyle(_ style: NSUIFont.TextStyle, weight: NSUIFont.Weight? = nil) -> Self {
                var property = Self()
                if let weight = weight {
                    property.font = .system(style).weight(weight)
                } else {
                    property.font = .system(.body)
                }
                return property
            }

            public static func system(size: CGFloat, weight: NSUIFont.Weight? = nil, color: NSUIColor = NSUIColor.label, numberOfLines: Int = 1) -> Self {
                let font: NSUIFont
                if let weight = weight {
                    font = NSUIFont.systemFont(ofSize: size, weight: weight)
                } else {
                    font = NSUIFont.systemFont(ofSize: size)
                }
                var properties = Self()
                properties.font = font
                properties.textColor = color
                properties.numberOfLines = numberOfLines
                if numberOfLines == 1 {
                    properties.lineBreakMode = .byTruncatingTail
                } else {
                    properties.lineBreakMode = .byWordWrapping
                }
                return properties
            }

            public static func system(_ fontSize: FontSize, weight: NSUIFont.Weight? = nil, color: NSUIColor = .labelColor, numberOfLines: Int = 1) -> Self {
                return system(size: fontSize.value, weight: weight, color: color, numberOfLines: numberOfLines)
            }

            public static func system(controlSize: NSControl.ControlSize, weight: NSUIFont.Weight? = nil, color: NSUIColor = .labelColor, numberOfLines: Int = 1) -> Self {
                return system(.controlSize(controlSize), weight: weight, color: color, numberOfLines: numberOfLines)
            }

            public static func system(tableRowSize: NSTableView.RowSizeStyle, weight: NSUIFont.Weight? = nil, color: NSUIColor = .labelColor, numberOfLines: Int = 1) -> Self {
                return system(.tableRowSize(tableRowSize), weight: weight, color: color, numberOfLines: numberOfLines)
            }
        #endif
    }
}

#if os(macOS)
    public extension ContentConfiguration.Text {
        enum FontSize: Hashable {
            case absolute(CGFloat)
            case controlSize(NSControl.ControlSize)
            case tableRowSize(NSTableView.RowSizeStyle)
            public var value: CGFloat {
                switch self {
                case let .absolute(value):
                    return value
                case let .controlSize(value):
                    return NSFont.systemFontSize(for: value)
                case let .tableRowSize(value):
                    return NSFont.systemFontSize(forTableRowSize: value)
                }
            }
        }
    }
#endif

#if os(macOS)
    public extension NSTextField {
        /**
         Configurates the text and apperance of the textfield.

         - Parameters:
            - configuration:The configuration for configurating the textfield.
         */
        func configurate(using configuration: ContentConfiguration.Text) {
            font = configuration.font
            textColor = configuration.resolvedTextColor()
            backgroundColor = configuration.resolvedBackgroundColor()
            drawsBackground = (backgroundColor != nil)
            isEditable = configuration.isEditable
            isSelectable = configuration.isSelectable
            bezelStyle = configuration.bezelStyle?.textfield ?? .squareBezel
            isBezeled = (configuration.bezelStyle != nil)
            lineBreakMode = configuration.lineBreakMode
            alignment = configuration.alignment
            maximumNumberOfLines = configuration.numberOfLines
            stringValue = stringValue.transform(using: configuration.transform)
            attributedStringValue = attributedStringValue.transform(using: configuration.transform)
        }
    }

    public extension NSTextView {
        func configurate(using configuration: ContentConfiguration.Text) {
            font = configuration.font
            textColor = configuration.resolvedTextColor()
            backgroundColor = configuration.resolvedBackgroundColor()
            drawsBackground = (backgroundColor != nil)
            isEditable = configuration.isEditable
            isSelectable = configuration.isSelectable
            alignment = configuration.alignment
            let attributedString = self.attributedString().transform(using: configuration.transform)
            textStorage?.setAttributedString(attributedString)
            string = string.transform(using: configuration.transform)
        }
    }

#elseif canImport(UIKit)
    public extension UILabel {
        func configurate(using configuration: ContentConfiguration.Text) {
            font = configuration.font
            textColor = configuration.resolvedTextColor()
            backgroundColor = configuration.resolvedBackgroundColor()
            numberOfLines = configuration.numberOfLines
            textAlignment = configuration.alignment
            lineBreakMode = configuration.lineBreakMode
            attributedText = attributedText?.transform(using: configuration.transform)
            text = text?.transform(using: configuration.transform)
        }
    }

    public extension UITextField {
        /**
         Configurates the text and apperance of the textfield.

         - Parameters:
            - configuration:The configuration for configurating the textfield.
         */
        func configurate(using configuration: ContentConfiguration.Text) {
            font = configuration.font
            textColor = configuration.resolvedTextColor()
            backgroundColor = configuration.resolvedBackgroundColor()
            textAlignment = configuration.alignment
            //    self.lineBreakMode = configuration.lineBreakMode
            attributedText = attributedText?.transform(using: configuration.transform)
            text = text?.transform(using: configuration.transform)
        }
    }

    public extension UITextView {
        /**
         Configurates the text and apperance of the textview.

         - Parameters:
            - configuration:The configuration for configurating the textview.
         */
        func configurate(using configuration: ContentConfiguration.Text) {
            font = configuration.font
            textColor = configuration.resolvedTextColor()
            backgroundColor = configuration.resolvedBackgroundColor()
            textAlignment = configuration.alignment
            attributedText = attributedText.transform(using: configuration.transform)
            text = text.transform(using: configuration.transform)
            textContainer.maximumNumberOfLines = configuration.numberOfLines
            textContainer.lineBreakMode = configuration.lineBreakMode
        }
    }
    // maximumNumberOfLines
#endif

public extension String {
    func transform(using transform: ContentConfiguration.Text.TextTransform) -> String {
        switch transform {
        case .none:
            return self
        case .capitalized:
            return capitalized
        case .lowercase:
            return lowercased()
        case .uppercase:
            return uppercased()
        }
    }
}

public extension NSAttributedString {
    func transform(using transform: ContentConfiguration.Text.TextTransform) -> NSAttributedString {
        switch transform {
        case .none:
            return self
        case .capitalized:
            return capitalized()
        case .lowercase:
            return lowercased()
        case .uppercase:
            return uppercased()
        }
    }
}
