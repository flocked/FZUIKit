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
     
     If you you set this property to `true`, ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` is ignored.
     */
    @objc open var automaticallyResizesToFit: Bool {
        get { getAssociatedValue("automaticallyResizesToFit") ?? false }
        set {
            guard newValue != automaticallyResizesToFit else { return }
            setAssociatedValue(newValue, key: "automaticallyResizesToFit")
            swizzleIntrinsicContentSize()
            setupTextFieldObserver()
            observeEditing()
            guard newValue || needsFontAdjustments else { return }
            resizeToFit()
            adjustFontSize()
        }
    }
    
    /**
     Sets Boolean value indicating whether the text field is automatically adjust it's size to fit it's string value.
     
     If you you set this property to `true`, ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` is ignored.

     - Note: This property isn't working with `NSSearchField`.
     */
    @discardableResult
    @objc open func automaticallyResizesToFit(_ resizesToFit: Bool) -> Self {
        automaticallyResizesToFit = resizesToFit
        return self
    }
    
    /**
     The edges the textfield's size expands when automatic resizing (``AppKit/NSTextField/automaticallyResizesToFit``) is enabled.
          
     The default value is `[.bottom , .right]`
     */
    public var preferredResizingEdges: RectEdge {
        get { getAssociatedValue("preferredResizingEdges") ?? [.bottom, .right] }
        set { setAssociatedValue(newValue, key: "preferredResizingEdges") }
    }
    
    /// Sets the edges the textfield's size expands when automatic resizing (``AppKit/NSTextField/automaticallyResizesToFit``) is enabled.
    @discardableResult
    public func preferredResizingEdges(_ edges: RectEdge) -> Self {
        preferredResizingEdges = edges
        return self
    }
    
    /**
     The preferred minimum width of the text field.
     
     The default value is `0`, indicating to use the placeholder width as minimum width, if [stringValue](https://developer.apple.com/documentation/appkit/nscontrol/stringvalue) is empty.
     
     To always use the placeholder width as minimum width, specify the constant ``AppKit/NSTextField/placeholderWidth``.
     */
    @objc open var preferredMinLayoutWidth: CGFloat {
        get { getAssociatedValue("preferredMinLayoutWidth") ?? 0 }
        set {
            guard newValue != preferredMinLayoutWidth else { return }
            swizzleIntrinsicContentSize()
            setAssociatedValue(newValue, key: "preferredMinLayoutWidth")
            resizeToFit()
        }
    }
    
    /**
     Sets the preferred minimum width of the text field.
     
     The default value is `0`, indicating to use the placeholder width as minimum width, if [stringValue](https://developer.apple.com/documentation/appkit/nscontrol/stringvalue) is empty.

     To always use the placeholder width as minimum value, specify the constant ``AppKit/NSTextField/placeholderWidth``.
     */
    @discardableResult
    @objc open func preferredMinLayoutWidth(_ minWidth: CGFloat) -> Self {
        preferredMinLayoutWidth = minWidth
        return self
    }
    
    /// A value that tells the layout system to constraint the preferred minimum width (``AppKit/NSTextField/preferredMinLayoutWidth``) to the width of the placeholder string.
    public static let placeholderWidth: CGFloat = -1
    
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
    
    var intrinsicContentSizeHook: Hook? {
        get { getAssociatedValue("intrinsicContentSizeHook") }
        set { setAssociatedValue(newValue, key: "intrinsicContentSizeHook") }
    }

    func swizzleIntrinsicContentSize() {
        if automaticallyResizesToFit || preferredMinLayoutWidth != 0.0 {
            guard intrinsicContentSizeHook == nil else { return }
            do {
                intrinsicContentSizeHook = try hook(#selector(getter: NSTextField.intrinsicContentSize), closure: { original, textField, sel in
                    textField.calculatedFittingSize
                } as @convention(block) ((NSTextField, Selector) -> CGSize, NSTextField, Selector) -> CGSize)
            } catch {
                Swift.debugPrint(error)
            }
        } else {
            try? intrinsicContentSizeHook?.revert()
            intrinsicContentSizeHook = nil
        }
    }
    
    func withoutPlaceholder(_ without: Bool, handler: @escaping ()->()) {
        if without, let cell = textFieldCell, placeholderAttributedString != nil || placeholderString != nil {
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
        withoutPlaceholder(preferredMinLayoutWidth != 0) {
            cellSize = self.sizeThatFits(width: self.maxLayoutWidth)
        }
        cellSize.width.clamp(min: minLayoutWidth)
        cellSize.width.clamp(max: maxLayoutWidth)
     //   cellSize.width += textPadding.width
      //  cellSize.height += textPadding.height
        cellSize = cellSize.scaledIntegral(for: self)
        // Swift.print("calculatedFittingSize", cellSize)
        return cellSize
    }
        
    var placeholderStringSize: CGSize {
        guard placeholderString != nil || placeholderAttributedString != nil else { return .zero }
        var size: CGSize = .zero
        let attributedString = attributedStringValue
        stringValue = ""
        size = sizeThatFits(width: maxLayoutWidth, height: nil)
        attributedStringValue = attributedString
        return size
    }
    
    var minLayoutWidth: CGFloat {
        preferredMinLayoutWidth == Self.placeholderWidth ? placeholderStringSize.width + 1.0 : preferredMinLayoutWidth
    }
    
    var maxLayoutWidth: CGFloat {
        preferredMaxLayoutWidth == 0 ? CGFloat.greatestFiniteMagnitude : preferredMaxLayoutWidth
    }
    
    /// Asks the text field to calculate and return the size that best fits the specified width and height.
    func sizeThatFits(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        guard let cell = cell else { return bounds.size }
        var rect = cell.drawingRect(forBounds: bounds)
        if let width = width {
            rect.size.width = width != NSView.noIntrinsicMetric && width != 0 ? width : .greatestFiniteMagnitude
        }
        if let height = height {
            rect.size.height = height != NSView.noIntrinsicMetric && height != 0 ? height : .greatestFiniteMagnitude
        }
        return cell.cellSize(forBounds: rect)
    }
    
    public func sizeThatFits(in size: CGSize) -> CGSize {
        sizeThatFits(width: size.width, height: size.height)
    }
    
    public func sizeThatFits(width: CGFloat) -> CGSize {
        sizeThatFits(in: CGSize(width, NSView.noIntrinsicMetric))
    }
    
    public func sizeThatFits(height: CGFloat) -> CGSize {
        sizeThatFits(in: CGSize(NSView.noIntrinsicMetric, height))
    }
}

#endif
