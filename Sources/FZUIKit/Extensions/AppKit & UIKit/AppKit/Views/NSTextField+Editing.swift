//
//  NSTextField+Editing.swift
//  Tester
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSTextField {
        typealias EditingHandler = (_ state: EditingState, _ stringValue: String) -> Void
        enum EditingState {
            case isStarted
            case didUpdate
            case isEnded
        }

        enum EscapeKeyAction {
            case none
            case endEditing
            case endEditingAndReset
        }

        enum EnterKeyAction {
            case none
            case endEditing
        }

        private(set) var editingState: EditingState {
            get { getAssociatedValue(key: "_textFieldEditingState", object: self, initialValue: .isEnded) }
            set {
                set(associatedValue: newValue, key: "_textFieldEditingState", object: self)
                editingHandler?(self.editingState, stringValue)
            }
        }

        var editingHandler: EditingHandler? {
            get { getAssociatedValue(key: "_textFieldEditingHandler", object: self, initialValue: nil) }
            set {
                set(associatedValue: newValue, key: "_textFieldEditingHandler", object: self)
                bridgeTextField()
            }
        }

        var actionAtEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue(key: "_textFieldEnterKeyAction", object: self, initialValue: .none) }
            set {
                set(associatedValue: newValue, key: "_textFieldEnterKeyAction", object: self)
                bridgeTextField()
            }
        }

        var actionAtEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue(key: "_textFieldEscapeKeyAction", object: self, initialValue: .none) }
            set {
                set(associatedValue: newValue, key: "_textFieldEscapeKeyAction", object: self)
                bridgeTextField()
                //  Self.swizzleTextField()
            }
        }

        var maximumNumberOfCharacters: Int? {
            get { getAssociatedValue(key: "_textFieldMaximumNumberOfCharacters", object: self, initialValue: nil) }
            set {
                set(associatedValue: newValue, key: "_textFieldMaximumNumberOfCharacters", object: self)
                if let maxCharCount = newValue, stringValue.count > maxCharCount {
                    stringValue = String(stringValue.prefix(maxCharCount))
                }
                bridgeTextField()
            }
        }

        internal var startStringValue: String {
            get { getAssociatedValue(key: "_textFieldStartStringValue", object: self, initialValue: stringValue) }
            set { set(associatedValue: newValue, key: "_textFieldStartStringValue", object: self)
            }
        }

        internal class var didSwizzleTextField: Bool {
            get { getAssociatedValue(key: "_didSwizzleTextField", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "_didSwizzleTextField", object: self)
            }
        }

        internal var delegateBridge: DelegateProxy? {
            get { getAssociatedValue(key: "_textFieldDelegateProxy", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "_textFieldDelegateProxy", object: self)
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
                _ = try? Swizzle(Self.self) {
                    #selector(getter: delegate) <-> #selector(getter: swizzled_delegate)
                    #selector(setter: delegate) <-> #selector(setter: swizzled_delegate)
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
