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

     The following appearances are light: ``aqua``, ``vibrantLight``, ``accessibilityHighContrastAqua`` and ``accessibilityHighContrastVibrantLight``.
     */
    var isLight: Bool {
        bestMatch(from: [.darkAqua, .aqua]) == .aqua
    }

    /**
     A Boolean value indicating whether the appearance is dark.

     The following appearances are dark: ``darkAqua``, ``vibrantDark``, ``accessibilityHighContrastDarkAqua`` and ``accessibilityHighContrastVibrantDark``.
     */
    var isDark: Bool {
        !isLight
    }
    
    /*
    internal func performAsCurrentDrawing(_ block: () -> Void) {
        if #available(macOS 11.0, *) {
            performAsCurrentDrawingAppearance(block)
        } else {
            let current = NSAppearance.current
            NSAppearance.current = self
            block()
            NSAppearance.current = current
        }
    }
     */
    
    /**
     Sets the appearance to be the active drawing appearance and returns teh value of the specified block.
     
     This method saves and restores the previous current appearance.
     
     - Parameter block: The block to invoke after setting the appearance to be the current drawing appearance.
     - Returns: The value that the `block` returns.
     */
    @_disfavoredOverload
    func performAsCurrentDrawingAppearance<V>(_ block: () -> V) -> V {
         var result: V?
        if #available(macOS 11.0, *) {
            performAsCurrentDrawingAppearance {
                result = block()
            }
        } else {
            let current = NSAppearance.current
            NSAppearance.current = self
            result = block()
            NSAppearance.current = current
        }
         return result!
     }
    
    /**
     Sets the appearance to be the active drawing appearance and returns teh value of the specified block.
     
     This method saves and restores the previous current appearance.
     
     - Parameter block: The block to invoke after setting the appearance to be the current drawing appearance.
     - Returns: The value that the `block` returns.
     */
    @_disfavoredOverload
    func performAsCurrentDrawingAppearance<V>(_ block: () throws -> V) throws -> V {
        let result: Result<V, Error> = performAsCurrentDrawingAppearance {
            do {
                return .success(try block())
            } catch {
                return .failure(error)
            }
        }
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
      }
    
    internal static func current() -> NSAppearance {
        if #available(macOS 11.0, *) {
            return .currentDrawing()
        }
        return .current
    }
}

extension NSAppearance {
    
}

extension NSAppearance: Swift.Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

extension Encoder {
    /// Encodes the specified value in a single value container.
    func encodeSingleValue<T: Encodable>(_ value: T) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }
}

extension Decoder {
    /// Decodes a value of the given type from a sing
    func decodeSingleValue<T: Decodable>(_ type: T.Type) throws -> T {
        try singleValueContainer().decode(type)
    }
}

extension Decodable where Self: NSAppearance {
    /// Decodes a value of the given type from a sing
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .init(named: try container.decode())!
    }
}

extension NSAppearance.Name: Swift.Codable { }

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
