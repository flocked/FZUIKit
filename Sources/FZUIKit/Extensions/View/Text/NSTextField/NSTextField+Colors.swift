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
    /// The color for selected text.
    public var selectionColor: NSColor? {
        get { _selectionColor }
        set {
            NSView.swizzleAnimationForKey()
            _selectionColor = newValue
        }
    }
    
    @objc var _selectionColor: NSColor? {
        get { getAssociatedValue("selectionColor") }
        set {
            guard newValue != selectionColor else { return }
            setAssociatedValue(newValue, key: "selectionColor")
            updateSelectionObservation()
        }
    }
    
    /// Sets the color for selected text.
    @discardableResult
    public func selectionColor(_ color: NSColor?) -> Self {
        selectionColor = color
        return self
    }
    
    /// The text color for selected text.
    public var selectionTextColor: NSColor? {
        get { _selectionTextColor }
        set {
            NSView.swizzleAnimationForKey()
            _selectionTextColor = newValue
        }
    }
    
    @objc var _selectionTextColor: NSColor? {
        get { getAssociatedValue("selectionTextColor") }
        set {
            guard newValue != selectionTextColor else { return }
            setAssociatedValue(newValue, key: "selectionTextColor")
            updateSelectionObservation()
        }
    }
    
    /// Sets the text color for selected text.
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
    
    @objc var _placeholderTextColor: NSColor? {
        get { getAssociatedValue("placeholderTextColor") }
        set {
            guard newValue != placeholderTextColor else { return }
            setAssociatedValue(newValue, key: "placeholderTextColor")
            if let color = newValue {
                var aaaa: PartialKeyPath<NSTextField> = \.stringValue
                aaaa.getterName()
                setPlaceholderColor(color)
                if placeholderObservations.isEmpty {
                    _placeholderString = placeholderString
                    /*
                    placeholderHook = try? hook(#selector(getter: NSTextField.placeholderString), closure: {
                        original, textField, selector in
                        return textField._placeholderString ?? original(textField, selector)
                     } as @convention(block) (
                         (NSTextField, Selector) -> String?,
                         NSTextField, Selector) -> String?)
                    */
                    placeholderHook = try? hook(\.placeholderString) { textField, value in
                        Swift.print("SWWWWW", value)
                        Swift.print("_----")
                       return textField._placeholderString ?? value
                    }
                    placeholderObservations += observeChanges(for: \.placeholderString) { [weak self] _,new in
                        self?._placeholderString = new
                        self?.setPlaceholderColor(color)
                    }
                    placeholderObservations += observeChanges(for: \.placeholderAttributedString) { [weak self] _,_ in
                        self?._placeholderString = nil
                    //    self?.setPlaceholderColor(color)
                    }
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
    
    func setPlaceholderColor(_ color: NSColor) {
        guard let cell = cell as? NSTextFieldCell else { return }
        if let placeholder = placeholderString {
            cell.placeholderAttributedString = .init(string: placeholder, attributes: [.foregroundColor: color])
        } else if let placeholder = placeholderAttributedString {
            cell.placeholderAttributedString = placeholder.color(color)
        }
    }
    
    func updateSelectionObservation() {
        if selectionColor == nil && selectionTextColor == nil {
            selectionObservation = nil
        } else if selectionObservation == nil {
            selectionIsFirstResponder = window?.firstResponder == currentEditor()
            updateSelectionColors()
            selectionObservation = observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                guard let self = self else { return }
                if !self.selectionIsFirstResponder, new == self.currentEditor() {
                    self.selectionIsFirstResponder = true
                    self.updateSelectionColors()
                } else {
                    self.selectionIsFirstResponder = false
                }
            }
        }
    }
    
    func updateSelectionColors() {
        guard isFirstResponder, let editor = currentEditor() as? NSTextView else { return }
        editor.selectedTextAttributes[.backgroundColor] = selectionColor
        editor.selectedTextAttributes[.foregroundColor] = selectionTextColor
    }
    
    var selectionObservation: KeyValueObservation? {
        get { getAssociatedValue("selectionColorObservation") }
        set { setAssociatedValue(newValue, key: "selectionColorObservation") }
    }
    
    var _placeholderString: String? {
        get { getAssociatedValue("_placeholderString") }
        set { setAssociatedValue(newValue, key: "_placeholderString") }
    }
    
    var placeholderHook: Hook? {
        get { getAssociatedValue("placeholderHook") }
        set { setAssociatedValue(newValue, key: "placeholderHook") }
    }
    
    var selectionIsFirstResponder: Bool {
        get { getAssociatedValue("selectionColorIsFirstResponder") ?? false }
        set { setAssociatedValue(newValue, key: "selectionColorIsFirstResponder") }
    }
    
    var placeholderObservations: [KeyValueObservation] {
        get { getAssociatedValue("placeholderObservations") ?? [] }
        set { setAssociatedValue(newValue, key: "placeholderObservations") }
    }
}
#endif
