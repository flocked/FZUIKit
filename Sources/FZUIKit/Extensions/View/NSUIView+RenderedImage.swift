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
                guard bounds.size != .zero else { return NSImage(size: .zero) }
                let hidden = isHidden
                isHidden = false
                guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
                    isHidden = hidden
                    return NSImage(size: bounds.size)
                }
                cacheDisplay(in: bounds, to: rep)
                let image = NSImage(size: bounds.size)
                image.addRepresentation(rep)
                isHidden = hidden
                return image
            }

            /// Renders a compound image from multiple views.
            static func renderedImage(from views: [NSView]) -> NSImage {
                let unionRect = views.compactMap({$0.frame}).union()
                guard unionRect.size != .zero else { return NSImage(size: .zero) }
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
            /// A rendered image of the view.
            var renderedImage: UIImage {
                let hidden = isHidden
                isHidden = false
                let renderer = UIGraphicsImageRenderer(size: bounds.size)
                let image = renderer.image { _ in
                    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
                }
                isHidden = hidden
                return image
            }
            
            /// Renders a compound image from multiple views.
            static func renderedImage(from views: [UIView]) -> UIImage {
                let unionRect = views.compactMap({$0.frame}).union()
                let renderer = UIGraphicsImageRenderer(size: unionRect.size)
                return renderer.image { context in
                    for view in views {
                        context.cgContext.translateBy(x: view.frame.origin.x, y: view.frame.origin.y)
                        view.layer.render(in: context.cgContext)
                        context.cgContext.translateBy(x: -view.frame.origin.x, y: -view.frame.origin.y)
                    }
                }
            }
        }
    #endif
#endif
