//
//  NSImage+SymbolConfiguration.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0,  *)
extension NSUIImage.SymbolConfiguration {
    /// Returns the symbol configuration with the specified text style.
    func font(_ textStyle: NSUIFont.TextStyle?) -> NSUIImage.SymbolConfiguration {
        if let textStyle = textStyle {
            return applying(NSUIImage.SymbolConfiguration.textStyle(textStyle))
        } else {
            let conf = self
            conf.textStyle = nil
            conf.pointSize = 0.0
            conf.weight = NSUIFont.Weight(0.0)
            return conf
        }
    }

    /// Returns the symbol configuration with the specified text style, symbol weight, and symbol scale.
    func font(_ textStyle: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil, scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        let conf: NSUIImage.SymbolConfiguration = .textStyle(textStyle, weight: weight, scale: scale)
        return applying(conf)
    }

    /// Returns the symbol configuration with a system font with the specified point size, symbol weight and symbol scale.
    func font(size: CGFloat, weight: NSUIImage.SymbolWeight = .regular, scale: NSUIImage.SymbolScale? = nil) -> NSUIImage.SymbolConfiguration {
        let conf: NSUIImage.SymbolConfiguration = .systemFont(size, weight: weight, scale: scale)
        return applying(conf)
    }

    /// Returns the symbol configuration with the specified symbol scale.
    func scale(_ scale: NSUIImage.SymbolScale?) -> NSUIImage.SymbolConfiguration {
        let conf = self
        conf.scale = scale
        return conf
    }

    /// Returns the symbol configuration with the specified symbol weight.
    func weight(_ weight: NSUIImage.SymbolWeight?) -> NSUIImage.SymbolConfiguration {
        let conf = self
        conf.weight = weight?.fontWeight()
        return conf
    }

    /// Returns the symbol configuration with a monochrome color configuration.
    func monochrome() -> NSUIImage.SymbolConfiguration {
        let conf = applying(NSUIImage.SymbolConfiguration.monochrome())
        conf.colors = nil
        #if os(macOS)
        conf.prefersMulticolor = false
        #endif
        return conf
    }

    /// Returns the symbol configuration with a multicolor configuration.
    func multicolor(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        let conf: NSUIImage.SymbolConfiguration = .multicolor(color)
        return applying(conf)
    }

    /// Returns the symbol configuration with a hierarchical color configuration.
    func hierarchical(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        let conf = applying(NSUIImage.SymbolConfiguration.hierarchical(color))
        #if os(macOS)
        conf.prefersMulticolor = false
        #endif
        return conf
    }

    /// Returns the symbol configuration with a palette color configuration-
    func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        let conf = applying(NSUIImage.SymbolConfiguration.palette(primary, secondary, tertiary))
        #if os(macOS)
        conf.prefersMulticolor = false
        #endif
        return conf
    }

    /// A symbol configuration with the specified text style, symbol weight and symbol scale.
    static func textStyle(_ textStyle: NSUIFont.TextStyle, weight: NSUIImage.SymbolWeight? = nil, scale: NSUIImage.SymbolScale? = nil) -> NSUIImage.SymbolConfiguration {
        if let scale = scale {
            if let weight = weight {
                return NSUIImage.SymbolConfiguration(textStyle: textStyle, scale: scale).weight(weight)
            }
            return NSUIImage.SymbolConfiguration(textStyle: textStyle, scale: scale)
        }
        if let weight = weight {
            return NSUIImage.SymbolConfiguration(textStyle: textStyle).weight(weight)
        }
        return NSUIImage.SymbolConfiguration(textStyle: textStyle)
    }

    /// A symbol configuration with system font with specified point size, symbol weight, and symbol scale.
    static func systemFont(_ pointSize: CGFloat, weight: NSUIImage.SymbolWeight = .regular, scale: NSUIImage.SymbolScale? = nil) -> NSUIImage.SymbolConfiguration {
        #if os(macOS)
        if let scale = scale {
            return NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight.fontWeight(), scale: scale)
        }
        return NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight.fontWeight())
        #else
        if let scale = scale {
            return NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
        }
        return NSUIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        #endif
    }

    /// A symbol configuration with the specified symbol scale.
    static func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        let conf = NSUIImage.SymbolConfiguration(scale: scale)
        return conf
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
        let conf = NSUIImage.SymbolConfiguration.preferringMulticolor().applying(NSUIImage.SymbolConfiguration.palette(color))
        return conf
    }

    /// A hierarchical symbol configuration with the specified color.
    static func hierarchical(_ primary: NSUIColor) -> NSUIImage.SymbolConfiguration {
        return NSUIImage.SymbolConfiguration(hierarchicalColor: primary)
    }

    /// A palette symbol configuration with the specified colors.
    static func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        return NSUIImage.SymbolConfiguration(paletteColors: [primary, secondary, tertiary].compactMap { $0 })
    }

    /// A symbol configuration with the specified symbol weight.
    static func weight(_ weight: NSUIImage.SymbolWeight) -> NSUIImage.SymbolConfiguration {
        let conf = NSUIImage.SymbolConfiguration.monochrome()
        conf.weight = weight.fontWeight()
        return conf
    }
}

@available(macOS 12.0, iOS 13.0, *)
extension NSUIImage.SymbolConfiguration {
    var weight: NSUIFont.Weight? {
        get { guard let rawValue = value(forKey: "weight", type: CGFloat.self), rawValue != CGFloat.greatestFiniteMagnitude else { return nil }
            return NSUIFont.Weight(rawValue: rawValue)
        }
        set { setValue(safely: newValue?.rawValue ?? 0.0, forKey: "weight") }
    }

    var pointSize: CGFloat {
        get { return value(forKey: "pointSize", type: CGFloat.self) ?? 0.0 }
        set { setValue(safely: newValue, forKey: "pointSize") }
    }

    var textStyle: NSUIFont.TextStyle? {
        get { return value(forKey: "textStyle", type: NSUIFont.TextStyle.self) }
        set { setValue(safely: newValue, forKey: "textStyle") }
    }

    var prefersMulticolor: Bool {
        get { return value(forKey: "prefersMulticolor", type: Bool.self) ?? false }
        set { setValue(safely: newValue, forKey: "prefersMulticolor") }
    }

    var scale: NSUIImage.SymbolScale? {
        get { guard let rawValue = value(forKey: "scale", type: Int.self), rawValue != -1
            else { return nil }
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

    /**
     Creates a symbol image with the system symbol name and symbol configuration.
     
     - Parameters:
        -  systemSymbolName: The name of the system symbol image.
        - configuration: The symbol configuration.
     
     - Returns: A symbol image based on the name you specify; otherwise `nil` if the method couldn’t find a suitable image.
     */
    convenience init?(systemSymbolName: String, configuration: NSImage.SymbolConfiguration) {
        self.init(systemSymbolName: systemSymbolName, accessibilityDescription: nil, configuration: configuration)
    }

    /**
     Creates a symbol image with the system symbol name and symbol configuration.
     
     - Parameters:
        - systemSymbolName: The name of the system symbol image.
        - description: The accessibility description for the symbol image, if any.
        - configuration: The symbol configuration.
     
     - Returns: A symbol image based on the name you specify; otherwise `nil` if the method couldn’t find a suitable image.
     */
    convenience init?(systemSymbolName: String, accessibilityDescription description: String?, configuration: NSImage.SymbolConfiguration) {
        self.init(systemSymbolName: systemSymbolName, accessibilityDescription: description)
        if let size = withSymbolConfiguration(configuration)?.representations.first?.size {
            representations.first?.size = size
        }
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

/*
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension NSUIFont.Weight {
    func symbolWeight() -> NSUIImage.SymbolWeight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .unspecified
        }
    }
}
*/
@available(macOS 11.0, *)
public extension NSImage {
    /// Constants that indicate which weight variant of a symbol image to use.
    enum SymbolWeight: Int, CaseIterable {
        /// An unspecified symbol image weight.
        case unspecified = 0
        /// An ultralight weight.
        case ultraLight
        /// A thin weight.
        case thin
        /// A light weight.
        case light
        /// A regular weight.
        case regular
        /// A medium weight.
        case medium
        /// A semibold weight.
        case semibold
        /// A bold weight.
        case bold
        /// A heavy weight.
        case heavy
        /// A black weight.
        case black
        /// The font weight for the specified symbol weight.
        func fontWeight() -> NSFont.Weight {
            switch self {
            case .unspecified: return .init(rawValue: CGFloat.greatestFiniteMagnitude)
            case .ultraLight: return .ultraLight
            case .thin: return .thin
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            case .heavy: return .heavy
            case .black: return .black
            }
        }
    }
}

@available(macOS 11.0, *)
public extension NSFont.Weight {
    /// Provides the corresponding symbol weight for this font weight.
    func symbolWeight() -> NSImage.SymbolWeight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}
#endif


@available(macOS 12.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
internal extension NSUIImage.SymbolConfiguration {
    static var colorsValueKey: String {
        #if os(macOS)
        "paletteColors"
        #else
        "_colors"
        #endif
    }

    var colors: [NSUIColor]? {
        get { value(forKey: Self.colorsValueKey, type: [NSUIColor].self) }
        set { setValue(safely: newValue, forKey: Self.colorsValueKey) }
    }

    var primary: NSUIColor? {
        guard colors?.count ?? 0 > 0 else { return nil }
        return colors?[0] ?? nil
    }

    var secondary: NSUIColor? {
        guard colors?.count ?? 0 > 1 else { return nil }
        return colors?[1] ?? nil
    }

    var tertiary: NSUIColor? {
        guard colors?.count ?? 0 > 2 else { return nil }
        return colors?[2] ?? nil
    }

    var font: NSUIFont? {
        if let textStyle = textStyle {
            if let weight = weight {
                return NSUIFont.preferredFont(forTextStyle: textStyle).weight(weight)
            } else {
                return NSUIFont.preferredFont(forTextStyle: textStyle)
            }
        }
        guard pointSize != 0.0 else { return nil }
        guard let weight = weight else { return .systemFont(ofSize: pointSize) }
        return .systemFont(ofSize: pointSize, weight: weight)
    }

    var uiFont: Font? {
        if let textStyle = textStyle?.swiftUI {
            if let weight = weight?.swiftUI {
                return Font.system(textStyle).weight(weight)
            } else {
                return Font.system(textStyle)
            }
        }
        guard pointSize != 0.0 else { return nil }
        guard let weight = weight?.swiftUI else { return .system(size: pointSize) }
        return .system(size: pointSize, weight: weight)
    }
}

#if os(macOS)
@available(macOS 11.0, *)
public extension NSImage.SymbolScale {
    /// The default scale variant that matches the system usage.
    static var `default`: NSImage.SymbolScale { return NSImage.SymbolScale(rawValue: -1)! }
    
    /// An unspecified scale.
    static var unspecified: NSImage.SymbolScale { return NSImage.SymbolScale(rawValue: 0)! }

}

@available(macOS 12.0, *)
public extension Image {
    @ViewBuilder
    func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration) -> some View {
        modifier(NSImage.SymbolConfiguration.Modifier(configuration: configuration))
    }
}

@available(macOS 12.0, *)
internal extension NSImage.SymbolConfiguration {
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

     enum ColorConfiguration: String {
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

    var colorConfiguration: ColorConfiguration? {
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
#endif