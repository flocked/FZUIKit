//
//  NSTextField+SelectionColor.swift
//
//
//  Created by Florian Zand on 18.11.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTextField {
    /// The background color of selected text.
    public var selectionColor: NSColor? {
        get { _selectionColor }
        set {
            NSView.swizzleAnimationForKey()
            _selectionColor = newValue
        }
    }
    
    @objc private var _selectionColor: NSColor? {
        get { getAssociatedValue("selectionColor") }
        set {
            guard newValue != selectionColor else { return }
            setAssociatedValue(newValue, key: "selectionColor")
            updateSelectionObservation()
        }
    }
    
    /// Sets the background color of selected text.
    @discardableResult
    public func selectionColor(_ color: NSColor?) -> Self {
        selectionColor = color
        return self
    }
    
    /// The text color of selected text.
    public var selectionTextColor: NSColor? {
        get { _selectionTextColor }
        set {
            NSView.swizzleAnimationForKey()
            _selectionTextColor = newValue
        }
    }
    
    @objc private var _selectionTextColor: NSColor? {
        get { getAssociatedValue("selectionTextColor") }
        set {
            isFirstResponder
            guard newValue != selectionTextColor else { return }
            setAssociatedValue(newValue, key: "selectionTextColor")
            updateSelectionObservation()
        }
    }
    
    /// Sets the text color of selected text.
    @discardableResult
    public func selectionTextColor(_ color: NSColor?) -> Self {
        selectionTextColor = color
        return self
    }
    
    /// The text color of the placeholder text.
    public var placeholderTextColor: NSColor? {
        get { _placeholderTextColor }
        set {
            NSView.swizzleAnimationForKey()
            _placeholderTextColor = newValue
        }
    }
    
    @objc private var _placeholderTextColor: NSColor? {
        get { getAssociatedValue("placeholderTextColor") }
        set {
            guard newValue != placeholderTextColor else { return }
            setAssociatedValue(newValue, key: "placeholderTextColor")
            if let color = newValue {
                setPlaceholderColor(color)
                guard placeholderObservations.isEmpty else { return }
                _placeholderString = placeholderString
                placeholderHook = try? hook(\.placeholderString) {
                    $0._placeholderString ?? $1
                }
                placeholderObservations += observeChanges(for: \.placeholderString) { [weak self] _,new in
                    self?._placeholderString = new
                    self?.setPlaceholderColor(color)
                }
                placeholderObservations += observeChanges(for: \.placeholderAttributedString) { [weak self] _,_ in
                    self?._placeholderString = nil
                    self?.setPlaceholderColor(color)
                }
            } else {
                placeholderHook = nil
                placeholderObservations = []
                placeholderString = _placeholderString
            }
        }
    }
    
    /// Sets the text color of the placeholder text.
    @discardableResult
    public func placeholderTextColor(_ color: NSColor?) -> Self {
        placeholderTextColor = color
        return self
    }
    
    private func setPlaceholderColor(_ color: NSColor) {
        guard let cell = textFieldCell else { return }
        if let placeholder = placeholderString {
            cell.placeholderAttributedString = .init(string: placeholder, attributes: [.foregroundColor: color])
        } else if let placeholder = placeholderAttributedString {
            cell.placeholderAttributedString = placeholder.color(color)
        }
    }
    
    private func updateSelectionObservation() {
        if selectionColor == nil && selectionTextColor == nil {
            try? selectionHook?.revert()
            selectionHook = nil
        } else if selectionHook == nil {
            do {
                selectionHook = try textFieldCell?.hook(#selector(NSTextFieldCell.setUpFieldEditorAttributes(_:)), closure: {
                    original, cell, selector, text in
                    if let textField = cell.textField, let textView = text as? NSTextView {
                        textView.selectedTextAttributes[.backgroundColor] = textField.selectionColor
                        textView.selectedTextAttributes[.foregroundColor] = textField.selectionTextColor
                    }
                    return original(cell, selector, text)
                } as @convention(block) (
                    (NSTextFieldCell, Selector, NSText) -> NSText,
                    NSTextFieldCell, Selector, NSText) -> NSText)
            } catch {
                Swift.print(error)
            }
        }
        guard let editor = currentEditor() as? NSTextView else { return }
        editor.selectedTextAttributes[.backgroundColor] = selectionColor
        editor.selectedTextAttributes[.foregroundColor] = selectionTextColor
    }

    private var selectionHook: Hook? {
        get { getAssociatedValue("selectionHook") }
        set { setAssociatedValue(newValue, key: "selectionHook") }
    }
    
    private var _placeholderString: String? {
        get { getAssociatedValue("_placeholderString") }
        set { setAssociatedValue(newValue, key: "_placeholderString") }
    }
    
    private var placeholderHook: Hook? {
        get { getAssociatedValue("placeholderHook") }
        set { setAssociatedValue(newValue, key: "placeholderHook") }
    }

    private var placeholderObservations: [KeyValueObservation] {
        get { getAssociatedValue("placeholderObservations") ?? [] }
        set { setAssociatedValue(newValue, key: "placeholderObservations") }
    }
}
#endif
