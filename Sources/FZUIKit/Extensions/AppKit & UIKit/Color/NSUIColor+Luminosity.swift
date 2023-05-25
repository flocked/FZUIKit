//
//  File.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import FZSwiftUtils

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension NSUIColor {
    var brightness: CGFloat {
        #if os(macOS)
            let color: NSUIColor? = usingColorSpace(.deviceRGB)
        #else
            let color: NSUIColor? = self
        #endif
        if let components = color?.cgColor.components {
            return ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        }
        #if os(macOS)
            return brightnessComponent
        #else
            return 1.0
        #endif
    }

    var luminance: CGFloat {
        let components = rgbaComponents()
        let componentsArray = [components.red, components.green, components.blue].map { val -> CGFloat in
            guard val <= 0.03928 else { return pow((val + 0.055) / 1.055, 2.4) }

            return val / 12.92
        }
        return (0.2126 * componentsArray[0]) + (0.7152 * componentsArray[1]) + (0.0722 * componentsArray[2])
    }

    var luminosity: CGFloat {
        #if os(macOS)
            var color: NSUIColor = self
            let supportedColorSpaces: [NSColorSpace] = [.sRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .deviceRGB, .displayP3]
            if supportedColorSpaces.contains(colorSpace) == false {
                color = (usingColorSpace(.extendedSRGB) ?? usingColorSpace(.genericRGB)) ?? self
            }

            let coreColour = CIColor(color: color)!
        #else
            let coreColour = CIColor(color: self)
        #endif
        let rgb: [CGFloat] = [coreColour.red.clamped(max: 1.0), coreColour.green.clamped(max: 1.0), coreColour.blue.clamped(max: 1.0)]
        guard let minRGB = rgb.min(), let maxRGB = rgb.max() else { return 1.0 }
        return ((minRGB + maxRGB) / 2)
    }

    func withLuminosity(_ newLuminosity: CGFloat) -> NSUIColor {
        // 1 - Convert the RGB values to the range 0-1
        #if os(macOS)
            let coreColour = CIColor(color: self)!
        #else
            let coreColour = CIColor(color: self)
        #endif
        let alpha = coreColour.alpha
        let red = coreColour.red.clamped(max: 1.0)
        let green = coreColour.green.clamped(max: 1.0)
        let blue = coreColour.blue.clamped(max: 1.0)
        let rgb: [CGFloat] = [red, green, blue]
        guard let minRGB = rgb.min(), let maxRGB = rgb.max() else { return self }

        // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
        var luminosity = (minRGB + maxRGB) / 2

        // 4 - The next step is to find the Saturation.
        // 4a - if min and max RGB are the same, we have 0 saturation
        var saturation: CGFloat = 0

        // 5 - Now we know that there is Saturation we need to do check the level of the Luminance in order to select the correct formula.
        //     If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
        //     If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
        if luminosity <= 0.5 {
            saturation = (maxRGB - minRGB) / (maxRGB + minRGB)
        } else if luminosity > 0.5 {
            saturation = (maxRGB - minRGB) / (2.0 - maxRGB - minRGB)
        } else {
            // 0 if we are equal RGBs
        }

        // 6 - The Hue formula is depending on what RGB color channel is the max value. The three different formulas are:
        var hue: CGFloat = 0
        // 6a - If Red is max, then Hue = (G-B)/(max-min)
        if red == maxRGB {
            hue = (green - blue) / (maxRGB - minRGB)
        }
        // 6b - If Green is max, then Hue = 2.0 + (B-R)/(max-min)
        else if green == maxRGB {
            hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
        }
        // 6c - If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
        else if blue == maxRGB {
            hue = 4.0 + ((red - green) / (maxRGB - minRGB))
        }

        // 7 - The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
        //     If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
        if hue < 0 {
            hue += 360
        } else {
            hue = hue * 60
        }

        // we want to convert the luminosity. So we will.
        luminosity = newLuminosity

        // Now we need to convert back to RGB

        // 1 - If there is no Saturation it means that it’s a shade of grey. So in that case we just need to convert the Luminance and set R,G and B to that level.
        if saturation == 0 {
            return NSUIColor(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, alpha: alpha)
        }

        // 2 - If Luminance is smaller then 0.5 (50%) then temporary_1 = Luminance x (1.0+Saturation)
        //     If Luminance is equal or larger then 0.5 (50%) then temporary_1 = Luminance + Saturation – Luminance x Saturation
        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }

        // 3 - Final calculated temporary variable
        let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne

        // 4 - The next step is to convert the 360 degrees in a circle to 1 by dividing the angle by 360
        let convertedHue = hue / 360

        // 5 - Now we need a temporary variable for each colour channel
        let tempRed = (convertedHue + 0.333).convertToColourChannel()
        let tempGreen = convertedHue.convertToColourChannel()
        let tempBlue = (convertedHue - 0.333).convertToColourChannel()

        // 6 we must run up to 3 tests to select the correct formula for each colour channel, converting to RGB
        let newRed = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)

        return NSUIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}

internal extension CGFloat {
    func convertToColourChannel() -> CGFloat {
        let min: CGFloat = 0
        let max: CGFloat = 1
        let modifier: CGFloat = 1
        if self < min {
            return self + modifier
        } else if self > max {
            return self - max
        } else {
            return self
        }
    }

    func convertToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
        if 6 * self < 1 {
            return temp2 + (temp1 - temp2) * 6 * self
        } else if 2 * self < 1 {
            return temp1
        } else if 3 * self < 2 {
            return temp2 + (temp1 - temp2) * (0.666 - self) * 6
        } else {
            return temp2
        }
    }
}
