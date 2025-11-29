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
        - alignment: The horizontal alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public convenience init?(combineVertical images: [NSUIImage], alignment: HorizontalAlignment = .center) {
        guard let cgImage = CGImage.combineVertical(images.compactMap({$0.cgImage}), alignment: .init(rawValue: alignment.rawValue)!) else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /**
     Creates a new image by combining the specified images horizontally.
     
     - Parameters:
        - images: The images to combine.
        - alignment: The vertical alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public convenience init?(combineHorizontal images: [NSUIImage], alignment: VerticalAlignment = .center) {
        guard let cgImage = CGImage.combineHorizontal(images.compactMap({$0.cgImage}), alignment: .init(rawValue: alignment.rawValue)!) else { return nil }
        self.init(cgImage: cgImage)
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
}

extension CFType where Self == CGImage {
    /**
     Creates a new image by combining the specified images vertically.
     
     - Parameters:
        - images: The images to combine.
        - alignment: The horizontal alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public init?(combineVertical images: [CGImage], alignment: CGImage.HorizontalAlignment = .center) {
        guard let image = CGImage.combineVertical(images, alignment: alignment) else { return nil }
        self = image
    }
    
    /**
     Creates a new image by combining the specified images horizontally.
     
     - Parameters:
        - images: The images to combine.
        - alignment: The vertical alignment of the images.
     - Returns: The image, or `nil` if the image couldn't be created.
     */
    public init?(combineHorizonal images: [CGImage], alignment: CGImage.VerticalAlignment = .center) {
        guard let image = CGImage.combineHorizontal(images, alignment: alignment) else { return nil }
        self = image
    }
}

extension CGImage {
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
    
    fileprivate static func combineVertical(_ images: [CGImage], alignment: HorizontalAlignment = .center) -> CGImage? {
        guard !images.isEmpty else { return nil }
        
        // Total height = sum of heights
        let totalHeight = images.reduce(0) { $0 + $1.height }
        let maxWidth = images.map(\.width).max() ?? 0
        
        guard let ctx = CGContext(data: nil, width: maxWidth, height: totalHeight, bitsPerComponent: 8, bytesPerRow: maxWidth * 4, space: .deviceRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        var yOffset = 0
        
        for image in images {
            let x: Int
            switch alignment {
            case .left:
                x = 0
            case .center:
                x = (maxWidth - image.width) / 2
            case .right:
                x = maxWidth - image.width
            }
            ctx.draw(image, in: CGRect(x: x, y: yOffset, width: image.width, height: image.height))
            yOffset += image.height
        }
        
        return ctx.makeImage()
    }
    
    
    fileprivate static func combineHorizontal(_ images: [CGImage], alignment: VerticalAlignment = .center) -> CGImage? {
        guard !images.isEmpty else { return nil }
        
        let totalWidth = images.reduce(0) { $0 + $1.width }
        let maxHeight = images.map(\.height).max() ?? 0
        guard let ctx = CGContext(data: nil, width: totalWidth, height: maxHeight, bitsPerComponent: 8, bytesPerRow: totalWidth * 4, space: .deviceRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        var xOffset = 0
        
        for image in images {
            let y: Int
            switch alignment {
            case .top:
                y = maxHeight - image.height
            case .center:
                y = (maxHeight - image.height) / 2
            case .bottom:
                y = 0
            }
            ctx.draw(image, in: CGRect(x: xOffset, y: y, width: image.width, height: image.height))
            xOffset += image.width
        }
        
        return ctx.makeImage()
    }
}
