//
//  NSUIColor+RGB.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

public extension NSUIColor {
    /// Returns the CMYB (cyan, magenta, yellow, black, alpha) components of the color.
    func cmybComponents() -> CMYBComponents {
        var cmyb = CMYBComponents(0, 0, 0, 0, 1.0)
        #if os(macOS)
        if colorSpace == NSColorSpace.deviceCMYK || colorSpace == NSColorSpace.genericCMYK {
            getCyan(&cmyb.cyan, magenta: &cmyb.magenta, yellow: &cmyb.yellow, black: &cmyb.black, alpha: &cmyb.alpha)
        } else if let color = usingColorSpace(.deviceCMYK) ?? usingColorSpace(.genericCMYK) {
            color.getCyan(&cmyb.cyan, magenta: &cmyb.magenta, yellow: &cmyb.yellow, black: &cmyb.black, alpha: &cmyb.alpha)
        }
        #else
        cmyb = cgColor.cmybComponents() ?? cmyb
        #endif
        return cmyb
    }
    
    /// Creates a color using the RGBA components.
    convenience init(_ cmybComponents: CMYBComponents) {
        #if os(macOS)
        self.init(deviceCyan: cmybComponents.cyan, magenta: cmybComponents.magenta, yellow: cmybComponents.yellow, black: cmybComponents.black, alpha: cmybComponents.alpha)
        #else
        self.init(cgColor: CGColor(genericCMYKCyan: cmybComponents.cyan, magenta: cmybComponents.magenta, yellow: cmybComponents.yellow, black: cmybComponents.black, alpha: cmybComponents.alpha))

        #endif
    }
}

public extension CGColor {
    /// Returns the CMYB (cyan, magenta, yellow, black, alpha) components of the color.
    func cmybComponents() -> CMYBComponents? {
        #if os(macOS)
        if let cmybComponents = nsUIColor?.cmybComponents() {
            return cmybComponents
        }
        #endif
        var color = self
        if color.colorSpace?.model != .cmyk, #available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *) {
            color = color.converted(to: CGColorSpaceCreateDeviceCMYK()) ?? color
        }
        guard color.colorSpace?.model == .cmyk, let components = color.components else { return nil }
        switch components.count {
        case 4:
            return CMYBComponents(components[0], components[1], components[2], components[3], 1.0)
        case 5:
            return CMYBComponents(components[0], components[1], components[2], components[3],  components[4])
        default:
            return nil
        }
    }
}

public extension Color {
    /// Creates a color using the CMYB components.
    init(_ cmybComponents: CMYBComponents) {
        self = NSUIColor(cmybComponents).swiftUI
    }
}

public extension CFType where Self == CGColor {
    /// Creates a color using the CMYB components.
    init(_ cmybComponents: CMYBComponents) {
        self = NSUIColor(cmybComponents).cgColor
    }
}


/// The CMYBA (cyan, magenta, yellow, black, alpha) components of a color.
public struct CMYBComponents: Codable, Hashable {
    /// The cyan component of the color (between `0.0` and `1.0`).
    public var cyan: CGFloat = 0.0
    
    /// Sets the cyan component of the color (between `0.0` and `1.0`).
    @discardableResult
    public func cyan(_ cyan: CGFloat) -> Self {
        var components = self
        components.cyan = cyan
        return components
    }
    
    /// The magenta component of the color (between `0.0` and `1.0`).
    public var magenta: CGFloat = 0.0
    
    /// Sets the magenta component of the color (between `0.0` and `1.0`).
    @discardableResult
    public func magenta(_ magenta: CGFloat) -> Self {
        var components = self
        components.magenta = magenta
        return components
    }

    /// The yellow component of the color (between `0.0` and `1.0`).
    public var yellow: CGFloat = 0.0
    
    /// Sets the yellow component of the color (between `0.0` and `1.0`).
    @discardableResult
    public func yellow(_ yellow: CGFloat) -> Self {
        var components = self
        components.yellow = yellow
        return components
    }
    
    /// The black component of the color (between `0.0` and `1.0`).
    public var black: CGFloat = 0.0
    
    /// Sets the black component of the color (between `0.0` and `1.0`).
    @discardableResult
    public func black(_ black: CGFloat) -> Self {
        var components = self
        components.black = black
        return components
    }

    /// The alpha value of the color (between `0.0` and `1.0`).
    public var alpha: CGFloat = 1.0
    
    /// Sets the alpha value of the color (between `0.0` and `1.0`).
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }

    /**
     Creates CMYBA components with the specified cyan, magenta, yellow, black and alpha components.
     
     - Parameters:
        - cyan: The cyan component of the color (between `0.0` and `1.0`).
        - magenta: The magenta component of the color (between `0.0` and `1.0`).
        - yellow: The yellow component of the color (between `0.0` and `1.0`).
        - black: The black component of the color (between `0.0` and `1.0`).
        - alpha: The alpha value of the color (between `0.0` and `1.0`).
     */
    public init(cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat, alpha: CGFloat = 1.0) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
        self.alpha = alpha
    }
    
    init(_ cyan: CGFloat, _ magenta: CGFloat, _ yellow: CGFloat, _ black: CGFloat, _ alpha: CGFloat) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
        self.alpha = alpha
    }
}
