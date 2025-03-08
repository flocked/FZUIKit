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
import FZSwiftUtils


@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    /// Creates a symbol configuration with the specified text style, font weight and symbol scale.
    public convenience init(textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) {
        self.init(textStyle: textStyle, scale: scale)
        guard weight != .regular else { return }
        self.weight = weight
    }
    
    #if os(macOS)
    /// Creates a configuration object with the specified weight information.
    public convenience init(weight: NSUISymbolWeight = .regular) {
        self.init()
        guard weight != .regular else { return }
        self.weight = weight
    }
    
    static var unspecified: NSUIImage.SymbolConfiguration {
        .init()
    }
    #endif

    /// Returns the symbol configuration with the specified symbol scale.
    public func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            return applying(NSUIImage.SymbolConfiguration(scale: scale))
        } else {
            let configuration = self
            configuration.scale = scale
            return configuration
        }
    }
    
    /// Returns the symbol configuration with the specified symbol weight.
    public func weight(_ weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        let configuration = self
        configuration.weight = weight
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
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    /// Returns the symbol configuration with the specified text style, symbol weight, and symbol scale.
    public func font(textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        #if os(macOS)
        applying(.init(textStyle: textStyle, weight: weight, scale: scale))
        #else
        applying(NSUIImage.SymbolConfiguration(textStyle: textStyle, scale: scale)).applying(NSUIImage.SymbolConfiguration(weight: weight))
        #endif
    }
    
    /// Returns the symbol configuration with a system font with the specified point size, symbol weight and symbol scale.
    public func font(pointSize: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        applying(NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale))
    }
    
    /// Returns the symbol configuration without font.
    public var withoutFont: NSUIImage.SymbolConfiguration {
        let configuration = self
        #if os(iOS)
        configuration.textStyle = nil
        #endif
        configuration.pointSize = 0.0
        configuration.weight = .unspecified
        return configuration
    }
    
    /// A symbol configuration with the specified symbol weight.
    static func weight(_ weight: NSUISymbolWeight?) -> NSUIImage.SymbolConfiguration {
        let configuration = NSUIImage.SymbolConfiguration.monochrome()
        configuration.weight = weight ?? .regular
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
    
    /// A symbol configuration with the image symbol configuration.
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
    
    /// Returns a configuration object that applies the right configuration values on top of the left object’s values.
    public static func + (lhs: NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        lhs.applying(rhs)
    }
    
    /// Applies the right configuration values on top of the left object’s values.
    public static func += (lhs: inout NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) {
        lhs = lhs.applying(rhs)
    }
    
    public static func && (lhs: NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        lhs.applying(rhs)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    /// Returns the symbol configuration with the specified color configuration.
    public func color(_ colorConfiguration: ColorConfiguration) -> NSUIImage.SymbolConfiguration {
        applying(colorConfiguration.symbolConfiguration)
    }
    
    /// The configuration of the color.
    public struct ColorConfiguration {
        enum Mode {
            case monochrome
            case hierarchical
            case palette
            @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
            case multicolor
        }
        
        var mode: Mode = .monochrome
        var primary: NSUIColor?
        var secondary: NSUIColor?
        var tertiary: NSUIColor?
        
        init(_ mode: Mode, _ primary: NSUIColor? = nil, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) {
            self.mode = mode
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
        }
        
        @available(macOS 12.0, iOS 15.0, *)
        var symbolConfiguration: NSUIImage.SymbolConfiguration {
            switch mode {
            case .monochrome:
                if let primary = primary {
                    if #available(macOS 13.0, iOS 16.0, tvOS 15.0, watchOS 9.0, *) {
                        return .init(paletteColors: [primary]) + .preferringMonochrome()
                    } else {
                        return .init(paletteColors: [primary])
                    }
                } else {
                    if #available(macOS 13.0, iOS 16.0, tvOS 15.0, watchOS 9.0, *) {
                        return .preferringMonochrome()
                    } else {
                        return .unspecified
                    }
                }
            case .hierarchical:
                if #available(macOS 13.0, iOS 16.0, tvOS 15.0, watchOS 9.0, *) {
                    #if os(macOS)
                    if let primary = primary {
                        return NSUIImage.SymbolConfiguration(hierarchicalColor: primary)
                    } else {
                        return .preferringHierarchical()
                    }
                    #else
                    return NSUIImage.SymbolConfiguration(hierarchicalColor: primary!)
                    #endif
                } else {
                    return .unspecified
                }
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
}

@available(macOS 11.0, iOS 13.0, *)
extension NSUIImage.SymbolConfiguration {
    private struct Keys {
        static let weight = "weight".mangled
        static let pointSize = "pointSize".mangled
        static let prefersMulticolor = "prefersMulticolor".mangled
        static let scale = "scale".mangled
        static let colors = "_colors".mangled
        static let paletteType = "paletteType".mangled
        static let renderingStyle = "renderingStyle".mangled
        static let textStyle = "textStyle".mangled
    }

    var pointSize: CGFloat {
        get { value(forKey: Keys.pointSize.unmangled) ?? 0.0 }
        set { setValue(safely: newValue, forKey: Keys.pointSize.unmangled) }
    }
    
    var weight: NSUISymbolWeight? {
        get {
            #if os(macOS)
            guard let rawValue: CGFloat = value(forKey: Keys.weight.unmangled), rawValue != CGFloat.greatestFiniteMagnitude else { return nil }
            return NSUISymbolWeight(rawValue: rawValue)
            #else
            guard let rawValue: Int = value(forKey: Keys.weight.unmangled) else { return nil }
            return NSUISymbolWeight(rawValue: rawValue)
            #endif
        }
        set { setValue(safely: newValue?.rawValue ?? 0, forKey: Keys.weight.unmangled) }
    }

    var prefersMulticolor: Bool {
        get { value(forKey: Keys.prefersMulticolor.unmangled) ?? false }
        set { setValue(safely: newValue, forKey: Keys.prefersMulticolor.unmangled) }
    }

    var scale: NSUIImage.SymbolScale {
        get {
            guard let rawValue: Int = value(forKey: Keys.scale.unmangled), rawValue != -1 else {
                return .default }
            return NSUIImage.SymbolScale(rawValue: rawValue) ?? .default
        }
        set {
            #if os(macOS)
                setValue(newValue.rawValue, forKey: Keys.scale.unmangled)
            #elseif canImport(UIKit)
                setValue(newValue.rawValue, forKey: Keys.scale.unmangled)
            #endif
        }
    }
    
    var colors: [NSUIColor]? {
        get { value(forKey: Keys.colors.unmangled) }
        set { setValue(newValue, forKey: Keys.colors.unmangled) }
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
    
#if os(iOS)
var textStyle: NSUIFont.TextStyle? {
    get { value(forKey: Keys.textStyle.unmangled) }
    set { setValue(safely: newValue, forKey: Keys.textStyle.unmangled) }
}

var font: NSUIFont? {
    if let textStyle = textStyle {
        if let weight = weight {
            return .systemFont(textStyle).weight(weight.fontWeight())
        } else {
            return .systemFont(textStyle)
        }
    }
    guard pointSize != 0.0 else { return nil }
    return .systemFont(ofSize: pointSize, weight: (weight ?? .regular).fontWeight())
}

var uiFont: Font? {
    font?.swiftUI
}
#endif
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

/*
#if os(iOS)
@available(macOS 12.0, *)
public extension Image {
    @ViewBuilder
    func symbolConfiguration(_ configuration: NSUIImage.SymbolConfiguration) -> some View {
        modifier(NSUIImage.SymbolConfiguration.Modifier(configuration: configuration))
    }
}

struct Modifier: ImageModifier {
    let configuration: NSUIImage.SymbolConfiguration
    @ViewBuilder
    func body(image: SwiftUI.Image) -> some View {
        image.symbolRenderingMode(configuration.colorConfiguration?.symbolRendering)
            .font(configuration.uiFont)
            .imageScale(configuration.scale?.swiftUI)
            .foregroundStyle(configuration.primary?.swiftUI, configuration.secondary?.swiftUI, configuration.tertiary?.swiftUI)
    }
}
#endif
 */

#if os(macOS)
@available(macOS 11.0, *)
public extension NSImage.SymbolScale {
    /// The default scale variant that matches the system usage.
    static var `default`: NSImage.SymbolScale { NSImage.SymbolScale(rawValue: -1)! }
    
    /// An unspecified scale.
    static var unspecified: NSImage.SymbolScale { NSImage.SymbolScale(rawValue: 0)! }
}

@available(macOS 12.0, *)
extension NSImage.SymbolConfiguration {
    static func _preferringHierarchical() -> NSImage.SymbolConfiguration {
        if #available(macOS 13.0, *) {
            return NSImage.SymbolConfiguration.preferringHierarchical()
        } else {
            let configuration = NSImage.SymbolConfiguration()
            configuration.setValue(safely: 1, forKey: Keys.paletteType.unmangled)
            configuration.setValue(safely: 2, forKey: Keys.renderingStyle.unmangled)
            return configuration
        }
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
