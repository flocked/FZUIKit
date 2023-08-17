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

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration {
    /**
     An object that contains font, color, and image scale attributes to apply to an object with a symbol image.
     
     On AppKit `NSImageView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.SymbolConfiguration)`.
     A configuration can also be applied to a `NSImage` via `withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration)`.
`
     On UIKit `UIImageView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.SymbolConfiguration)`.
     A configuration can also be applied to a `UIImage` via `applyingSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration)`.
     */
    struct SymbolConfiguration: Hashable {
        /// The font of the symbol configuration.
        public var font: FontConfiguration? = nil
        
        /// The color configuration of the symbol configuration.
        public var colorConfiguration: ColorConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the color style.
        public var colorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// The image scaling of the symbol configuration.
        public var imageScale: ImageScale? = nil
        
        /// Sets the font of the symbol configuration.
        public func font(_ font: FontConfiguration?) -> Self {
            var configuration = self
            configuration.font = font
            return configuration
        }
        
        /// Sets the color configuration of the symbol configuration.
        public func colorConfiguration(_ configuration: ColorConfiguration?) -> Self {
            var newConfiguration = self
            newConfiguration.colorConfiguration = configuration
            return newConfiguration
        }
        
        /// Sets the color transformer of the symbol configuration.
        public func colorTransformer(_ transformer: ColorTransformer?) -> Self {
            var newConfiguration = self
            newConfiguration.colorTransform = transformer
            return newConfiguration
        }
        
        /// Sets the image scale of the symbol configuration.
        public func imageScale(_ scale: ImageScale?) -> Self {
            var configuration = self
            configuration.imageScale = scale
            return configuration
        }
        
        /**
         Creates a symbol configuration.
         
         - Parameters:
            - font: The font.
            - colorConfiguration: The color configuration.
            - colorTransform: The color transformer.
            - imageScale: The image scaling.
         
         - Returns: a symbol configuration object.
         */
        public init(font: FontConfiguration? = nil, colorConfiguration: ColorConfiguration? = nil, colorTransform: ColorTransformer? = nil, imageScale: ImageScale? = nil) {
            self.font = font
            self.colorConfiguration = colorConfiguration
            self.colorTransform = colorTransform
            self.imageScale = imageScale
            self.updateResolvedColors()
        }
        
        /// Creates a configuration with a monochrome color configuration.
        public static var monochrome: SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .monochrome)
        }
        
        /// Creates a configuration with a hierarchical color configuration with the specified color.
        public static func hierarchical(_ color: NSUIColor) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .hierarchical(color))
        }
        
        /// Creates a configuration with a multicolor configuration with the specified color.
        public static func multicolor(_ color: NSUIColor) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .multicolor(color))
        }
        
        /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
        public static func palette(_ primary: NSUIColor, secondary: NSUIColor, tertiary: NSUIColor? = nil) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .palette(primary, secondary, tertiary))
        }
        
        /// Creates a configuration with the specified font style and weight.
        public static func font(_ style: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight = .regular) -> SymbolConfiguration {
            SymbolConfiguration(font: .textStyle(style, weight:  weight))
        }
        
        /// Creates a configuration with the specified font size and weight.
        public static func font(size: CGFloat, weight: NSUIImage.SymbolWeight = .regular) -> SymbolConfiguration {
            SymbolConfiguration(font: .system(size: size, weight: weight))
        }
        
        /*
        /// The font you use for body text.
        public static var body: Self { Self.font(.body) }
        /// The font you use for callouts.
        public static var callout: Self { Self.font(.callout) }
        /// The font you use for standard captions.
        public static var caption1: Self { Self.font(.caption1) }
        /// The font you use for alternate captions.
        public static var caption2: Self { Self.font(.caption2) }
        /// The font you use in footnotes.
        public static var footnote: Self { Self.font(.footnote) }
        /// The font you use for headings.
        public static var headline: Self { Self.font(.headline) }
        /// The font you use for subheadings.
        public static var subheadline: Self { Self.font(.subheadline) }
        /// The font you use for large titles.
        public static var largeTitle: Self { Self.font(.largeTitle) }
        /// The font you use for first-level hierarchical headings.
        public static var title1: Self { Self.font(.title1) }
        /// The font you use for second-level hierarchical headings.
        public static var title2: Self { Self.font(.title2) }
        /// The font you use for third-level hierarchical headings.
        public static var title3: Self { Self.font(.title3) }
        */
        /*
        
        /// The font you use for body text.
        public var body: Self {
            var configuration = self
            configuration.font = .body
            return configuration
        }
        /// The font you use for callouts.
        public var callout: Self {
            var configuration = self
            configuration.font = .callout
            return configuration
        }
        /// The font you use for standard captions.
        public var caption1: Self {
            var configuration = self
            configuration.font = .caption1
            return configuration
        }
        /// The font you use for alternate captions.
        public var caption2: Self {
            var configuration = self
            configuration.font = .caption2
            return configuration
        }
        /// The font you use in footnotes.
        public var footnote: Self {
            var configuration = self
            configuration.font = .footnote
            return configuration
        }
        /// The font you use for headings.
        public var headline: Self {
            var configuration = self
            configuration.font = .headline
            return configuration
        }
        /// The font you use for subheadings.
        public var subheadline: Self {
            var configuration = self
            configuration.font = .subheadline
            return configuration
        }
        /// The font you use for large titles.
        public var largeTitle: Self {
            var configuration = self
            configuration.font = .largeTitle
            return configuration
        }
        /// The font you use for first-level hierarchical headings.
        public var title1: Self {
            var configuration = self
            configuration.font = .title1
            return configuration
        }
        /// The font you use for second-level hierarchical headings.
        public var title2: Self {
            var configuration = self
            configuration.font = .title2
            return configuration
        }
        /// The font you use for third-level hierarchical headings.
        public var title3: Self {
            var configuration = self
            configuration.font = .title3
            return configuration
        }
                
        /// Sets the font of the symbol configuration.
        public func fontWeight(weight: NSUIImage.SymbolWeight?) -> Self {
            var configuration = self
            configuration.font = configuration.font?.weight(weight)
            return configuration
        }
        
        /// Sets the font of the symbol configuration.
        public func fontDesign(_ design: NSUIFontDescriptor.SystemDesign) -> Self {
            var configuration = self
            configuration.font = configuration.font?.design(design)
            return configuration
        }
        */
        
        /// Generates the resolved primary color for the specified color style, using the color style and color transformer.
        public func resolvedPrimaryColor() -> NSUIColor? {
            if let primary = self.colorConfiguration?.primary {
                return self.colorTransform?(primary) ?? primary
            }
            return nil
        }
        
        /// Generates the resolved secondary color for the specified color style, using the color style and color transformer.
        public func resolvedSecondaryColor() -> NSUIColor? {
            if let secondary = self.colorConfiguration?.secondary {
                return self.colorTransform?(secondary) ?? secondary
            }
            return nil
        }
        
        /// Generates the resolved tertiary color for the specified color style, using the color style and color transformer.
        public func resolvedTertiaryColor() -> NSUIColor? {
            if let tertiary = self.colorConfiguration?.tertiary {
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
            case system(size: CGFloat, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)
            
            /// A font with the specified text style and font weight.
            case textStyle(NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil, design: NSUIFontDescriptor.SystemDesign = .default)
            
            /// Sets the weight of the font.
            public func weight(_ weight: NSUIImage.SymbolWeight?) -> Self {
                switch self {
                case .system(let size, _, let design):
                    return .system(size: size, weight: weight, design: design)
                case .textStyle(let style, _, let design):
                    return .textStyle(style, weight: weight, design: design)
                }
            }
            
            /// Sets the design of the font.
            public func design(_ design: NSUIFontDescriptor.SystemDesign) -> Self {
                switch self {
                case .system(let size, let weight, _):
                    return .system(size: size, weight: weight, design: design)
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
            /// The font you use for large titles.
            public static var largeTitle: Self { Self.textStyle(.largeTitle) }
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
                case .system(size: let size, weight: let weight, design: let design):
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

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration.SymbolConfiguration {
    func nsUI() -> NSUIImage.SymbolConfiguration {
        var configuration: NSUIImage.SymbolConfiguration
        switch self.colorConfiguration {
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
        case .system(size: let size, weight: let weight, design: _):
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

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
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
                .symbolRenderingMode(configuration.colorConfiguration?.renderingMode)
                .foregroundStyle(tintColor ?? configuration.colorConfiguration?.primary?.swiftUI, configuration.colorConfiguration?.secondary?.swiftUI, configuration.colorConfiguration?.tertiary?.swiftUI)
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
                .symbolRenderingMode(configuration.colorConfiguration?.renderingMode)
                .foregroundStyle(configuration.colorConfiguration?.primary?.swiftUI, configuration.colorConfiguration?.secondary?.swiftUI, configuration.colorConfiguration?.tertiary?.swiftUI)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }
}

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

#if os(macOS)
@available(macOS 12.0, *)
public extension NSImage {
    /// Creates a new symbol image with the specified configuration.
    func withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSImage? {
        withSymbolConfiguration(configuration.nsUI())
    }
}
#elseif canImport(UIKit)
@available(iOS 16.0, tvOS 16.0, watchOS 7.0, *)
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

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
extension ContentConfiguration.SymbolConfiguration: KeyValueCodable {
    public func value(for key: String) -> Any? {
        switch key {
        case "_resolvedPrimaryColor": return _resolvedPrimaryColor
        case "_resolvedSecondaryColor": return _resolvedSecondaryColor
        case "_resolvedTertiaryColor": return _resolvedTertiaryColor
        case "nsUI": return nsUI()
        default: return nil
        }
    }
}
