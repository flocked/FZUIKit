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
        get { getAssociatedValue("placeholderTextColor") }
        set {
            guard newValue != placeholderTextColor else { return }
            setAssociatedValue(newValue, key: "placeholderTextColor")
            if let color = newValue {
                placeholderObservation = observeChanges(for: \.placeholderString) { [weak self] old, new in
                    guard let self = self, let placeholder = new, let color = self.placeholderTextColor else { return }
                    self.placeholderAttributedString = .init(string: placeholder, attributes: [.foregroundColor: color])
                }
                if let placeholder = placeholderString {
                    placeholderAttributedString = .init(string: placeholder, attributes: [.foregroundColor: color])
                }
            } else {
                placeholderObservation = nil
            }
        }
    }
    
    /// Sets the text color of the placeholder text.
    @discardableResult
    public func placeholderTextColor(_ color: NSColor?) -> Self {
        placeholderTextColor = color
        return self
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
    
    var selectionIsFirstResponder: Bool {
        get { getAssociatedValue("selectionColorIsFirstResponder") ?? false }
        set { setAssociatedValue(newValue, key: "selectionColorIsFirstResponder") }
    }
    
    var placeholderObservation: KeyValueObservation? {
        get { getAssociatedValue("placeholderObservation") }
        set { setAssociatedValue(newValue, key: "placeholderObservation") }
    }
}
#endif
