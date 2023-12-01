//
//  ContentConfiguration+SymbolConfiguration.swift
//  
//
//  Created by Florian Zand on 03.06.23.
//


#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension ContentConfiguration {
    /**
     An object that contains font, color, and image scale attributes to apply to an object with a symbol image.
     
     `NSImageView/UIImageView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.SymbolConfiguration)`.
     
     `NSImage` can be configurated via `withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration)`.
`
     `UIImage` can be configurated via `applyingSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration)`.
     */
    struct SymbolConfiguration: Hashable {
        /// The font of the symbol configuration.
        public var font: FontConfiguration? = nil
        
        /// The color configuration of the symbol configuration.
        public var color: ColorConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the color style.
        public var colorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// The image scaling of the symbol configuration.
        public var imageScale: ImageScale? = nil
        
        /// Sets the font of the symbol configuration.
        @discardableResult
        public func font(_ font: FontConfiguration?) -> Self {
            var configuration = self
            configuration.font = font
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
            newConfiguration.colorTransform = transformer
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
         Creates a symbol configuration.
         
         - Parameters:
            - font: The font.
            - color: The color configuration.
            - colorTransform: The color transformer.
            - imageScale: The image scaling.
         
         - Returns: a symbol configuration object.
         */
        public init(font: FontConfiguration? = nil, color: ColorConfiguration? = nil, colorTransform: ColorTransformer? = nil, imageScale: ImageScale? = nil) {
            self.font = font
            self.color = color
            self.colorTransform = colorTransform
            self.imageScale = imageScale
            self.updateResolvedColors()
        }
        
        /// Creates a configuration with a monochrome color configuration.
        public static var monochrome: SymbolConfiguration {
            SymbolConfiguration(color: .monochrome)
        }
        
        /// Creates a configuration with a hierarchical color configuration with the specified color.
        public static func hierarchical(_ color: NSUIColor) -> SymbolConfiguration {
            SymbolConfiguration(color: .hierarchical(color))
        }
        
        /// Creates a configuration with a multicolor configuration with the specified color.
        public static func multicolor(_ color: NSUIColor) -> SymbolConfiguration {
            SymbolConfiguration(color: .multicolor(color))
        }
        
        /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
        public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor, _ tertiary: NSUIColor? = nil) -> SymbolConfiguration {
            SymbolConfiguration(color: .palette(primary, secondary, tertiary))
        }
        
        /// Creates a configuration with the specified font style and weight.
        public static func font(_ style: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> SymbolConfiguration {
            SymbolConfiguration(font: .textStyle(style, weight:  weight, design: design))
        }
        
        /// Creates a configuration with the specified font size and weight.
        public static func font(size: CGFloat, weight: NSUIImage.SymbolWeight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> SymbolConfiguration {
            SymbolConfiguration(font: .systemFont(size: size, weight: weight, design: design))
        }
        
        /// Creates a configuration with the specified image scale.
        public static func imageScale(_ imageScale: ImageScale) -> SymbolConfiguration {
            SymbolConfiguration(imageScale: imageScale)
        }
        
        /// Generates the resolved primary color for the specified color style, using the color style and color transformer.
        public func resolvedPrimaryColor() -> NSUIColor? {
            if let primary = self.color?.primary {
                return self.colorTransform?(primary) ?? primary
            }
            return nil
        }
        
        /// Generates the resolved secondary color for the specified color style, using the color style and color transformer.
        public func resolvedSecondaryColor() -> NSUIColor? {
            if let secondary = self.color?.secondary {
                return self.colorTransform?(secondary) ?? secondary
            }
            return nil
        }
        
        /// Generates the resolved tertiary color for the specified color style, using the color style and color transformer.
        public func resolvedTertiaryColor() -> NSUIColor? {
            if let tertiary = self.color?.tertiary {
                return self.colorTransform?(tertiary) ?? tertiary
            }
            return nil
        }
        
        internal var _resolvedPrimaryColor: NSUIColor? = nil
        internal var _resolvedSecondaryColor: NSUIColor? = nil
        internal var _resolvedTertiaryColor: NSUIColor? = nil
        internal mutating func updateResolvedColors() {
            _resolvedPrimaryColor = resolvedPrimaryColor()
            _resolvedSecondaryColor = resolvedSecondaryColor()
            _resolvedTertiaryColor = resolvedTertiaryColor()
        }
        
        /// The font of a symbol image.
        public enum FontConfiguration: Hashable {
            /// A font with the specified point size and font weight.
            case systemFont(size: CGFloat, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)
            
            /// A font with the specified text style and font weight.
            case textStyle(NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)
            
            /// Sets the weight of the font.
            @discardableResult
            public func weight(_ weight: NSUIImage.SymbolWeight?) -> Self {
                switch self {
                case .systemFont(let size, _, let design):
                    return .systemFont(size: size, weight: weight, design: design)
                case .textStyle(let style, _, let design):
                    return .textStyle(style, weight: weight, design: design)
                }
            }
            
            /// Sets the design of the font.
            @discardableResult
            public func design(_ design: NSUIFontDescriptor.SystemDesign) -> Self {
                switch self {
                case .systemFont(let size, let weight, _):
                    return .systemFont(size: size, weight: weight, design: design)
                case .textStyle(let style, let weight, _):
                    return .textStyle(style, weight: weight, design: design)
                }
            }
            
            /// The font you use for body text.
            public static var body: Self { Self.textStyle(.body) }
            /// The font you use for callouts.
            public static var callout: Self { Self.textStyle(.callout) }
            /// The font you use for standard captions.
            public static var caption1: Self { Self.textStyle(.caption1) }
            /// The font you use for alternate captions.
            public static var caption2: Self { Self.textStyle(.caption2) }
            /// The font you use in footnotes.
            public static var footnote: Self { Self.textStyle(.footnote) }
            /// The font you use for headings.
            public static var headline: Self { Self.textStyle(.headline) }
            /// The font you use for subheadings.
            public static var subheadline: Self { Self.textStyle(.subheadline) }
            #if os(macOS) || os(iOS)
            /// The font you use for large titles.
            public static var largeTitle: Self { Self.textStyle(.largeTitle) }
            #endif
            /// The font you use for first-level hierarchical headings.
            public static var title1: Self { Self.textStyle(.title1) }
            /// The font you use for second-level hierarchical headings.
            public static var title2: Self { Self.textStyle(.title2) }
            /// The font you use for third-level hierarchical headings.
            public static var title3: Self { Self.textStyle(.title3) }
            
            internal var swiftui: Font {
                switch self {
                case .textStyle(let style, weight: let weight, design: let design):
                    return Font.system(style.swiftUI, design: design.swiftUI).weight(weight?.swiftUI ?? .regular)
                case .systemFont(size: let size, weight: let weight, design: let design):
                    return Font.system(size: size, design: design.swiftUI).weight(weight?.swiftUI ?? .regular)
                }
            }
        }
        
        /// Constants that specify which symbol image scale.
        public enum ImageScale: Hashable {
            /// A scale that produces small images.
            case small
            /// A scale that produces medium-sized images.
            case medium
            /// A scale that produces large images.
            case large
            
            internal var nsSymbolScale: NSUIImage.SymbolScale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
            
            internal var swiftui: SwiftUI.Image.Scale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
        }
        
        /// Constants that specify the color configuration of a symbol image.
        public enum ColorConfiguration: Hashable {
            /// A color configuration by specifying a palette of colors.
            case palette(NSUIColor, NSUIColor, NSUIColor? = nil)
            ///  A monochrome color configuration using the content tint color.
            case monochrome
            ///  A multicolor color configuration using the color you specify as primary color.
            case multicolor(NSUIColor)
            ///  A hierarchical color configuration using the color you specify.
            case hierarchical(NSUIColor)
            
            internal var renderingMode: SwiftUI.SymbolRenderingMode {
                switch self {
                case .palette(_, _, _): return .palette
                case .monochrome: return .monochrome
                case .multicolor(_): return .multicolor
                case .hierarchical(_): return .hierarchical
                }
            }
            
            internal var primary: NSUIColor? {
                switch self {
                case .palette(let primary, _, _):
                    return primary
                case .multicolor(let primary):
                    return primary
                case .hierarchical(let primary):
                    return primary
                case .monochrome:
                    return nil
                }
            }
            
            internal var secondary: NSUIColor? {
                switch self {
                case .palette(_, let secondary, _):
                    return secondary
                default:
                    return nil
                }
            }
            
            internal var tertiary: NSUIColor? {
                switch self {
                case .palette(_, _, let tertiary):
                    return tertiary
                default:
                    return nil
                }
            }
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension ContentConfiguration.SymbolConfiguration {
    #if os(macOS)
    /// Returns a `NSImage.SymbolConfiguration` representation.
    func nsSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
        return self.nsUI()
    }
    #elseif canImport(UIKit)
    /// Returns a `UIImage.SymbolConfiguration` representation.
    func uiSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
        return self.nsUI()
    }
    #endif
    internal func nsUI() -> NSUIImage.SymbolConfiguration {
        var configuration: NSUIImage.SymbolConfiguration
        switch self.color {
        case .hierarchical(let color):
            configuration = .hierarchical(color)
        case .monochrome:
            configuration = .monochrome()
        case .palette(let primary, let secondary, let tertiary):
            configuration = .palette(primary, secondary, tertiary)
        case .multicolor(let color):
            configuration = .multicolor(color)
        case .none:
            #if os(macOS)
            configuration = .init()
            #else
            configuration = .unspecified
            #endif
        }
        
        switch self.font {
        case .systemFont(size: let size, weight: let weight, design: _):
                configuration = configuration.font(size: size)
                configuration = configuration.weight(weight)
        case .textStyle(let style, weight: let weight, design: _):
                configuration = configuration.font(style)
                configuration = configuration.weight(weight)
            case .none:
                break
        }
        
        if let symbolScale = self.imageScale?.nsSymbolScale {
            configuration = configuration.scale(symbolScale)
        }
        
        return configuration
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension View {
    /**
     Configurates symbol images within this view.

     - Parameters:
        - tintColor: The tint color of the symbol images.
     - configuration: The configuration for the symbol images.
     */
    @ViewBuilder func symbolConfiguration(tintColor: Color?, configuration: ContentConfiguration.SymbolConfiguration?) -> some View {
        if let configuration = configuration {
            self
                .imageScale(configuration.imageScale?.swiftui)
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
    @ViewBuilder func symbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration?) -> some View {
        if let configuration = configuration {
            self
                .imageScale(configuration.imageScale?.swiftui)
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
    func configurate(using configuration: ContentConfiguration.SymbolConfiguration) {
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

#if os(macOS)
@available(macOS 12.0, *)
public extension NSImage {
    /// Creates a new symbol image with the specified configuration.
    func withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSImage? {
        withSymbolConfiguration(configuration.nsUI())
    }
}
#elseif canImport(UIKit)
@available(iOS 16.0, tvOS 16.0, watchOS 8.0, *)
public extension UIImage {
    /// Returns a new version of the current image, replacing the current configuration attributes with the specified attributes.
    func withConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSUIImage? {
        withConfiguration(configuration.nsUI())
    }
    
    /// Returns a new version of the current image, applying the specified configuration attributes on top of the current attributes.
    func applyingSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSUIImage? {
        applyingSymbolConfiguration(configuration.nsUI())
    }
}
#endif
