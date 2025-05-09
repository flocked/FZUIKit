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
         
         - Note: If you you set this property to `true`, ``automaticallyResizesToFit`` is set to `false`.
         - Note: This property isn't working with `NSSearchField`.
         */
        public var adjustsFontSizeToFitWidth: Bool {
            get { getAssociatedValue("adjustsFontSizeToFitWidth", initialValue: false) }
            set {
                guard !(self is NSSearchField) else { return }
                guard newValue != adjustsFontSizeToFitWidth else { return }
                setAssociatedValue(newValue, key: "adjustsFontSizeToFitWidth")
                setupFontAdjustment()
                if newValue {
                    automaticallyResizesToFit = false
                }
                adjustFontSize()
            }
        }

        /**
         The minimum scale factor for the text field’s text.

         If the ``adjustsFontSizeToFitWidth`` is `true`, use this property to specify the smallest multiplier for the current font size that yields an acceptable font size for the text field’s text. If you specify a value of `0` for this property, the text field doesn’t scale the text down. The default value of this property is `0`.
         
         - Note: This property isn't working with `NSSearchField`.
         */
        public var minimumScaleFactor: CGFloat {
            get { getAssociatedValue("minimumScaleFactor", initialValue: 0.0) }
            set {
                guard !(self is NSSearchField) else { return }
                let newValue = newValue.clamped(to: 0.0...1.0)
                guard newValue != minimumScaleFactor else { return }
                setAssociatedValue(newValue, key: "minimumScaleFactor")
                setupFontAdjustment()
                adjustFontSize()
            }
        }

        var isFittingCurrentText: Bool {
            let isFitting = !isTruncatingText
            if isFitting == true {
                if let cell = cell {
                    let cellSize = cell.cellSize(forBounds: CGRect(.zero, CGSize(frame.width-0.5, CGFloat.greatestFiniteMagnitude)))
                    if cellSize.height > frame.height || cellSize.width > frame.width {
                        return false
                    }
                }
            }
            return isFitting
        }
        
        /// Returns the font size that fits the current string value in the text field's bounds, or `0` if no font size fits.
        public var fittingFontSize: CGFloat {
            guard let _font = _font ?? font else { return 0.0 }
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
                    fittingPointSize = currentPointSize.rounded(toPlaces: 1, rule: .towardZero)
                } else {
                    pointSize = currentPointSize
                }
                needsUpdate = !minPointSize.isApproximatelyEqual(to: pointSize, epsilon: 0.1)
            }
            cell?.font = _font
            return fittingPointSize ?? 0.0
        }

        func adjustFontSize() {
            guard needsFontAdjustments else { return }
            guard let _font = _font else { return }
            cell?.font = _font
            var scaleFactor = 1.0
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
              //  adjustFontKerning()
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
        
        var needsFontAdjustments: Bool {
            adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0
        }

        func setupFontAdjustment() {
            if needsFontAdjustments {
                guard isMethodHooked(#selector(setter: font)) == false else { return }                
                textFieldObserver = nil
                _font = font
                do {
                    try hook(#selector(setter: font), closure: { original, object, sel, font in
                        guard let textField = (object as? NSTextField), textField._font != font else { return }
                        textField._font = font
                        original(object, sel, font)
                        textField.adjustFontSize()
                    } as @convention(block) (
                        (AnyObject, Selector, NSFont?) -> Void,
                        AnyObject, Selector, NSFont?) -> Void)
                    
                    try hook(#selector(getter: font), closure: { original, object, sel in
                        (object as? NSTextField)?._font ?? original(object, sel)
                    } as @convention(block) (
                        (AnyObject, Selector) -> NSFont?,
                        AnyObject, Selector) -> NSFont?)
                } catch {
                    Swift.debugPrint(error)
                }
                setupTextFieldObserver()
                observeEditing()
            } else if isMethodHooked(#selector(setter: font)) {
                textFieldObserver = nil
                revertHooks(for: #selector(setter: font))
                revertHooks(for: #selector(getter: font))
                setupTextFieldObserver()
                observeEditing()
                font = _font ?? font
            }
        }
        
        var _font: NSFont? {
            get { getAssociatedValue("_font") }
            set { 
                setAssociatedValue(newValue, key: "_font")
            }
        }
    }
#endif
