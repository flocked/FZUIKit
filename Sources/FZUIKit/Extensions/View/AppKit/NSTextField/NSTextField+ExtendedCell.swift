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
        get { getAssociatedValue(key: "focusType", object: self, initialValue: .default) }
        set {
            guard newValue != focusType else { return }
            if newValue != .default {
                convertToExtendedTextFieldCell()
            }
            set(associatedValue: newValue, key: "focusType", object: self)
        }
    }
    
    /// A Boolean value indicating whether the text is vertically centered.
    public var isVerticallyCentered: Bool {
        get { getAssociatedValue(key: "isVerticallyCentered", object: self, initialValue: false) }
        set {
            guard newValue != isVerticallyCentered else { return }
            if newValue != false {
                convertToExtendedTextFieldCell()
            }
            set(associatedValue: newValue, key: "isVerticallyCentered", object: self)
        }
    }
    
    /// The padding of the text.
    public var textPadding: NSEdgeInsets {
        get { getAssociatedValue(key: "textPadding", object: self, initialValue: .zero) }
        set {
            guard newValue != textPadding else { return }
            if newValue != .zero {
                convertToExtendedTextFieldCell()
            }
            set(associatedValue: newValue, key: "textPadding", object: self)
        }
    }
    
    var extendedTextFieldCell: ExtendedTextFieldCell? {
        cell as? ExtendedTextFieldCell
    }
    
    func convertToExtendedTextFieldCell() {
        guard let cell = cell as? NSTextFieldCell, !cell.isMethodReplaced(#selector(NSTextFieldCell.cellSize(forBounds:))) else { return }
        cell.swizzleCell()
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
    
    
    override func cellSize(forBounds rect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: rect)
        size.height += (textPadding.height)
        size.width += (textPadding.width)
        return size
    }

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        return super.titleRect(forBounds: rect).insetBy(dx: textPadding.left, dy: textPadding.bottom)
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
    
    override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {
        Swift.print("textCell highlight")
        let insetRect = cellFrame.insetBy(dx: textPadding.left, dy: textPadding.bottom)
        super.highlight(flag, withFrame: insetRect, in: controlView)
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
        /*
        bounds.origin.x -= textPadding.left
        bounds.origin.y -= textPadding.bottom
        bounds.size.width += textPadding.width
        bounds.size.height += textPadding.height
         */
        
        Swift.print("focusRingMaskBounds", super.focusRingMaskBounds(forFrame: cellFrame, in: controlView), bounds)
        return bounds
    }
    
    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard focusType != .none else {
            return
        }
        
        Swift.print("drawFocusRingMask", cellFrame, focusRingMaskBounds(forFrame: cellFrame, in: controlView))

        var cornerRadius: CGFloat = 0
        switch focusType {
        case .capsule:
            cornerRadius = cellFrame.size.height / 2.0
        case let .roundedCorners(radius):
            cornerRadius = radius
        case let .roundedCornersRelative(relative):
            cornerRadius = cornerRadius * relative.clamped(max: 1.0)
        default:
            break
        }
        
        guard focusType != .default, cornerRadius != 0 else {
            super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
            return
        }
        
        // Make focus ring frame fit with cell size via cellFrame.insetBy(dx: 2, dy: 1)
        let cellFrame = focusRingMaskBounds(forFrame: cellFrame, in: controlView)
        NSBezierPath(roundedRect: cellFrame, cornerRadius: cornerRadius).fill()
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

extension NSTextFieldCell {
    var isEditingOrSelecting: Bool {
        get { getAssociatedValue(key: "isEditingOrSelecting", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "isEditingOrSelecting", object: self) }
    }
    
    var textField: NSTextField? {
        controlView as? NSTextField
    }
    
    func swizzleCell() {
        do {
           try replaceMethod(
           #selector(NSTextFieldCell.cellSize(forBounds:)),
           methodSignature: (@convention(c)  (AnyObject, Selector, CGRect) -> (CGSize)).self,
           hookSignature: (@convention(block)  (AnyObject, CGRect) -> (CGSize)).self) { store in {
               object, bounds in
               var cellSize = store.original(object, #selector(NSTextFieldCell.cellSize(forBounds:)), bounds)
               if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                   cellSize.height += textField.textPadding.height
                   cellSize.width += textField.textPadding.height
               }
               return cellSize
               }
           }
            
            try replaceMethod(
            #selector(NSTextFieldCell.titleRect(forBounds:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect) -> (CGRect)).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect) -> (CGRect)).self) { store in {
                object, rect in
                var titleRect = rect
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    titleRect = titleRect.insetBy(dx: textField.textPadding.left, dy: textField.textPadding.bottom)
                    if !cell.isEditingOrSelecting {
                        let textSize = cell.cellSize(forBounds: rect)
                        let heightDelta = titleRect.size.height - textSize.height
                        if heightDelta > 0 {
                            titleRect.size.height -= heightDelta
                            titleRect.origin.y += heightDelta/2
                        }
                    }
                }
                return titleRect
                }
            }

            try replaceMethod(
            #selector(NSTextFieldCell.edit(withFrame:in:editor:delegate:event:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect, NSView, NSText, Any?, NSEvent) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect, NSView, NSText, Any?, NSEvent) -> ()).self) { store in {
                object, rect, controlView, textObj, delegate, event in
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    cell.isEditingOrSelecting = true
                    let insetRect = rect.insetBy(dx: textField.textPadding.left, dy: textField.textPadding.bottom)
                    store.original(object, #selector(NSTextFieldCell.edit(withFrame:in:editor:delegate:event:)), insetRect, controlView, textObj, delegate, event)
                    cell.isEditingOrSelecting = false
                }
                }
            }
            
            try replaceMethod(
            #selector(NSTextFieldCell.select(withFrame:in:editor:delegate:start:length:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect, NSView, NSText, Any?, Int, Int) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect, NSView, NSText, Any?, Int, Int) -> ()).self) { store in {
                object, rect, controlView, textObj, delegate, selStart, length in
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    cell.isEditingOrSelecting = true
                    let insetRect = rect.insetBy(dx: textField.textPadding.left, dy: textField.textPadding.bottom)
                    store.original(object, #selector(NSTextFieldCell.select(withFrame:in:editor:delegate:start:length:)), insetRect, controlView, textObj, delegate, selStart, length)
                    cell.isEditingOrSelecting = false
                }
                }
            }
            
            try replaceMethod(
            #selector(NSTextFieldCell.highlight(_:withFrame:in:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, Bool, CGRect, NSView) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject, Bool, CGRect, NSView) -> ()).self) { store in {
                object, flag, cellFrame, controlView in
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    let insetRect = cellFrame.insetBy(dx: textField.textPadding.left, dy: textField.textPadding.bottom)
                    store.original(object, #selector(NSTextFieldCell.highlight(_:withFrame:in:)), flag, insetRect, controlView)
                }
                }
            }
            
            try replaceMethod(
            #selector(NSTextFieldCell.drawInterior(withFrame:in:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect, NSView) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect, NSView) -> ()).self) { store in {
                object, cellFrame, controlView in
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    let insetRect = cellFrame.insetBy(dx: textField.textPadding.left, dy: textField.textPadding.bottom)
                    store.original(object, #selector(NSTextFieldCell.drawInterior(withFrame:in:)), insetRect, controlView)
                }
                }
            }
            
            try replaceMethod(
            #selector(NSTextFieldCell.drawFocusRingMask(withFrame:in:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect, NSView) -> ()).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect, NSView) -> ()).self) { store in {
                object, cellFrame, controlView in
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    guard textField.focusType != .none else {
                        return
                    }
                    
                    Swift.print("drawFocusRingMask", cellFrame, cell.focusRingMaskBounds(forFrame: cellFrame, in: controlView))
                    var cornerRadius: CGFloat = 0
                    switch textField.focusType {
                    case .capsule:
                        cornerRadius = cellFrame.size.height / 2.0
                    case let .roundedCorners(radius):
                        cornerRadius = radius
                    case let .roundedCornersRelative(relative):
                        cornerRadius = cornerRadius * relative.clamped(max: 1.0)
                    default:
                        break
                    }
                    
                    guard textField.focusType != .default, cornerRadius != 0 else {
                        store.original(object, #selector(NSTextFieldCell.drawFocusRingMask(withFrame:in:)), cellFrame, controlView)
                        return
                    }
                    
                    // Make focus ring frame fit with cell size via cellFrame.insetBy(dx: 2, dy: 1)
                    let cellFrame = cell.focusRingMaskBounds(forFrame: cellFrame, in: controlView)
                    NSBezierPath(roundedRect: cellFrame, cornerRadius: cornerRadius).fill()
                }
                }
            }
            
            try replaceMethod(
            #selector(NSTextFieldCell.focusRingMaskBounds(forFrame:in:)),
            methodSignature: (@convention(c)  (AnyObject, Selector, CGRect, NSView) -> (CGRect)).self,
            hookSignature: (@convention(block)  (AnyObject, CGRect, NSView) -> (CGRect)).self) { store in {
                object, cellFrame, controlView in
                
                var bounds = store.original(object, #selector(NSTextFieldCell.focusRingMaskBounds(forFrame:in:)), cellFrame, controlView)
                if let cell = object as? NSTextFieldCell, let textField = cell.textField {
                    if textField.focusType == .capsule {
                        let leftRight = bounds.height/3.0
                        let topBottom = bounds.height/10.0
                        bounds.origin.x -= leftRight
                        bounds.origin.y -= topBottom
                        bounds.size.width += leftRight + leftRight
                        bounds.size.height += topBottom + topBottom
                    }
                    bounds.origin.x -= textField.textPadding.left
                    bounds.origin.y -= textField.textPadding.bottom
                    bounds.size.width += textField.textPadding.width
                    bounds.size.height += textField.textPadding.height
                    
                }
                return bounds
                }
            }
        } catch {
           Swift.debugPrint(error)
        }
    }
}

#endif
