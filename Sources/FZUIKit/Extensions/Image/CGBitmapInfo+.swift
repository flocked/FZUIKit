//
//  CGBitmapInfo+.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics

extension CGBitmapInfo: Swift.Hashable {
    /// RGBA.
    public static let rgba = CGBitmapInfo(alpha: .premultipliedLast, byteOrder: .order32Big)
    /// BGRA.
    public static let bgra = CGBitmapInfo(alpha: .premultipliedLast, byteOrder: .order32Little)
    /// ARGB.
    public static let argb = CGBitmapInfo(alpha: .premultipliedFirst, byteOrder: .order32Big)
    /// ABGR.
    public static let abgr = CGBitmapInfo(alpha: .premultipliedFirst, byteOrder: .order32Little)
    /// RGB.
    public static let rgb = CGBitmapInfo(alpha: .none, byteOrder: .order32Big)
    /// BGR.
    public static let bgr = CGBitmapInfo(alpha: .none, byteOrder: .order32Little)

    /// Returns the bits per component for creating a `CGContext` based on this bitmap info.
    public var bitsPerComponent: Int {
        if component == .float {
            return 32
        }
        switch pixelFormat {
        case .RGB101010, .RGBCIF10:
            return 10
        case .RGB555, .RGB565:
            return 5
        default:
            return 8
        }
    }
    
    /// The byte order of the components in memory.
    public enum PixelByteOrder {
        /// BGRA (blue, green, red, alpha).
        case bgra
        /// ABGR (alpha, blue, green, red).
        case abgr
        /// ARGB (alpha, red, green, blue).
        case argb
        /// RGBA (red, green, blue, alpha).
        case rgba
        /// BGR (blue, green, red).
        case bgr
        /// RGB (red, green, blue).
        case rgb

        /// The number of the components.
        var count: Int {
            switch self {
            case .bgr, .rgb: return 3
            default: return 4
            }
        }
    }

    /// The byte order of the components in memory.
    public var pixelByteOrder: PixelByteOrder {
        let littleEndian = contains(.byteOrder32Little)
        switch alpha {
        case .none:
            return littleEndian ? .bgr : .rgb
        case .noneSkipFirst, .first, .premultipliedFirst:
            return littleEndian ? .bgra : .argb
        case .noneSkipLast, .last, .premultipliedLast:
            return littleEndian ? .abgr : .rgba
        default:
            return littleEndian ? .bgra : .argb
        }
    }

    var isAlphaPremultiplied: Bool {
        alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
}

extension CGBitmapInfo: Swift.CustomStringConvertible {
    public var description: String {
        "[alpha: .\(alpha), component: .\(component), byteOrder: .\(byteOrder), pixelFormat: .\(pixelFormat)]"
    }
}

extension CGImageComponentInfo: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .integer: return "integer"
        case .float: return "float"
        default: return "\(rawValue)"
        }
    }
}

extension CGImagePixelFormatInfo: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .mask: return "mask"
        case .packed: return "packed"
        case .RGB555: return "RGB555"
        case .RGB565: return "RGB565"
        case .RGB101010: return "RGB101010"
        case .RGBCIF10: return "RGBCIF10"
        default: return "\(rawValue)"
        }
    }
}

extension CGImageByteOrderInfo: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .orderMask:  return "orderMask"
        case .orderDefault: return "orderDefault"
        case .order16Little: return "order16Little"
        case .order32Little: return "order32Little"
        case .order16Big: return "order16Big"
        case .order32Big: return "order32Big"
        case .order16Host: return "order16Host"
        case .order32Host: return "order32Host"
        default: return "\(rawValue)"
        }
    }
}

extension CGImageAlphaInfo: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "none"
        case .premultipliedLast: return "premultipliedLast"
        case .premultipliedFirst: return "premultipliedFirst"
        case .last: return "last"
        case .first: return "first"
        case .noneSkipLast: return "noneSkipLast"
        case .noneSkipFirst: return "noneSkipFirst"
        case .alphaOnly: return "alphaOnly"
        default: return "\(rawValue)"
        }
    }
}

extension CGImageAlphaInfo {
    /// A Boolean value indicating whether the image data contains an alpha channel.
    public var hasAlpha: Bool {
        switch self {
        case .none, .noneSkipLast, .noneSkipFirst: return false
        default: return true
        }
    }
}
#endif
