//
//  NSUIView+RenderedImage.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    #if os(macOS)
        public extension NSView {
            /// A rendered image of the view.
            var renderedImage: NSImage {
                let rep = bitmapImageRepForCachingDisplay(in: bounds)!
                cacheDisplay(in: bounds, to: rep)

                let image = NSImage(size: bounds.size)
                image.addRepresentation(rep)

                return image
            }

            /// Renders a compound image from multiple views.
            static func renderedImage(from views: [NSView]) -> NSImage {
                let unionRect = views.compactMap({$0.frame}).union()

                let image = NSImage(size: unionRect.size)
                image.lockFocus()

                for view in views {
                    let rect = view.frame
                    view.renderedImage.draw(in: rect)
                }
                image.unlockFocus()
                return image
            }
        }

    #elseif os(iOS) || os(tvOS)
        public extension UIView {            
            /// Renders an image of this view.
            var renderedImage: UIImage {
                let renderer = UIGraphicsImageRenderer(size: bounds.size)
                return renderer.image { _ in
                    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
                }
            }
        }
    #endif
#endif
