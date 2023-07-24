//
//  NSTextField+Editing.swift
//  
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSTextField {
    /// The editing state of a text field.
    enum EditingState {
        /// Editing of the text started.
        case isStarted
        /// The text did update.
        case didUpdate
        /// Editing of the text did end.
        case isEnded
    }

    /// The action to perform when the user pressed the escape key.
    enum EscapeKeyAction {
        /// No action.
        case none
        /// Ends editing the text.
        case endEditing
        /// Ends editing the text and resets it to the the state before editing.
        case endEditingAndReset
    }

    /// The action to perform when the user pressed the enter key.
    enum EnterKeyAction {
        /// No action.
        case none
        /// Ends editing the text.
        case endEditing
    }

    private(set) var editingState: EditingState {
        get {
            bridgeTextField()
            return getAssociatedValue(key: "NSTextField_editingState", object: self, initialValue: .isEnded) }
        set {
            set(associatedValue: newValue, key: "NSTextField_editingState", object: self)
            editingHandler?(self.editingState, stringValue)
        }
    }

    /// The handler that gets called when the editing state updates.
    var editingHandler: ((_ state: EditingState, _ stringValue: String) -> ())? {
        get { getAssociatedValue(key: "NSTextField_editingHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTextField_editingHandler", object: self)
            if newValue != nil {
                bridgeTextField()
            }
        }
    }

    /// The action to perform when the user pressed the enter key.
    var actionAtEnterKeyDown: EnterKeyAction {
        get { getAssociatedValue(key: "NSTextField_actionAtEnterKeyDown", object: self, initialValue: .none) }
        set {
            set(associatedValue: newValue, key: "NSTextField_actionAtEnterKeyDown", object: self)
            if newValue == .endEditing {
                bridgeTextField()
            }
        }
    }

    /// The action to perform when the user pressed the escpae key.
    var actionAtEscapeKeyDown: EscapeKeyAction {
        get { getAssociatedValue(key: "NSTextFIeld_actionAtEscapeKeyDown", object: self, initialValue: .none) }
        set {
            set(associatedValue: newValue, key: "NSTextFIeld_actionAtEscapeKeyDown", object: self)
            if newValue != .none {
                bridgeTextField()
            }
        }
    }

    /// The maximum numbers of characters of the string value.
    var maximumNumberOfCharacters: Int? {
        get { getAssociatedValue(key: "NSTextField_maximumNumberOfCharacters", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTextField_maximumNumberOfCharacters", object: self)
            if let maxCharCount = newValue, stringValue.count > maxCharCount {
                stringValue = String(stringValue.prefix(maxCharCount))
            }
            bridgeTextField()
        }
    }

    internal var startStringValue: String {
        get { getAssociatedValue(key: "NSTextField_startStringValue", object: self, initialValue: stringValue) }
        set { set(associatedValue: newValue, key: "NSTextField_startStringValue", object: self)
        }
    }

    internal class var didSwizzleTextField: Bool {
        get { getAssociatedValue(key: "_didSwizzleTextField", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "_didSwizzleTextField", object: self)
        }
    }

    internal var delegateBridge: DelegateProxy? {
        get { getAssociatedValue(key: "NSTextField_delegateBridge", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTextField_delegateBridge", object: self)
        }
    }

    @objc internal func bridgeTextField() {
        if delegateBridge == nil {
            delegateBridge = DelegateProxy(self)
            Self.swizzleTextField()
        }
    }

    @objc internal var swizzled_delegate: NSTextFieldDelegate? {
        get {
            if let delegateBridge = delegateBridge {
                return delegateBridge.delegate
            } else {
                return self.swizzled_delegate
            }
        }
        set {
            if let delegateBridge = delegateBridge {
                return delegateBridge.delegate = newValue
            } else {
                self.swizzled_delegate = newValue
            }
        }
    }

    @objc internal class func swizzleTextField() {
        if didSwizzleTextField == false {
            didSwizzleTextField = true
            do {
                try Swizzle(Self.self) {
                    #selector(getter: delegate) <-> #selector(getter: swizzled_delegate)
                    #selector(setter: delegate) <-> #selector(setter: swizzled_delegate)
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}

internal extension NSTextField {
    class DelegateProxy: NSObject, NSTextFieldDelegate {
        weak var textField: NSTextField!
        weak var delegate: NSTextFieldDelegate? = nil

        func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
            return delegate?.control?(control, textShouldEndEditing: fieldEditor) ?? true
        }

        func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
            return delegate?.control?(control, textShouldBeginEditing: fieldEditor) ?? true
        }

        func control(_ control: NSControl, didFailToFormatString string: String, errorDescription error: String?) -> Bool {
            return delegate?.control?(control, didFailToFormatString: string, errorDescription: error) ?? true
        }

        func control(_ control: NSControl, didFailToValidatePartialString string: String, errorDescription error: String?) {
            delegate?.control?(control, didFailToValidatePartialString: string, errorDescription: error)
        }

        func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
            return delegate?.control?(control, textView: textView, completions: words, forPartialWordRange: charRange, indexOfSelectedItem: index) ?? []
        }

        func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
            return delegate?.control?(control, isValidObject: obj) ?? true
        }

        func controlTextDidChange(_ obj: Notification) {
            textField.editingState = .didUpdate
            if let maxCharCount = textField.maximumNumberOfCharacters, textField.stringValue.count > maxCharCount {
                textField.stringValue = String(textField.stringValue.prefix(maxCharCount))
            }
            delegate?.controlTextDidChange?(obj)
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            textField.startStringValue = textField.stringValue
            textField.editingState = .isStarted
            delegate?.controlTextDidBeginEditing?(obj)
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            textField.editingState = .isEnded
            delegate?.controlTextDidEndEditing?(obj)
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if textField.editingState != .isEnded, textField.actionAtEnterKeyDown == .endEditing {
                    textField.window?.makeFirstResponder(nil)
                    return true
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                if textField.actionAtEscapeKeyDown == .endEditingAndReset {
                    textField.stringValue = textField.startStringValue
                }
                if textField.actionAtEscapeKeyDown != .none {
                    textField.window?.makeFirstResponder(nil)
                    return true
                }
            }

            return delegate?.control?(control, textView: textView, doCommandBy: commandSelector) ?? false
        }

        init(_ textField: NSTextField) {
            self.textField = textField
            super.init()
            delegate = self.textField.delegate
            self.textField.delegate = self
        }
    }
}
#endif
