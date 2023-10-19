//
//  NSColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
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
            if appereance.name == .vibrantLight || appereance.name == .aqua {
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
     
     - Parameters appearance: The appearance of the resolved color.
     - Returns: A `NSColor` for the appearance.
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
        var color: NSColor? = nil
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
                let supportedColorSpaces: [NSColorSpace] = [.sRGB, .deviceRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3]
                for supportedColorSpace in supportedColorSpaces {
                    if let color = resolvedColor(for: appearance, colorSpace: supportedColorSpace) {
                        return color
                    }
                }
            }
        }
        return color
    }

    /// Creates a new color object with a supported color space
    func withSupportedColorSpace() -> NSColor? {
        let supportedColorSpaces: [NSColorSpace] = [.sRGB, .deviceRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3]
        let needsConverting: Bool
        if (self.className == "NSDynamicSystemColor") {
            needsConverting = true
        } else {
            needsConverting = (supportedColorSpaces.contains(self.colorSpace) == false)
        }
        
        if (needsConverting) {
            for supportedColorSpace in supportedColorSpaces {
                if let supportedColor = usingColorSpace(supportedColorSpace) {
                    return supportedColor
                }
            }
            return nil
        }
        return self
    }
}
#endif
