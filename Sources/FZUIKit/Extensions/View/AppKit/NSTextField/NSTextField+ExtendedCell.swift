//
//  ExtendedTextFieldCell.swift
//
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

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
            observeEditing()
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
        guard extendedTextFieldCell == nil, let textFieldCell = cell as? NSTextFieldCell else { return }
        guard let layer = layer else {
            do {
                cell = try textFieldCell.archiveBasedCopy(as: ExtendedTextFieldCell.self)
            } catch {
                debugPrint(error)
            }
            return
        }
        do {
            let convertedCell = try textFieldCell.archiveBasedCopy(as: ExtendedTextFieldCell.self)
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
            cell = convertedCell
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
        } catch {
            debugPrint(error)
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
    
    var isEditingOrSelecting: Bool = false
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
    }
            
    func insetRect(for rect: CGRect) -> CGRect {
        var newRect = rect
        newRect.origin.x += textPadding.left
        newRect.origin.y += textPadding.top
        newRect.size.width -= textPadding.width
        newRect.size.height -= textPadding.height
        
        
        if isVerticallyCentered {
            let textSize = self.cellSize(forBounds: rect)
            let heightDelta = newRect.size.height - textSize.height
            if heightDelta > 0 {
                newRect.size.height -= heightDelta
                newRect.origin.y += heightDelta/2
            }
        }
        return newRect
    }
    
    override func cellSize(forBounds rect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: rect)
        size.height += (textPadding.height)
        size.width += (textPadding.width)
        return size
    }
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
      return super.drawingRect(forBounds: insetRect(for: rect))
    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        return insetRect(for: rect)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        isEditingOrSelecting = true
        super.edit(withFrame: insetRect(for: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
        isEditingOrSelecting = false
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        isEditingOrSelecting = true
        super.select(withFrame: insetRect(for: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        isEditingOrSelecting = false
    }
    
    override func focusRingMaskBounds(forFrame cellFrame: NSRect, in controlView: NSView) -> NSRect {
        var bounds = super.focusRingMaskBounds(forFrame: cellFrame, in: controlView)
        if focusType == .capsule {
            
            let leftRight = bounds.height/3.0
            let topBottom = bounds.height/10.0
            bounds.origin.x -= leftRight
            bounds.origin.y -= topBottom
            bounds.size.width += leftRight + leftRight
            bounds.size.height += topBottom + topBottom
        }
        return bounds
    }
    
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
            cornerRadius = (cellFrame.height/2.0) * relative.clamped(to: 0.0...1.0)
        default:
            break
        }
        
        let cellFrame = focusRingMaskBounds(forFrame: cellFrame, in: controlView)
        guard focusType != .default, cornerRadius != 0 else {
            super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
            return
        }
        NSBezierPath(roundedRect: cellFrame, cornerRadius: cornerRadius).fill()
    }
}

#endif
