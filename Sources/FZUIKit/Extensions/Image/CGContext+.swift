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
#endif
