//
//  NSUIImage+Combine.swift
//  
//
//  Created by Florian Zand on 15.03.25.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import FZSwiftUtils

extension NSUIImage {
    /**
     Creates a new image by combining the specified images.
     
     - Parameters:
        - images: The images to combine.
        - orientation: The orientation of the images when combining them.
        - alignment: The alignment of the images when combining them.
     - Returns: The combined images, or `nil` if the images couldn't be combined.
     */
    public convenience init?(combineVertical images: [NSUIImage], alignment: HorizontalAlignment = .center) {
        guard let image = NSUIImage.combined(images: images, vertical: true, alignment: alignment.rawValue)?.cgImage else { return nil }
        self.init(cgImage: image)
    }
    
    public convenience init?(combineHorizontal images: [NSUIImage], alignment: VerticalAlignment = .center) {
        guard let image = NSUIImage.combined(images: images, vertical: false, alignment: alignment.rawValue)?.cgImage else { return nil }
        self.init(cgImage: image)
    }

    /// The vertical alignment of images when combining them to a new image.
    public enum VerticalAlignment: Int {
        /// Leading.
        case top
        /// Center.
        case center
        /// Trailing.
        case bottom
    }
    
    /// The horizontal alignment of images when combining them to a new image.
    public enum HorizontalAlignment: Int {
        /// Leading.
        case left
        /// Center.
        case center
        /// Trailing.
        case right
    }
    
    private static func combined(images: [NSUIImage], vertical: Bool, alignment: Int) -> NSUIImage? {
        guard !images.isEmpty else { return nil }
        let rects = vertical ? images.map({$0.size}).alignVertical(alignment: .init(rawValue: alignment)!) : images.map({$0.size}).alignHorizontal(alignment: .init(rawValue: alignment)!)
        #if os(macOS)
        let finalImage = NSUIImage(size: rects.union().size)
        finalImage.lockFocus()
        defer { finalImage.unlockFocus() }
        var currentPoint: CGPoint = .zero
        for value in zip(images, rects) {
            let image = value.0
            let drawRect = value.1
            image.draw(in: drawRect)
            currentPoint = vertical ? CGPoint(x: currentPoint.x, y: currentPoint.y + image.size.height) : CGPoint(x: currentPoint.x + image.size.width, y: currentPoint.y)
        }
        return finalImage
        #else
        UIGraphicsBeginImageContextWithOptions(rects.union().size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        var currentPoint: CGPoint = .zero
        for value in zip(images, rects) {
            let image = value.0
            let drawRect = value.1
            image.draw(in: drawRect)
            currentPoint = vertical ? CGPoint(x: currentPoint.x, y: currentPoint.y + image.size.height) : CGPoint(x: currentPoint.x + image.size.width, y: currentPoint.y)
        }
        return UIGraphicsGetImageFromCurrentImageContext()
        #endif
    }
}
