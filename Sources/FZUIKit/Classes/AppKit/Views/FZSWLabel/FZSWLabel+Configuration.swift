//
//  FZSWLabel+Configuration.swift
//  FZSWLabel+Configuration
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    @available(macOS 12.0, *)
    public extension FZSWLabel {
        struct Configuration: Equatable {
            var text: String? = "Florian Zand"
            var systemImage: String? = "photo"

            var textStyle: TextStyle = .body
            var weight: NSFont.Weight = .regular
            var imageScale: NSImage.SymbolScale = .medium

            var foregroundColor: NSColor = .white
            var background: Background = .color(.controlAccentColor)

            var shape: LabelShape = .roundedRect(8)
            var borderWidth: CGFloat = 0.0
            var shadow: ShadowProperties = .black()

            var margin: CGFloat = 6
            var iconToTextPadding: CGFloat = 6
            var iconPlacement: IconPlacement = .left

            public enum Background: Equatable {
                public enum Material {
                    case ultraThin
                    case thin
                    case regular
                    case thick
                    case ultraThick
                    case bar
                    internal var swiftUI: SwiftUI.Material {
                        switch self {
                        case .ultraThin: return .ultraThin
                        case .thin: return .thin
                        case .regular: return .regular
                        case .thick: return .thick
                        case .ultraThick: return .ultraThick
                        case .bar: return .bar
                        }
                    }
                }

                case blur(Material)
                case color(NSColor)
                case clear
                case visualEffect(NSVisualEffectView.Material? = nil)
                internal var color: NSColor? {
                    switch self {
                    case let .color(color): return color
                    default: return nil
                    }
                }

                internal var material: SwiftUI.Material? {
                    switch self {
                    case let .blur(material):
                        return material.swiftUI
                    default: return nil
                    }
                }
            }

            public struct ShadowProperties: Equatable {
                var color: NSColor? = nil
                var opacity: CGFloat = 0.2
                var radius: CGFloat = 1.0
                var x: CGFloat = 2
                var y: CGFloat = 2

                static func none() -> ShadowProperties {
                    return ShadowProperties()
                }

                static func black() -> ShadowProperties {
                    return ShadowProperties(color: .black)
                }

                static func softBlack() -> ShadowProperties {
                    return ShadowProperties(color: .black, opacity: 0.1, radius: 5)
                }
            }

            public enum IconPlacement: Equatable {
                case left
                case right
                case top
                case bottom
            }

            public enum LabelShape: Equatable {
                case capsule
                case roundedRect(CGFloat)
                case rect
                //     case circle
                @InsettableShapeBuilder internal var shape: some InsettableShape {
                    switch self {
                    case let .roundedRect(radius):
                        RoundedRectangle(cornerRadius: radius)
                    case .capsule:
                        Capsule()
                    case .rect:
                        Rectangle()
                        //      case .circle:
                        //          Circle()
                    }
                }
            }

            public enum TextStyle: Equatable {
                case body
                case callout
                case caption1
                case caption2
                case footnote
                case headline
                case subheadline
                case largeTitle
                case title1
                case title2
                case title3
                case size(CGFloat)

                internal var font: Font {
                    if let textStyle = textStyle {
                        return Font.system(textStyle)
                    }
                    return Font.system(size: pointSize ?? 12)
                }

                internal var pointSize: CGFloat? {
                    switch self {
                    case let .size(pointSize): return pointSize
                    default: return nil
                    }
                }

                internal var textStyle: Font.TextStyle? {
                    switch self {
                    case .body: return .body
                    case .callout: return .body
                    case .caption1: return .caption
                    case .caption2: return .caption2
                    case .footnote: return .footnote
                    case .headline: return .headline
                    case .subheadline: return .subheadline
                    case .largeTitle: return .largeTitle
                    case .title1: return .title
                    case .title2: return .title2
                    case .title3: return .title3
                    case .size: return nil
                    }
                }
            }
        }
    }

    @available(macOS 12.0, *)
    extension FZSWLabel.Configuration {
        static func tinted(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = color
            properties.background = .color(color.withAlphaComponent(0.1))
            return properties
        }

        static func blurred() -> Self {
            var properties = Self()
            properties.foregroundColor = .textColor
            properties.background = .blur(.thin)
            return properties
        }

        static func visualEffect() -> Self {
            var properties = Self()
            properties.foregroundColor = .textColor
            properties.background = .visualEffect()
            return properties
        }

        static func filled(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = .textColor
            properties.background = .color(color)
            return properties
        }

        static func capsuled(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = .textColor
            properties.background = .color(color)
            properties.shape = .capsule
            return properties
        }

        static func plain(_ color: NSColor = .textColor) -> Self {
            var properties = Self()
            properties.foregroundColor = color
            properties.background = .clear
            properties.margin = 0.0
            properties.iconToTextPadding = 6.0
            return properties
        }

        static func gray(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = color
            properties.background = .color(.gray)
            return properties
        }

        static func bordered(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = color
            properties.background = .clear
            properties.borderWidth = 1.0
            return properties
        }

        static func white(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = Self()
            properties.foregroundColor = color
            properties.background = .color(.white)
            properties.shadow.radius = 5
            properties.shadow.opacity = 0.1
            return properties
        }

        func tinted(_ color: NSColor = .controlAccentColor) -> Self {
            var properties = self
            properties.foregroundColor = color
            properties.background = .color(color.withAlphaComponent(0.1))
            return properties
        }

        func filled() -> Self {
            var properties = self
            properties.background = .color(properties.foregroundColor)
            properties.foregroundColor = .white
            return properties
        }

        func shape(_ shape: LabelShape) -> Self {
            var properties = self
            properties.shape = shape
            return properties
        }

        func capsule() -> Self {
            var properties = self
            properties.shape = .capsule
            return properties
        }
    }
#endif
