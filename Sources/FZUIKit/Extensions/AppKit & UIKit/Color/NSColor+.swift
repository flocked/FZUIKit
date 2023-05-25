//
//  NSColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
public extension NSColor {
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

    var dynamicColors: (light: NSColor, dark: NSColor) {
        let light = self.resolvedColor(for: .aqua)
        let dark = self.resolvedColor(for: .darkAqua)
        return (light, dark)
    }

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

    func withSupportedColorSpace() -> NSColor? {
        let supportedColorSpaces: [NSColorSpace] = [.extendedSRGB, .sRGB, .genericRGB, .adobeRGB1998, .deviceRGB, .displayP3]
        if supportedColorSpaces.contains(colorSpace) == false {
            for supportedColorSpace in supportedColorSpaces {
                if let supportedColor = usingColorSpace(supportedColorSpace) {
                    return supportedColor
                }
            }
            return nil
        }
        return self
    }

    static var label: NSColor {
        return NSColor.labelColor
    }
}
#endif
