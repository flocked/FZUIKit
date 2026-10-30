//
//  NSAppearance+.swift
//
//
//  Created by Florian Zand on 06.08.22.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSAppearance {
    /// Returns a aqua appearance.
    static var aqua: NSAppearance {
        NSAppearance(named: .aqua)!
    }

    /// Returns a dark aqua appearance.
    static var darkAqua: NSAppearance {
        NSAppearance(named: .darkAqua)!
    }

    /// Returns a vibrant light appearance.
    static var vibrantLight: NSAppearance {
        NSAppearance(named: .vibrantLight)!
    }

    /// Returns a vibrant dark appearance.
    static var vibrantDark: NSAppearance {
        NSAppearance(named: .vibrantDark)!
    }

    /// Returns a high-contrast version of the standard light system appearance.
    static var accessibilityHighContrastAqua: NSAppearance {
        NSAppearance(named: .accessibilityHighContrastAqua)!
    }

    /// Returns a high-contrast version of the standard dark system appearance.
    static var accessibilityHighContrastDarkAqua: NSAppearance {
        NSAppearance(named: .accessibilityHighContrastDarkAqua)!
    }

    /// Returns a high-contrast version of the dark vibrant system appearance.
    static var accessibilityHighContrastVibrantDark: NSAppearance {
        NSAppearance(named: .accessibilityHighContrastVibrantDark)!
    }

    /// Returns a high-contrast version of the light vibrant system appearance.
    static var accessibilityHighContrastVibrantLight: NSAppearance {
        NSAppearance(named: .accessibilityHighContrastVibrantLight)!
    }

    /**
     A Boolean value indicating whether the appearance is light.

     The following appearances are light: ``AppKit/NSAppearance/aqua``, ``AppKit/NSAppearance/vibrantLight``, ``AppKit/NSAppearance/accessibilityHighContrastAqua`` and ``AppKit/NSAppearance/accessibilityHighContrastVibrantLight``.
     */
    var isLight: Bool {
        bestMatch(from: [.darkAqua, .aqua]) == .aqua
    }

    /**
     A Boolean value indicating whether the appearance is dark.

     The following appearances are dark: ``AppKit/NSAppearance/darkAqua``, ``AppKit/NSAppearance/vibrantDark``, ``AppKit/NSAppearance/accessibilityHighContrastDarkAqua`` and ``AppKit/NSAppearance/accessibilityHighContrastVibrantDark``.
     */
    var isDark: Bool {
        !isLight
    }

    /**
     Sets the appearance as the current drawing appearance and returns the value of the specified block.
     
     This method saves and restores the previous current appearance.

     - Parameter block: The block to invoke after setting the appearance as the current drawing appearance.
     - Returns: The value returned by `block`.
     */
    @_disfavoredOverload
    func performAsCurrentDrawingAppearance<V>(_ block: () -> V) -> V {
        var result: V?
        performAsCurrentDrawingAppearance {
            result = block()
        }
        return result!
    }

    /**
     Sets the appearance as the current drawing appearance and returns the value of the specified block.

     This method saves and restores the previous current appearance.

     - Parameter block: The block to invoke after setting the appearance as the current drawing appearance.
     - Returns: The value returned by `block`.
     - Throws: Any error thrown by `block`.
     */
    @_disfavoredOverload
    func performAsCurrentDrawingAppearance<V, E: Error>(_ block: () throws(E) -> V) rethrows -> V {
        let current = NSAppearance.currentAppearance
        NSAppearance.currentAppearance = self
        defer { NSAppearance.currentAppearance = current }
        return try block()
    }
    
    fileprivate static var currentAppearance: NSAppearance? {
        get { value(forKey: "currentAppearance") }
        set { setValue(safely: newValue, forKey: "currentAppearance") }
    }
}

extension NSAppearance: Swift.Encodable, Swift.Decodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

public extension Decodable where Self: NSAppearance {
    /// Decodes a value of the given type from a sing
    init(from decoder: Decoder) throws {
        try self.init(named: decoder.singleValueContainer().decode())!
    }
}

extension NSAppearance.Name: Swift.Encodable, Swift.Decodable {}

extension NSAppearance.Name: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .aqua: return "aqua"
        case .darkAqua: return "darkAqua"
        case .vibrantLight: return "vibrantLight"
        case .vibrantDark: return "vibrantDark"
        case .accessibilityHighContrastAqua: return "accessibilityHighContrastAqua"
        case .accessibilityHighContrastDarkAqua: return "accessibilityHighContrastDarkAqua"
        case .accessibilityHighContrastVibrantLight: return "accessibilityHighContrastVibrantLight"
        case .accessibilityHighContrastVibrantDark: return "accessibilityHighContrastVibrantDark"
        default: return rawValue.replacingOccurrences(of: "NSAppearanceName", with: "").lowercasedFirst()
        }
    }
}

public extension NSAppearanceCustomization {
    /// Sets the appearance.
    @discardableResult
    func appearance(_ appearance: NSAppearance?) -> Self {
        self.appearance = appearance
        return self
    }
}

#endif
