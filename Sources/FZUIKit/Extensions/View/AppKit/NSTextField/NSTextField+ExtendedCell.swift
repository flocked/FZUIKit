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
    
    /// The leading padding of the text filed.
    public var leadingPadding: CGFloat {
        get { extendedTextFieldCell?.leadingPadding ?? 0.0 }
        set {
            if newValue != 0.0 {
                convertToExtendedTextFieldCell()
            }
            extendedTextFieldCell?.leadingPadding = newValue
        }
    }
    
    /// The trailing padding of the text field.
    public var trailingPadding: CGFloat {
        get { extendedTextFieldCell?.trailingPadding ?? 0.0 }
        set {
            if newValue != 0.0 {
                convertToExtendedTextFieldCell()
            }
            extendedTextFieldCell?.leadingPadding = newValue
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
                
                cell = textFieldCell.convertToExtended()
                
                self.wantsLayer = true
                self.layer?.backgroundColor = backgroundColor
                self.border = border
                self.innerShadow = innerShadow
                self.outerShadow = outerShadow
                self.cornerRadius = cornerRadius
                self.cornerCurve = cornerCurve
                self.roundedCorners = roundedCorners
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
    
    /// The leading padding of the cell.
    public var leadingPadding: CGFloat = 0 {
        didSet { leadingPadding = leadingPadding.clamped(min: 0.0) }
    }
    
    /// The trailing padding of the cell.
    public var trailingPadding: CGFloat = 0 {
        didSet { trailingPadding = trailingPadding.clamped(min: 0.0) }
    }
    
    var isEditingOrSelecting = false
    
    override public func titleRect(forBounds rect: NSRect) -> NSRect {
        if isVerticallyCentered {
            var titleRect = super.titleRect(forBounds: rect)
            let minimumHeight = cellSize(forBounds: rect).height
            titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2
            titleRect.size.height = minimumHeight
            titleRect = titleRectWithPadding(for: titleRect)
            return titleRect
        } else {
            let paddedRect = titleRectWithPadding(for: rect)
            return super.titleRect(forBounds: paddedRect)
        }
    }
    
    func titleRectWithPadding(for rect: NSRect) -> NSRect {
        let isLTR = userInterfaceLayoutDirection == .leftToRight
        let newRect = NSRect(x: rect.origin.x + (isLTR ? leadingPadding : trailingPadding),
                             y: rect.origin.y,
                             width: rect.width - leadingPadding - trailingPadding,
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
