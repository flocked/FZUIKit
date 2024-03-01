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
            if let self = self as? NSControl, self.backgroundStyle != backgroundStyle {
                self.backgroundStyle = backgroundStyle
            } else if let self = self as? NSTableCellView, self.backgroundStyle != backgroundStyle {
                self.backgroundStyle = backgroundStyle
            }
            
            for subview in subviews {
                subview.setBackgroundStyle(backgroundStyle)
            }
        }
    }

#endif
