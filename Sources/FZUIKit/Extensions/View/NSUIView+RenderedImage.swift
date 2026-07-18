//
//  NSUIView+RenderedImage.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)

public extension NSView {
    /// A rendered image of the view.
    var renderedImage: NSImage {
        let bounds = bounds
        let hidden = isHidden
        isHidden = false
        defer { isHidden = hidden }
        layoutSubtreeIfNeeded()
        displayIfNeeded()
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return NSImage(size: bounds.size)
        }
        cacheDisplay(in: bounds, to: rep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(rep)
        return image
    }
    
    /**
     A rendered image of the view with the specified backing scale factor.

     - Parameter scale: The backing scale factor to use for the bitmap representation.
     - Returns: An image containing the rendered contents of the view.
     */
    func renderedImage(scale: CGFloat) -> NSImage {
        let hidden = isHidden
        isHidden = false
        defer { isHidden = hidden }
        layoutSubtreeIfNeeded()
        displayIfNeeded()
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return NSImage(size: bounds.size)
        }

        rep.pixelsWide = Int((bounds.width * scale).rounded(.up))
        rep.pixelsHigh = Int((bounds.height * scale).rounded(.up))
        cacheDisplay(in: bounds, to: rep)
        rep.size = bounds.size
        let image = NSImage(size: bounds.size)
        image.addRepresentation(rep)
        return image
    }

    /// Renders a compound image from multiple views.
    static func renderedImage(from views: [NSView]) -> NSImage {
        let unionRect = views.compactMap({ $0.frame }).union()
        guard unionRect.size != .zero else { return NSImage(size: .zero) }
        let image = NSImage(size: unionRect.size)
        image.lockFocus()
        for view in views {
            let offset = CGPoint(x: view.frame.origin.x - unionRect.origin.x, y: view.frame.origin.y - unionRect.origin.y)
            view.renderedImage.draw(at: offset, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        image.unlockFocus()
        return image
    }
}

#elseif os(iOS) || os(tvOS) || os(visionOS)
public extension UIView {            
    /// A rendered image of the view.
    var renderedImage: UIImage {
        let hidden = isHidden
        isHidden = false
        defer { isHidden = hidden }
        layoutIfNeeded()
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    /// Renders a compound image from multiple views.
    static func renderedImage(from views: [UIView]) -> UIImage {
        let unionRect = views.compactMap({ $0.frame }).union()
        let renderer = UIGraphicsImageRenderer(size: unionRect.size)
        return renderer.image { context in
            for view in views {
                context.cgContext.saveGState()
                context.cgContext.translateBy(x: view.frame.origin.x - unionRect.origin.x, y: view.frame.origin.y - unionRect.origin.y)
                view.layer.render(in: context.cgContext)
                context.cgContext.restoreGState()
            }
        }
    }
}
#endif
#endif
