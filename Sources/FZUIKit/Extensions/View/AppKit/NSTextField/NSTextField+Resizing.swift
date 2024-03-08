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
     */
    @objc open var automaticallyResizesToFit: Bool {
        get { getAssociatedValue(key: "automaticallyResizesToFit", object: self, initialValue: false) }
        set {
            guard newValue != automaticallyResizesToFit else { return }
            set(associatedValue: newValue, key: "automaticallyResizesToFit", object: self)
            swizzleIntrinsicContentSize()
            observeEditing()
            if newValue {
                adjustsFontSizeToFitWidth = false
                resizeToFit()
                adjustFontSize()
            }
        }
    }
    
    /// The direction the textfield's height expands when automatic resizing is enabled.
    public enum ResizingDirection {
        /// The frameheight expands to the top.
        case top
        /// The height expands to the bottom.
        case bottom
    }
    
    /// The direction the textfield's height expands when automatic resizing is enabled.
    public var automaticResizingDirection: ResizingDirection {
        get { getAssociatedValue(key: "resizingDirection", object: self, initialValue: .top) }
        set { set(associatedValue: newValue, key: "resizingDirection", object: self) }
    }
    
    /**
     The preferred minimum width of the text field.
     
     Apply ``AppKit/NSTextField/placeholderWidth`` to this property, to use the placeholder width as minimum value
     */
    public var preferredMinLayoutWidth: CGFloat {
        get { getAssociatedValue(key: "preferredMinLayoutWidth", object: self, initialValue: 0) }
        set {
            set(associatedValue: newValue, key: "preferredMinLayoutWidth", object: self)
            resizeToFit()
        }
    }
    
    
    /// A value that tells the layout system to use the placeholder width as preferred minimum width (see ``preferredMinLayoutWidth``).
    public static let placeholderWidth: CGFloat = -1
    
    /// A value that tells the layout system to constraint the preferred maximum width to the superview width.
    public static let superviewWidth: CGFloat = -1
    
    func resizeToFit() {
        guard automaticallyResizesToFit else { return }
        if translatesAutoresizingMaskIntoConstraints {
            var newFrame = frame
            newFrame.size = calculatedFittingSize
            if automaticResizingDirection == .bottom {
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
                            if textField.automaticResizingDirection == .bottom {
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
    
    var _preferredMaxLayoutWidth: CGFloat {
        if preferredMaxLayoutWidth == NSTextField.superviewWidth, let superview = superview {
            return superview.frame.width - (frame.origin.x * 2)
        }
        return preferredMaxLayoutWidth
    }
    
    var calculatedFittingSize: CGSize {
        guard let cell = cell else { return frame.size }
        var cellSize = sizeThatFits(width: _preferredMaxLayoutWidth)
        cellSize.height.round(toNearest: 0.5, .awayFromZero)
        if preferredMinLayoutWidth == Self.placeholderWidth {
            let placeholderSize = placeholderStringSize
            cellSize.width = max(placeholderSize.width, cellSize.width)
            cellSize.width.round(toNearest: 0.5, .awayFromZero)
        } else {
            cellSize.width.round(toNearest: 0.5, .awayFromZero)
            cellSize.width = min(cellSize.width, _preferredMaxLayoutWidth)
        }
        return cellSize
    }
    
    var placeholderStringSize: CGSize {
        guard let cell = cell else { return .zero }
        var size = CGSize.zero
        if let placeholder = placeholderAttributedString {
            let attributedStringValue = attributedStringValue
            cell.attributedStringValue = placeholder
            size = sizeThatFits(width: _preferredMaxLayoutWidth)
            cell.attributedStringValue = attributedStringValue
        } else if let placeholder = placeholderString {
            let stringValue = stringValue
            cell.stringValue = placeholder
            size = sizeThatFits(width: _preferredMaxLayoutWidth)
            cell.stringValue = stringValue
        }
        return size
    }
}

#endif
