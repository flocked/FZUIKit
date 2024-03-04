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

        var isEditingOrSelecting = false
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

        func titleRectWithPadding(for rect: NSRect) -> NSRect {
            if isEditingOrSelecting {
                let isLTR = userInterfaceLayoutDirection == .leftToRight
                let newRect = NSRect(x: rect.origin.x + (isLTR ? leadingPadding : trailingPadding),
                                     y: rect.origin.y,
                                     width: rect.width - leadingPadding - trailingPadding,
                                     height: rect.height)
                return newRect
            }
            return super.titleRect(forBounds: rect)
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
            guard focusType != FocusType.default, cornerRadius != 0 else {
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

extension NSTextFieldCell {
    func convertToVerticalTextFieldCell() -> VerticallyCenteredTextFieldCell {
        let cell = VerticallyCenteredTextFieldCell(textCell: stringValue)
        cell.title = title
        cell.objectValue = objectValue
        cell.representedObject = representedObject
        cell.attributedStringValue = attributedStringValue
        cell.textColor = textColor
        cell.bezelStyle = bezelStyle
        cell.drawsBackground = drawsBackground
        cell.backgroundColor = backgroundColor
        cell.placeholderString = placeholderString
        cell.placeholderAttributedString = placeholderAttributedString
        cell.allowedInputSourceLocales = allowedInputSourceLocales
        cell.tag = tag
        cell.focusRingType = focusRingType
        cell.controlSize = controlSize
        cell.action = action
        cell.target = target
        cell.formatter = formatter
        cell.isHighlighted = isHighlighted
        cell.isSelectable = isSelectable
        cell.alignment = alignment
        cell.font = font
        cell.lineBreakMode = lineBreakMode
        cell.usesSingleLineMode = usesSingleLineMode
        cell.userInterfaceLayoutDirection = userInterfaceLayoutDirection
        cell.wraps = wraps
        cell.truncatesLastVisibleLine = truncatesLastVisibleLine
        cell.baseWritingDirection = baseWritingDirection
        cell.isEditable = isEditable
        cell.isEnabled = isEnabled
        cell.isBordered = isBordered
        cell.isBezeled = isBezeled
        cell.bezelStyle = bezelStyle
        cell.backgroundStyle = backgroundStyle
        cell.allowsUndo = allowsUndo
        cell.state = state
        cell.baseWritingDirection = baseWritingDirection
        cell.allowsEditingTextAttributes = allowsEditingTextAttributes
        cell.importsGraphics = importsGraphics
        cell.isContinuous = isContinuous
        cell.menu = menu
        cell.showsFirstResponder = showsFirstResponder
        cell.refusesFirstResponder = refusesFirstResponder
        cell.controlView = controlView
        return cell
    }
}

#endif
