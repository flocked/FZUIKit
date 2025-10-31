//
//  CGContext+.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

#if canImport(CoreImage)
import Foundation
import CoreImage
import FZSwiftUtils

extension CGContext {
    /// Fills the specified rectangle with the provided color.
    public func fill(_ color: CGColor, in rect: CGRect) {
        saveGState()
        setFillColor(color)
        fill(rect)
        restoreGState()
    }
    
    /// Strokes the specified rectangle with the provided color.
    public func stroke(_ color: CGColor, in rect: CGRect) {
        saveGState()
        setStrokeColor(color)
        stroke(rect)
        restoreGState()
    }
}

public extension CFType where Self == CGContext {
    /// Creates a `CGContext` with the specified parameters.
    init?(data: UnsafeMutableRawPointer? = nil, size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, space: CGColorSpaceName? = nil, bitmapInfo: CGBitmapInfo) {
        guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space != nil ? CGColorSpace(name: space!) : nil, bitmapInfo: bitmapInfo) else { return nil }
        self = context
    }
    
    /// Creates a `CGContext` with the specified parameters.
    init?(data: UnsafeMutableRawPointer? = nil, size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, space: CGColorSpaceName? = nil, hasAlpha: Bool = true) {
        guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space != nil ? CGColorSpace(name: space!) : nil, bitmapInfo: hasAlpha ? .rgba : .rgb) else { return nil }
        self = context
    }
}

/*
 
 public protocol CGContextType { }
 extension CGContext: CGContextType { }

 public extension CGContextType where Self == CGContext {
     /**
      Creates a bitmap graphics context.
      
      When you draw into this context, Core Graphics renders your drawing as bitmapped data in the specified block of memory.
      
      The pixel format for a new bitmap context is determined by three parameters—the number of bits per component, the color space, and an alpha option (expressed as a CGBitmapInfo constant). The alpha value determines the opacity of a pixel when it is drawn.
      
      - Parameters:
         - data: A pointer to the destination in memory where the drawing is to be rendered. The size of this memory block should be at least `(bytesPerRow*height)` bytes. Pass `nil` if you want this function to allocate memory for the bitmap. This frees you from managing your own memory, which reduces memory leak issues.
         - size: The size, in pixels, of the required bitmap.
         - bitsPerComponent: The number of bits to use for each component of a pixel in memory. For example, for a 32-bit pixel format and an RGB color space, you would specify a value of `8` bits per component.
         - bytesPerRow: The number of bytes of memory to use per row of the bitmap. If `data` is `nil`, passing a value of `0` causes the value to be calculated automatically.
         - space: The color space to use for the bitmap context. Note that indexed color spaces are not supported for bitmap graphics contexts.
         - bitmapInfo: The component information for a bitmap context.
      - Returns: A new bitmap context, or `nil` if a context could not be created.
      */
     init?(data: UnsafeMutableRawPointer? = nil, size: CGSize, bitsPerComponent: Int = 8, bytesPerRow: Int = 0, space: CGColorSpace, bitmapInfo: CGContext.BitmapInfo = .init()) {
         guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo.rawValue) else { return nil }
         self = context
     }
 }

 extension CGContext {
     /// Component information for a bitmap context.
     public struct BitmapInfo {
         /// The byte order.
         public enum ByteOrder: UInt32 {
             /// Default byte order.
             case `default` = 0
             /// 16-bit, little endian format.
             case little16 = 4096
             /// 32-bit, little endian format.
             case little32 = 8192
             /// 16-bit, big endian format.
             case big16 = 12288
             /// 32-bit, big endian format.
             case big32 = 16384
         }
         
         /// The storage options for alpha component data.
         public var alpha: CGImageAlphaInfo = .none
         
         /// The byte order.
         public var byteOrder: ByteOrder = .default
         
         /// A Boolean value indicating whether pixel components are floats (e.g., for HDR)
         public var usesFloatComponents: Bool = false
         
         /// Creates component information for a bitmap context.
         public init(alpha: CGImageAlphaInfo = .none, byteOrder: ByteOrder = .default, usesFloatComponents: Bool = false) {
             self.alpha = alpha
             self.byteOrder = byteOrder
             self.usesFloatComponents = usesFloatComponents
         }
         
         var rawValue: UInt32 {
             var info: UInt32 = alpha.rawValue | byteOrder.rawValue
             if usesFloatComponents {
                 info |= CGBitmapInfo.floatComponents.rawValue
             }
             return info
         }
     }
 }
 */
#endif
