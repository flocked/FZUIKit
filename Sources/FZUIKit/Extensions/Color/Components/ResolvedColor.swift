//
//  ResolvedColor.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import Foundation
import FZSwiftUtils
import Accelerate
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A components based representation of a color.
public protocol ColorModel: CustomStringConvertible {
    /// The components of the color.
    var components: [Double] { get }
    /// Creates the color with the specified color components.
    init(_ components: [Double])
    /// The color space of the color.
    static var colorSpace: CGColorSpace { get }
}

public extension ColorModel {
    /// Blends the color with another color.
    func blended(withFraction fraction: Double, of color: Self) -> Self {
        Self(vDSP.linearInterpolate(components, color.components, using: fraction))
    }
    
    /// Creates a new color from by blending the color with another color.
    mutating func blend(withFraction fraction: Double, of color: Self) {
        self = blended(withFraction: fraction, of: color)
    }
    
    /// `CGColor` representation of the color.
    var cgColor: CGColor {
        CGColor(self)
    }
    
    /// SwiftUI`Color` representation of the color.
    var color: Color {
        Color(self)
    }
    
    #if os(macOS)
    /// `NSColor` representation of the color.
    var nsColor: NSColor {
        NSColor(self)
    }
    #else
    /// `UIColor` representation of the color.
    var uiColor: UIColor {
        UIColor(self)
    }
    #endif
}

extension NSObjectProtocol where Self == NSUIColor {
    /// Creates the color with the specified color components.
    public init(_ colorComponents: ColorModel) {
        #if os(macOS)
        self.init(cgColor: CGColor(colorComponents))!
        #else
        self.init(cgColor: CGColor(colorComponents))
        #endif
    }
}

extension CFType where Self == CGColor {
    /// Creates the color with the specified color components.
    public init<V: ColorModel>(_ colorComponents: V) {
        self.init(colorSpace: V.colorSpace, components: (colorComponents as! ColorModelInternal)._components.map({CGFloat($0)}))!
    }
}

extension Color {
    /// Creates the color with the specified color components.
    public init(_ colorComponents: ColorModel) {
        #if os(macOS)
        self.init(nsColor: colorComponents.nsColor)
        #else
        self.init(uiColor: colorComponents.uiColor)
        #endif
    }
}

fileprivate protocol ColorModelInternal: ColorModel {
    var _components: [Double] { get }
}

extension ColorModelInternal {
    var _components: [Double] { components }
}

/// The color components for a color.
public struct ColorComponents {
    /// The color components for a color in the sRGB color space.
    public struct SRGB: ColorModelInternal {
        /// The red component of the color.
        public var red: Double
        /// The green component of the color.
        public var green: Double
        /// The blue component of the color.
        public var blue: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        /// The linear red component of the color.
        public var linearRed: Double {
            get { Self.srgbToLinear(red) }
            set { red = Self.linearToSRGB(newValue) }
        }
        
        /// The linear green component of the color.
        public var linearGreen: Double {
            get { Self.srgbToLinear(green) }
            set { green = Self.linearToSRGB(newValue) }
        }
        
        /// The linear blue component of the color.
        public var linearBlue: Double {
            get { Self.srgbToLinear(blue) }
            set { blue = Self.linearToSRGB(newValue) }
        }
        
        public var components: [Double] { [red, green, blue, alpha] }
        
        public var description: String {
            "[red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)]"
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            let lR = linearRed
            let lG = linearGreen
            let lB = linearBlue
            let Lc = cbrt(0.4122214708*lR + 0.5363325363*lG + 0.0514459929*lB)
            let Mc = cbrt(0.2119034982*lR + 0.6806995451*lG + 0.1073969566*lB)
            let Sc = cbrt(0.0883024619*lR + 0.2817188376*lG + 0.6299787005*lB)
            let outL = 0.2104542553*Lc + 0.7936177850*Mc - 0.0040720468*Sc
            let outA = 1.9779984951*Lc - 2.4285922050*Mc + 0.4505937099*Sc
            let outB = 0.0259040371*Lc + 0.7827717662*Mc - 0.8086757660*Sc
            return OKLAB(lightness: outL, greenRed: outA, blueYellow: outB, alpha: alpha)
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            oklab.oklch
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            hsb.hsl
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let maxV = max(red, max(green, blue))
            let minV = min(red, min(green, blue))
            let delta = maxV - minV
            
            var hue = 0.0
            let saturation = (maxV == 0) ? 0 : delta / maxV
            let brightness = maxV
            
            if delta != 0 {
                if maxV == red { hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6) }
                else if maxV == green { hue = (blue - red) / delta + 2 }
                else { hue = (red - green) / delta + 4 }
                hue /= 6
                if hue < 0 { hue += 1 }
            }
            return HSB(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            let black = 1.0 - max(red, max(green, blue))
            if black >= 1.0 - 1e-6 {
                return CMYK(cyan: 0.0, magenta: 0.0, yellow: 0.0, black: black, alpha: alpha)
            }
            let cyan = (1.0 - red - black) / (1.0 - black)
            let magenta = (1.0 - green - black) / (1.0 - black)
            let yellow = (1.0 - blue - black) / (1.0 - black)
            return CMYK(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: XYZ {
            let r = linearRed
            let g = linearGreen
            let b = linearBlue
            let x = 0.4124564*r + 0.3575761*g + 0.1804375*b
            let y = 0.2126729*r + 0.7151522*g + 0.0721750*b
            let z = 0.0193339*r + 0.1191920*g + 0.9503041*b
            return XYZ(x: x, y: y, z: z, alpha: alpha)
        }
        
        /// The color in the CIE Lab color space.
        public var lab: LAB {
            xyz.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            Gray(white: 0.2126 * red + 0.7152 * green + 0.0722 * blue, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        
        /// Creates the color with the specified linear components.
        public init(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = Self.linearToSRGB(red)
            self.green = Self.linearToSRGB(green)
            self.blue = Self.linearToSRGB(blue)
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in SRGB color space.")
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        public static let colorSpace = CGColorSpace(name: .extendedSRGB)!
        
        @inline(__always)
        private static func srgbToLinear(_ c: Double) -> Double {
            c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        @inline(__always)
        private static func linearToSRGB(_ c: Double) -> Double {
            c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055
        }
    }
    
    /// The color components for a color in the OKLAB color space.
    public struct OKLAB: ColorModelInternal {
        /// The lightness component of the color.
        public var lightness: Double
        /// The green-red component of the color.
        public var greenRed: Double
        /// The blue-yellow component of the color.
        public var blueYellow: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [lightness, greenRed, blueYellow, alpha] }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            let a = greenRed, b = blueYellow
            let chroma = sqrt(a*a + b*b)
            var hue = atan2(b, a) / (2.0 * Double.pi)
            if hue < 0 { hue += 1 }
            return OKLCH(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let Lc = lightness + 0.3963377774*greenRed + 0.2158037573*greenRed
            let Mc = lightness - 0.1055613458*greenRed - 0.0638541728*greenRed
            let Sc = lightness - 0.0894841775*greenRed - 1.2914855480*greenRed
            let L3 = Lc * Lc * Lc
            let M3 = Mc * Mc * Mc
            let S3 = Sc * Sc * Sc
            let red =  4.0767416621*L3 - 3.3077115913*M3 + 0.2309699292*S3
            let green = -1.2684380046*L3 + 2.6097574011*M3 - 0.3413193965*S3
            let blue = -0.0041960863*L3 - 0.7034186147*M3 + 1.7076147010*S3
            return SRGB(linearRed: red, green: green, blue: blue, alpha: alpha)
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.greenRed = greenRed
            self.blueYellow = blueYellow
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = SRGB.colorSpace
    }
    
    /// The color components for a color in the OKLCH color space.
    public struct OKLCH: ColorModelInternal {
        /// The lightness component of the color.
        public var lightness: Double
        /// The chroma component of the color.
        public var chroma: Double
        /// The hue component of the color.
        public var hue: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[lightness: \(lightness), chroma: \(chroma), hue: \(hue), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [lightness, chroma, hue, alpha] }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            let hRad = hue * 2.0 * Double.pi
            let greenRed = chroma * cos(hRad)
            let blueYellow = chroma * sin(hRad)
            return OKLAB(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            oklab.rgb
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.chroma = chroma
            self.hue = hue
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLCH color space.")
            self.init(lightness: components[0], chroma: components[1], hue: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = SRGB.colorSpace
    }
    
    /// The color components for a color in the HSB color space.
    public struct HSB: ColorModelInternal {
        /// The hue component of the color.
        public var hue: Double
        /// The saturation component of the color.
        public var saturation: Double
        /// The brightness component of the color.
        public var brightness: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[hue: \(hue), saturation: \(saturation), brightness: \(brightness), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [hue, saturation, brightness, alpha] }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            let lightness = brightness * (1 - saturation * 0.5)
            let saturation: Double
            if lightness == 0 || lightness >= brightness {
                saturation = 0
            } else {
                saturation = (brightness - lightness) / min(lightness, brightness - lightness)
            }
            return HSL(hue: Self.wrapUnit(hue), saturation: saturation, lightness: lightness, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            if saturation <= 0 { return SRGB(red: brightness, green: brightness, blue: brightness, alpha: alpha) }
            var hue = hue.truncatingRemainder(dividingBy: 1)
            if hue < 0 { hue += 1 }
            let h = hue * 6.0
            let i = Int(floor(h))
            let f = h - Double(i)
            let p = brightness * (1.0 - saturation)
            let q = brightness * (1.0 - saturation * f)
            let t = brightness * (1.0 - saturation * (1.0 - f))
            
            switch (i % 6) {
            case 0:
                return SRGB(red: brightness, green: t, blue: p, alpha: alpha)
            case 1:
                return SRGB(red: q, green: brightness, blue: p, alpha: alpha)
            case 2:
                return SRGB(red: p, green: brightness, blue: t, alpha: alpha)
            case 3:
                return SRGB(red: p, green: q, blue: brightness, alpha: alpha)
            case 4:
                return SRGB(red: t, green: p, blue: brightness, alpha: alpha)
            default:
                return SRGB(red: brightness, green: p, blue: q, alpha: alpha)
            }
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSB color space.")
            self.init(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        @inline(__always)
        private static func wrapUnit(_ x: Double) -> Double {
            let r = x.truncatingRemainder(dividingBy: 1)
            return r < 0 ? r + 1 : r
        }
        
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = SRGB.colorSpace
    }
    
    /// The color components for a color in the HSL color space.
    public struct HSL: ColorModelInternal {
        /// The hue component of the color.
        public var hue: Double
        /// The saturation component of the color.
        public var saturation: Double
        /// The lightness component of the color.
        public var lightness: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[hue: \(hue), saturation: \(saturation), lightness: \(lightness), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [hue, saturation, lightness, alpha] }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            hsb.rgb
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let l = lightness
            let s_hsl = saturation
            let v = l + s_hsl * min(l, max(0, 1 - l))
            let s_hsv: Double
            if v == 0 {
                s_hsv = 0
            } else {
                s_hsv = 2 * (1 - l / v)
            }
            return HSB(hue: Self.wrapUnit(hue), saturation: s_hsv, brightness: v, alpha: alpha)
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
            self.hue = hue
            self.saturation = saturation
            self.lightness = lightness
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSL color space.")
            self.init(hue: components[0], saturation: components[1], lightness: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        @inline(__always)
        private static func wrapUnit(_ x: Double) -> Double {
            let r = x.truncatingRemainder(dividingBy: 1)
            return r < 0 ? r + 1 : r
        }
        
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = SRGB.colorSpace
    }
    
    /// The color components for a color in the CMYK color space.
    public struct CMYK: ColorModelInternal {
        /// The cyan component of the color.
        public var cyan: Double
        /// The magenta component of the color.
        public var magenta: Double
        /// The yellow component of the color.
        public var yellow: Double
        /// The black component of the color.
        public var black: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[cyan: \(cyan), magenta: \(magenta), yellow: \(yellow), black: \(black), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [cyan, magenta, yellow, black, alpha] }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let k = black
            let r = (1 - cyan) * (1 - k)
            let g = (1 - magenta) * (1 - k)
            let b = (1 - yellow) * (1 - k)
            return SRGB(red: r, green: g, blue: b, alpha: alpha)
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
            self.black = black
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 4, "You need to provide at least 4 components for a color in CMYK color space.")
            self.init(cyan: components[0], magenta: components[1], yellow: components[2], black: components[3], alpha: components[safe: 4] ?? 1.0)
        }
        
        public static let colorSpace = CGColorSpace(name: .genericCMYK)!
    }
    
    /// The color components for a color in the XYZ color space.
    public struct XYZ: ColorModelInternal {
        /// The x component of the color.
        public var x: Double
        /// The y component of the color.
        public var y: Double
        /// The z component of the color.
        public var z: Double
                /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[x: \(x), y: \(y), z: \(z), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [x, y, z, alpha] }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let rL =  3.2404542 * x - 1.5371385 * y - 0.4985314 * z
            let gL = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z
            let bL =  0.0556434 * x - 0.2040259 * y + 1.0572252 * z
            return SRGB(linearRed: rL, green: gL, blue: bL, alpha: alpha)
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            let fx = labF(x / D65.Xn)
            let fy = labF(y / D65.Yn)
            let fz = labF(z / D65.Zn)
            return LAB(lightness: 116.0 * fy - 16.0, greenRed: 500.0 * (fx - fy), blueYellow: 200.0 * (fy - fz), alpha: alpha)
        }

        /// Creates the color with the specified components.
        public init(x: Double, y: Double, z: Double, alpha: Double = 1.0) {
            self.x = x
            self.y = y
            self.z = z
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in XYZ color space.")
            self.init(x: components[0], y: components[1], z: components[2], alpha: components[safe: 3] ?? 0.0)
        }
              
        #if os(macOS)
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = CGColorSpace(name: .extendedSRGB)!
        #else
        fileprivate var _components: [Double] { components }
        public static let colorSpace = CGColorSpace(name: .genericXYZ)!
        #endif
        
        @inline(__always)
        private func labF(_ t: Double) -> Double {
            t > 0.008856451679 ? cbrt(t) : 7.787037037 * t + 16.0 / 116.0
        }
    }
    
    /// The color components for a color in the CIE Lab color space.
    public struct LAB: ColorModelInternal {
        /// The lightness component of the color.
        public var lightness: Double
        /// The green-red component of the color.
        public var greenRed: Double
        /// The blue-yellow component of the color.
        public var blueYellow: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "[lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha)]"
        }
        
        public var components: [Double] { [lightness, greenRed, blueYellow, alpha] }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            xyz.rgb
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            let fy = (lightness + 16.0) / 116.0
            let fx = fy + greenRed / 500.0
            let fz = fy - blueYellow / 200.0
            return XYZ(x: fInv(fx) * D65.Xn, y: fInv(fy) * D65.Yn, z: fInv(fz) * D65.Zn, alpha: alpha)
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.greenRed = greenRed
            self.blueYellow = blueYellow
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in CIE LAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        @inline(__always)
        private func fInv(_ t: Double) -> Double {
            let t3 = t * t * t
            return t3 > 0.008856 ? t3 : (t - 16.0/116.0) / 7.787
        }
        
        #if os(macOS)
        fileprivate var _components: [Double] { rgb.components }
        public static let colorSpace = CGColorSpace(name: .extendedSRGB)!
        #else
        fileprivate var _components: [Double] { components }
        public static let colorSpace = CGColorSpace(name: .genericLab)!
        #endif
    }
    
    /// The color components for a color in the grayscale color space.
    public struct Gray: ColorModelInternal {
        /// The white component of the color.
        public var white: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var components: [Double] { [white, alpha] }
        
        public var description: String {
            "[white: \(white), alpha: \(alpha)]"
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            SRGB(red: white, green: white, blue: white, alpha: alpha)
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// Creates the color with the specified components.
        public init(white: Double, alpha: Double = 1.0) {
            self.white = white
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 1, "You need to provide at least 1 component for a color in grayscale color space.")
            self.init(white: components[0], alpha: components[safe: 1] ?? 1.0)
        }
                
        public static let colorSpace = CGColorSpace(name: .extendedGray)!
    }
    
    private enum D65 {
        static let Xn = 0.95047
        static let Yn = 1.00000
        static let Zn = 1.08883
    }
}

public extension ColorModel where Self == ColorComponents.SRGB {
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(red: Double, green: Double, blue: Double, alpha: Double) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.HSB {
    /// Returns the color components for a color in the HSB color space.
    static func hsb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSB color space.
    static func hsb(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.HSL {
    /// Returns the color components for a color in the HSL color space.
    static func hsl(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSL color space.
    static func hsl(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.CMYK {
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) -> Self {
        .init(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.OKLAB {
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.OKLCH {
    /// Returns the color components for a color in the OKLCH color space.
    static func oklch(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the OKLCH color space.
    static func oklch(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.XYZ {
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(x: Double, y: Double, z: Double, alpha: Double = 1.0) -> Self {
        .init(x: x, y: y, z: z, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.LAB {
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}

public extension ColorModel where Self == ColorComponents.Gray {
    /// Returns the color components for a color in the grayscale color space.
    static func gray(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the grayscale color space.
    static func gray(white: Double, alpha: Double = 1.0) -> Self {
        .init(white: white, alpha: alpha)
    }
}

/*
 public struct ColorSpace {
     /// The name of the color space.
     public let name: String
     /// The number of components of the color space.
     public let numberOfComponents: Int
     public let cgColorSpace: CGColorSpace
     /// The color model representing the color components of a color for the color space.
     public let model: ColorModel.Type
     
     public static let srgb = Self("SRGB", model: SRGB.self)
     public static let hsl = Self("HSL", model: HSL.self)
     public static let hsb = Self("HSB", model: HSB.self)
     public static let oklab = Self("OKLAB", model: OKLAB.self)
     public static let oklch = Self("OKLCH", model: OKLCH.self)
     public static let xyz = Self("XYZ", model: XYZ.self)
     public static let lab = Self("LAB", model: LAB.self)
     public static let grayscale = Self("Grayscale", model: Gray.self, numberOfComponents: 2, cgColorSpace: CGColorSpace(name: .extendedGray)!)
     public static let cmyk = Self("CMYK", model: CMYK.self, numberOfComponents: 5, cgColorSpace: CGColorSpace(name: .genericCMYK)!)
     
     init(_ name: String, model: ColorModel.Type, numberOfComponents: Int = 4, cgColorSpace: CGColorSpace = CGColorSpace(name: .extendedSRGB)!) {
         self.name = name
         self.numberOfComponents = numberOfComponents
         self.cgColorSpace = cgColorSpace
         self.model = model
     }
 }
 */
