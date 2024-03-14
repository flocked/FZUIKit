//
//  ImageSymbolConfiguration.swift
//
//
//  Created by Florian Zand on 03.06.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import FZSwiftUtils
import SwiftUI

/**
 An object that contains font, color, and image scale attributes to apply to an object with a symbol image.

 `NSImageView` and `UIImageView` can be configurated by applying the configuration to `configurate(using:_)`.

 `NSImage` can be configurated using `withSymbolConfiguration(_)` and `UIImage` can be configurated using `applyingSymbolConfiguration(_)`.
 */
@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public struct ImageSymbolConfiguration: Hashable {
    /// The font of the symbol configuration.
    public var font: FontConfiguration?

    /// The color configuration of the symbol configuration.
    public var color: ColorConfiguration? {
        didSet { updateResolvedColors() }
    }

    /// The color transformer for resolving the colors of the color configuration.
    public var colorTransformer: ColorTransformer? {
        didSet { updateResolvedColors() }
    }

    /// The image scaling of the symbol configuration.
    public var imageScale: ImageScale?

    /// Sets the font of the symbol configuration.
    @discardableResult
    public func font(_ font: FontConfiguration?) -> Self {
        var configuration = self
        configuration.font = font
        return configuration
    }
    
    /// Sets the font weight of the symbol configuration.
    @discardableResult
    public func weight(_ weight: NSUIImage.SymbolWeight) -> Self {
        var configuration = self
        configuration.font = configuration.font?.weight(weight)
        return configuration
    }
    
    /*
    /// Sets the font design of the symbol configuration.
    @discardableResult
    public func design(_ design: NSUIFontDescriptor.SystemDesign) -> Self {
        var configuration = self
        configuration.font = configuration.font?.design(design)
        return configuration
    }
    */

    /// Sets the color configuration of the symbol configuration.
    @discardableResult
    public func color(_ configuration: ColorConfiguration?) -> Self {
        var newConfiguration = self
        newConfiguration.color = configuration
        return newConfiguration
    }

    /// Sets the color transformer of the symbol configuration.
    @discardableResult
    public func colorTransformer(_ transformer: ColorTransformer?) -> Self {
        var newConfiguration = self
        newConfiguration.colorTransformer = transformer
        return newConfiguration
    }

    /// Sets the image scale of the symbol configuration.
    @discardableResult
    public func imageScale(_ scale: ImageScale?) -> Self {
        var configuration = self
        configuration.imageScale = scale
        return configuration
    }
    
    /**
     Returns a configuration that applies the specified configuration values on top of the current configuration’s values.
     
     - Parameter configuration: The configuration to apply.
     - Returns: A new configuration that prioritizes the values from the configuration you specify.
     */
    public func applying(_ configuration: ImageSymbolConfiguration) -> ImageSymbolConfiguration {
        var newConfiguration = self
        newConfiguration.font = configuration.font ?? newConfiguration.font
        newConfiguration.color = configuration.color ?? newConfiguration.color
        newConfiguration.colorTransformer = configuration.colorTransformer ?? newConfiguration.colorTransformer
        newConfiguration.imageScale = configuration.imageScale ?? newConfiguration.imageScale
        return newConfiguration
    }
    
    /// Returns a configuration that applies the right configuration values on top of the left configuration’s values.
    public static func + (lhs: ImageSymbolConfiguration, rhs: ImageSymbolConfiguration) -> ImageSymbolConfiguration {
        lhs.applying(rhs)
    }
    
    /// Applies the right configuration values on top of the left configuration’s values.
    public static func += (lhs: inout ImageSymbolConfiguration, rhs: ImageSymbolConfiguration) {
        lhs = lhs.applying(rhs)
    }

    /**
     Creates a symbol configuration.

     - Parameters:
        - font: The font.
        - color: The color configuration.
        - colorTransformer: The color transformer.
        - imageScale: The image scaling.

     - Returns: a symbol configuration object.
     */
    public init(font: FontConfiguration? = nil, color: ColorConfiguration? = nil, colorTransformer: ColorTransformer? = nil, imageScale: ImageScale? = nil) {
        self.font = font
        self.color = color
        self.colorTransformer = colorTransformer
        self.imageScale = imageScale
        updateResolvedColors()
    }

    /// Creates a configuration with a monochrome color configuration using the tint color.
    public static var monochrome: Self {
        Self(color: .monochrome)
    }

    /// Creates a configuration with a monochrome color configuration using the specified color.
    public static func monochrome(_ color: NSUIColor) -> Self {
        palette(color, color)
    }

    /// Creates a configuration with a hierarchical color configuration with the specified color.
    public static func hierarchical(_ color: NSUIColor) -> Self {
        Self(color: .hierarchical(color))
    }

    /// Creates a configuration with a multicolor configuration with the specified color.
    public static func multicolor(_ color: NSUIColor) -> Self {
        Self(color: .multicolor(color))
    }

    /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
    public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor, _ tertiary: NSUIColor? = nil) -> Self {
        Self(color: .palette(primary, secondary, tertiary))
    }

    /// Creates a configuration with the specified font style and weight.
    public static func font(_ style: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        Self(font: .textStyle(style, weight: weight, design: design))
    }

    /// Creates a configuration with the specified font size and weight.
    public static func font(size: CGFloat, weight: NSUIImage.SymbolWeight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        Self(font: .systemFont(size: size, weight: weight, design: design))
    }

    /// Creates a configuration with the specified image scale.
    public static func imageScale(_ imageScale: ImageScale) -> Self {
        Self(imageScale: imageScale)
    }

    /// Creates a configuration  with a body font configuration.
    public static let body = Self.font(.body)
    /// Creates a configuration with a callout font configuration.
    public static let callout = Self.font(.callout)
    /// Creates a configuration with a caption font configuration.
    public static let caption1 = Self.font(.caption1)
    /// Creates a configuration with a alternate caption font configuration.
    public static let caption2 = Self.font(.caption2)
    /// Creates a configuration with a footnote font configuration.
    public static let footnote = Self.font(.footnote)
    /// Creates a configuration with a headline font configuration.
    public static let headline = Self.font(.headline)
    /// Creates a configuration with a subheadline font configuration.
    public static let subheadline = Self.font(.subheadline)
    #if os(macOS) || os(iOS)
        /// Creates a configuration with a large title font configuration.
        public static let largeTitle = Self.font(.largeTitle)
    #endif
    /// Creates a configuration with a first-level title font configuration.
    public static let title1 = Self.font(.title1)
    /// Creates a configuration with a second-level title font configuration.
    public static let title2 = Self.font(.title2)
    /// Creates a configuration with a third-level title font configuration.
    public static let title3 = Self.font(.title3)

    /// Generates the resolved primary color for the specified color style, using the color style's primary color and color transformer.
    public func resolvedPrimaryColor() -> NSUIColor? {
        if let primary = color?.primary {
            return colorTransformer?(primary) ?? primary
        }
        return nil
    }

    /// Generates the resolved secondary color for the specified color style, using the color style's secondary color and color transformer.
    public func resolvedSecondaryColor() -> NSUIColor? {
        if let secondary = color?.secondary {
            return colorTransformer?(secondary) ?? secondary
        }
        return nil
    }

    /// Generates the resolved tertiary color for the specified color style, using the color style's tertiary color and color transformer.
    public func resolvedTertiaryColor() -> NSUIColor? {
        if let tertiary = color?.tertiary {
            return colorTransformer?(tertiary) ?? tertiary
        }
        return nil
    }

    var _resolvedPrimaryColor: NSUIColor?
    var _resolvedSecondaryColor: NSUIColor?
    var _resolvedTertiaryColor: NSUIColor?
    mutating func updateResolvedColors() {
        _resolvedPrimaryColor = resolvedPrimaryColor()
        _resolvedSecondaryColor = resolvedSecondaryColor()
        _resolvedTertiaryColor = resolvedTertiaryColor()
    }

    /// The font of a symbol image.
    public enum FontConfiguration: Hashable {
        /// A font with the specified point size and font weight.
        case systemFont(size: CGFloat, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)

        /// A font with the specified text style and font weight.
        case textStyle(_ style: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)

        /// Sets the weight of the font.
        @discardableResult
        public func weight(_ weight: NSUIImage.SymbolWeight?) -> Self {
            switch self {
            case let .systemFont(size, _, design):
                return .systemFont(size: size, weight: weight, design: design)
            case let .textStyle(style, _, design):
                return .textStyle(style, weight: weight, design: design)
            }
        }

        /// Sets the design of the font.
        @discardableResult
        public func design(_ design: NSUIFontDescriptor.SystemDesign) -> Self {
            switch self {
            case let .systemFont(size, weight, _):
                return .systemFont(size: size, weight: weight, design: design)
            case let .textStyle(style, weight, _):
                return .textStyle(style, weight: weight, design: design)
            }
        }

        /// The font you use for body text.
        public static let body = Self.textStyle(.body)
        /// The font you use for callouts.
        public static let callout = Self.textStyle(.callout)
        /// The font you use for standard captions.
        public static let caption1 = Self.textStyle(.caption1)
        /// The font you use for alternate captions.
        public static let caption2 = Self.textStyle(.caption2)
        /// The font you use in footnotes.
        public static let footnote = Self.textStyle(.footnote)
        /// The font you use for headings.
        public static let headline = Self.textStyle(.headline)
        /// The font you use for subheadings.
        public static let subheadline = Self.textStyle(.subheadline)
        #if os(macOS) || os(iOS)
            /// The font you use for large titles.
            public static let largeTitle = Self.textStyle(.largeTitle)
        #endif
        /// The font you use for first-level hierarchical headings.
        public static let title1 = Self.textStyle(.title1)
        /// The font you use for second-level hierarchical headings.
        public static let title2 = Self.textStyle(.title2)
        /// The font you use for third-level hierarchical headings.
        public static let title3 = Self.textStyle(.title3)

        /// The font configuration as SwiftUI `Font`.
        public var swiftui: Font {
            switch self {
            case let .textStyle(style, weight: weight, design: design):
                return Font.system(style.swiftUI, design: design.swiftUI).weight(weight?.swiftUI ?? .regular)
            case let .systemFont(size: size, weight: weight, design: design):
                return Font.system(size: size, design: design.swiftUI).weight(weight?.swiftUI ?? .regular)
            }
        }

        #if os(macOS)
            /// The font configuration as `NSFont`.
            public var nsFont: NSFont {
                switch self {
                case let .systemFont(size, weight, design):
                    return .systemFont(ofSize: size, weight: weight?.fontWeight() ?? .regular, design: design)
                case let .textStyle(textStyle, weight, design):
                    return .systemFont(textStyle, design: design).weight(weight?.fontWeight() ?? .regular)
                }
            }
        #endif
    }

    /// Constants that specify which symbol image scale.
    public enum ImageScale: Hashable {
        /// A scale that produces small images.
        case small
        /// A scale that produces medium-sized images.
        case medium
        /// A scale that produces large images.
        case large

        #if os(macOS)
            /// The image scale as `NSImage.SymbolScale`.
            public var nsSymbolScale: NSUIImage.SymbolScale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
        #else
            /// The image scale as `UIImage.SymbolScale`.
            public var uiSymbolScale: NSUIImage.SymbolScale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
        #endif

        /// The image scale as `SwiftUI.Image.Scale`.
        public var swiftui: SwiftUI.Image.Scale {
            switch self {
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            }
        }
    }

    /// Constants that specify the color configuration of a symbol image.
    public enum ColorConfiguration: Hashable {
        #if os(macOS)
        ///  A monochrome color configuration using the specified color.
        case monochrome(NSUIColor?)
        ///  A hierarchical color configuration using the specified color.
        case hierarchical(NSUIColor?)
        ///  A multicolor color configuration using the color you specify as primary color.
        case multicolor(NSUIColor)
        /// A color configuration by specifying a palette of colors.
        case palette(NSUIColor, NSUIColor, NSUIColor? = nil)
        
        ///  A monochrome color configuration using the tint color.
        public static var monochrome: Self {
            monochrome(nil)
        }
        ///  A hierarchical color configuration using the tint color.
        public static var hierarchical: Self {
            hierarchical(nil)
        }
        #else
        ///  A monochrome color configuration using the specified color.
        case monochrome(NSUIColor?)
        ///  A hierarchical color configuration using the specified color.
        case hierarchical(NSUIColor)
        ///  A multicolor color configuration using the color you specify as primary color.
        case multicolor(NSUIColor)
        /// A color configuration by specifying a palette of colors.
        case palette(NSUIColor, NSUIColor, NSUIColor? = nil)
        
        ///  A monochrome color configuration using the tint color.
        public static var monochrome: Self {
            monochrome(nil)
        }
        #endif

        #if os(macOS)
            /// A color configuration with monochrome accent color.
            public static var accentColor: Self {
                .monochrome(.controlAccentColor)
            }

        #elseif os(iOS) || os(tvOS)
            /// A color configuration with monochrome tint color.
            public static var tintColor: Self {
                .monochrome(.tintColor)
            }
        #endif

        /// A color configuration with monochrome black color.
        public static var black: Self {
            .monochrome(.black)
        }
        
        /// A color configuration with monochrome white color.
        public static var white: Self {
            .monochrome(.white)
        }
        
        #if os(macOS)
        /// A color configuration with primary label color.
        public static var labelColor: Self {
            .monochrome(.labelColor)
        }
        /// A color configuration with secondary label color.
        public static var secondaryLabelColor: Self {
            .monochrome(.secondaryLabelColor)
        }
        /// A color configuration with tertiary label color.
        public static var tertiaryLabelColor: Self {
            .monochrome(.tertiaryLabelColor)
        }
        /// A color configuration with quaternary label color.
        public static var quaternaryLabelColor: Self {
            .monochrome(.quaternaryLabelColor)
        }
        #elseif os(iOS) || os(tvOS)
        /// A color configuration with primary label color.
        public static var label: Self {
            .monochrome(.label)
        }
        /// A color configuration with secondary label color.
        public static var secondaryLabel: Self {
            .monochrome(.secondaryLabel)
        }
        /// A color configuration with tertiary label color.
        public static var tertiaryLabel: Self {
            .monochrome(.tertiaryLabel)
        }
        /// A color configuration with quaternary label color.
        public static var quaternaryLabel: Self {
            .monochrome(.quaternaryLabel)
        }
        #endif

        var renderingMode: SwiftUI.SymbolRenderingMode {
            switch self {
            case .palette: return .palette
            case .monochrome: return .monochrome
            case .multicolor: return .multicolor
            case .hierarchical: return .hierarchical
            }
        }

        /// The primary color, or `nil` if there isn't a primary color.
        public var primary: NSUIColor? {
            switch self {
            case let .palette(primary, _, _):
                return primary
            case let .multicolor(primary):
                return primary
            case let .hierarchical(primary):
                return primary
            case .monochrome:
                return nil
            }
        }

        /// The secondary color, or `nil` if there isn't a secondary color.
        public var secondary: NSUIColor? {
            switch self {
            case let .palette(_, secondary, _):
                return secondary
            default:
                return nil
            }
        }

        /// The tertiary color, or `nil` if there isn't a tertiary color.
        public var tertiary: NSUIColor? {
            switch self {
            case let .palette(_, _, tertiary):
                return tertiary
            default:
                return nil
            }
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    var symbolConfiguration: ImageSymbolConfiguration? {
        get { getAssociatedValue(key: "symbolConfiguration", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "symbolConfiguration", object: self) }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension ImageSymbolConfiguration {
    #if os(macOS)
        /// Returns a `NSImage.SymbolConfiguration` representation.
        func nsSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
            nsUI()
        }

    #elseif canImport(UIKit)
        /// Returns a `UIImage.SymbolConfiguration` representation.
        func uiSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
            nsUI()
        }
    #endif
    internal func nsUI() -> NSUIImage.SymbolConfiguration {
        var configuration: NSUIImage.SymbolConfiguration
        switch color {
        case let .hierarchical(color):
            #if os(macOS)
            if let color = color {
                configuration = .hierarchical(color)
            } else {
                configuration = ._preferringHierarchical()
            }
            #else
            configuration = .hierarchical(color)
            #endif
        case .monochrome(let color):
            if let color = color {
                configuration = .palette(color, color)
            } else {
                configuration = .monochrome()
            }
        case let .palette(primary, secondary, tertiary):
            configuration = .palette(primary, secondary, tertiary)
        case let .multicolor(color):
            configuration = .multicolor(color)
        case .none:
            #if os(macOS)
                configuration = .init()
            #else
                configuration = .unspecified
            #endif
        }

        switch font {
        case .systemFont(size: let size, weight: let weight, design: _):
            configuration = configuration.font(size: size)
            configuration = configuration.weight(weight)
        case .textStyle(let style, weight: let weight, design: _):
            configuration = configuration.font(style)
            configuration = configuration.weight(weight)
        case .none:
            break
        }

        #if os(macOS)
            if let symbolScale = imageScale?.nsSymbolScale {
                configuration = configuration.scale(symbolScale)
            }
        #else
            if let symbolScale = imageScale?.uiSymbolScale {
                configuration = configuration.scale(symbolScale)
            }
        #endif

        configuration.symbolConfiguration = self
        return configuration
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.00, *)
public extension NSUIImageView {
    #if os(macOS)
    /// The configuration values to use when rendering the image.
    var imageSymbolConfiguration: ImageSymbolConfiguration? {
        get { symbolConfiguration?.symbolConfiguration }
        set { symbolConfiguration = newValue?.nsUI() }
    }
    #else
    /// The configuration values to use when rendering the image.
    var preferredImageSymbolConfiguration: ImageSymbolConfiguration? {
        get { preferredSymbolConfiguration?.symbolConfiguration }
        set { preferredSymbolConfiguration = newValue?.nsUI() }
    }
    #endif
}

@available(macOS 12.0, iOS 16.0, tvOS 16.00, *)
public extension NSUIButton {
    #if os(macOS)
    /// The configuration values to use when rendering the image.
    var imageSymbolConfiguration: ImageSymbolConfiguration? {
        get { symbolConfiguration?.symbolConfiguration }
        set { symbolConfiguration = newValue?.nsUI() }
    }
    #endif
}
#endif

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension View {
    /**
     Configurates symbol images within this view.

     - Parameters:
        - tintColor: The tint color of the symbol images.
     - configuration: The configuration for the symbol images.
     */
    @ViewBuilder func symbolConfiguration(tintColor: Color?, configuration: ImageSymbolConfiguration?) -> some View {
        if let configuration = configuration {
            imageScale(configuration.imageScale?.swiftui)
                .symbolRenderingMode(configuration.color?.renderingMode)
                .foregroundStyle(tintColor ?? configuration.color?.primary?.swiftUI, configuration.color?.secondary?.swiftUI, configuration.color?.tertiary?.swiftUI)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }

    /**
     Configurates symbol images within this view.

     - Parameters:
        - configuration: The configuration for the symbol images.
     */
    @ViewBuilder func symbolConfiguration(_ configuration: ImageSymbolConfiguration?) -> some View {
        if let configuration = configuration {
            imageScale(configuration.imageScale?.swiftui)
                .symbolRenderingMode(configuration.color?.renderingMode)
                .foregroundStyle(configuration.color?.primary?.swiftUI, configuration.color?.secondary?.swiftUI, configuration.color?.tertiary?.swiftUI)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
    public extension NSUIImageView {
        /// Configurates the image view with the specified symbol configuration.
        func configurate(using configuration: ImageSymbolConfiguration) {
            #if os(macOS)
                symbolConfiguration = configuration.nsUI()
                contentTintColor = configuration._resolvedPrimaryColor ?? contentTintColor
            #elseif canImport(UIKit)
                preferredSymbolConfiguration = configuration.nsUI()
                tintColor = configuration._resolvedPrimaryColor ?? tintColor
            #endif
        }
    }
#endif

    @available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
    public extension NSUIImage {
        /// Creates a new symbol image with the specified configuration.
        func withSymbolConfiguration(_ configuration: ImageSymbolConfiguration) -> NSUIImage? {
            #if os(macOS)
            withSymbolConfiguration(configuration.nsUI())
            #else
            withConfiguration(configuration.nsUI())
            #endif
        }

        /// Returns a new version of the current image, applying the specified configuration attributes on top of the current attributes.
        func applyingSymbolConfiguration(_ configuration: ImageSymbolConfiguration) -> NSUIImage? {
            applyingSymbolConfiguration(configuration.nsUI())

        }
        
        /// The configuration details for a symbol image.
        var imageSymbolConfiguration: ImageSymbolConfiguration? {
            #if os(macOS)
            symbolConfiguration.symbolConfiguration
            #else
            symbolConfiguration?.symbolConfiguration
            #endif
        }
    }
