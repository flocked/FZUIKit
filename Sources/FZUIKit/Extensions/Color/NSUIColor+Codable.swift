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

extension NSUIColor: Swift.Encodable, Swift.Decodable {
    public enum CodingKeys: String, CodingKey {
        case light
        case dark
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamicColors = dynamicColors
        try container.encode(dynamicColors.light.values, forKey: .light)
        if dynamicColors.light != dynamicColors.dark {
            try container.encode(dynamicColors.dark.values, forKey: .dark)
        }
        #else
        try container.encode(values, forKey: .light)
        #endif
    }
    
    fileprivate var values: [CGFloat] {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        #if os(macOS)
        if let color = usingColorSpace(.deviceRGB) ?? usingColorSpace(.genericRGB) {
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let light: [CGFloat] = try container.decode(.light)
        #if os(macOS) || os(iOS) || os(tvOS)
        if let dark: [CGFloat] = try container.decodeIfPresent(.dark) {
            self = NSUIColor(light:  Self(light), dark: Self(dark)) as! Self
        } else {
            self = Self(light)
        }
        #else
        self = Self(light)
        #endif
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
        default: self = Self(white: 0.0, alpha: 0.0)
        }
    }
}

#endif
