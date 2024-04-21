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
     A Boolean value that indicates whether the text field is automatically adjust it's size to fit it's string value.
     
     - Note: If you you set this property to `true`, ``adjustsFontSizeToFitWidth`` is set to `false`.
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
    
    /// The direction the textfield's height expands when automatic resizing is enabled and `preferredMaxLayoutWidth` is reached.
    public enum ResizingDirection {
        /// The textfield's height expands to the top.
        case top
        /// The textfield's height expands to the bottom.
        case bottom
    }
    
    /// The direction the textfield's height expands when automatic resizing is enabled and `preferredMaxLayoutWidth` is reached.
    public var preferredResizingDirection: ResizingDirection {
        get { getAssociatedValue("resizingDirection", initialValue: .top) }
        set { setAssociatedValue(newValue, key: "resizingDirection") }
    }
    
    /**
     The preferred minimum width of the text field.
     
     Apply ``AppKit/NSTextField/placeholderWidth`` to this property, to use the placeholder width as minimum value
     */
    public var preferredMinLayoutWidth: CGFloat {
        get { getAssociatedValue("preferredMinLayoutWidth", initialValue: 0) }
        set {
            setAssociatedValue(newValue, key: "preferredMinLayoutWidth")
            resizeToFit()
        }
    }
    
    /// A value that tells the layout system to constraint the preferred minimum width to the width of the placeholder string. (see ``preferredMinLayoutWidth``).
    public static let placeholderWidth: CGFloat = -1
    
    /// A value that tells the layout system to constraint the preferred maximum width to the width of the superview (see `preferredMaxLayoutWidth`).
    public static let superviewWidth: CGFloat = -1
    
    func resizeToFit() {
        guard automaticallyResizesToFit else { return }
        if translatesAutoresizingMaskIntoConstraints {
            var newFrame = frame
            newFrame.size = calculatedFittingSize
            if preferredResizingDirection == .bottom {
                let diff = newFrame.height - frame.height
                newFrame.origin.y -= diff
            }
            frame = newFrame
        } else {
            invalidateIntrinsicContentSize()
        }
    }

    func swizzleIntrinsicContentSize() {
        if automaticallyResizesToFit || preferredMinLayoutWidth != 0.0 {
            guard !isMethodReplaced(#selector(getter: NSTextField.intrinsicContentSize)) else { return }
            textFieldObserver = nil
            do {
                try replaceMethod(
                    #selector(getter: NSTextField.intrinsicContentSize),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> (CGSize)).self,
                    hookSignature: (@convention(block)  (AnyObject) -> (CGSize)).self) { store in {
                        object in
                        if let textField = object as? NSTextField, (textField.automaticallyResizesToFit || textField.preferredMinLayoutWidth != 0.0) {
                            let size = textField.frame.size
                            let newSize = textField.calculatedFittingSize
                            if textField.preferredResizingDirection == .bottom {
                                let diff = newSize.height - size.height
                                Swift.print(textField.frame.origin.y)
                                textField.frame.origin.y -= diff
                            }
                            return newSize
                        }
                        return store.original(object, #selector(getter: NSTextField.intrinsicContentSize))
                    }
                    }
                setupTextFieldObserver()
            } catch {
                Swift.debugPrint(error)
            }
        } else if isMethodReplaced(#selector(getter: NSTextField.intrinsicContentSize)) {
            textFieldObserver = nil
            resetMethod(#selector(getter: NSTextField.intrinsicContentSize))
            setupTextFieldObserver()
        }
    }

    var calculatedFittingSize: CGSize {
        guard cell != nil else { return frame.size }
        var cellSize = sizeThatFits(width: maxLayoutWidth)
        cellSize.height.round(toNearest: 0.5, .awayFromZero)
        if preferredMinLayoutWidth == Self.placeholderWidth {
            let placeholderSize = placeholderStringSize
            cellSize.width = max(placeholderSize.width, cellSize.width)
            cellSize.width.round(toNearest: 0.5, .awayFromZero)
        } else {
            cellSize.width.round(toNearest: 0.5, .awayFromZero)
            cellSize.width = max(cellSize.width, maxLayoutWidth)
        }
        return cellSize
    }
        
    var placeholderStringSize: CGSize {
        guard cell != nil else { return .zero }
        if let placeholder = placeholderAttributedString {
            return fittingSize(for: placeholder, maxWidth: maxLayoutWidth)
        } else if let placeholder = placeholderString {
            return fittingSize(for: placeholder, maxWidth: maxLayoutWidth)
        }
        return .zero
    }
    
    var maxLayoutWidth: CGFloat {
        if preferredMaxLayoutWidth == NSTextField.superviewWidth, let superview = superview {
            return superview.frame.width - (frame.origin.x * 2)
        }
        return preferredMaxLayoutWidth
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
}

#endif
