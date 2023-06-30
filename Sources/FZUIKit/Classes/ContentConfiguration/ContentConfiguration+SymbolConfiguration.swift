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

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration {
    /// An object that contains the specific font, style, and weight attributes to apply to a item symbol image.
    struct SymbolConfiguration: Hashable {
        /// The font for the symbol configuration.
        public var font: FontConfiguration? = nil
        
        /// The color configuration of the symbol configuration.
        public var colorConfiguration: ColorConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
        /// The image scaling of the symbol configuration.
        public var imageScale: ImageScale? = nil
        
        public func imageScale(_ scale: ImageScale?) -> Self {
            var configuration = self
            configuration.imageScale = imageScale
            return configuration
        }
        
        public func font(_ font: FontConfiguration?) -> Self {
            var configuration = self
            configuration.font = font
            return configuration
        }
        
        public func colorConfiguration(_ configuration: ColorConfiguration?) -> Self {
            var newConfiguration = self
            newConfiguration.colorConfiguration = configuration
            return newConfiguration
        }
        
        /// The color transformer for resolving the color style.
        public var colorTransform: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        public init(font: FontConfiguration? = nil, colorConfiguration: ColorConfiguration? = nil, imageScale: ImageScale? = nil, colorTransform: NSUIConfigurationColorTransformer? = nil) {
            self.font = font
            self.colorConfiguration = colorConfiguration
            self.imageScale = imageScale
            self.colorTransform = colorTransform
            self.updateResolvedColors()
        }
        
        
        /// Creates a configuration with a monochrome color configuration.
        public static func monochrome() -> SymbolConfiguration {
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
            SymbolConfiguration(font: .systemFont(size: size, weight: weight))
        }
        
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
        
        /// Constants that specify the font of a symbol image.
        public enum FontConfiguration: Hashable {
            /// A font with the specified point size and font weight.
            case systemFont(size: CGFloat, weight: NSUIImage.SymbolWeight? = nil)
            /// A font with the specified text style and font weight.
            case textStyle(NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil)
            internal var swiftui: Font {
                switch self {
                case .textStyle(let style, weight: let weight):
                    return Font.system(style.swiftUI).weight(weight?.swiftUI ?? .regular)
                case .systemFont(size: let size, weight: let weight):
                    return Font.system(size: size).weight(weight?.swiftUI ?? .regular)
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
            ///  A monochrome color configuration using the color you specify.
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
internal extension ContentConfiguration.SymbolConfiguration {
    func nsSymbolConfiguration() -> NSUIImage.SymbolConfiguration {
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
            configuration = .unspecified
        }
        
        switch self.font {
            case .systemFont(size: let size, weight: let weight):
                configuration = configuration.font(size: size)
                configuration = configuration.weight(weight)
            case .textStyle(let style, weight: let weight):
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
internal extension View {
    @ViewBuilder func symbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration?) -> some View {
        if let configuration = configuration {
            self
                .symbolRenderingMode(configuration.colorConfiguration?.renderingMode)
                .foregroundStyle(configuration.colorConfiguration?.primary?.swiftUI, configuration.colorConfiguration?.secondary?.swiftUI, configuration.colorConfiguration?.tertiary?.swiftUI)
                .imageScale(configuration.imageScale?.swiftui)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }
}

#if os(macOS)
@available(macOS 12.0, *)
public extension NSImageView {
    func configurate(using configuration: ContentConfiguration.SymbolConfiguration) {
        symbolConfiguration = configuration.nsSymbolConfiguration()
        if let primary = configuration._resolvedPrimaryColor {
            contentTintColor = primary
        }
    }
}

@available(macOS 12.0, *)
public extension NSImage {
    func withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSImage? {
        if let image = withSymbolConfiguration(configuration.nsSymbolConfiguration()) {
            return image
        }
        return nil
    }
}

#elseif canImport(UIKit)
@available(iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension UIImageView {
    func configurate(using configuration: ContentConfiguration.SymbolConfiguration) {
        preferredSymbolConfiguration = configuration.nsSymbolConfiguration()
        if let primary = configuration._resolvedPrimaryColor {
            tintColor = primary
        }
    }
}

@available(iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension UIImage {
    func applyingSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSUIImage? {
        if let image = applyingSymbolConfiguration(configuration.nsSymbolConfiguration()) {
            return image
        }
        return nil
    }
}
#endif
