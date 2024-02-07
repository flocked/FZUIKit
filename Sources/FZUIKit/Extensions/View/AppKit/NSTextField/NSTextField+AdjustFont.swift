//
//  NSTextField+AdjustFont.swift
//
//
//  Created by Florian Zand on 05.10.23.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils

    extension NSTextField {
        /**
         A Boolean value that determines whether the text field reduces the text’s font size to fit the title string into the text field’s bounding rectangle.

         Normally, the text field draws the text with the font you specify in the `font` property. If this property is true, and the text in the `stringValue` property exceeds the text field’s bounding rectangle, the text field reduces the font size until the text fits or it has scaled the font down to the minimum font size. The default value for this property is `false`. If you change it to `true`, be sure that you also set an appropriate minimum font scale by modifying the ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` property. This autoshrinking behavior is only intended for use with a single-line text field.
         */
        public var adjustsFontSizeToFitWidth: Bool {
            get { getAssociatedValue(key: "adjustsFontSizeToFitWidth", object: self, initialValue: false) }
            set {
                guard newValue != adjustsFontSizeToFitWidth else { return }
                set(associatedValue: newValue, key: "adjustsFontSizeToFitWidth", object: self)
                setupTextFieldObserver()
            }
        }

        /**
         The minimum scale factor for the text field’s text.

         If the ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` is `true`, use this property to specify the smallest multiplier for the current font size that yields an acceptable font size for the text field’s text. If you specify a value of `0` for this property, the text field doesn’t scale the text down. The default value of this property is `0`.
         */
        public var minimumScaleFactor: CGFloat {
            get { getAssociatedValue(key: "minimumScaleFactor", object: self, initialValue: 0.0) }
            set {
                let newValue = newValue.clamped(max: 1.0)
                guard newValue != minimumScaleFactor else { return }
                set(associatedValue: newValue, key: "minimumScaleFactor", object: self)
                setupTextFieldObserver()
            }
        }

        var isFittingCurrentText: Bool {
            let isFitting = !isTruncatingText
            if isFitting == true {
                if let cell = cell, cell.cellSize(forBounds: CGRect(.zero, CGSize(bounds.width, CGFloat.greatestFiniteMagnitude))).height > bounds.height {
                    return false
                }
            }
            return isFitting
        }
        
        /// Returns the font size that fits the current string value in the text field's bounds, or `0` if no font size fits.
        public var fittingFontSize: CGFloat {
            guard let _font = _font ?? font else { return 0.0 }
            isAdjustingFontSize = true
            cell?.font = _font
            stringValue = stringValue
            var needsUpdate = !isFittingCurrentText
            var pointSize = _font.pointSize
            var minPointSize = 0.1
            var fittingPointSize: CGFloat? = nil
            while needsUpdate {
                let currentPointSize = minPointSize + ((pointSize - minPointSize) / 2.0)
                let adjustedFont = _font.withSize(currentPointSize)
                cell?.font = adjustedFont
                if isFittingCurrentText {
                    minPointSize = currentPointSize
                    fittingPointSize = currentPointSize.rounded(.toPlacesTowardZero(1))
                } else {
                    pointSize = currentPointSize
                }
                needsUpdate = !minPointSize.isApproximatelyEqual(to: pointSize, epsilon: 0.1)
            }
            cell?.font = _font
            isAdjustingFontSize = false
            return fittingPointSize ?? 0.0
        }

        func adjustFontSize(requiresSmallerScale: Bool = false) {
            guard let _font = _font else { return }
            isAdjustingFontSize = true
            cell?.font = _font
                        
            if adjustsFontSizeToFitWidth, minimumScaleFactor != 0.0 {
                var scaleFactor = requiresSmallerScale ? lastFontScaleFactor : 1.0
                var needsUpdate = !isFittingCurrentText
                var pointSize = _font.pointSize
                var minPointSize = pointSize * minimumScaleFactor
                while needsUpdate, scaleFactor >= minimumScaleFactor {
                    let currentPointSize = minPointSize + ((pointSize - minPointSize) / 2.0)
                    let adjustedFont = _font.withSize(currentPointSize)
                    scaleFactor = currentPointSize / _font.pointSize
                    cell?.font = adjustedFont
                    if isFittingCurrentText {
                        minPointSize = currentPointSize
                    } else {
                        pointSize = currentPointSize
                    }
                    needsUpdate = !minPointSize.isApproximatelyEqual(to: pointSize, epsilon: 0.001)
                }
                
            } else if allowsDefaultTighteningForTruncation {
                adjustFontKerning()
            }
            isAdjustingFontSize = false
        }

        func adjustFontKerning() {
            guard let fontSize = _font?.pointSize else { return }
            var needsUpdate = !isFittingCurrentText
            var kerning: Float = 0.0
            let maxKerning: Float
            if fontSize < 8 {
                maxKerning = 0.6
            } else if fontSize < 16 {
                maxKerning = 0.8
            } else {
                maxKerning = 1.0
            }
            while needsUpdate, kerning <= maxKerning {
                attributedStringValue = attributedStringValue.applyingAttributes([.kern: -kerning])
                kerning += 0.005
                needsUpdate = !isFittingCurrentText
            }
        }
        
        var needsSwizzling: Bool {
            (adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0) || allowsDefaultTighteningForTruncation || editingHandlers.needsSwizzle || allowedCharacters.needsSwizzling || actionOnEnterKeyDown.needsSwizzling || actionOnEscapeKeyDown.needsSwizzling || minimumNumberOfCharacters != nil || maximumNumberOfCharacters != nil || isEditableByDoubleClick
        }

        func setupTextFieldObserver() {
            if (adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0) || allowsDefaultTighteningForTruncation {
                swizzleTextField(shouldSwizzle: true)
                if observer == nil {
                    observer = KeyValueObserver(self)
                    observer?.add(\.stringValue, handler: { [weak self] old, new in
                        guard let self = self, self.isAdjustingFontSize == false, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.isBezeled, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.isBordered, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.bezelStyle, handler: { [weak self] old, new in
                        guard let self = self, self.isBezeled, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.preferredMaxLayoutWidth, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.allowsDefaultTighteningForTruncation, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.adjustFontSize()
                    })
                    observer?.add(\.maximumNumberOfLines, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.adjustFontSize()
                    })
                }
            } else {
                observer = nil
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
            adjustFontSize()
        }

        func updateString() {
            let newString = allowedCharacters.trimString(stringValue)

            if let maxCharCount = maximumNumberOfCharacters, newString.count > maxCharCount {
                if previousString.count <= maxCharCount {
                    stringValue = previousString
                    currentEditor()?.selectedRange = editingRange
                } else {
                    stringValue = String(newString.prefix(maxCharCount))
                }
                editingHandlers.didEdit?()
            } else if let minCharCount = minimumNumberOfCharacters, newString.count < minCharCount {
                if previousString.count >= minCharCount {
                    stringValue = previousString
                    currentEditor()?.selectedRange = editingRange
                }
                
            } else if editingHandlers.shouldEdit?(stringValue) == false {
                stringValue = previousString
                currentEditor()?.selectedRange = editingRange
            } else {
                stringValue = newString
                if previousString == newString {
                    currentEditor()?.selectedRange = editingRange
                }
                editingHandlers.didEdit?()
            }
            previousString = stringValue
            if let editingRange = currentEditor()?.selectedRange {
                self.editingRange = editingRange
            }
            adjustFontSize()
        }

        func swizzleTextField(shouldSwizzle: Bool) {
            if shouldSwizzle {
                guard didSwizzleTextField == false else { return }
                didSwizzleTextField = true
                _font = font
                
                do {
                    try replaceMethod(
                        #selector(setter: font),
                        methodSignature: (@convention(c) (AnyObject, Selector, NSFont?) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, NSFont?) -> Void).self
                    ) { _ in { object, font in
                        guard let textField = (object as? NSTextField), textField._font != font else { return }
                        textField._font = font
                        textField.adjustFontSize()
                    }
                    }
                    
                    try replaceMethod(
                        #selector(getter: font),
                        methodSignature: (@convention(c) (AnyObject, Selector) -> NSFont?).self,
                        hookSignature: (@convention(block) (AnyObject) -> NSFont?).self
                    ) { _ in { object in
                        return (object as? NSTextField)?._font ?? nil
                    }
                    }
                    
                    try replaceMethod(
                        #selector(layout),
                        methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject) -> Void).self
                    ) { store in { object in
                        store.original(object, #selector(NSView.layout))
                        guard let textField = (object as? NSTextField), textField.bounds.size != textField._bounds.size else { return }
                        textField.adjustFontSize()
                        textField._bounds = textField.bounds
                    }
                    }
                    
                    try replaceMethod(
                        #selector(NSTextViewDelegate.textView(_:doCommandBy:)),
                        methodSignature: (@convention(c) (AnyObject, Selector, NSTextView, Selector) -> (Bool)).self,
                        hookSignature: (@convention(block) (AnyObject, NSTextView, Selector) -> (Bool)).self
                    ) { store in { object, textView, selector in
                        if let doCommand = (object as? NSTextField)?.editingHandlers.doCommand {
                            return doCommand(selector)
                        }
                        if let textField = object as? NSTextField {
                            switch selector {
                            case #selector(NSControl.cancelOperation(_:)):
                                switch textField.actionOnEscapeKeyDown {
                                case .endEditingAndReset:
                                    textField.stringValue = textField.editStartString
                                    textField.adjustFontSize()
                                    textField.window?.makeFirstResponder(nil)
                                    return true
                                case .endEditing:
                                    if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                        return false
                                    } else {
                                        textField.window?.makeFirstResponder(nil)
                                        return true
                                    }
                                case .none:
                                    break
                                }
                            case #selector(NSControl.insertNewline(_:)):
                                switch textField.actionOnEnterKeyDown {
                                case .endEditing:
                                    if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                        return false
                                    } else {
                                        textField.window?.makeFirstResponder(nil)
                                        return true
                                    }
                                case .none: break
                                }
                            default: break
                            }
                        }
                        return store.original(object, #selector(NSTextViewDelegate.textView(_:doCommandBy:)), textView, selector)
                    }
                    }
                    
                    try replaceMethod(
                        #selector(textDidEndEditing),
                        methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
                    ) { store in { object, notification in
                        if let textField = (object as? NSTextField) {
                            //  textField.editingState = .didEnd
                            textField.adjustFontSize()
                            textField.editingHandlers.didEnd?()
                            if textField.isEditableByDoubleClick {
                                textField.isSelectable = textField._isSelectable
                                textField.isEditable = textField._isEditable
                            }
                        }
                        store.original(object, #selector(NSTextField.textDidEndEditing), notification)
                    }
                    }
                    
                    try replaceMethod(
                        #selector(textDidBeginEditing),
                        methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
                    ) { store in { object, notification in
                        store.original(object, #selector(NSTextField.textDidBeginEditing), notification)
                        if let textField = (object as? NSTextField) {
                            textField.editStartString = textField.stringValue
                            textField.previousString = textField.stringValue
                            textField.editingHandlers.didBegin?()
                            if let editingRange = textField.currentEditor()?.selectedRange {
                                textField.editingRange = editingRange
                            }
                        }
                    }
                    }
                    
                    try replaceMethod(
                        #selector(textDidChange),
                        methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
                    ) { store in { object, notification in
                        if let textField = (object as? NSTextField) {
                            textField.updateString()
                        }
                        store.original(object, #selector(NSTextField.textDidChange), notification)
                    }
                    }
                    
                    try replaceMethod(
                        #selector(NSResponder.mouseDown(with:)),
                        methodSignature: (@convention(c) (AnyObject, Selector, NSEvent) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, NSEvent) -> Void).self
                    ) { store in { object, event in
                        if let textField = (object as? NSTextField), textField.isEditableByDoubleClick, event.clickCount > 2, !textField.isFirstResponder {
                            textField._isEditable = textField.isEditable
                            textField._isSelectable = textField.isSelectable
                            textField.isSelectable = true
                            textField.isEditable = true
                            textField.becomeFirstResponder()
                        }
                        store.original(object, #selector(NSResponder.mouseDown(with:)), event)
                    }
                    }
                } catch {
                    Swift.debugPrint(error)
                }
            } else if didSwizzleTextField {
                didSwizzleTextField = false
                resetMethod(#selector(setter: font))
                resetMethod(#selector(getter: font))
                resetMethod(#selector(layout))
                resetMethod(#selector(NSTextViewDelegate.textView(_:doCommandBy:)))
                resetMethod(#selector(textDidEndEditing))
                resetMethod(#selector(textDidBeginEditing))
                resetMethod(#selector(textDidChange))
                resetMethod(#selector(NSResponder.mouseDown(with:)))
            }
        }

        var isAdjustingFontSize: Bool {
            get { getAssociatedValue(key: "isAdjustingFontSize", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "isAdjustingFontSize", object: self)
            }
        }

        var didSwizzleTextField: Bool {
            get { getAssociatedValue(key: "didSwizzleTextField", object: self, initialValue: false) }
            set {
                set(associatedValue: newValue, key: "didSwizzleTextField", object: self)
            }
        }

        var _bounds: CGRect {
            get { getAssociatedValue(key: "bounds", object: self, initialValue: .zero) }
            set { set(associatedValue: newValue, key: "bounds", object: self) }
        }

        var lastFontScaleFactor: CGFloat {
            get { getAssociatedValue(key: "lastFontScaleFactor", object: self, initialValue: 1.0) }
            set { set(associatedValue: newValue, key: "lastFontScaleFactor", object: self) }
        }

        var _font: NSFont? {
            get { getAssociatedValue(key: "_font", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "_font", object: self) }
        }

        var editStartString: String {
            get { getAssociatedValue(key: "editStartString", object: self, initialValue: stringValue) }
            set { set(associatedValue: newValue, key: "editStartString", object: self) }
        }

        var previousString: String {
            get { getAssociatedValue(key: "previousString", object: self, initialValue: stringValue) }
            set { set(associatedValue: newValue, key: "previousString", object: self) }
        }

        var editingRange: NSRange {
            get { getAssociatedValue(key: "editingRange", object: self, initialValue: currentEditor()?.selectedRange ?? NSRange(location: 0, length: 0)) }
            set { set(associatedValue: newValue, key: "editingRange", object: self) }
        }

        var observer: KeyValueObserver<NSTextField>? {
            get { getAssociatedValue(key: "observer", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "observer", object: self) }
        }
    }

#endif
