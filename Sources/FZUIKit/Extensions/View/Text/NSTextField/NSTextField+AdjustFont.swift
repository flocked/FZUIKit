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

     Normally, the text field draws the text with the font you specify in the `font` property. If this property is `true`, and the text in the `stringValue` property exceeds the text field’s bounding rectangle, the text field reduces the font size until the text fits or it has scaled the font down to the minimum font size.
     
     The default value for this property is `false`. If you change it to `true`, be sure that you also set an appropriate minimum font scale by modifying the ``AppKit/NSTextField/minimumScaleFactor`` property. This autoshrinking behavior is only intended for use with a single-line text field.

     - Note: If you have ``AppKit/NSTextField/automaticallyResizesToFit`` set to `true`, this property is ignored.
     */
    public var adjustsFontSizeToFitWidth: Bool {
        get { getAssociatedValue("adjustsFontSizeToFitWidth") ?? false }
        set {
            guard newValue != adjustsFontSizeToFitWidth else { return }
            setAssociatedValue(newValue, key: "adjustsFontSizeToFitWidth")
            setupFontAdjustment()
            adjustFontSize()
        }
    }

    /**
     The minimum scale factor for the text field’s text.

     If the ``adjustsFontSizeToFitWidth`` is `true`, use this property to specify the smallest multiplier for the current font size that yields an acceptable font size for the text field’s text. If you specify a value of `0` for this property, the text field doesn’t scale the text down. The default value of this property is `0`.
     */
    public var minimumScaleFactor: CGFloat {
        get { getAssociatedValue("minimumScaleFactor") ?? 0.0 }
        set {
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
        fittingFontSize(min: 0.1)
    }

    func adjustFontSize() {
        guard !automaticallyResizesToFit, let font = _font else { return }
        cell?.font = font.withSize(fittingFontSize(min: font.pointSize * minimumScaleFactor, max: font.pointSize))
    }
    
    func fittingFontSize(min: CGFloat, max: CGFloat? = nil, epsilon: CGFloat = 0.001) -> CGFloat {
        guard let baseFont = _font ?? font, let cell = cell else { return 0.0 }
        let currentFont = cell.font
        defer { cell.font = currentFont }
        var low = min
        var high = max ?? 0.0
        var best = min
        if high == 0 {
            high = 200
            cell.font = baseFont.withSize(high)
            while !isFittingCurrentText {
                high += 1.2
                cell.font = baseFont.withSize(high)
                if high > 2000 { break }
            }
        }
        while high - low > epsilon {
            let mid = (low + high) * 0.5
            let testFont = baseFont.withSize(mid)
            cell.font = testFont
            if isFittingCurrentText {
                best = mid
                low = mid
            } else {
                high = mid
            }
        }
        return best
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
            guard fontHooks.isEmpty else { return }
            textFieldObserver = nil
            _font = font
            do {
                fontHooks += try hookAfter(set: \.font) { textField, font in
                    guard textField._font != font else { return }
                    textField._font = font
                    textField.adjustFontSize()
                }
                fontHooks += try hook(\.font) { return $0._font ?? $1 }
            } catch {
                Swift.debugPrint(error)
            }
            setupTextFieldObserver()
            observeEditing()
        } else if !fontHooks.isEmpty {
            textFieldObserver = nil
            fontHooks.forEach({ try? $0.revert() })
            fontHooks = []
            setupTextFieldObserver()
            observeEditing()
            font = _font ?? font
        }
    }
    
    var fontHooks: [Hook] {
        get { getAssociatedValue("fontHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "fontHooks") }
    }

    var _font: NSFont? {
        get { getAssociatedValue("_font") }
        set { 
            setAssociatedValue(newValue, key: "_font")
        }
    }
}
#endif

/*
 
 /// Returns the font size that fits the current string value in the text field's bounds, or `0` if no font size fits.
 public var fittingFontSize: CGFloat {
     guard let baseFont = _font ?? font, let cell = cell else { return 0.0 }
     let currentFont = cell.font
     defer { cell.font = currentFont }
     cell.font = baseFont
     stringValue = stringValue
     let initialSize = baseFont.pointSize
     guard isFittingCurrentText else { return 0.1 }
     var low: CGFloat = 0.1
     var high: CGFloat = initialSize
     while true {
         let test = high * 2.0
         cell.font = baseFont.withSize(test)
         if isFittingCurrentText {
             high = test
         } else {
             break
         }
     }
     cell.font = baseFont
     var best = low
     while high - low > 0.1 {
         let mid = (low + high) * 0.5
         cell.font = baseFont.withSize(mid)
         if isFittingCurrentText {
             best = mid
             low = mid
         } else {
             high = mid
         }
     }
     return best.rounded(toPlaces: 1, rule: .towardZero)
 }

 func adjustFontSize() {
     guard let baseFont = _font else { return }

     let maxPoint = baseFont.pointSize
     let minPoint = maxPoint * minimumScaleFactor

     // Reset to full size before measuring
     cell?.font = baseFont

     // Quick exit if the text already fits at full size
     if isFittingCurrentText { return }

     // Binary search bounds
     var low = minPoint
     var high = maxPoint
     var best = minPoint

     while high - low > 0.001 {
         let mid = (low + high) * 0.5
         let testFont = baseFont.withSize(mid)
         cell?.font = testFont

         if isFittingCurrentText {
             // Text fits → try larger
             best = mid
             low = mid
         } else {
             // Text doesn't fit → try smaller
             high = mid
         }
     }

     // Apply the largest fitting font size
     cell?.font = baseFont.withSize(best)
 }
 */
