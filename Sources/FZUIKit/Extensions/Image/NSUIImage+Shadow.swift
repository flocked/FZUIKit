//
//  NSUIImage+Shadow.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

#if os(macOS)
import AppKit

fileprivate extension NSImage {
    func retinaReadyCursorImage() -> NSImage {
        let resultImage = NSImage(size: size)
        for scale in 1..<4 {
            let transform = NSAffineTransform()
            transform.scale(by: CGFloat(scale))
            if let rasterCGImage = cgImage(forProposedRect: nil, context: nil, hints: [NSImageRep.HintKey.ctm: transform]) {
                let rep = NSBitmapImageRep(cgImage: rasterCGImage)
                rep.size = size
                resultImage.addRepresentation(rep)
            }
        }
        return resultImage
    }
}

extension NSImage {
    /// Returns a new image with the specified shadow configuraton.
    /// This will increase the size of the image to fit the shadow and the original image.
    func withShadow(_ shadow: ShadowConfiguration) -> NSImage? {
        guard let color = shadow.resolvedColor()?.cgColor, color.alpha >= 0.0 else { return self }
        
        let newImage = NSImage(size: size)
        var representations = representations.compactMap({ $0 as? NSBitmapImageRep })
        representations = []
        if !representations.isEmpty {
            for representation in representations {
                let width = CGFloat(representation.pixelsWide)
                let height = CGFloat(representation.pixelsHigh)
                let newSize = CGSize(width: width + 2 * shadow.radius + abs(shadow.offset.x), height: height + 2 * shadow.radius + abs(shadow.offset.y))
                
                guard let shadowedRep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(newSize.width),
                    pixelsHigh: Int(newSize.height),
                    bitsPerSample: representation.bitsPerSample,
                    samplesPerPixel: representation.samplesPerPixel,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: representation.colorSpaceName,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                ) else { continue }
                
                NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: shadowedRep)
                NSGraphicsContext.current?.saveGraphicsState()
                NSGraphicsContext.current?.cgContext.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)
                
                let drawRect = CGRect(
                    x: shadow.radius + max(0, shadow.offset.x),
                    y: shadow.radius + max(0, shadow.offset.y),
                    width: newSize.width,
                    height: newSize.height)
                representation.draw(in: drawRect)
                
                NSGraphicsContext.current?.restoreGraphicsState()
                NSGraphicsContext.current = nil
                newImage.addRepresentation(shadowedRep)
            }
        } else {
            let shadowRect = CGRect(
                x: shadow.offset.x - shadow.radius,
                y: shadow.offset.y - shadow.radius,
                width: size.width + shadow.radius * 2,
                height: size.height + shadow.radius * 2
            )
            
            let newSize = CGSize(width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0), height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
            )
            
            newImage.lockFocus()
            
            let context = NSGraphicsContext.current?.cgContext
            context?.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)
            
            let drawingRect = CGRect(
                x: max(0, -shadowRect.origin.x),
                y: max(0, -shadowRect.origin.y),
                width: size.width,
                height: size.height
            )
            draw(in: drawingRect, from: .zero, operation: .sourceOver, fraction: 1.0)
            
            newImage.unlockFocus()
        }
        return newImage
    }
}
#elseif canImport(UIKit)
import UIKit

extension UIImage {
    /// Returns a new image with the specified shadow properties.
    /// This will increase the size of the image to fit the shadow and the original image.
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
