//
//  NSTextField+Resizing.swift
//
//
//  Created by Florian Zand on 05.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTextField {
    /**
     A Boolean value indicating whether the text field is automatically adjust it's size to fit it's string value.
     
     If you you set this property to `true`, ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` is set to `false`.
     
     - Note: This property isn't working with `NSSearchField`.
     */
    @objc open var automaticallyResizesToFit: Bool {
        get { getAssociatedValue("automaticallyResizesToFit", initialValue: false) }
        set {
            guard !(self is NSSearchField) else { return }
            guard newValue != automaticallyResizesToFit else { return }
            setAssociatedValue(newValue, key: "automaticallyResizesToFit")
            swizzleIntrinsicContentSize()
            observeEditing()
            if newValue {
                adjustsFontSizeToFitWidth = false
                resizeToFit()
                adjustFontSize()
            }
        }
    }
    
    /**
     Sets Boolean value indicating whether the text field is automatically adjust it's size to fit it's string value.
     
     If you you set this property to `true`, ``adjustsFontSizeToFitWidth`` is set to `false`.
     
     - Note: This property isn't working with `NSSearchField`.
     */
    @discardableResult
    @objc open func automaticallyResizesToFit(_ resizesToFit: Bool) -> Self {
        automaticallyResizesToFit = resizesToFit
        return self
    }
    
    /**
     The edges the textfield's size expands when automatic resizing is enabled.
     
     The default value is `[.bottom , .right]`
     */
    public var preferredResizingEdges: RectEdge {
        get { getAssociatedValue("preferredResizingEdges", initialValue: [.bottom, .right]) }
        set { setAssociatedValue(newValue, key: "preferredResizingEdges") }
    }
    
    /// Sets edges the textfield's size expands when automatic resizing is enabled.
    @discardableResult
    public func preferredResizingEdges(_ edges: RectEdge) -> Self {
        preferredResizingEdges = edges
        return self
    }
    
    /**
     The preferred minimum width of the text field.
     
     The default value is ``AppKit/NSTextField/automaticWidth``. It uses the placeholder width as minimum width, if the string value is empty.

     To always use the placeholder width as minimum width, specify the constant ``AppKit/NSTextField/placeholderWidth``.
     */
    @objc open var preferredMinLayoutWidth: CGFloat {
        get { getAssociatedValue("preferredMinLayoutWidth") ?? NSTextField.automaticWidth }
        set {
            swizzleIntrinsicContentSize()
            setAssociatedValue(newValue, key: "preferredMinLayoutWidth")
            resizeToFit()
        }
    }
    
    /**
     Sets the preferred minimum width of the text field.
     
     The default value is ``AppKit/NSTextField/automaticWidth``. It uses the placeholder width as minimum value, if the string value of the text field is empty.
     
     To always use the placeholder width as minimum value, specify the constant ``AppKit/NSTextField/placeholderWidth``.
     */
    @discardableResult
    @objc open func preferredMinLayoutWidth(_ minWidth: CGFloat) -> Self {
        preferredMinLayoutWidth = minWidth
        return self
    }
    
    /// A value that tells the layout system to constraint the preferred minimum width to the width of the placeholder string (see ``AppKit/NSTextField/preferredMinLayoutWidth``).
    public static let placeholderWidth: CGFloat = -1
    
    /// A value that tells the layout system to constraint the preferred minimum width to the width of the placeholder string, if the string value of the text field is empty (see ``AppKit/NSTextField/preferredMinLayoutWidth``).
    public static let automaticWidth: CGFloat = -2
    
    /// A value that tells the layout system to constraint the preferred maximum width to the width of the superview (see `preferredMaxLayoutWidth`).
    public static let superviewWidth: CGFloat = -1
    
    func resizeToFit() {
        guard automaticallyResizesToFit else { return }
        if translatesAutoresizingMaskIntoConstraints {
            var newFrame = frame
            newFrame.size = calculatedFittingSize
            if preferredResizingEdges.contains([.bottom, .top]) {
                let diff = newFrame.height - frame.height
                newFrame.origin.y -= diff / 2.0
            } else if preferredResizingEdges.contains(.bottom) {
                let diff = newFrame.height - frame.height
                newFrame.origin.y -= diff
            }
            if preferredResizingEdges.contains([.left, .right]) {
                let diff = newFrame.width - frame.width
                newFrame.origin.x -= diff / 2.0
            } else if preferredResizingEdges.contains(.left) {
                let diff = newFrame.width - frame.width
                newFrame.origin.x -= diff
            }
            frame = newFrame
        } else {
            invalidateIntrinsicContentSize()
        }
    }

    func swizzleIntrinsicContentSize() {
        if automaticallyResizesToFit || preferredMinLayoutWidth != 0.0 {
            guard !isMethodHooked(#selector(getter: NSTextField.intrinsicContentSize)) else { return }
            textFieldObserver = nil
            do {
                try hook(#selector(getter: NSTextField.intrinsicContentSize), closure: { original, textField, sel in
                    if (textField.automaticallyResizesToFit || textField.preferredMinLayoutWidth != .zero) {
                        let newSize = textField.calculatedFittingSize
                        return newSize
                    }
                    return original(textField, sel)
                } as @convention(block) ((NSTextField, Selector) -> CGSize, NSTextField, Selector) -> CGSize)
                setupTextFieldObserver()
            } catch {
                Swift.debugPrint(error)
            }
        } else if isMethodHooked(#selector(getter: NSTextField.intrinsicContentSize)) {
            textFieldObserver = nil
            revertHooks(for: #selector(getter: NSTextField.intrinsicContentSize))
            setupTextFieldObserver()
        }
    }
    
    func withoutPlaceholder(_ without: Bool, handler: @escaping ()->()) {
        if without, let cell = cell as? NSTextFieldCell, placeholderAttributedString != nil || placeholderString != nil {
            if let placeholder = placeholderAttributedString {
                cell.placeholderAttributedString = nil
                handler()
                cell.placeholderAttributedString = placeholder
            } else if let placeholder = placeholderString {
                cell.placeholderString = nil
                handler()
                cell.placeholderString = placeholder
            }
        } else {
            handler()
        }
    }

    var calculatedFittingSize: CGSize {
        guard cell != nil else { return frame.size }
        var cellSize: CGSize = .zero
        withoutPlaceholder(preferredMinLayoutWidth != NSTextField.automaticWidth) {
            cellSize = self.sizeThatFits(width: self.maxLayoutWidth)
        }        
        if preferredMinLayoutWidth == Self.placeholderWidth {
            cellSize.width = max((placeholderStringSize.width + 1.0).clamped(max: maxLayoutWidth), cellSize.width)
        } else if preferredMinLayoutWidth > 0.0 {
            cellSize.width = max(preferredMinLayoutWidth.clamped(max: maxLayoutWidth), cellSize.width)
        }
        cellSize.width.round(toMultiple: 0.5, rule: .awayFromZero)
        cellSize.height.round(toMultiple: 0.5, rule: .awayFromZero)
        // Swift.print("calculatedFittingSize", cellSize)
        return cellSize
    }
        
    var placeholderStringSize: CGSize {
        if let placeholder = placeholderString {
            return fittingSize(for: placeholder, maxWidth: maxLayoutWidth)
        } else if let placeholder = placeholderAttributedString {
            return fittingSize(for: placeholder, maxWidth: maxLayoutWidth)
        }
        return .zero
        /*
        let attributedStringValue = attributedStringValue
        cell.stringValue = ""
        let size = self.sizeThatFits(width: self.maxLayoutWidth)
        cell.attributedStringValue = attributedStringValue
        return size
         */
    }
    
    var maxLayoutWidth: CGFloat {
        if preferredMaxLayoutWidth == NSTextField.superviewWidth, let superview = superview {
            return superview.frame.width - (frame.origin.x * 2)
        }
        return preferredMaxLayoutWidth == 0 ? CGFloat.greatestFiniteMagnitude : preferredMaxLayoutWidth
    }
    
    func fittingSize(for string: String, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGSize {
        guard let cell = cell else { return .zero }
        var size: CGSize = .zero
        let stringValue = stringValue
        cell.stringValue = string
        size = sizeThatFits(width: maxWidth, height: maxHeight)
        cell.stringValue = stringValue
        return size
    }
    
    
    func fittingSize(for attributedString: NSAttributedString, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGSize {
        guard let cell = cell else { return .zero }
        var size: CGSize = .zero
        let stringValue = attributedStringValue
        cell.attributedStringValue = attributedString
        size = sizeThatFits(width: maxWidth, height: maxHeight)
        cell.attributedStringValue = stringValue
        return size
    }
    
    /// Asks the text field to calculate and return the size that best fits the specified width and height.
    func sizeThatFits(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        guard let cell = cell else { return frame.size }
        var rect = cell.drawingRect(forBounds: bounds)
        if let width = width {
            rect.size.width = width != NSView.noIntrinsicMetric ? width : .greatestFiniteMagnitude
        }
        if let height = height {
            rect.size.height = height != NSView.noIntrinsicMetric ? height : .greatestFiniteMagnitude
        }
        return cell.cellSize(forBounds: rect)
        
    }
}

#endif
