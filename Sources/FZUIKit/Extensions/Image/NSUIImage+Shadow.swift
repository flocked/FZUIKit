//
//  NSUIImage+Shadow.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)
public extension NSImage {
    /// Returns a new image with the specified shadow configuraton.
    func withShadow(_ shadow: ShadowConfiguration) -> NSImage? {
        guard let color = shadow.resolvedColor()?.cgColor, color.alpha >= 0.0 else { return self }
        
        let repImages = representations.compactMap({ ($0 as? NSBitmapImageRep)?.cgImage?.withShadow(shadow) })
        if !repImages.isEmpty {
            let newImage = NSImage(size: size)
            for repImage in repImages {
                let rep = NSBitmapImageRep(cgImage: repImage)
                rep.size = size
                newImage.addRepresentation(rep)
            }
            return newImage
        }
        
        let newSize = CGSize(size.width + abs(shadow.offset.x) + 2 * shadow.radius, size.height + abs(shadow.offset.y) + 2 * shadow.radius)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)
        }
        let drawRect = CGRect(x: shadow.radius + max(shadow.offset.x, 0), y: shadow.radius + max(shadow.offset.y, 0), width: size.width, height: size.height)
        draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
#elseif canImport(UIKit)
import UIKit

public extension UIImage {
    /// Returns a new image with the specified shadow configuration.
    func withShadow(_ shadow: ShadowConfiguration) -> UIImage {
        guard let color = shadow.resolvedColor()?.cgColor, color.alpha >= 0.0 else { return self }
        
        let shadowRect = CGRect(
            x: shadow.offset.x - shadow.radius,
            y: shadow.offset.y - shadow.radius,
            width: size.width + shadow.radius * 2,
            height: size.height + shadow.radius * 2
        )
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0), height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)), false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)
        
        draw(in: CGRect(x: max(0, -shadowRect.origin.x), y: max(0, -shadowRect.origin.y), width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return image
    }
}
#endif


public extension CGImage {
    /// Returns a new image with the specified shadow configuraton.
    func withShadow(_ shadow: ShadowConfiguration) -> CGImage? {
        guard let color = shadow.resolvedColor()?.cgColor, color.alpha > 0.0 else { return self }
        let newSize = CGSize(size.width + abs(shadow.offset.x) + 2 * shadow.radius, size.height + abs(shadow.offset.y) + 2 * shadow.radius)
        guard let context = CGContext(data: nil, width: Int(newSize.width), height: Int(newSize.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)
        let drawRect = CGRect(x: shadow.radius + max(shadow.offset.x, 0), y: shadow.radius + max(shadow.offset.y, 0), width: size.width, height: size.height)
        context.draw(self, in: drawRect)
        return context.makeImage()
    }
}
