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
    
    /// Sets the Boolean value that determines whether the text field reduces the text’s font size to fit the title string into the text field’s bounding rectangle.
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjusts
        return self
    }

    /**
     The minimum scale factor for the text field’s text.

     If the ``adjustsFontSizeToFitWidth`` is `true`, use this property to specify the smallest multiplier for the current font size that yields an acceptable font size for the text field’s text. If you specify a value of `0` for this property, the text field doesn’t scale the text down. The default value of this property is `0`.
     
     - Note: If you have ``AppKit/NSTextField/automaticallyResizesToFit`` set to `true`, this property is ignored.
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
    
    /// Sets the minimum scale factor for the text field’s text.
    @discardableResult
    public func minimumScaleFactor(_ minimumFactor: CGFloat) -> Self {
        self.minimumScaleFactor = minimumFactor
        return self
    }
    
    /// A Boolean value indicating whether the text field is truncating the text.
    public var isTruncatingText: Bool {
        guard let cell = cell else { return false }
        let isTruncating = cell.expansionFrame(withFrame: frame, in: self) != .zero
        usesSingleLineMode
        guard !isTruncating, maximumNumberOfLines == 1 || usesSingleLineMode else { return isTruncating }
        let cellSize = cell.cellSize(forBounds: CGRect(0, 0, CGFloat.greatestFiniteMagnitude, frame.height-0.5))
        return cellSize.width > frame.width
    }

    /// A Boolean value indicating whether the text field is fitting the current text.
    public var isFittingText: Bool {
        let isFitting = !isTruncatingText
        if isFitting, let cell = cell {
            let cellSize = cell.cellSize(forBounds: CGRect(.zero, CGSize(frame.width-0.5, .greatestFiniteMagnitude)))
            if cellSize.height > frame.height || cellSize.width > frame.width {
                return false
            }
        }
        return isFitting
    }
    
    /// Returns the font size that fits the current string value in the text field's bounds, or `0` if no font size fits.
    public var fittingFontSize: CGFloat {
        fittingFontSize(min: 0.1)
    }

    func adjustFontSize() {
        guard !automaticallyResizesToFit, needsFontAdjustments, let font = _font else { return }
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
            while !isFittingText {
                high *= 1.2
                cell.font = baseFont.withSize(high)
                if high > 2000 { break }
            }
        }
        while high - low > epsilon {
            let mid = (low + high) * 0.5
            let testFont = baseFont.withSize(mid)
            cell.font = testFont
            if isFittingText {
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
        var needsUpdate = !isFittingText
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
            needsUpdate = !isFittingText
        }
    }

    var needsFontAdjustments: Bool {
        adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0
    }

    func setupFontAdjustment() {
        if adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0 {
            guard fontHooks.isEmpty else { return }
            textFieldObserver = nil
            _font = font
            do {
                fontHooks += try hook(\.font) { return $0._font ?? $1 }
                fontHooks += try hookAfter(set: \.font) { textField, font in
                    guard textField._font != font else { return }
                    textField._font = font
                    textField.adjustFontSize()
                }
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
    
    private var fontHooks: [Hook] {
        get { getAssociatedValue("fontHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "fontHooks") }
    }

    private var _font: NSFont? {
        get { getAssociatedValue("_font") }
        set { setAssociatedValue(newValue, key: "_font") }
    }
}
#endif
