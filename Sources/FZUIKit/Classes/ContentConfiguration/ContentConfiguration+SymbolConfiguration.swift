//
//  File.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension ContentConfiguration {
    @available(macOS 11.0, iOS 16.0, *)
    struct SymbolConfiguration: Hashable {
        public enum ColorOption: Hashable {
            case multicolor
            case palette
            case monochrome
            case hierarchical
        }

        public enum FontOption: Hashable {
            case textStyle(NSUIFont.TextStyle)
            case pointSize(CGFloat)
        }

        public var colorMode: ColorOption = .monochrome
        public var primary: NSUIColor? = nil
        public var secondary: NSUIColor? = nil
        internal var tertiary: NSUIColor? = nil

        public var font: FontOption? = nil
        public var scale: NSUIImage.SymbolScale? = nil
        public var weight: NSUIImage.SymbolWeight? = nil

        public static func multicolor(primary: NSUIColor) -> Self {
            Self(colorMode: .multicolor, primary: primary)
        }

        public static func palette(primary: NSUIColor, secondary: NSUIColor, tertiary: NSUIColor? = nil) -> Self {
            Self(colorMode: .palette, primary: primary, secondary: secondary, tertiary: tertiary)
        }

        public static func monochrome(primary: NSUIColor) -> Self {
            Self(colorMode: .monochrome, primary: primary)
        }

        public static func hierarchical(primary: NSUIColor) -> Self {
            Self(colorMode: .hierarchical, primary: primary)
        }

        @available(macOS 13.0, iOS 16.0, *)
        internal func toImageSymbolConfiguration() -> NSUIImageSymbolConfiguration {
            var configuration: NSUIImageSymbolConfiguration

            switch colorMode {
            case .multicolor:
                if let primary = primary {
                    //   configuration = .preferringMulticolor()
                    //   configuration = configuration.applying(.init(hierarchicalColor: primary))
                    configuration = .init(paletteColors: [primary])
                    NSUIImageSymbolConfiguration.preferringMulticolor()
                    configuration = configuration.applying(NSUIImageSymbolConfiguration.preferringMulticolor())
                } else {
                    configuration = .preferringMulticolor()
                }
                configuration = .preferringMulticolor()
            case .palette:
                if primary != nil {
                    let colors = [primary, secondary].compactMap { $0 }
                    configuration = .init(paletteColors: colors)
                } else {
                    configuration = .preferringMonochrome()
                }
            case .monochrome:
                if let primary = primary {
                    configuration = .init(paletteColors: [primary])
                } else {
                    configuration = .preferringMonochrome()
                }
            case .hierarchical:
                if let primary = primary {
                    configuration = .init(hierarchicalColor: primary)
                } else {
                    #if os(macOS)
                    configuration = .preferringHierarchical()
                    #elseif canImport(UIKit)
                    configuration = .preferringMonochrome()
                    #endif
                }
            }

            if let font = font {
                switch font {
                case let .textStyle(style):
                    configuration = configuration.font(style)
                case let .pointSize(size):
                    configuration = configuration.font(size: size)
                }
            }

            if let weight = weight {
                configuration = configuration.weight(weight)
            }

            if let scale = scale {
                configuration = configuration.scale(scale)
            }
            return configuration
        }

        public init(colorMode: ColorOption = .monochrome,
                    primary: NSUIColor? = nil,
                    secondary: NSUIColor? = nil,
                    tertiary: NSUIColor? = nil,
                    font: FontOption? = nil,
                    scale: NSUIImage.SymbolScale? = nil)
        {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
            self.colorMode = colorMode
            self.font = font
            self.scale = scale
        }
    }
}

#if os(macOS)
@available(macOS 13.0, *)
public extension NSImageView {
    func configurate(using configuration: ContentConfiguration.SymbolConfiguration) {
        symbolConfiguration = configuration.toImageSymbolConfiguration()
        if configuration.colorMode == .multicolor, let primary = configuration.primary {
            contentTintColor = primary
        }
    }
}

@available(macOS 13.0, *)
public extension NSImage {
    func withSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSImage? {
        if var image = withSymbolConfiguration(configuration.toImageSymbolConfiguration()) {
            if configuration.colorMode == .multicolor, let primary = configuration.primary {
                image = image.withTintColor(primary)
            }
            return image
        }
        return nil
    }
}

#elseif canImport(UIKit)
@available(iOS 16.0, *)
public extension UIImageView {
    func configurate(using configuration: ContentConfiguration.SymbolConfiguration) {
        preferredSymbolConfiguration = configuration.toImageSymbolConfiguration()
        if configuration.colorMode == .multicolor, let primary = configuration.primary {
            tintColor = primary
        }
    }
}

@available(iOS 16.0, *)
public extension UIImage {
    func applyingSymbolConfiguration(_ configuration: ContentConfiguration.SymbolConfiguration) -> NSUIImage? {
        if var image = applyingSymbolConfiguration(configuration.toImageSymbolConfiguration()) {
            if configuration.colorMode == .multicolor, let primary = configuration.primary {
                image = image.withTintColor(primary)
            }
            return image
        }
        return nil
    }
}
#endif
