//
//  NSTextField+Editing.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    extension NSTextField {
        /// Handlers for editing the text of a text field.
        public struct EditingHandler {
            /// Handler that gets called whenever editing the text did begin.
            public var didBegin: (() -> Void)?
            /// Handler that determines whether the text should change. If you provide ``AppKit/NSTextField/minimumNumberOfCharacters``, ``AppKit/NSTextField/maximumNumberOfCharacters`` or ``AppKit/NSTextField/allowedCharacters-swift.property`` the handler is called after checking the string against the specified property conditions.
            public var shouldEdit: ((String) -> (Bool))?
            /// Handler that gets called whenever the text did change.
            public var didEdit: (() -> Void)?
            /*
            /// Handler that determines whether editing the text can end.
            public var shouldEnd: ((String) -> (Bool))?
             */
            /// Handler that gets called whenever editing the text did end.
            public var didEnd: (() -> Void)?
            /// Handler that determines whether a command should be performed (e.g. cancel, enter).
            public var doCommand: ((Selector) -> (Bool))?
            var needsSwizzle: Bool {
                didBegin != nil || shouldEdit != nil || didEdit != nil || didEnd != nil || doCommand != nil
            }
        }

        /// The action to perform when the user presses the escape key.
        public enum EscapeKeyAction {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            /// Ends editing the text and resets it to the the state before editing.
            case endEditingAndReset
            
            var needsSwizzling: Bool {
                switch self {
                case .none: return false
                default: return true
                }
            }
        }

        /// The action to perform when the user presses the enter key.
        public enum EnterKeyAction {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            
            var needsSwizzling: Bool {
                switch self {
                case .none: return false
                case .endEditing: return true
                }
            }
        }

        /// The allowed characters the user can enter when editing.
        public struct AllowedCharacters: OptionSet {
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
            
            var needsSwizzling: Bool {
                self != AllowedCharacters.all
            }

            func trimString<S: StringProtocol>(_ string: S) -> String {
                var string = String(string)
                if contains(.lowercaseLetters) == false { string = string.trimmingCharacters(in: .lowercaseLetters) }
                if contains(.uppercaseLetters) == false { string = string.trimmingCharacters(in: .uppercaseLetters) }
                if contains(.digits) == false { string = string.trimmingCharacters(in: .decimalDigits) }
                if contains(.symbols) == false { string = string.trimmingCharacters(in: .symbols) }
                if contains(.newLines) == false { string = string.trimmingCharacters(in: .newlines) }
                if contains(.emojis) == false { string = string.trimmingEmojis() }
                return string
            }

            /// Creates a allowed characters structure with the specified raw value.
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }

        /// The allowed characters the user can enter when editing.
        public var allowedCharacters: AllowedCharacters {
            get { getAssociatedValue(key: "allowedCharacters", object: self, initialValue: .all) }
            set { 
                guard newValue != allowedCharacters else { return }
                set(associatedValue: newValue, key: "allowedCharacters", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }

        /// The handlers for editing the text.
        public var editingHandlers: EditingHandler {
            get { getAssociatedValue(key: "editingHandlers", object: self, initialValue: EditingHandler()) }
            set { 
                set(associatedValue: newValue, key: "editingHandlers", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }
        
        /// A Boolean value that indicates whether the user can edit the string value of the text field by double clicking it.
        public var isEditableByDoubleClick: Bool {
            get { getAssociatedValue(key: "isEditableByDoubleClick", object: self, initialValue: false) }
            set { 
                guard newValue != isEditableByDoubleClick else { return }
                set(associatedValue: newValue, key: "isEditableByDoubleClick", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }
        
        var _isSelectable: Bool {
            get { getAssociatedValue(key: "_isSelectable", object: self, initialValue: isSelectable) }
            set { set(associatedValue: newValue, key: "_isSelectable", object: self) }
        }
        
        var _isEditable: Bool {
            get { getAssociatedValue(key: "_isEditable", object: self, initialValue: isEditable) }
            set { set(associatedValue: newValue, key: "_isEditable", object: self) }
        }
        
        /// A Boolean value that indicates whether text field should automatically adjust it's size to fit the string value.
        @objc open var automaticallyResizesToFit: Bool {
            get { getAssociatedValue(key: "automaticallyResizesToFit", object: self, initialValue: false) }
            set {
                guard newValue != automaticallyResizesToFit else { return }
                set(associatedValue: newValue, key: "automaticallyResizesToFit", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
                if newValue {
                    sizeToFit()
                }
            }
        }

        /// The action to perform when the user presses the enter key.
        public var actionOnEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue(key: "actionOnEnterKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEnterKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEnterKeyDown", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }

        /// The action to perform when the user presses the escape key.
        public var actionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue(key: "actionOnEscapeKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEscapeKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEscapeKeyDown", object: self)
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }

        /// The minimum numbers of characters needed when the user edits the string value.
        public var minimumNumberOfCharacters: Int? {
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
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }

        /// The maximum numbers of characters allowed when the user edits the string value.
        public var maximumNumberOfCharacters: Int? {
            get { getAssociatedValue(key: "maximumNumberOfCharacters", object: self, initialValue: nil) }
            set {
                set(associatedValue: newValue, key: "maximumNumberOfCharacters", object: self)
                if let newValue = newValue {
                    if let minimumNumberOfCharacters = minimumNumberOfCharacters, newValue < minimumNumberOfCharacters {
                        self.minimumNumberOfCharacters = newValue
                    }
                }
                if let maxCharCount = newValue, stringValue.count > maxCharCount {
                    stringValue = String(stringValue.prefix(maxCharCount))
                }
                swizzleTextField(shouldSwizzle: needsSwizzling)
            }
        }

        /// A Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
        public var endEditingOnOutsideMouseDown: Bool {
            get { getAssociatedValue(key: "endEditingOnOutsideMouseDown", object: self, initialValue: false) }
            set {
                set(associatedValue: newValue, key: "endEditingOnOutsideMouseDown", object: self)
                setupMouseMonitor()
            }
        }

        var mouseDownMonitor: NSEvent.Monitor? {
            get { getAssociatedValue(key: "mouseDownMonitor", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "mouseDownMonitor", object: self) }
        }

        func setupMouseMonitor() {
            if endEditingOnOutsideMouseDown {
                if mouseDownMonitor == nil {
                    mouseDownMonitor = NSEvent.localMonitor(for: .leftMouseDown) { [weak self] event in
                        guard let self = self, self.endEditingOnOutsideMouseDown, self.hasKeyboardFocus else { return event }
                        if self.bounds.contains(event.location(in: self)) == false, let window = self.window {
                            //  if self.stringValue
                            self.updateString()
                            window.makeFirstResponder(nil)
                        }
                        return event
                    }
                }
            } else {
                mouseDownMonitor = nil
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
