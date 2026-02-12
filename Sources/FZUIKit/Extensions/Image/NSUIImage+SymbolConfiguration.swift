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

extension NSUIImage.SymbolConfiguration {
    #if os(macOS)
    /// Creates a configuration object with the specified weight information.
    public convenience init(weight: NSUISymbolWeight) {
        self.init()
        guard weight != .unspecified else { return }
        self.weight = weight
    }
    
    /**
     Creates a configuration object with the specified point-size information.
     
     - Parameter pointSize: The system font point size to use for the configuration.
     - Returns: A new symbol configuration object with the specified information.
     */
    public convenience init(pointSize: CGFloat) {
        self.init(pointSize: pointSize, weight: .unspecified)
    }
    
    /**
     Creates a configuration object with the specified font information.
     
     - Parameter font: The font from which to derive the configuration attributes.
     */
    public convenience init(font: NSFont) {
        self.init(pointSize: font.pointSize, weight: font.fontDescriptor.weight)
    }
    
    /**
     Creates a configuration object with the specified font and scale information.
     
     - Parameters:
        - font: The font from which to derive the configuration attributes.
        - scale: The symbol image scale variant to select.
     */
    public convenience init(font: NSFont, scale: NSImage.SymbolScale) {
        self.init(pointSize: font.pointSize, weight: font.fontDescriptor.weight, scale: scale)
    }
    
    /// A symbol configuration object that contains unspecified values for all attributes.
    public static var unspecified: NSUIImage.SymbolConfiguration {
        .init()
    }
    #endif
    
    /// Creates a configuration object with the specified point-size information.
    public static func pointSize(_ pointSize: CGFloat) -> NSUIImage.SymbolConfiguration {
        .init(pointSize: pointSize)
    }
    
    /// Creates a configuration object with the specified point-size and weight information.
    public static func pointSize(_ pointSize: CGFloat, weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        .init(pointSize: pointSize, weight: weight)
    }
    
    /// Creates a configuration object with the specified point-size, weight, and scale information.
    public static func pointSize(_ pointSize: CGFloat, weight: NSUISymbolWeight = .regular, scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        .init(pointSize: pointSize, weight: weight, scale: scale)
    }
    
    /// Creates a configuration object with the specified font text style information.
    public static func textStyle(_ textStyle: NSUIFontTextStyle) -> NSUIImage.SymbolConfiguration {
        .init(textStyle: textStyle)
    }
    
    /// Creates a configuration object with the specified font text style and scale information.
    public static func textStyle(_ textStyle: NSUIFontTextStyle, scale: NSUIImageSymbolScale) -> NSUIImage.SymbolConfiguration {
        .init(textStyle: textStyle, scale: scale)
    }
    
    /// Creates a configuration object with the specified font information.
    public static func font(_ font: NSUIFont) -> NSUIImage.SymbolConfiguration {
        .init(font: font)
    }

    /// Creates a configuration object with the specified font and scale information.
    public static func font(_ font: NSUIFont, scale: NSUIImageSymbolScale) -> NSUIImage.SymbolConfiguration {
        .init(font: font, scale: scale)
    }
    
    /// Creates a configuration object with the specified scale information.
    public static func scale(_ scale: NSUIImageSymbolScale) -> NSUIImage.SymbolConfiguration {
        .init(scale: scale)
    }
    
    /// Creates a configuration object with the specified weight information.
    public static func weight(_ weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        .init(weight: weight)
    }
    
    /// Creates a color configuration with a color scheme from a palette of multiple colors.
    public static func palette(_ colors: [NSUIColor]) -> NSUIImage.SymbolConfiguration {
        .init(paletteColors: colors)
    }
    
    /// Creates a color configuration with a color scheme from a palette of multiple colors.
    public static func palette(_ primary: NSUIColor, _ secondary: NSUIColor? = nil, _ tertiary: NSUIColor? = nil, _ quaternary: NSUIColor? = nil, _ quinary: NSUIColor? = nil) -> NSUIImage.SymbolConfiguration {
        .init(paletteColors: [primary, secondary, tertiary, quaternary, quinary].nonNil )
    }
    
    /// Creates a color configuration that specifies that the symbol image uses its monochrome variant.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static var monochrome: NSUIImage.SymbolConfiguration {
        .preferringMonochrome()
    }
    
    /// Creates a color configuration with a color scheme that originates from one color.
    public static func monochrome(_ color: NSUIColor) -> NSUIImage.SymbolConfiguration {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return .preferringMonochrome() + .palette([color])
        } else {
            return .palette([color])
        }
    }
    
    #if os(macOS)
    /// Creates a color configuration that specifies that the symbol image uses its hierarchical variant.
    @available(macOS 13.0, *)
    public static var hierarchical: NSUIImage.SymbolConfiguration {
        .preferringHierarchical()
    }
    #endif
    
    /// Creates a color configuration with a color scheme that originates from one color.
    public static func hierarchical(_ primary: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .init(hierarchicalColor: primary)
    }
    
    /// Creates a configuration that specifies that the symbol should prefer its multicolor variant if one exists.
    public static var multicolor: NSUIImage.SymbolConfiguration {
        .preferringMulticolor()
    }
    
    /// Creates a multi color configuration with the specified primary color.
    public static func multicolor(_ primary: NSUIColor) -> NSUIImage.SymbolConfiguration {
        .preferringMulticolor() + .palette([primary])
    }
    
    /// Creates a configuration  with a body font configuration.
    public static var body: NSUIImage.SymbolConfiguration { .init(textStyle: .body) }
    
    /// Creates a configuration with a callout font configuration.
    public static var callout: NSUIImage.SymbolConfiguration { .init(textStyle: .callout) }
    
    /// Creates a configuration with a caption font configuration.
    public static var caption1: NSUIImage.SymbolConfiguration { .init(textStyle: .caption1) }
    
    /// Creates a configuration with a alternate caption font configuration.
    public static var caption2: NSUIImage.SymbolConfiguration { .init(textStyle: .caption2) }
    
    /// Creates a configuration with a footnote font configuration.
    public static var footnote: NSUIImage.SymbolConfiguration { .init(textStyle: .footnote) }
    
    /// Creates a configuration with a headline font configuration.
    public static var headline: NSUIImage.SymbolConfiguration { .init(textStyle: .headline) }
    
    /// Creates a configuration with a subheadline font configuration.
    public static var subheadline: NSUIImage.SymbolConfiguration { .init(textStyle: .subheadline)  }
    
    /// Creates a configuration with a first-level title font configuration.
    public static var title1: NSUIImage.SymbolConfiguration { .init(textStyle: .title1) }
    
    /// Creates a configuration with a second-level title font configuration.
    public static var title2: NSUIImage.SymbolConfiguration { .init(textStyle: .title2) }
    
    /// Creates a configuration with a third-level title font configuration.
    public static var title3: NSUIImage.SymbolConfiguration { .init(textStyle: .title3) }
    
    #if os(macOS) || os(iOS) || os(watchOS)
    /// Creates a configuration with a large title font configuration.
    public static var largeTitle: NSUIImage.SymbolConfiguration { .init(textStyle: .largeTitle) }
    
    /// Creates a configuration with a extra large title font configuration.
    @available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    public static var extraLargeTitle1: NSUIImage.SymbolConfiguration {
        .init(textStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle"))
    }
    
    /// Creates a configuration with a extra extra large title font configuration.
    @available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    public static var extraLargeTitle2: NSUIImage.SymbolConfiguration {
        .init(textStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle2"))
    }
    #endif
    
    /// Returns a configuration object that applies the right configuration values on top of the left object’s values.
    public static func + (lhs: NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) -> NSUIImage.SymbolConfiguration {
        lhs.applying(rhs)
    }
    
    /// Applies the right configuration values on top of the left object’s values.
    public static func += (lhs: inout NSUIImage.SymbolConfiguration, rhs: NSUIImage.SymbolConfiguration) {
        lhs = lhs.applying(rhs)
    }
}

/*
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSUIImage.SymbolConfiguration {
 @available(macOS 12.0, *)
 static func color(_ color: ColorConfiguration) -> NSUIImage.SymbolConfiguration {
     color.symbolConfiguration
 }
 
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
                    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                        return .init(paletteColors: [primary]) + .preferringMonochrome()
                    } else {
                        return .init(paletteColors: [primary])
                    }
                } else {
                    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
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
*/

extension NSUIImage.SymbolConfiguration {
    #if os(macOS)
    var pointSize: CGFloat {
        get { value(forKey: "pointSize") ?? 0.0 }
        set { setIvarValue(Double(newValue), named: "_pointSize") }
    }
    #else
    var pointSize: CGFloat? {
        get { value(forKey: "pointSize") ?? 0.0 }
        set {
            let newValue = newValue != nil ? Double(newValue!) : nil
            setIvarValue(newValue, named: "_pointSize")
            guard newValue != nil else { return }
            textStyle = nil
        }
    }
    #endif
    
    var prefersMulticolor: Bool {
        get {
            guard responds(to: NSSelectorFromString("prefersMulticolor")) else { return false }
            return value(forKeySafely: "prefersMulticolor") as? Bool ?? false
        }
        set {
            #if os(macOS)
            setIvarValue(newValue, named: "_prefersMulticolor")
            #else
            guard responds(to: NSSelectorFromString("prefersMulticolor")) else { return }
            setValue(safely: newValue, forKey: "prefersMulticolor")
            #endif
        }
    }
    
    private func pointSize(_ size: CGFloat) -> NSUIImage.SymbolConfiguration {
        self.pointSize = pointSize
        return self
    }
    
    var weight: NSUISymbolWeight {
        get {
            #if os(macOS)
            guard let weight: Double = value(forKey: "weight") else { return .unspecified }
            return NSUISymbolWeight(rawValue: weight)
            #else
            guard let rawValue: Int = value(forKey: "weight") else { return .unspecified }
            return NSUISymbolWeight(rawValue: rawValue) ?? .unspecified
            #endif
        }
        set {
            #if os(macOS)
            setIvarValue(Double(newValue.symbolWeight().rawValue), named: "_weight")
            #else
            setIvarValue(newValue.rawValue, named: "_weight")
            #endif
        }
    }
    
    private func weight(_ weight: NSUISymbolWeight) -> NSUIImage.SymbolConfiguration {
        self.weight = weight
        return self
    }
    
    var scale: NSUIImage.SymbolScale {
        get {
            guard let rawValue: Int = value(forKey: "scale"), rawValue != -1 else {
                return .default }
            return NSUIImage.SymbolScale(rawValue: rawValue) ?? .default
        }
        set { setIvarValue(newValue.rawValue, named: "_scale") }
    }
    
    private func scale(_ scale: NSUIImage.SymbolScale) -> NSUIImage.SymbolConfiguration {
        self.scale = scale
        return self
    }
    
    var colors: [NSUIColor]? {
        get { value(forKey: "colors") }
        set { setIvarValue(newValue, named: "_colors") }
    }
    
    /*
    var primary: NSUIColor? {
        colors?[safe: 0]
    }
    
    var secondary: NSUIColor? {
        colors?[safe: 1]
    }
    
    var tertiary: NSUIColor? {
        colors?[safe: 2]
    }
     */
    
    #if os(macOS)
    /// Color rendering mode.
    public enum ColorRenderStyle: Int {
        /// Automatic.
        case automatic
        /// Monochrome.
        case monochrome
        /// Hierarchical.
        case hierarchical
        /// Palette.
        case palette
    }
  
    var colorRenderStyle: ColorRenderStyle {
        get {
            guard responds(to: NSSelectorFromString("renderingStyle")) else { return .automatic }
            return .init(rawValue: value(forKeySafely: "renderingStyle") as? Int ?? 0)!
        }
        set { setIvarValue(newValue.rawValue, named: "_renderingStyle") }
    }
    #else
    var textStyle: NSUIFont.TextStyle? {
        get { value(forKey: "textStyle") }
        set {
            let value = newValue?.uictName
            setIvarValue(value, named: "_textStyle")
            guard value != nil else { return }
            pointSize = nil
        }
    }
    #endif
    
    #if os(iOS)
    var font: NSUIFont? {
        if let textStyle = textStyle {
            return .systemFont(textStyle).weight(weight.fontWeight())
        } else if let pointSize = pointSize {
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
public extension NSImage {
    /**
     Creates a symbol image with the system symbol name.
     
     - Parameter name: The name of the system symbol image.
     - Returns: A symbol image based on the name you specify; otherwise `nil` if the method couldn’t find a suitable image.
     */
    convenience init?(systemSymbolName name: String) {
        self.init(systemSymbolName: name, accessibilityDescription: nil)
    }
    
    /**
     Creates a symbol image with the specified system symbol name and configuration.
     
     - Parameters:
        - name: The name of the system symbol image.
        - description: The accessibility description for the symbol image, if any.
        - configuration: The symbol configuration the system applies to the image.
     - Returns: A symbol image based on the name and configuration you specify; otherwise `nil` if the method couldn’t find a suitable image.
     */
    convenience init?(systemSymbolName name: String, accessibilityDescription description: String? = nil, withConfiguration configuration: SymbolConfiguration) {
        guard let data = try? NSImage(systemSymbolName: name, accessibilityDescription: description)?.withSymbolConfiguration(configuration)?.archivedData() else { return nil }
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        self.init(coder: unarchiver)
    }
    
    /**
     Creates a symbol image with the specified system symbol name and configuration.
     
     - Parameters:
        - name: The name of the system symbol image.
        - description: The accessibility description for the symbol image, if any.
        - configuration: The symbol configuration the system applies to the image.
     - Returns: A symbol image based on the name and configuration you specify; otherwise `nil` if the method couldn’t find a suitable image.
     */
    convenience init?(systemSymbolName name: String, accessibilityDescription description: String? = nil, withConfiguration configuration: ImageSymbolConfiguration) {
        self.init(systemSymbolName: name, accessibilityDescription: description, withConfiguration: configuration.nsUI())
    }
    
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
#elseif canImport(UIKit)
public extension UIImage {
    /**
     Creates an image object that contains a system symbol image with the specified configuration.
     
     - Parameters:
        - name: The name of the system symbol image.
        - configuration: The symbol configuration the system applies to the image.
     - Returns: The object containing the image variant that matches the specified configuration data, or nil if no suitable image was found.
     */
    convenience init?(systemName name: String, withConfiguration configuration: ImageSymbolConfiguration) {
        self.init(systemName: name, withConfiguration: configuration.nsUI())
    }
}
#endif

#if os(macOS)
@available(macOS 11.0, *)
public extension NSImage.SymbolScale {
    /// The default scale variant that matches the system usage.
    static let `default` = NSImage.SymbolScale(rawValue: -1)!
}

public extension NSFont.Weight {
    /// An unspecified font weight.
    static let unspecified = Self(rawValue: .greatestFiniteMagnitude)
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

#if os(macOS)
extension NSFont.Weight {
    /**
     Provides the corresponding symbol weight for this font weight.
     
     When placing symbols adjacent to text, use this method to find the appropriate symbol weight to match the weight of the text.
     
     - Returns: The weight that most closely coordinates with the provided font weight.
     */
    public func symbolWeight() -> NSFont.Weight {
        typealias Function = @convention(c) (AnyObject, Selector, NSFont.Weight) -> NSFont.Weight
        let selector = NSSelectorFromString("_symbolWeightForFontWeight:")
        return NSImage.SymbolConfiguration.instanceMethod(for: selector, as: Function.self)?(NSImage.SymbolConfiguration.self, selector, self) ?? self
    }
}
#endif
