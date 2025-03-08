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


@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
    
    private func copied() -> NSUIImage.SymbolConfiguration {
        copy() as! NSUIImage.SymbolConfiguration
    }

    /// Returns the symbol configuration with the specified symbol scale.
    func scale(_ scale: NSUIImage.SymbolScale?) -> NSUIImage.SymbolConfiguration {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            return applying(NSUIImage.SymbolConfiguration(scale: scale ?? .unspecified))
        } else {
            return copied().scale(scale ?? .unspecified)
        }
    }
    
    /// Returns the symbol configuration with the specified symbol weight.
    func weight(_ weight: NSUISymbolWeight?) -> NSUIImage.SymbolConfiguration {
        copied().weight(weight ?? .unspecified)
    }
    
    /// Returns the symbol configuration with the specified text style.
    func font(_ textStyle: NSUIFont.TextStyle?) -> NSUIImage.SymbolConfiguration {
        if let textStyle = textStyle {
            return self.font(textStyle)
        }
        return copied().pointSize(0.0)
    }
    
    /// Returns the symbol configuration with the specified text style, symbol weight, and symbol scale.
    func font(_ textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        #if os(macOS)
        return self.font(pointSize: NSFont.systemFont(textStyle).pointSize, weight: weight, scale: scale)
        #else
        applying(NSUIImage.SymbolConfiguration(textStyle: textStyle, scale: scale)).applying(NSUIImage.SymbolConfiguration(weight: weight))
        #endif
    }
    
    /// Returns the symbol configuration with a system font with the specified point size, symbol weight and symbol scale.
    func font(pointSize: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        #if os(macOS)
        if #available(macOS 12.0, *) {
            return applying(NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale))
        } else {
            return copied().pointSize(pointSize).weight(weight).scale(scale)
        }
        #else
        return applying(NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale))
        #endif
    }

    /// A symbol configuration with the specified text style, symbol weight and symbol scale.
    static func font(_ textStyle: NSUIFont.TextStyle, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        .init(textStyle: textStyle, weight: weight, scale: scale)
    }

    /// A symbol configuration with system font with specified point size, symbol weight, and symbol scale.
    static func font(pointSize: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale = .default) -> NSUIImage.SymbolConfiguration {
        .init(pointSize: pointSize, weight: weight, scale: scale)
    }

    /// A symbol configuration with the specified symbol scale.
    static func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        .init(scale: scale)
    }
    
    /// A symbol configuration with the specified symbol weight.
    static func weight(_ weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        .init(weight: weight)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
    @available(macOS 12.0, *)
    static func color(_ color: ColorConfiguration) -> NSUIImage.SymbolConfiguration {
        color.symbolConfiguration
    }
    
    /// A multicolor symbol configuration with the specified color.
    @available(macOS 12.0, *)
    static func monochrome(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .color(.monochrome(color))
    }

    /// A hierarchical symbol configuration with the specified color.
    static func hierarchical(_ primary: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .init(hierarchicalColor: primary)
    }

    /// A multicolor symbol configuration with the specified color.
    static func multicolor(_ primary: NSUIColor, secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        .palette(primary, secondary, tertiary) + .preferringMulticolor()
    }

    /// A palette symbol configuration with the specified colors.
    static func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        .init(paletteColors: [primary, secondary, tertiary].nonNil )
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
    
    #if os(macOS)
    func _applying(_ configuration: NSUIImage.SymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        if #available(macOS 12.0, *) {
            return applying(configuration)
        } else {
            let copy = copied()
            let pointSize = configuration.pointSize
            let scale = configuration.scale
            let weight = configuration.weight
            let renderingStyle = configuration.renderingStyle
            let colors = configuration.colors
            copy.pointSize = pointSize != 0.0 ? pointSize : copy.pointSize
            copy.scale = scale != .unspecified ? scale : copy.scale
            copy.weight = weight != .unspecified ? weight : copy.weight
            copy.renderingStyle = renderingStyle != 0 ? renderingStyle : copy.renderingStyle
            copy.colors = colors != nil ? colors! : copy.colors
            return copy
        }
    }
    
    var renderingStyle: Int {
        get {
            guard responds(to: NSSelectorFromString(Keys.renderingStyle.unmangled)) else { return 0 }
            return value(forKey: Keys.renderingStyle.unmangled) as? Int ?? 0
        }
        set {
            guard responds(to: NSSelectorFromString(Keys.renderingStyle.unmangled)) else { return }
            setValue(newValue, forKey: Keys.renderingStyle.unmangled)
        }
    }
    
    var prefersMulticolor: Bool {
        get {
            guard responds(to: NSSelectorFromString(Keys.prefersMulticolor.unmangled)) else { return false }
            return value(forKey: Keys.prefersMulticolor.unmangled) as? Bool ?? false
        }
        set {
            guard responds(to: NSSelectorFromString(Keys.prefersMulticolor.unmangled)) else { return }
            setValue(newValue, forKey: Keys.prefersMulticolor.unmangled)
        }
    }
    #endif

    var pointSize: CGFloat {
        get { value(forKey: Keys.pointSize.unmangled) ?? 0.0 }
        set { pointSize(newValue) } }
    
    @discardableResult func pointSize(_ size: CGFloat) -> NSUIImage.SymbolConfiguration {
        guard responds(to: NSSelectorFromString(Keys.pointSize.unmangled)) else { return self }
        setValue(size, forKey: Keys.pointSize.unmangled)
        return self
    }
    
    @discardableResult func weight(_ weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        guard responds(to: NSSelectorFromString(Keys.weight.unmangled)) else { return self }
        setValue(weight.rawValue, forKey: Keys.weight.unmangled)
        return self
    }
    
    @discardableResult func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        guard responds(to: NSSelectorFromString(Keys.scale.unmangled)) else { return self }
        setValue(scale.rawValue, forKey: Keys.scale.unmangled)
        return self
    }
    
    var weight: NSUISymbolWeight {
        get {
            #if os(macOS)
            guard let rawValue: CGFloat = value(forKey: Keys.weight.unmangled), rawValue != CGFloat.greatestFiniteMagnitude else { return .unspecified }
            return NSUISymbolWeight(rawValue: rawValue)
            #else
            guard let rawValue: Int = value(forKey: Keys.weight.unmangled) else { return .unspecified }
            return NSUISymbolWeight(rawValue: rawValue) ?? .unspecified
            #endif
        }
        set { weight(newValue) }
    }

    var scale: NSUIImage.SymbolScale {
        get {
            guard let rawValue: Int = value(forKey: Keys.scale.unmangled), rawValue != -1 else {
                return .default }
            return NSUIImage.SymbolScale(rawValue: rawValue) ?? .default
        }
        set { scale(newValue) }
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
        return .systemFont(textStyle).weight(weight.fontWeight())
    } else if pointSize != 0.0 {
        return .systemFont(ofSize: pointSize, weight: weight.fontWeight())
    }
    return nil
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

public extension NSFont.Weight {
    /// An unspecified font weight.
    static var unspecified: Self { Self(rawValue: .greatestFiniteMagnitude) }
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
