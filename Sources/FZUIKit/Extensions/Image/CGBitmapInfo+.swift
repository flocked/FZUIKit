//
//  CGBitmapInfo+.swift
//  FZUIKit
//
//  Created by Florian Zand on 31.10.25.
//

#if canImport(CoreImage)
import Foundation
import CoreImage

extension CGBitmapInfo: Hashable {
    /// Sets the alpha info.
    public func alpha(_ alpha: CGImageAlphaInfo) -> Self {
        var info = self
        info.alpha = alpha
        return info
    }
    
    /// 32-bit little-endian bitmap without an alpha channel (xRGB layout).
    public static let rgb = CGBitmapInfo.byteOrder32Little.alpha(.noneSkipFirst)
    /// 32-bit little-endian bitmap with a alpha channel (BGRA layout).
    public static let rgba = CGBitmapInfo.byteOrder32Little.alpha(.premultipliedFirst)
    /// 32-bit big-endian bitmap without an alpha channel (RGBx layout, legacy format).
    public static let rgbLegacy = CGBitmapInfo.byteOrder32Big.alpha(.noneSkipLast)
    /// 32-bit big-endian bitmap with a alpha channel (RGBA layout, legacy format).
    public static let rgbaLegacy = CGBitmapInfo.byteOrder32Big.alpha(.premultipliedLast)
}
#endif
