//
//  NSColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSColor {
        /**
         Creates a dynamic catalog color with the specified light and dark color.

         - Parameters:
            - name: The name of the color.
            - light: The light color.
            - dark: The dark color.
         */
        convenience init(name: NSColor.Name? = nil,
                         light lightModeColor: @escaping @autoclosure () -> NSColor,
                         dark darkModeColor: @escaping @autoclosure () -> NSColor)
        {
            self.init(name: name, dynamicProvider: { appereance in
                if appereance.isLight {
                    return lightModeColor()
                } else {
                    return darkModeColor()
                }
            })
        }

        /// Returns the dynamic light and dark colors.
        var dynamicColors: (light: NSColor, dark: NSColor) {
            let light = self.resolvedColor(for: .aqua)
            let dark = self.resolvedColor(for: .darkAqua)
            return (light, dark)
        }

        /**
         Generates the resolved color for the specified appearance.

         - Parameter appearance: The appearance of the resolved color.
         */
        func resolvedColor(for appearance: NSAppearance? = nil) -> NSColor {
            resolvedColor(for: appearance, colorSpace: nil) ?? self
        }

        /**
         Generates the resolved color for the specified appearance and color space. If color space is `nil`, the color resolves to the first compatible color space.

         - Parameters:
            - appearance: The appearance of the resolved color.
            - colorSpace: The color space of the resolved color. If `nil`, the first compatible color space is used.
         - Returns: A color for the appearance and color space.
         */
        func resolvedColor(for appearance: NSAppearance? = nil, colorSpace: NSColorSpace?) -> NSColor? {
            var color: NSColor?
            if type == .catalog {
                if let colorSpace = colorSpace {
                    if #available(macOS 11.0, *) {
                        let appearance = appearance ?? .currentDrawing()
                        appearance.performAsCurrentDrawingAppearance {
                            color = self.usingColorSpace(colorSpace)
                        }
                    } else {
                        let appearance = appearance ?? .current
                        let current = NSAppearance.current
                        NSAppearance.current = appearance
                        color = usingColorSpace(colorSpace)
                        NSAppearance.current = current
                    }
                } else {
                    for supportedColorSpace in Self.supportedColorSpaces {
                        if let color = resolvedColor(for: appearance, colorSpace: supportedColorSpace) {
                            return color
                        }
                    }
                }
            }
            return color
        }

        
        /**
         Generates the resolved color for the specified appearance provider object (e.g.  `NSApplication`, `NSView` or `NSWindow`).

         It uses the objects's `effectiveAppearance` for resolving the color.

         - Parameter appearanceProvider: The object for the resolved color.
         - Returns: A resolved color for the object.
         */
        func resolvedColor<AppearanceProvider>(for appearanceProvider: AppearanceProvider) -> NSColor where AppearanceProvider: NSAppearanceCustomization {
            resolvedColor(for: appearanceProvider.effectiveAppearance)
        }

        /// Creates a new color object with a supported color space.
        func withSupportedColorSpace() -> NSColor? {
            if type == .componentBased || type == .catalog {
                //   let dynamics = self.dynamicColors
                for supportedColorSpace in Self.supportedColorSpaces {
                    if let supportedColor = usingColorSpace(supportedColorSpace) {
                        return supportedColor
                    }
                    /*
                     if dynamics.light != dynamics.dark,
                         let light = dynamics.light.usingColorSpace(supportedColorSpace),
                         let dark = dynamics.dark.usingColorSpace(supportedColorSpace) {
                             return NSColor(name: self.colorNameComponent, light: light, dark: dark)
                     } else if let supportedColor = usingColorSpace(supportedColorSpace) {
                         return supportedColor
                     }
                     */
                }
            }
            return nil
        }

        /// A `CIColor` representation of the color, or `nil` if the color cannot be accurately represented as `CIColor`.
        var ciColor: CIColor? {
            CIColor(color: self)
        }

        /// A Boolean value that indicates whether the color has a color space. Accessing `colorSpace` directly crashes if a color doesn't have a color space. Therefore it's recommended to use this property prior.
        var hasColorSpace: Bool {
            if type == .pattern {
                return false
            }
            return String(describing: self).contains("customDynamic") == false
        }

        /// Supported color spaces for displaying a color.
        internal static let supportedColorSpaces: [NSColorSpace] = [.sRGB, .deviceRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3]
    }
#endif
