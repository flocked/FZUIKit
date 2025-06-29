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
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ImageSymbolConfiguration: Hashable {
    /// The font of the symbol configuration.
    public var font: FontConfiguration?

    /// The color configuration of the symbol configuration.
    public var color: ColorConfiguration?

    /// The color transformer for resolving the colors of the color configuration.
    public var colorTransformer: ColorTransformer?
    
    /// Generates the resolved color configuration, using the color configuration and color transformer.
    public func resolvedColor() -> ColorConfiguration? {
        guard var color = color else { return nil }
        color.colors = colorTransformer?(color.colors) ?? color.colors
        return color
    }

    /// The scale variant of the symbol configuration.
    public var scale: SymbolScale?

    /// Sets the font of the symbol configuration.
    @discardableResult
    public func font(_ font: FontConfiguration?) -> Self {
        var configuration = self
        configuration.font = font
        return configuration
    }
    
    /// Sets the font weight of the symbol configuration.
    @discardableResult
    public func weight(_ weight: NSUISymbolWeight) -> Self {
        var configuration = self
        configuration.font = configuration.font?.weight(weight)
        return configuration
    }

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

    /// Sets the scale variant of the symbol configuration.
    @discardableResult
    public func scale(_ scale: SymbolScale?) -> Self {
        var configuration = self
        configuration.scale = scale
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
        newConfiguration.scale = configuration.scale ?? newConfiguration.scale
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
    public init(font: FontConfiguration? = nil, color: ColorConfiguration? = nil, colorTransformer: ColorTransformer? = nil, scale: SymbolScale? = nil) {
        self.font = font
        self.color = color
        self.colorTransformer = colorTransformer
        self.scale = scale
    }
    
    #if os(macOS)
    @available(macOS 13.0, *)
    init(symbolConfiguration configuration: NSUIImage.SymbolConfiguration) {
        let pointSize = configuration.pointSize
        if pointSize != 0.0 {
            if let textStyle = NSFont.TextStyle.allCases.first(where: { NSFont.systemFont($0).pointSize == pointSize }) {
                font = .textStyle(textStyle, weight: configuration.weight)
            } else {
                font = .size(pointSize, weight: configuration.weight)
            }
        }
        if let mode = ImageSymbolConfiguration.ColorConfiguration.Mode(rawValue: configuration.colorRenderMode.rawValue) {
            color = .init(mode)
        }
        if configuration.prefersMulticolor {
            color = .multicolor
        }
        color?.colors = configuration.colors ?? []
        scale = .init(rawValue: configuration.scale.rawValue)
    }
    #endif

    /// Creates a configuration with a monochrome color using the tint color.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static var monochrome: Self {
        Self(color: .monochrome)
    }

    /// Creates a configuration with a monochrome color using the specified color.
    public static func monochrome(_ color: NSUIColor) -> Self {
        Self(color: .monochrome(color))
    }
    
    #if os(macOS)
    /// Creates a configuration with a hierarchical color using the tint color.
    @available(macOS 13.0, *)
    public static var hierarchical: Self {
        Self(color: .hierarchical)
    }
    #endif
    
    /// Creates a configuration with a hierarchical color with the specified color.
    public static func hierarchical(_ color: NSUIColor) -> Self {
        Self(color: .hierarchical(color))
    }
    
    /// Creates a configuration with a multicolor color using the tint color.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static var multicolor: Self {
        Self(color: .multicolor)
    }

    /// Creates a configuration with a multicolor color with the specified color.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static func multicolor(_ color: NSUIColor) -> Self {
        Self(color: .multicolor(color))
    }

    /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
    public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor, _ tertiary: NSUIColor? = nil) -> Self {
        Self(color: .palette(primary, secondary, tertiary))
    }

    /// Creates a configuration with the specified font style and weight.
    public static func font(_ style: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular) -> Self {
        Self(font: .textStyle(style, weight: weight))
    }

    /// Creates a configuration with the specified font size and weight.
    public static func font(size: CGFloat, weight: NSUISymbolWeight = .regular) -> Self {
        Self(font: .size(size, weight: weight))
    }

    /// Creates a configuration with the specified image scale.
    public static func scale(_ scale: SymbolScale) -> Self {
        Self(scale: scale)
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
    /// Creates a configuration with a first-level title font configuration.
    public static let title1 = Self.font(.title1)
    /// Creates a configuration with a second-level title font configuration.
    public static let title2 = Self.font(.title2)
    /// Creates a configuration with a third-level title font configuration.
    public static let title3 = Self.font(.title3)
    #if os(macOS) || os(iOS)
    /// Creates a configuration with a large title font configuration.
    public static let largeTitle = Self.font(.largeTitle)
    #endif

    /// The font of a symbol image.
    public enum FontConfiguration: Hashable {
        /// A font with the specified point size and font weight.
        case size(_ size: CGFloat, weight: NSUISymbolWeight = .regular)

        /// A font with the specified text style and font weight.
        case textStyle(_ style: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular)

        /// Sets the weight of the font.
        @discardableResult
        public func weight(_ weight: NSUISymbolWeight) -> Self {
            switch self {
            case let .size(size, _):
                return .size(size, weight: weight)
            case let .textStyle(style, _):
                return .textStyle(style, weight: weight)
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

        var symbolConfiguration: NSUIImage.SymbolConfiguration {
            switch self {
            case .size(let size, let weight):
                return .init(pointSize: size, weight: weight, scale: .default)
            case .textStyle(let style, let weight):
                return .init(textStyle: style, weight: weight)
            }
        }
        
        #if os(macOS)
        /// `NSFont` representation of the font.
        public var nsFont: NSFont {
            switch self {
            case let .size(size, weight):
                return .systemFont(ofSize: size, weight: weight)
            case let .textStyle(textStyle, weight):
                return .systemFont(textStyle).weight(weight)
            }
        }
        var nsUIFont: NSUIFont { nsFont }
        #else
        /// `UIFont` representation of the font.
        public var uiFont: UIFont {
            switch self {
            case let .size(size, weight):
                return .systemFont(ofSize: size, weight: weight.fontWeight())
            case let .textStyle(textStyle, weight):
                return .systemFont(textStyle).weight(weight.fontWeight())
            }
        }
        var nsUIFont: NSUIFont { uiFont }
        #endif
    }

    /// Constants that indicate which scale variant of a symbol image to use.
    public enum SymbolScale: Int, Hashable, Codable {
        /// The default scale variant that matches the system usage.
        case `default` = 0
        /// A scale that produces small images.
        case small
        /// A scale that produces medium-sized images.
        case medium
        /// A scale that produces large images.
        case large
        
        // .default, .unspecified, .medium, .large]
        
        var nsUI: NSUIImage.SymbolScale {
            .init(rawValue: rawValue)!
        }

        #if os(macOS)
            /// `NSImage.SymbolScale` representation of the scale.
            public var nsSymbolScale: NSUIImage.SymbolScale {
                nsUI
            }
        #else
        /// `UIImage.SymbolScale` representation of the scale.
            public var uiSymbolScale: NSUIImage.SymbolScale {
                nsUI
            }
        #endif

        /// SwiftUI `Image.Scale` representation of the scale.
        public var swiftui: SwiftUI.Image.Scale {
            switch self {
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            case .default: return .medium
            }
        }
    }
    
    /// The configuration of the color.
    public struct ColorConfiguration: Hashable, Codable {
        enum Mode: Int, Hashable, Codable {
            case monochrome = 1
            case hierarchical
            case palette
            @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
            case multicolor = 10
        }
        
        var renderingMode: SwiftUI.SymbolRenderingMode {
            switch mode {
            case .palette: return .palette
            case .monochrome: return .monochrome
            case .multicolor: return .multicolor
            case .hierarchical: return .hierarchical
            }
        }
        
        var mode: Mode = .monochrome
        var primary: NSUIColor? { colors[safe: 0] }
        var secondary: NSUIColor? { colors[safe: 1] }
        var tertiary: NSUIColor? { colors[safe: 2] }
        
        /// The colors of the color configuration.
        public internal(set) var colors: [NSUIColor] = []
        
        init(_ mode: Mode, _ primary: NSUIColor? = nil, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) {
            self.mode = mode
            colors = [primary, secondary, tertiary].nonNil
        }
        
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        var symbolConfiguration: NSUIImage.SymbolConfiguration {
            switch mode {
            case .monochrome:
                if let primary = primary {
                    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                        return .init(paletteColors: [primary]) + .preferringMonochrome()
                    } else {
                        return .init(paletteColors: [primary])
                    }
                } else if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                    return .preferringMonochrome()
                }
                return .unspecified
            case .hierarchical:
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                    #if os(macOS)
                    if let primary = primary {
                        return NSUIImage.SymbolConfiguration(hierarchicalColor: primary)
                    } else {
                        return .preferringHierarchical()
                    }
                    #else
                    return NSUIImage.SymbolConfiguration(hierarchicalColor: primary!)
                    #endif
                }
                return .unspecified
            case .palette:
                    if let secondary = secondary {
                        if let tertiary = tertiary {
                            return .init(paletteColors: [primary!, secondary, tertiary])
                        }
                        return .init(paletteColors: [primary!, secondary])
                    }
                    return .init(paletteColors: [primary!])
            case .multicolor:
                if let primary = primary {
                    return .init(paletteColors: [primary]) + .preferringMulticolor()
                } else {
                    return .preferringMulticolor()
                }
            }
        }
        
        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        /// Monochrome.
        public static var monochrome: Self {
            ColorConfiguration(.monochrome)
        }
        
        /// Monochrome with the specified color.
        public static func monochrome(_ color: NSUIColor) -> Self {
            ColorConfiguration(.monochrome, color)
        }
        
        #if os(macOS)
        @available(macOS 13.0, *)
        /// Hierarchical.
        public static var hierarchical: Self {
            ColorConfiguration(.hierarchical)
        }
        #endif
        
        /// Hierarchical with the specified color.
        public static func hierarchical(_ color: NSUIColor) -> Self {
            ColorConfiguration(.hierarchical, color)
        }
        
        /// Palette with the specified primary, secondary and tertiary color.
        public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor, _ tertiary: NSUIColor? = nil) -> Self {
            ColorConfiguration(.palette, primary, secondary, tertiary)
        }
        
        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        /// Multicolor.
        public static var multicolor: Self {
            ColorConfiguration(.multicolor)
        }
        
        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        /// Multicolor with the specified primary, secondary and tertiary color.
        public static func multicolor(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> Self {
            ColorConfiguration(.multicolor, primary, secondary, tertiary)
        }
    }

    #if os(macOS)
    /// `NSImage.SymbolConfiguration` representation of the symbol configuration.
    public func nsSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
        nsUI()
    }

    #elseif canImport(UIKit)
        /// `UIImage.SymbolConfiguration` representation of the symbol configuration.
    public func uiSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
        nsUI()
    }
    #endif
    
    func nsUI() -> NSUIImage.SymbolConfiguration {
        var configuration = resolvedColor()?.symbolConfiguration
        
        if let _configuration = font?.symbolConfiguration {
            configuration = configuration?.applying(_configuration) ?? _configuration
        }
    
        if let symbolScale = scale?.nsUI {
            if let _configuration = configuration, font == nil {
                configuration = _configuration.scale(symbolScale)
            } else if configuration == nil {
                configuration = .init(scale: symbolScale)
            }
        }
        return configuration ?? .unspecified
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
@available(macOS 13.0, iOS 15.0, tvOS 15.0, *)
public extension NSUIImageView {
    #if os(macOS)
    /// The configuration values to use when rendering the image.
    var imageSymbolConfiguration: ImageSymbolConfiguration? {
        get { 
            guard let configuration = symbolConfiguration else { return nil }
            return .init(symbolConfiguration: configuration)
        }
        set { symbolConfiguration = newValue?.nsUI() }
    }

    #else
    /// The configuration values to use when rendering the image.
    var preferredImageSymbolConfiguration: ImageSymbolConfiguration? {
        get { getAssociatedValue("_imageSymbolConfiguration") }
        set {
            setAssociatedValue(newValue, key: "_imageSymbolConfiguration")
            preferredSymbolConfiguration = newValue?.nsUI()
        }
    }
    #endif
}

#endif

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension View {
    /**
     Configurates symbol images within this view.

     - Parameters:
        - tintColor: The tint color of the symbol images.
     - configuration: The configuration for the symbol images.
     */
    @ViewBuilder func symbolConfiguration(tintColor: Color?, configuration: ImageSymbolConfiguration?) -> some View {
        if let configuration = configuration {
            imageScale(configuration.scale?.swiftui)
                .symbolRenderingMode(configuration.color?.renderingMode)
                .foregroundStyle(tintColor ?? configuration.color?.primary?.swiftUI, configuration.color?.secondary?.swiftUI, configuration.color?.tertiary?.swiftUI)
                .font(configuration.font?.nsUIFont.swiftUI)
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
            imageScale(configuration.scale?.swiftui)
                .symbolRenderingMode(configuration.color?.renderingMode)
                .foregroundStyle(configuration.color?.primary?.swiftUI, configuration.color?.secondary?.swiftUI, configuration.color?.tertiary?.swiftUI)
                .font(configuration.font?.nsUIFont.swiftUI)
        } else {
            self
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension NSUIImageView {
    /// Configurates the image view with the specified symbol configuration.
    func configurate(using configuration: ImageSymbolConfiguration) {
        #if os(macOS)
            symbolConfiguration = configuration.nsUI()
        contentTintColor = configuration.resolvedColor()?.primary ?? contentTintColor
        #elseif canImport(UIKit)
            preferredSymbolConfiguration = configuration.nsUI()
        tintColor = configuration.resolvedColor()?.primary ?? tintColor
        #endif
    }
}
#endif

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
}

@available(macOS 11.0, *)
extension NSUIImage.SymbolConfiguration {
    /// Creates a configuration  with a body font configuration.
    static var body: NSUIImage.SymbolConfiguration { .init(textStyle: .body) }
    
    /// Creates a configuration with a callout font configuration.
    static var callout: NSUIImage.SymbolConfiguration { .init(textStyle: .callout) }
    
    /// Creates a configuration with a caption font configuration.
    static var caption1: NSUIImage.SymbolConfiguration { .init(textStyle: .caption1) }
    
    /// Creates a configuration with a alternate caption font configuration.
    static var caption2: NSUIImage.SymbolConfiguration { .init(textStyle: .caption2) }
    
    /// Creates a configuration with a footnote font configuration.
    static var footnote: NSUIImage.SymbolConfiguration { .init(textStyle: .footnote) }
    
    /// Creates a configuration with a headline font configuration.
    static var headline: NSUIImage.SymbolConfiguration { .init(textStyle: .headline) }
    
    /// Creates a configuration with a subheadline font configuration.
    static var subheadline: NSUIImage.SymbolConfiguration { .init(textStyle: .subheadline) }
    
    #if os(macOS)
    /// Creates a configuration with a large title font configuration.
    static var largeTitle: NSUIImage.SymbolConfiguration { .init(textStyle: .largeTitle) }
    #endif
    
    /// Creates a configuration with a first-level title font configuration.
    static var title1: NSUIImage.SymbolConfiguration { .init(textStyle: .title1) }
    
    /// Creates a configuration with a second-level title font configuration.
    static var title2: NSUIImage.SymbolConfiguration { .init(textStyle: .title2) }
    
    /// Creates a configuration with a third-level title font configuration.
    static var title3: NSUIImage.SymbolConfiguration { .init(textStyle: .title3) }
    
    /*
    @available(macOS 12.0, *)
    static func monochrome(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .color(.monochrome(color))
    }
    
    
    @available(macOS 12.0, *)
    static func multicolor(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .color(.multicolor(color))
    }
     */
    
    /*
     /// Creates a configuration with a monochrome color using the tint color.
     @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
     public static var monochrome: Self {
         Self(color: .monochrome)
     }

     /// Creates a configuration with a monochrome color using the specified color.
     public static func monochrome(_ color: NSUIColor) -> Self {
         Self(color: .monochrome(color))
     }
     
     #if os(macOS)
     /// Creates a configuration with a hierarchical color using the tint color.
     @available(macOS 13.0, *)
     public static var hierarchical: Self {
         Self(color: .hierarchical)
     }
     #endif
     
     /// Creates a configuration with a hierarchical color with the specified color.
     public static func hierarchical(_ color: NSUIColor) -> Self {
         Self(color: .hierarchical(color))
     }
     
     /// Creates a configuration with a multicolor color using the tint color.
     @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
     public static var multicolor: Self {
         Self(color: .multicolor)
     }

     /// Creates a configuration with a multicolor color with the specified color.
     @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
     public static func multicolor(_ color: NSUIColor) -> Self {
         Self(color: .multicolor(color))
     }

     /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
     public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor, _ tertiary: NSUIColor? = nil) -> Self {
         Self(color: .palette(primary, secondary, tertiary))
     }
     */
}
