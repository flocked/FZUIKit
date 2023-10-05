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
     Generates the resolved color for the specified appearance,.
     
     - Parameters appearance: The appearance of the resolved color.
     - Returns: A `NSColor` for the appearance.
     */
    func resolvedColor(for appearance: NSAppearance? = nil) -> NSColor {
        var color = self
        if type == .catalog {
            if #available(macOS 11.0, *) {
                let appearance = appearance ?? .currentDrawing()
                appearance.performAsCurrentDrawingAppearance {
                    color = self.usingColorSpace(.sRGB) ?? self
                }
            } else {
                let appearance = appearance ?? .current
                let current = NSAppearance.current
                NSAppearance.current = appearance
                color = usingColorSpace(.sRGB) ?? self
                NSAppearance.current = current
            }
        }
        return color
    }

    /// Creates a new color object with a supported color space
    func withSupportedColorSpace() -> NSColor? {
        let supportedColorSpaces: [NSColorSpace] = [.extendedSRGB, .sRGB, .deviceRGB, .genericRGB, .adobeRGB1998, .displayP3]
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
