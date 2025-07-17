//
//  NSUIColor+Codable.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS) || canImport(UIKit)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIColor: Codable {
    public enum CodingKeys: String, CodingKey {
        case light
        case dark
    }
    
    public func encode(to encoder: Encoder) throws {
        let dynamicColors = dynamicColors

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dynamicColors.light.values, forKey: .light)
        if dynamicColors.light != dynamicColors.dark {
            try container.encode(dynamicColors.dark.values, forKey: .dark)
        }
    }
    
    fileprivate var values: [CGFloat] {
        var r, g, b, a, w: CGFloat
        (r, g, b, a, w) = (0, 0, 0, 0, 0)
        #if os(macOS)
        if let color = withSupportedColorSpace() {
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            return [r, g, b, a]
        }
        #else
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return [r, g, b, a]
        } else if getWhite(&r, alpha: &a) {
            return [r, a]
        } else if getHue(&r, saturation: &g, brightness: &b, alpha: &a) {
            return [r, g, b, a, 0.0]
        }
        #endif
        return [0, 0]
    }
}

extension Decodable where Self: NSUIColor {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let light = try values.decode([CGFloat].self, forKey: .light)
        if let dark = try? values.decode([CGFloat].self, forKey: .dark) {
            self = NSUIColor(light:  Self(light), dark: Self(dark)) as! Self
        } else {
            self = Self(light)
        }
    }
    
    fileprivate init(_ components: [CGFloat]) {
        switch components.count {
        case 2:
            self = Self(white: components[0], alpha: components[1])
        case 4:
            self = Self(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        case 5:
            #if os(macOS)
            self = Self(deviceCyan: components[0], magenta: components[1], yellow: components[2], black: components[3], alpha: components[4])
            #else
            self = Self(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[3])
            #endif
        default:
            self = Self(white: 0.0, alpha: 0.0)
        }
    }
}

#endif
