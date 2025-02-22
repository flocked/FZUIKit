//
//  NSBox+.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

    import AppKit

    public extension NSBox {
        /**
         Returns a horizontal line with the specified width.

         - Parameter width: The width of the line.
         - Returns: A horizontal line.
         */
        static func horizontalLine(width: CGFloat) -> NSBox {
            let box = NSBox(frame: NSRect(origin: .zero, size: NSSize(width: width, height: 1)))
            box.boxType = .separator
            return box
        }

        /**
         Returns a vertical line with the specified height.

         - Parameter width: The height of the line.
         - Returns: A vertical line.
         */
        static func verticalLine(height: CGFloat) -> NSBox {
            let box = NSBox(frame: NSRect(origin: .zero, size: NSSize(width: 1, height: height)))
            box.boxType = .separator
            return box
        }
        
        /// Sets the color of the box’s background when the receiver is a custom box with a simple line border.
        @discardableResult
        func fillColor(_ color: NSColor) -> Self {
            self.fillColor = color
            return self
        }
        
        /// Sets the content view.
        @discardableResult
        func contentView(_ view: NSView?) -> Self {
            self.contentView = view
            return self
        }
        
        /// Sets the distances between the border and the content view.
        @discardableResult
        func contentViewMargins(_ margins: CGSize) -> Self {
            self.contentViewMargins = margins
            return self
        }
        
        /// Sets the constant representing the title position.
        @discardableResult
        func titlePosition(_ position: TitlePosition) -> Self {
            self.titlePosition = position
            return self
        }
        
        /// Sets the title.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// Sets the font of the title.
        @discardableResult
        func titleFont(_ font: NSFont) -> Self {
            self.titleFont = font
            return self
        }
        
        /// Sets the Boolean value that indicates whether the box is transparent.
        @discardableResult
        func isTransparent(_ isTransparent: Bool) -> Self {
            self.isTransparent = isTransparent
            return self
        }
        
        /// Sets the box type.
        @discardableResult
        func type(_ type: BoxType) -> Self {
            self.boxType = type
            return self
        }
        
        /// Sets the border width.
        @discardableResult
        func borderWidth(_ width: CGFloat) -> Self {
            self.borderWidth = width
            return self
        }
        
        /// Sets the border color.
        @discardableResult
        func borderColor(_ color: NSColor) -> Self {
            self.borderColor = color
            return self
        }
    }

#endif
