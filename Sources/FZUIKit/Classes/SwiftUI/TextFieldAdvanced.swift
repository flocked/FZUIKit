//
//  TextFieldAdvanced.swift
//
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A `SwiftUI` text field with additional properties.
public struct TextFieldAdvanced: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String?
    var textColor: NSColor = .labelColor
    var font: NSFont = .body
    var numberOfLines: Int = 0
    var alignment: NSTextAlignment = .left
    var isSelectable: Bool = false
    var isEditable: Bool = false
    var actionOnEnterKeyDown: NSTextField.EnterKeyAction = .none
    var actionOnEscapeKeyDown: NSTextField.EscapeKeyAction = .none
    var onEditEnd: (() -> ())? = nil
    var stringValidation: ((String) -> (Bool))? = nil
    var minimumScaleFactor: CGFloat = 0.0
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    var allowsDefaultTighteningForTruncation: Bool = false
    var style: TextStyle = .plain
    enum TextStyle {
        case plain
        case roundedBorder
        case squareBorder
    }
    
    /// Creates a text field with the specified text.
    public init(_ text: String, placeholder: String? = nil) {
        self._text = .constant(text)
        self.placeholder = placeholder
    }
    
    /// Creates a text field with the specified text.
    public init(_  text: Binding<String>, placeholder: String? = nil) {
        self._text = text
        isEditable = true
        self.placeholder = placeholder
    }
    
    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField.wrapping(text)
        textField.truncatesLastVisibleLine = true
        updateNSView(textField, context: context)
        return textField
    }

    public func updateNSView(_ textField: NSTextField, context: Context) {
        textField.delegate = context.coordinator
        textField.placeholderString = placeholder
        switch style {
            case .plain: textField.isBezeled(false).isBordered(false)
            case .roundedBorder: textField.isBezeled(true).isBordered(true).bezelStyle(.roundedBezel)
            case .squareBorder: textField.isBezeled(true).isBordered(true).bezelStyle(.squareBezel)
        }
        textField.textColor = textColor
        textField.font = font
        textField.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        textField.minimumScaleFactor = minimumScaleFactor
        textField.adjustsFontSizeToFitWidth = minimumScaleFactor != 0.0
        textField.maximumNumberOfLines = numberOfLines
        textField.lineBreakMode = lineBreakMode
        textField.alignment = alignment
        textField.isSelectable = isSelectable
        textField.isEditable = isEditable
        textField.editingActionOnEnterKeyDown = actionOnEnterKeyDown
        textField.editingActionOnEscapeKeyDown = actionOnEscapeKeyDown
        textField.isEnabled = context.environment.isEnabled
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// The coordinator of the text field.
    public class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: TextFieldAdvanced
        var previousString: String = ""
        init(_ parent: TextFieldAdvanced) {
            self.parent = parent
        }
        
        public func controlTextDidBeginEditing(_ obj: Notification) {
            guard let stringValue = (obj.userInfo?["NSFieldEditor"] as? NSTextField)?.stringValue else { return }
            previousString = stringValue
        }
        
        public func controlTextDidChange(_ obj: Notification) {
            guard let textField = (obj.userInfo?["NSFieldEditor"] as? NSTextField) else { return }
            if let stringValidation = parent.stringValidation, !stringValidation(textField.stringValue) {
                textField.stringValue = previousString
            }
            previousString = textField.stringValue
            parent.text = textField.stringValue
        }
        
        public func controlTextDidEndEditing(_ obj: Notification) {
            parent.onEditEnd?()
        }
    }
}



extension TextFieldAdvanced {
    public func textFieldStyle<S>(_ style: S) -> Self where S : TextFieldStyle {
        var view = self
        if style is RoundedBorderTextFieldStyle {
            view.style = .roundedBorder
        } else if style is SquareBorderTextFieldStyle {
            view.style = .squareBorder
        } else {
            view.style = .plain
        }
        return self
    }
    
    
    public func placeholder(_ placeholder: String?) -> Self {
        var view = self
        view.placeholder = placeholder
        return view
    }
    
    public func allowsDefaultTighteningForTruncation(_ allows: Bool) -> Self {
        var view = self
        view.allowsDefaultTighteningForTruncation = allows
        return view
    }
    
    public func minimumScaleFactor(_ factor: CGFloat) -> Self {
        var view = self
        view.minimumScaleFactor = factor
        return view
    }
    
    public func lineBreakMode(_ mpde: NSLineBreakMode) -> Self {
        var view = self
        view.lineBreakMode = mpde
        return view
    }

    public func foregroundColor(_ color: NSColor) -> Self {
        var view = self
        view.textColor = color
        return view
    }
    
    @available(macOS 11.0, *)
    public func foregroundStyle<S>(_ style: S) -> Self where S : ShapeStyle {
        var view = self
        view.textColor = (style as? Color)?.nsColor ?? view.textColor
        return view
    }
    
    public func font(_ font: NSFont?) -> Self {
        var view = self
        view.font = font ?? view.font
        return view
    }
    
    public func actionOnEnterKeyDown(_ action: NSTextField.EnterKeyAction) -> Self {
        var view = self
        view.actionOnEnterKeyDown = action
        return self
    }
        
    public func actionOnEscapeKeyDown(_ action: NSTextField.EscapeKeyAction) -> Self {
        var view = self
        view.actionOnEscapeKeyDown = action
        return view
    }
    
    public func onEditEnd(_ handler: (() -> ())?) -> Self {
        var view = self
        view.onEditEnd = handler
        return view
    }
    
    public func stringValidation(_ validation: ((String) -> (Bool))?) -> Self {
        var view = self
        view.stringValidation = validation
        return view
    }
    
    public func isEditable(_ isEditable: Bool) -> Self {
        var view = self
        view.isEditable = isEditable
        return view
    }
    
    public func isSelectable(_ isSelectable: Bool) -> Self {
        var view = self
        view.isSelectable = isSelectable
        return view
    }
    
    @available(macOS 12.0, *)
    public func textSelection<S>(_ selectability: S) -> Self where S : TextSelectability {
        var view = self
        if selectability is EnabledTextSelectability {
            view.isSelectable = true
        } else if selectability is DisabledTextSelectability {
            view.isSelectable = false
        }
        return view
    }
        
    public func lineLimit(_ number: Int?) -> Self {
        var view = self
        view.numberOfLines = number ?? 0
        return view
    }
    
    public func multilineTextAlignment(_ alignment: TextAlignment) -> Self {
        var view = self
        view.alignment = alignment.nsTextAlignment
        return view
    }
}

#endif
