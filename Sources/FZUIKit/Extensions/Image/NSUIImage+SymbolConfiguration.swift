//
//  NSUIImage+SymbolConfiguration.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    /// Returns the symbol configuration with the specified text style.
    func font(_ textStyle: NSUIFont.TextStyle?) -> NSUIImage.SymbolConfiguration {
        if let textStyle = textStyle {
            return applying(NSUIImage.SymbolConfiguration.textStyle(textStyle))
        } else {
            let configuration = self
            configuration.textStyle = nil
            configuration.pointSize = 0.0
            configuration.weight = .unspecified
            return configuration
        }
    }

    /// Returns the symbol configuration with the specified text style, symbol weight, and symbol scale.
    func font(_ textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        return applying(Self.textStyle(textStyle, weight: weight, scale: scale))
    }

    /// Returns the symbol configuration with a system font with the specified point size, symbol weight and symbol scale.
    func font(size: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        let configuration: NSUIImage.SymbolConfiguration = .systemFont(size, weight: weight, scale: scale)
        return applying(configuration)
    }

    /// Returns the symbol configuration with the specified symbol scale.
    func scale(_ scale: NSUIImage.SymbolScale?) -> NSUIImage.SymbolConfiguration {
        let configuration = self
        configuration.scale = scale
        return configuration
    }

    /// Returns the symbol configuration with the specified symbol weight.
    func weight(_ weight: NSUISymbolWeight?) -> NSUIImage.SymbolConfiguration {
        let configuration = self
        configuration.weight = weight
        return configuration
    }

    /// Returns the symbol configuration with a monochrome color configuration.
    func monochrome() -> NSUIImage.SymbolConfiguration {
        let configuration = applying(NSUIImage.SymbolConfiguration.monochrome())
        configuration.colors = nil
        #if os(macOS)
        configuration.prefersMulticolor = false
        #endif
        return configuration
    }

    /// Returns the symbol configuration with a multicolor configuration.
    func multicolor(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        let configuration: NSUIImage.SymbolConfiguration = .multicolor(color)
        return applying(configuration)
    }

    /// Returns the symbol configuration with a hierarchical color configuration.
    func hierarchical(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        let configuration = applying(NSUIImage.SymbolConfiguration.hierarchical(color))
        #if os(macOS)
        configuration.prefersMulticolor = false
        #endif
        return configuration
    }

    /// Returns the symbol configuration with a palette color configuration-
    func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        let configuration = applying(NSUIImage.SymbolConfiguration.palette(primary, secondary, tertiary))
        #if os(macOS)
        configuration.prefersMulticolor = false
        #endif
        return configuration
    }

    /// A symbol configuration with the specified text style, symbol weight and symbol scale.
    static func textStyle(_ textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        if weight != .regular {
            return Self(textStyle: textStyle, scale: scale).weight(weight)
        }
        return Self(textStyle: textStyle, scale: scale)
    }

    /// A symbol configuration with system font with specified point size, symbol weight, and symbol scale.
    static func systemFont(_ pointSize: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        Self(pointSize: pointSize, weight: weight, scale: scale)
    }

    /// A symbol configuration with the specified symbol scale.
    static func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        Self(scale: scale)
    }
    
    /// A symbol configuration with the image symbol configuration.
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
    static func configuration(_ configuration: ImageSymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        return configuration.nsUI()
    }

    /// A monochrome symbol configuration.
    static func monochrome() -> NSUIImage.SymbolConfiguration {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return NSUIImage.SymbolConfiguration.preferringMonochrome()
        } else {
            #if os(macOS)
                return NSUIImage.SymbolConfiguration()
            #else
                return .unspecified
            #endif
        }
    }
    

    /// A multicolor symbol configuration with the specified color.
    static func multicolor(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        NSUIImage.SymbolConfiguration.preferringMulticolor().applying(NSUIImage.SymbolConfiguration.palette(color))
    }

    /// A hierarchical symbol configuration with the specified color.
    static func hierarchical(_ primary: NSUIColor) -> NSUIImage.SymbolConfiguration {
        Self(hierarchicalColor: primary)
    }

    /// A palette symbol configuration with the specified colors.
    static func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        Self(paletteColors: [primary, secondary, tertiary].compactMap { $0 })
    }

    /// A symbol configuration with the specified symbol weight.
    static func weight(_ weight: NSUISymbolWeight?) -> NSUIImage.SymbolConfiguration {
        let configuration = NSUIImage.SymbolConfiguration.monochrome()
        configuration.weight = weight ?? .regular
        return configuration
    }
    
    /// Returns a configuration object that applies the right configuration values on top of the left object’s values.
    static func + (lhs: NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        lhs.applying(rhs)
    }
    
    /// Applies the right configuration values on top of the left object’s values.
    static func += (lhs: inout NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) {
        lhs = lhs.applying(rhs)
    }
}

@available(macOS 12.0, iOS 13.0, *)
extension NSUIImage.SymbolConfiguration {
    var weight: NSUISymbolWeight? {
        get {
            #if os(macOS)
            guard let rawValue: CGFloat = value(forKey: "weight"), rawValue != CGFloat.greatestFiniteMagnitude else { return nil }
            return NSUISymbolWeight(rawValue: rawValue)
            #else
            guard let rawValue: Int = value(forKey: "weight") else { return nil }
            return NSUISymbolWeight(rawValue: rawValue)
            #endif
        }
        set { setValue(safely: newValue?.rawValue ?? 0, forKey: "weight") }
    }

    var pointSize: CGFloat {
        get { value(forKey: "pointSize") ?? 0.0 }
        set { setValue(safely: newValue, forKey: "pointSize") }
    }

    var textStyle: NSUIFont.TextStyle? {
        get { value(forKey: "textStyle") }
        set { setValue(safely: newValue, forKey: "textStyle") }
    }

    var prefersMulticolor: Bool {
        get { value(forKey: "prefersMulticolor") ?? false }
        set { setValue(safely: newValue, forKey: "prefersMulticolor") }
    }

    var scale: NSUIImage.SymbolScale? {
        get {
            guard let rawValue: Int = value(forKey: "scale"), rawValue != -1 else {
                return nil }
            return NSUIImage.SymbolScale(rawValue: rawValue)
        }
        set {
            #if os(macOS)
                setValue(safely: newValue?.rawValue ?? NSUIImage.SymbolScale.default, forKey: "scale")
            #elseif canImport(UIKit)
                setValue(safely: newValue?.rawValue ?? NSUIImage.SymbolScale.unspecified, forKey: "scale")
            #endif
        }
    }
}

#if os(macOS)
    @available(macOS 11.0, *)
    public extension NSImage {
        /**
         Creates a symbol image with the system symbol name.

         - Parameter systemSymbolName: The name of the system symbol image.
         - Returns: A symbol image based on the name you specify; otherwise `nil` if the method couldn’t find a suitable image.
         */
        convenience init?(systemSymbolName: String) {
            self.init(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
        }
    }

    @available(macOS 12.0, *)
    public extension NSImage {
        /**
         Returns a new version of the current image, applying the specified configuration attributes on top of the current attributes.

         - Parameter configuration: The configuration attributes to apply on top of the existing attributes. Values in this object take precedence over the image's current configuration values.
         - Returns: A new version of the image object that contains the merged configuration details.
         */
        func applyingSymbolConfiguration(_ configuration: NSImage.SymbolConfiguration) -> NSImage? {
            let updatedConfiguration = symbolConfiguration.applying(configuration)
            return withSymbolConfiguration(updatedConfiguration)
        }
    }
#endif

@available(macOS 12.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension NSUIImage.SymbolConfiguration {
    static var colorsValueKey: String {
        #if os(macOS)
            "_colors"
        #else
            "_colors"
        #endif
    }

    var colors: [NSUIColor]? {
        get { value(forKey: Self.colorsValueKey) }
        set { setValue(newValue, forKey: Self.colorsValueKey) }
    }

    var primary: NSUIColor? {
        colors?[safe: 0]
    }

    var secondary: NSUIColor? {
        colors?[safe: 1]
    }

    var tertiary: NSUIColor? {
        colors?[safe: 2]
    }

    var font: NSUIFont? {
        if let textStyle = textStyle {
            if let weight = weight {
                #if os(macOS)
                return .systemFont(textStyle).weight(weight)
                #else
                return .systemFont(textStyle).weight(weight.fontWeight())
                #endif
            } else {
                return .systemFont(textStyle)
            }
        }
        guard pointSize != 0.0 else { return nil }
        #if os(macOS)
        return .systemFont(ofSize: pointSize, weight: weight ?? .regular)
        #else
        return .systemFont(ofSize: pointSize, weight: (weight ?? .regular).fontWeight())
        #endif
    }

    var uiFont: Font? {
        font?.swiftUI
    }
}

#if os(macOS)
@available(macOS 11.0, *)
public extension NSImage.SymbolScale {
    /// The default scale variant that matches the system usage.
    static var `default`: NSImage.SymbolScale { NSImage.SymbolScale(rawValue: -1)! }
    
    /// An unspecified scale.
    static var unspecified: NSImage.SymbolScale { NSImage.SymbolScale(rawValue: 0)! }
}

@available(macOS 12.0, *)
public extension Image {
    @ViewBuilder
    func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration) -> some View {
        modifier(NSImage.SymbolConfiguration.Modifier(configuration: configuration))
    }
}

@available(macOS 12.0, *)
extension NSImage.SymbolConfiguration {
    static func _preferringHierarchical() -> NSImage.SymbolConfiguration {
        if #available(macOS 13.0, *) {
            return NSImage.SymbolConfiguration.preferringHierarchical()
        } else {
            let configuration = NSImage.SymbolConfiguration()
            configuration.setValue(safely: 1, forKey: "paletteType")
            configuration.setValue(safely: 2, forKey: "renderingStyle")
            return configuration
        }
    }
    
    struct Modifier: ImageModifier {
        let configuration: NSImage.SymbolConfiguration
        @ViewBuilder
        func body(image: SwiftUI.Image) -> some View {
            image.symbolRenderingMode(configuration.colorConfiguration?.symbolRendering)
                .font(configuration.uiFont)
                .imageScale(configuration.scale?.swiftUI)
                .foregroundStyle(configuration.primary?.swiftUI, configuration.secondary?.swiftUI, configuration.tertiary?.swiftUI)
        }
    }
    
    /// The color configuration.
    enum ColorConfiguration: Hashable {
        ///  A monochrome color configuration with the specified color.
        case monochrome(NSUIColor? = nil)
        
        ///  A hierarchical color configuration with the specified color.
        case hierarchical(NSUIColor? = nil)
        
        ///  A multicolor color configuration using the specified color as primary color.
        case multicolor(NSUIColor)
        
        /// A palette color configuration with the specified colors.
        case palette(primary: NSUIColor, secondary: NSUIColor, tertiary: NSUIColor? = nil)
        
        ///  A monochrome color configuration using the content tint color.
        public static var monochrome = ColorConfiguration.monochrome(nil)
        
        ///  A hierarchical color configuration using the content tint color.
        public static var hierarchical = ColorConfiguration.hierarchical(nil)
    }
    
    /// Returns the symbol configuration with the specified color configuration.
    func colorConfiguration(_ configuration: ColorConfiguration) -> NSImage.SymbolConfiguration {
        let conf: NSImage.SymbolConfiguration
        switch configuration {
        case .monochrome(let color):
            if let color = color {
                conf = .init(paletteColors: [color]).applying(.monochrome())
            } else {
                conf = .monochrome()
            }
        case .hierarchical(let color):
            if let color = color {
                conf = .hierarchical(color)
            } else {
                if #available(macOS 13.0, *) {
                    conf = .preferringHierarchical()
                } else {
                    conf = NSImage.SymbolConfiguration()
                    conf.setValue(1, forKey: "paletteType")
                }
            }
        case .multicolor(let color):
            conf = .multicolor(color)
        case .palette(let primary, let secondary, let tertiary):
            conf = .palette(primary, secondary, tertiary)
        }
        return applying(conf)
    }
    
    enum ColorConfigurationAlt: String {
        case monochrome
        case multicolor
        case hierarchical
        case palette
        var symbolRendering: SymbolRenderingMode {
            switch self {
            case .monochrome: return .monochrome
            case .multicolor: return .multicolor
            case .hierarchical: return .hierarchical
            case .palette: return .palette
            }
        }
    }
    
    
    
    var colorConfiguration: ColorConfigurationAlt? {
        #if os(macOS)
        if colors?.isEmpty == false, let type = value(forKey: "paletteType") as? Int {
            if type == 1 {
                return .hierarchical
            } else if type == 2 {
                if prefersMulticolor {
                    return .multicolor
                } else {
                    return .palette
                }
            }
        }
        #else
        var description = debugDescription
        if description.contains("multicolor") {
            return .multicolor
        } else if description.contains("palette") {
            return .palette
        } else if description.contains("hierarchical") {
            return .hierarchical
        }
        #endif
        return .monochrome
    }
}

extension NSFont.Weight {
    static var unspecified: NSFont.Weight { NSFont.Weight(0.0) }
}
#endif

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NSUIImage.SymbolScale {
    /// A SwiftUI representation of the symbol scale.
    var swiftUI: Image.Scale {
        switch self {
        case .medium: return .medium
        case .large: return .large
        case .small: return .small
        default: return .medium
        }
    }
}
