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
    
    /// A Boolean value that indicates whether text field should automatically adjust it's size to fit it's string value.
    @objc open var automaticallyResizesToFit: Bool {
        get { getAssociatedValue(key: "automaticallyResizesToFit", object: self, initialValue: false) }
        set {
            guard newValue != automaticallyResizesToFit else { return }
            set(associatedValue: newValue, key: "automaticallyResizesToFit", object: self)
            swizzleIntrinsicContentSize()
            observeEditing()
            if newValue {
                resizeToFit()
            }
        }
    }
    
    /**
     The preferred minimum width of the text field.
     
     Apply ``AppKit/NSTextField/placeholderWidth`` to this property, to use the placeholder width as minimum value
     */
    public var preferredMinLayoutWidth: CGFloat {
        get { getAssociatedValue(key: "preferredMinLayoutWidth", object: self, initialValue: 0) }
        set {
            set(associatedValue: newValue, key: "preferredMinLayoutWidth", object: self)
            swizzleIntrinsicContentSize()
            resizeToFit()
        }
    }
    
    /// A value that tells the layout system to use the placeholder width as preferred minimum width (see ``preferredMinLayoutWidth``).
    public static let placeholderWidth: CGFloat = -1
    
    func resizeToFit() {
        guard automaticallyResizesToFit else { return }
        if translatesAutoresizingMaskIntoConstraints {
            frame.size = calculatedFittingSize
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
                            return textField.calculatedFittingSize
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
        guard let cell = cell else { return frame.size }
        let maxWidth: CGFloat = preferredMaxLayoutWidth == 0 ? 40000 : preferredMaxLayoutWidth
        var cellSize = cell.cellSize(forBounds: CGRect(0, 0, maxWidth, 40000))
        cellSize.width.round(toNearest: 0.5, .awayFromZero)
        cellSize.height.round(toNearest: 0.5, .awayFromZero)
        if preferredMinLayoutWidth == Self.placeholderWidth {
            let placeholderSize = calculatedPlaceholderSize
            cellSize.width = max(placeholderSize.width, cellSize.width)
        } else {
            cellSize.width = max(cellSize.width, preferredMinLayoutWidth)
        }
        return cellSize
    }
    
    var calculatedPlaceholderSize: CGSize {
        guard let cell = cell else { return .zero }
        var size = CGSize.zero
        if let placeholder = placeholderAttributedString {
            let attributedStringValue = attributedStringValue
            self.attributedStringValue = placeholder
            size = cell.cellSize(forBounds: CGRect(0, 0, (preferredMaxLayoutWidth == 0 ? 40000 : preferredMaxLayoutWidth), 40000))
            size.width.round(toNearest: 0.5, .awayFromZero)
            size.height.round(toNearest: 0.5, .awayFromZero)
            self.attributedStringValue = attributedStringValue
        } else if let placeholder = placeholderString {
            let stringValue = self.stringValue
            self.stringValue = placeholder
            size = cell.cellSize(forBounds: CGRect(0, 0, (preferredMaxLayoutWidth == 0 ? 40000 : preferredMaxLayoutWidth), 40000))
            size.width.round(toNearest: 0.5, .awayFromZero)
            size.height.round(toNearest: 0.5, .awayFromZero)
            self.stringValue = stringValue
        }
        return size
    }
}

#endif
