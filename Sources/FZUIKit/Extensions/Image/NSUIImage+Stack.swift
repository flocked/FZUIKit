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
            origin = origin.offset(x: offset.x, y: offset.y)
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
            // Set the rotation angle: alternating clockwise and counterclockwise
            let angle = (index % 2 == 0) ? rotation : -rotation
            
            // Create a rotation transform
            var transform = NSAffineTransform()
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
