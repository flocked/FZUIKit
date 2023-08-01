//
//  NSView+RenderedImage.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)
public extension NSView {
    internal static var currentContext: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }
    
    /// Renders an image from this view.
    var renderedImage: NSImage {
        let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds)!
        self.cacheDisplay(in: self.bounds, to: rep)

        let image = NSImage(size: self.bounds.size)
        image.addRepresentation(rep)
        
        return image
    }

    /// Renders a compound image from multiple views.
    static func renderedImage(from views: [NSView]) -> NSImage {
        var frame = CGRect.zero
        for view in views {
            frame = NSUnionRect(frame, view.frame)
        }

        let image = NSImage(size: frame.size)
        image.lockFocus()

        for view in views {
            let rect = view.frame
            view.renderedImage.draw(in: rect)
        }
        image.unlockFocus()
        return image
    }
}

#elseif canImport(UIKit)
public extension UIView {
    /// Renders an image from this view.
    var renderedImage: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}
#endif
