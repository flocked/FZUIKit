//
//  File.swift
//  
//
//  Created by Florian Zand on 06.10.23.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension NSUIColor {
    /// Returns the HSBA components of the color.
    func hsbaComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        var color: NSUIColor? = self
#if os(macOS)
        if self == NSUIColor.white {
            return (hue: 0, saturation: 0, brightness: 1, alpha: alphaComponent)
        } else if self == NSUIColor.black {
            return (hue: 0, saturation: 0, brightness: 0, alpha: alphaComponent)
        }
        color = withSupportedColorSpace()
#endif
        color?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: h, saturation: s, brightness: b, alpha: a)
    }
    
    /// The hue component between 0.0 and 1.0
    var hueComponent: CGFloat {
        hsbaComponents().hue
    }
    
    /// The saturation component between 0.0 and 1.0
    var saturationComponent: CGFloat {
        hsbaComponents().saturation
    }
    
    /// The brightness component between 0.0 and 1.0
    var brightnessComponent: CGFloat {
        hsbaComponents().brightness
    }
}
