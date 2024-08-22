//
//  NSView+BackgroundStyle.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSControl {
        /**
         The background style of the view.

         The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.
         */
        var backgroundStyle: NSView.BackgroundStyle {
            get { cell?.backgroundStyle ?? .normal }
            set { cell?.backgroundStyle = newValue }
        }
    }

    extension NSView {
        /**
         Updates the background style of the view and all nested subviews to the specified style.

         It updates all views that implement ``setBackgroundStyle(_:)``: or are a `NSControl` or `NSTableCellView`.

         - Parameter backgroundStyle: The background style to apply.
         */
        @objc open func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            (self as? NSControl)?.backgroundStyle = backgroundStyle
            (self as? NSTableCellView)?.backgroundStyle = backgroundStyle

            if #available(macOS 12.0, *), let view = self as? NSImageView {
                if backgroundStyle == .emphasized, let configuration = view.symbolConfiguration {
                    view.previousConfiguration = configuration
                    let copy = configuration.copied()
                    copy.colors = nil
                    view.symbolConfiguration = copy
                    Swift.print(view.symbolConfiguration?.colors ?? "nil")
                    Swift.print(view.symbolConfiguration ?? "nil")
                } else if let configuration = view.previousConfiguration {
                    view.symbolConfiguration = configuration
                    view.previousConfiguration = nil
                }
                
                // Swift.print(view.symbolConfiguration ?? "nil")
                /*
                if backgroundStyle == .emphasized, let configuration = view.imageSymbolConfiguration {
                    view.previousConfiguration = view.symbolConfiguration
                    view.symbolConfiguration = configuration.color(nil).nsUI()
                } else if let configuration = view.previousConfiguration {
                    view.symbolConfiguration = configuration
                    view.previousConfiguration = nil
                }
                 */
            }
            
            for subview in subviews {
                subview.setBackgroundStyle(backgroundStyle)
            }
        }
    }

@available(macOS 12.0, *)
extension NSImage.SymbolConfiguration {    
    func copied() -> NSImage.SymbolConfiguration {
        var configuration = NSImage.SymbolConfiguration()
        configuration.setValue(value(forKey: "renderingStyle"), forKey: "renderingStyle")
        // configuration.colors = colors
        configuration.pointSize = pointSize
        configuration.setValue(value(forKey: "weight"), forKey: "weight")
        configuration.setValue(value(forKey: "scale"), forKey: "scale")
        configuration.prefersMulticolor = prefersMulticolor
        return configuration
    }
}


#endif
