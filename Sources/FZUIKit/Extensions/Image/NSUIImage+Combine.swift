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
     Creates a new image by combining the specified images vertically.
     
     - Parameters:
        - images: The images to combine.
        - alignment: The alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public convenience init?(combineVertical images: [NSUIImage], alignment: HorizontalAlignment = .center) {
        guard let image = NSUIImage.combined(images: images, vertical: true, alignment: alignment.rawValue) else { return nil }
        #if os(macOS)
        self.init(size: image.size)
        lockFocus()
        defer { unlockFocus() }
        image.draw(at: .zero, from: CGRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        #else
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
        #endif
    }
    
    /**
     Creates a new image by combining the specified images horizontally.
     
     - Parameters:
        - images: The images to combine.
        - alignment: The alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public convenience init?(combineHorizontal images: [NSUIImage], alignment: VerticalAlignment = .center) {
        guard let image = NSUIImage.combined(images: images, vertical: false, alignment: alignment.rawValue) else { return nil }
        #if os(macOS)
        self.init(size: image.size)
        lockFocus()
        defer { unlockFocus() }
        image.draw(at: .zero, from: CGRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        #else
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
        #endif
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
        guard images.count > 1 else { return images.first }
        
        let rects = vertical ? images.map({CGRect(.zero, $0.size)}).alignVertically(at: .init(rawValue: alignment)!) : images.map({CGRect(.zero, $0.size)}).alignHorizontally(at: .init(rawValue: alignment)!)
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
