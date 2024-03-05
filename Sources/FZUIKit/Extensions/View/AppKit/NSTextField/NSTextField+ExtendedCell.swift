//
//  ExtendedTextFieldCell.swift
//
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
import AppKit

extension NSTextField {
    
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
    
    /// The focus type of the text field.
    public var focusType: FocusType {
        get { extendedTextFieldCell?.focusType ?? .default }
        set {
            if newValue != .default {
                convertToExtendedTextFieldCell()
            }
            extendedTextFieldCell?.focusType = newValue
        }
    }
    
    /// A Boolean value indicating whether the text is vertically centered.
    public var isVerticallyCentered: Bool {
        get { extendedTextFieldCell?.isVerticallyCentered ?? false }
        set {
            if newValue != false {
                convertToExtendedTextFieldCell()
            }
            extendedTextFieldCell?.isVerticallyCentered = newValue
        }
    }
    
    /// The padding of the text.
    public var textPadding: NSEdgeInsets {
        get { extendedTextFieldCell?.textPadding ?? .zero }
        set {
            if newValue != .zero {
                convertToExtendedTextFieldCell()
            }
            extendedTextFieldCell?.textPadding = newValue
        }
    }
    
    var extendedTextFieldCell: ExtendedTextFieldCell? {
        cell as? ExtendedTextFieldCell
    }
    
    func convertToExtendedTextFieldCell() {
        if extendedTextFieldCell == nil, let textFieldCell = cell as? NSTextFieldCell {
            if let layer = layer {
                let backgroundColor = layer.backgroundColor
                let border = border
                let innerShadow = innerShadow
                let outerShadow = outerShadow
                let cornerRadius = cornerRadius
                let cornerCurve = cornerCurve
                let roundedCorners = roundedCorners
                let isOpaque = isOpaque
                let mask = mask
                let anchorPoint = anchorPoint
                let transform = transform
                let transform3D = transform3D
                let shadowPath = shadowPath
                let clipsToBounds = clipsToBounds

                cell = textFieldCell.convertToExtended()
                self.wantsLayer = true
                layer.delegate = self as? any CALayerDelegate
                self.layer = layer
                self.layer?.backgroundColor = backgroundColor
                self.border = border
                self.innerShadow = innerShadow
                self.outerShadow = outerShadow
                self.roundedCorners = roundedCorners
                self.cornerCurve = cornerCurve
                self.cornerRadius = cornerRadius
                self.clipsToBounds = clipsToBounds
                self.isOpaque = isOpaque
                self.mask = mask
                self.anchorPoint = anchorPoint
                self.shadowPath = shadowPath
                if transform != CGAffineTransformIdentity {
                    self.transform = transform
                }
                if transform3D != CATransform3DIdentity {
                    self.transform3D = transform3D
                }
            } else {
                cell = textFieldCell.convertToExtended()
            }
        }
    }
}

/// A text field cell with vertical alignment and focus type property.
class ExtendedTextFieldCell: NSTextFieldCell {
    
    /// The focus ring type.
    public var focusType: NSTextField.FocusType = .default
    
    /// A Boolean value indicating whether the text is vertically centered.
    public var isVerticallyCentered: Bool = false
    
    /// The padding of the text.
    public var textPadding = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { 
            textPadding.bottom = textPadding.bottom.clamped(min: 0.0)
            textPadding.top = textPadding.top.clamped(min: 0.0)
            textPadding.left = textPadding.left.clamped(min: 0.0)
            textPadding.right = textPadding.right.clamped(min: 0.0)
        }
    }
    
    var isEditingOrSelecting = false
    
    override func cellSize(forBounds rect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: rect)
        size.height += (textPadding.height)
        return size
    }

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        if isVerticallyCentered {
            var titleRect = rect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
            
            if !isEditingOrSelecting {
                let textSize = self.cellSize(forBounds: rect)
                let heightDelta = titleRect.size.height - textSize.height
                if heightDelta > 0 {
                    titleRect.size.height -= heightDelta
                    titleRect.origin.y += heightDelta/2
                }
            }
            return titleRect
            
            /*
             var titleRect = super.titleRect(forBounds: rect)
             let minimumHeight = cellSize(forBounds: rect).height
             titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2
             titleRect.size.height = minimumHeight
             titleRect = titleRect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
             return titleRect
             */
            
            /*
            var titleRect = rect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
            let minimumHeight = cellSize(forBounds: rect).height
            titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2
            titleRect.size.height = minimumHeight
            return titleRect
             */
        } else {
            return rect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
        }
    }

    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        isEditingOrSelecting = true
        let insetRect = rect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
        super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
        isEditingOrSelecting = false
    }

    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        isEditingOrSelecting = true
        let insetRect = rect.insetBy(dx: textPadding.left, dy: textPadding.bottom)
        super.select(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        isEditingOrSelecting = false
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let insetRect = cellFrame.insetBy(dx: textPadding.left, dy: textPadding.bottom)
        super.drawInterior(withFrame: insetRect, in: controlView)
    }
    
    /*
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let newRect = titleRectWithPadding(for: rect)
        return super.drawingRect(forBounds: newRect)
    }
     */
    
    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard focusType != .none else {
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
        guard focusType != .default, cornerRadius != 0 else {
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
    func convertToExtended() -> ExtendedTextFieldCell {
        let cell = ExtendedTextFieldCell(textCell: stringValue)
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
