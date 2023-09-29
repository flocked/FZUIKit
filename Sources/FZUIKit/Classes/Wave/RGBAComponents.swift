//
//  File.swift
//  
//
//  Created by Florian Zand on 22.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

internal struct HSLAComponents: Equatable {
    let h: CGFloat
    let s: CGFloat
    let l: CGFloat
    let a: CGFloat
    init(h: CGFloat, s: CGFloat, l: CGFloat, a: CGFloat) {
        self.h = h
        self.s = s
        self.l = l
        self.a = a
    }
    init(color: NSUIColor) {
        let components = color.hslaComponents()
        self.h = components.hue
        self.s = components.saturation
        self.l = components.lightness
        self.a = components.alpha
    }
    
    var color: NSUIColor { NSUIColor(hue: h, saturation: s, lightness: l, alpha: a) }
}

internal struct RGBAComponents: Equatable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat

    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(color: NSUIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        let color = color.withSupportedColorSpace() ?? color
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(r: r, g: g, b: b, a: a)
    }

    var color: NSUIColor {
        NSUIColor(red: r, green: g, blue: b, alpha: a)
    }
}
#endif
