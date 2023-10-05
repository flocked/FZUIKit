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
    /// Handlers for editing the text of a text field.
    struct TextEditingHandler {
        /// Handler that gets called whenever editing the text did begin.
        public var didBegin: (()->())? = nil
        /// Handler that determines whether the text should change. If provided ``AppKit/NSTextField/minimumNumberOfCharacters``, ``AppKit/NSTextField/maximumNumberOfCharacters`` and ``AppKit/NSTextField/allowedCharacters-swift.property`` will be ignored.
        public var shouldEdit: ((String)->(Bool))? = nil
        /// Handler that gets called whenever the text did change.
        public var didEdit: (()->())? = nil
        /// Handler that gets called whenever editing the text did end.
        public var didEnd: (()->())? = nil
        /// Handler that determines whether a command should be performed (e.g. cancel, enter).
        public var doCommand: ((Selector)->(Bool))? = nil
        internal var needsSwizzle: Bool {
            didBegin != nil || shouldEdit != nil || didEdit != nil || didEnd != nil || doCommand != nil
        }
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
    
    /// The allowed characters the user can enter when editing.
    struct AllowedCharacters: OptionSet {
        public let rawValue: UInt
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = AllowedCharacters(rawValue: 1 << 0)
        /// Allows all letter characters.
        public static let letters: AllowedCharacters = [.lowercaseLetters, .uppercaseLetters]
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = AllowedCharacters(rawValue: 1 << 1)
        /// Allows alphabetic uppercase characters (like A, B, C, etc.)
        public static let uppercaseLetters = AllowedCharacters(rawValue: 1 << 2)
        /// Allows all alphanumerics characters.
        public static let alphanumerics: AllowedCharacters = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = AllowedCharacters(rawValue: 1 << 3)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = AllowedCharacters(rawValue: 1 << 4)
        /// Allows whitespace characters.
        public static let whitespaces = AllowedCharacters(rawValue: 1 << 5)
        /// Allows new line characters.
        public static let newLines = AllowedCharacters(rawValue: 1 << 6)
        /// Allows all characters.
        public static let all: AllowedCharacters = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines]
        
        internal func trimString<S: StringProtocol>(_ string: S) -> String {
            var string = String(string)
            if self.contains(.lowercaseLetters) == false { string = string.trimmingCharacters(in: .lowercaseLetters) }
            if self.contains(.uppercaseLetters) == false { string = string.trimmingCharacters(in: .uppercaseLetters) }
            if self.contains(.digits) == false { string = string.trimmingCharacters(in: .decimalDigits) }
            if self.contains(.symbols) == false { string = string.trimmingCharacters(in: .symbols) }
            if self.contains(.newLines) == false { string = string.trimmingCharacters(in: .newlines) }
            if self.contains(.emojis) == false { string = string.trimmingEmojis() }
            return string
        }

        /// Creates a swipe direction structure with the specified raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    /// The allowed characters the user can enter when editing.
    var allowedCharacters: AllowedCharacters {
        get { getAssociatedValue(key: "allowedCharacters", object: self, initialValue: .all) }
        set { set(associatedValue: newValue, key: "allowedCharacters", object: self)
            if newValue != .all {
                swizzleTextField()
            }
        }
    }
    
    /// The handlers for editing the text.
    var editingHandlers: TextEditingHandler {
        get { getAssociatedValue(key: "editingHandlers", object: self, initialValue: TextEditingHandler()) }
        set { set(associatedValue: newValue, key: "editingHandlers", object: self)
            if newValue.needsSwizzle {
                swizzleTextField()
            }
        }
    }

    /// The action to perform when the user pressed the enter key.
    var actionOnEnterKeyDown: EnterKeyAction {
        get { getAssociatedValue(key: "NSTextField_actionOnEnterKeyDown", object: self, initialValue: .none) }
        set {
            
            set(associatedValue: newValue, key: "NSTextField_actionOnEnterKeyDown", object: self)
            if newValue != .none {
                swizzleTextField()
            }
        }
    }

    /// The action to perform when the user pressed the escpae key.
    var actionOnEscapeKeyDown: EscapeKeyAction {
        get { getAssociatedValue(key: "NSTextFIeld_actionOnEscapeKeyDown", object: self, initialValue: .none) }
        set {
            set(associatedValue: newValue, key: "NSTextFIeld_actionOnEscapeKeyDown", object: self)
            if newValue != .none {
                swizzleTextField()
            }
        }
    }
    
    /// The minimum numbers of characters needed when the user edits the string value.
    var minimumNumberOfCharacters: Int? {
        get { getAssociatedValue(key: "minimumNumberOfCharacters", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "minimumNumberOfCharacters", object: self)
            if let newValue = newValue {
                if let maximumNumberOfCharacters = maximumNumberOfCharacters, newValue > maximumNumberOfCharacters {
                    self.maximumNumberOfCharacters = newValue
                }
            }
            if let maxCharCount = newValue, stringValue.count > maxCharCount {
                stringValue = String(stringValue.prefix(maxCharCount))
            }
            swizzleTextField()
        }
    }

    /// The maximum numbers of characters allowed when the user edits the string value.
    var maximumNumberOfCharacters: Int? {
        get { getAssociatedValue(key: "NSTextField_maximumNumberOfCharacters", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTextField_maximumNumberOfCharacters", object: self)
            if let newValue = newValue {
                if let minimumNumberOfCharacters = minimumNumberOfCharacters, newValue < minimumNumberOfCharacters {
                    self.minimumNumberOfCharacters = newValue
                }
            }
            if let maxCharCount = newValue, stringValue.count > maxCharCount {
                stringValue = String(stringValue.prefix(maxCharCount))
            }
            swizzleTextField()
        }
    }
}

/*
internal extension NSTextField {
    class DelegateProxy: NSObject, NSTextFieldDelegate {
        weak var textField: NSTextField!
        weak var delegate: NSTextFieldDelegate? = nil
        
        var editingString = ""
        var editStartString = ""

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
            textField.editingState = .isEditing
            if let maxCharCount = textField.maximumNumberOfCharacters, textField.stringValue.count > maxCharCount {
                if textField.editingString.count == textField.maximumNumberOfCharacters {
                    textField.stringValue = textField.editingString
                    if let editor = textField.currentEditor(), editor.selectedRange.location > 0 {
                        editor.selectedRange.location -= 1
                    }
                } else {
                    textField.stringValue = String(textField.stringValue.prefix(maxCharCount))
                }
            }
            editingString = textField.stringValue
            delegate?.controlTextDidChange?(obj)
            textField.adjustFontSize()
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            editingString = textField.stringValue
            editStartString = textField.stringValue
            textField.editingState = .didBegin
            delegate?.controlTextDidBeginEditing?(obj)
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            textField.editingState = .didEnd
            delegate?.controlTextDidEndEditing?(obj)
            textField.adjustFontSize()
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if textField.editingState != .didEnd, textField.actionOnEnterKeyDown == .endEditing {
                    textField.window?.makeFirstResponder(nil)
                    return true
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                if textField.actionOnEscapeKeyDown == .endEditingAndReset {
                    textField.stringValue = editStartString
                    textField.adjustFontSize()
                }
                if textField.actionOnEscapeKeyDown != .none {
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
 */
#endif
