//
//  NSUIImage+Stack.swift
//
//
//  Created by Florian Zand on 15.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSImage {
    public static func stackImage(for images: [NSImage], offset: CGPoint, rotation: CGFloat) -> NSImage? {
        guard !images.isEmpty else { return nil }
        
        let sizes = images.compactMap({$0.size})
        var isCounter = false
        var rects = sizes.map({
            isCounter = !isCounter
            return CGRect(.zero, $0.rotated(by: isCounter ? -rotation : rotation))
        })
        let center = rects.union().center
        var origin: CGPoint = .zero
        rects = rects.map({
            var rect = $0
            rect.center = center
            rect.origin = origin
            origin = origin.offset(by: offset)
            return rect
        })
        
        // Create a new NSImage to contain the stacked images
        let size = rects.union().size
        
        let stackedImage = NSImage(size: size)
        
        // Begin drawing the stacked image
        stackedImage.lockFocus()
        
        var currentOffset = CGPoint.zero
        
        // Draw each image with alternating rotation and offset
        for (index, image) in images.enumerated() {
            let angle = (index % 2 == 0) ? rotation : -rotation
            
            // Create a rotation transform
            let transform = NSAffineTransform()
            transform.translateX(by: currentOffset.x, yBy: currentOffset.y)
            transform.rotate(byDegrees: angle)
            
            // Apply the transformation and draw the image
            transform.concat()
            
            image.draw(at: currentOffset, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1.0)
            
            // Update currentOffset by adding the given offset
            currentOffset.x += offset.x
            currentOffset.y += offset.y
        }
        
        // End drawing the stacked image
        stackedImage.unlockFocus()
        
        return stackedImage
    }
}

extension CGImage {
    public static func stackImage(for images: [CGImage], offset: CGPoint, rotation: CGFloat) -> CGImage? {
        guard !images.isEmpty else { return nil }
        
        // Compute rotated sizes
        var isCounter = false
        let sizes = images.map { $0.size }
        var rects = sizes.map {
            isCounter.toggle()
            return CGRect(origin: .zero, size: $0.rotated(by: isCounter ? -rotation : rotation))
        }
        
        // Compute union rect and center
        let unionRect = rects.union()
        let center = CGPoint(x: unionRect.midX, y: unionRect.midY)
        
        // Offset rects around the center
        var origin: CGPoint = .zero
        rects = rects.map {
            var rect = $0
            rect.center = center
            rect.origin = origin
            origin = origin.offset(by: offset)
            return rect
        }
        
        let finalSize = rects.reduce(CGSize.zero) { CGSize(width: max($0.width, $1.maxX), height: max($0.height, $1.maxY)) }
        
        guard let context = CGContext(data: nil, width: Int(finalSize.width), height: Int(finalSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: .deviceRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        context.translateBy(x: 0, y: finalSize.height)
        context.scaleBy(x: 1, y: -1) // Flip vertically for Core Graphics coordinate system
        
        var currentOffset = CGPoint.zero
        
        for (index, image) in images.enumerated() {
            let angle = (index % 2 == 0) ? rotation : -rotation
            let radians = angle * .pi / 180
            
            context.saveGState()
            
            context.translateBy(x: currentOffset.x + CGFloat(image.width)/2, y: currentOffset.y + CGFloat(image.height)/2)
            context.rotate(by: radians)
            context.translateBy(x: -CGFloat(image.width)/2, y: -CGFloat(image.height)/2)
            context.draw(image, in: CGRect(origin: .zero, size: image.size))
            
            context.restoreGState()
            
            currentOffset.x += offset.x
            currentOffset.y += offset.y
        }
        
        return context.makeImage()
    }
}

extension CGSize {
    func rotated(by degrees: CGFloat) -> CGSize {
        let radians = degrees * .pi / 180
        
        // Calculate the new width and height after rotation
        let newWidth = abs(self.width * cos(radians)) + abs(self.height * sin(radians))
        let newHeight = abs(self.width * sin(radians)) + abs(self.height * cos(radians))
        
        return CGSize(width: newWidth, height: newHeight)
    }
}
#endif
