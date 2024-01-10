//
//  VerticallyCenteredTextFieldCell.swift
//  
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
import AppKit

/// A text field cell with vertical alignment and focus type property.
public class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    /// The focus ring type.
    public enum FocusType: Equatable {
        /// No focus ring.
        case none
        /// A capsule focus ring.
        case capsule
        /// A focus ring with rounded corners.
        case roundedCorners(CGFloat)
        /// A focus ring with relative rounded corners.
        case roundedCornersRelative(CGFloat)
        /// The default focus ring.
        case `default`
    }

    /// The vertical alignment of the text.
    public enum VerticalAlignment: Equatable {
        /// The text is vertically centered.
        case center
        /// The default vertical text alignment.
        case `default`
    }

    /// The focus ring type.
    public var focusType: FocusType = .default {
        didSet { guard oldValue != focusType else { return }

        }
    }
    /// The vertical alignment of the text.
    public var verticalAlignment: VerticalAlignment = .center

    /// The leading padding of the cell.
    public var leadingPadding: CGFloat = 0
    /// The trailing padding of the cell.
    public var trailingPadding: CGFloat = 0

    internal var isEditingOrSelecting = false
    //  internal var isEditingHandler: ((Bool)->())? = nil

    override public func titleRect(forBounds rect: NSRect) -> NSRect {
        switch verticalAlignment {
        case .center:
            var titleRect = super.titleRect(forBounds: rect)
            let minimumHeight = cellSize(forBounds: rect).height
            titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2
            titleRect.size.height = minimumHeight
            titleRect = titleRectWithPadding(for: titleRect)
            return titleRect
        case .default:
            let paddedRect = titleRectWithPadding(for: rect)
            return super.titleRect(forBounds: paddedRect)
        }
    }

    internal func titleRectWithPadding(for rect: NSRect) -> NSRect {
        let isLTR = self.userInterfaceLayoutDirection == .leftToRight
        let newRect = NSRect(x: rect.origin.x + (isLTR ? self.leadingPadding : self.trailingPadding),
                                   y: rect.origin.y,
                                   width: rect.width - self.leadingPadding - self.trailingPadding,
                                   height: rect.height)
        return newRect
    }

    override public func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }

    override public func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        isEditingOrSelecting = true
        super.edit(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
        isEditingOrSelecting = false
    }

    override public func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        isEditingOrSelecting = true
        super.select(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        isEditingOrSelecting = false
    }

    override public func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard focusType != FocusType.none else {
            return
        }

        var cornerRadius: CGFloat = 0
        switch focusType {
        case .capsule:
            cornerRadius = cellFrame.size.height / 2.0
        case let .roundedCorners(radius):
            cornerRadius = radius
        case let .roundedCornersRelative(relative):
            cornerRadius = cellFrame.size.height / 2.0
            cornerRadius = cornerRadius * relative.clamped(max: 1.0)
        default:
            break
        }

        // Draw default
        guard focusType != FocusType.default && cornerRadius != 0 else {
            super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
            return
        }

        // Custome
        // Make forcus ring frame fit with cell size
        // let newFrame = cellFrame.insetBy(dx: 2, dy: 1)
        let newFrame = cellFrame

        let path = NSBezierPath(roundedRect: newFrame, xRadius: cornerRadius, yRadius: cornerRadius)
        path.fill()
    }
}

#endif
