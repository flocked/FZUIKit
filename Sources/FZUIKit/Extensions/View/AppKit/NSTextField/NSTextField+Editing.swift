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
            
            /// Handler that gets called whenever editing the text did end.
            public var didEnd: (() -> Void)?
            
            var needsSwizzle: Bool {
                didBegin != nil || shouldEdit != nil || didEdit != nil || didEnd != nil
            }
        }

        /// The action to perform when the user presses the escape key.
        public enum EscapeKeyAction: Int, Hashable {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            /// Ends editing the text and resets it to the the state before editing.
            case endEditingAndReset
        }

        /// The action to perform when the user presses the enter key.
        public enum EnterKeyAction: Int, Hashable {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
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

            func trimString(_ string: String) -> String {
                guard self != .all else { return string }
                var string = string
                var characterSet = CharacterSet()
                if contains(.lowercaseLetters) == false { characterSet += .lowercaseLetters }
                if contains(.uppercaseLetters) == false { characterSet += .uppercaseLetters }
                if contains(.digits) == false { characterSet += .decimalDigits }
                if contains(.symbols) == false { characterSet += .symbols}
                if contains(.newLines) == false { characterSet += .newlines }
                if !characterSet.isEmpty { string = string.trimmingCharacters(in: characterSet) }
                if contains(.whitespaces) == false { string = string.replacingOccurrences(of: " ", with: "") }
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
            get { getAssociatedValue("allowedCharacters", initialValue: .all) }
            set { 
                guard newValue != allowedCharacters else { return }
                setAssociatedValue(newValue, key: "allowedCharacters")
                observeEditing()
            }
        }

        /// The handlers for editing the text.
        public var editingHandlers: EditingHandler {
            get { getAssociatedValue("editingHandlers", initialValue: EditingHandler()) }
            set { 
                setAssociatedValue(newValue, key: "editingHandlers")
                observeEditing()
            }
        }
        
        public var isEditingText: Bool {
            get { getAssociatedValue("isEditingText", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isEditingText") }
        }
        

        /// The action to perform when the user presses the enter key.
        public var actionOnEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue("actionOnEnterKeyDown", initialValue: .none) }
            set {
                guard actionOnEnterKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEnterKeyDown")
                observeTextCommands()
            }
        }

        /// The action to perform when the user presses the escape key.
        public var actionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue("actionOnEscapeKeyDown", initialValue: .none) }
            set {
                guard actionOnEscapeKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEscapeKeyDown")
                observeTextCommands()
            }
        }

        /// The minimum numbers of characters needed when the user edits the string value.
        public var minimumNumberOfCharacters: Int? {
            get { getAssociatedValue("minimumNumberOfCharacters", initialValue: nil) }
            set {
                guard newValue != minimumNumberOfCharacters else { return }
                setAssociatedValue(newValue, key: "minimumNumberOfCharacters")
                if let newValue = newValue {
                    if let maximumNumberOfCharacters = maximumNumberOfCharacters, newValue > maximumNumberOfCharacters {
                        self.maximumNumberOfCharacters = newValue
                    }
                }
                if let maxCharCount = newValue, stringValue.count > maxCharCount {
                    stringValue = String(stringValue.prefix(maxCharCount))
                }
                observeEditing()
            }
        }

        /// The maximum numbers of characters allowed when the user edits the string value.
        public var maximumNumberOfCharacters: Int? {
            get { getAssociatedValue("maximumNumberOfCharacters", initialValue: nil) }
            set {
                guard newValue != maximumNumberOfCharacters else { return }
                setAssociatedValue(newValue, key: "maximumNumberOfCharacters")
                if let newValue = newValue {
                    if let minimumNumberOfCharacters = minimumNumberOfCharacters, newValue < minimumNumberOfCharacters {
                        self.minimumNumberOfCharacters = newValue
                    }
                }
                if let maxCharCount = newValue, stringValue.count > maxCharCount {
                    stringValue = String(stringValue.prefix(maxCharCount))
                }
                observeEditing()
            }
        }

        /// A Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
        public var endEditingOnOutsideClick: Bool {
            get { getAssociatedValue("endEditingOnOutsideClick", initialValue: false) }
            set { 
                guard newValue != endEditingOnOutsideClick else { return }
                setAssociatedValue(newValue, key: "endEditingOnOutsideClick")
                setupTextFieldObserver()
                keyboardFocusChanged()
            }
        }
        
        /// A Boolean value that indicates whether the user can edit the string value of the text field by double clicking it.
        public var isEditableByDoubleClick: Bool {
            get { doubleClickEditGestureRecognizer != nil }
            set {
                guard newValue != isEditableByDoubleClick else { return }
                if newValue {
                    doubleClickEditGestureRecognizer = DoubleClickEditGestureRecognizer()
                    doubleClickEditGestureRecognizer?.addToView(self)
                } else  {
                    doubleClickEditGestureRecognizer?.removeFromView(disablingReadding: true)
                    doubleClickEditGestureRecognizer = nil
                }
                setupTextFieldObserver()
                keyboardFocusChanged()
            }
        }
        
        func keyboardFocusChanged() {
            let hasKeyboardFocus = hasKeyboardFocus
            if !hasKeyboardFocus, let isSelectableEditableState = isSelectableEditableState {
                self.isSelectable = isSelectableEditableState.isSelectable
                self.isEditable = isSelectableEditableState.isEditable
                self.isSelectableEditableState = nil
            }
            if hasKeyboardFocus, endEditingOnOutsideClick {
                guard mouseDownMonitor == nil else { return }
                mouseDownMonitor = NSEvent.monitor(.leftMouseDown) { [weak self] event in
                    guard let self = self, self.endEditingOnOutsideClick, self.hasKeyboardFocus else { return event }
                    if self.bounds.contains(event.location(in: self)) == false {
                        self.updateString()
                        self.resignFirstResponding()
                    }
                    return event
                }
            } else {
                mouseDownMonitor = nil
            }
        }
        
        var isSelectableEditableState: (isSelectable: Bool, isEditable: Bool)? {
            get { getAssociatedValue("isSelectableEditableState", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "isSelectableEditableState") }
        }
        
        var hasKeyboardFocusState: Bool {
            get { getAssociatedValue("hasKeyboardFocusState", initialValue: false) }
            set { setAssociatedValue(newValue, key: "hasKeyboardFocusState") }
        }
        
        var mouseDownMonitor: NSEvent.Monitor? {
            get { getAssociatedValue("mouseDownMonitor", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "mouseDownMonitor") }
        }
        
        func updateString() {
            let newString = allowedCharacters.trimString(stringValue)
            if let maxCharCount = maximumNumberOfCharacters, newString.count > maxCharCount {
                if previousString.count <= maxCharCount {
                    stringValue = previousString
                    currentEditor()?.selectedRange = editingRange
                } else {
                    stringValue = String(newString.prefix(maxCharCount))
                }
            } else if let minCharCount = minimumNumberOfCharacters, newString.count < minCharCount {
                if previousString.count >= minCharCount {
                    stringValue = previousString
                    currentEditor()?.selectedRange = editingRange
                }
            } else if editingHandlers.shouldEdit?(stringValue) == false {
                stringValue = previousString
                currentEditor()?.selectedRange = editingRange
            } else {
                stringValue = newString
                if previousString == newString {
                    currentEditor()?.selectedRange = editingRange
                }
                editingHandlers.didEdit?()
            }
            previousString = stringValue
            if let editingRange = currentEditor()?.selectedRange {
                self.editingRange = editingRange
            }
            adjustFontSize()
        }

        func observeEditing() {
            if editingHandlers.needsSwizzle || allowedCharacters.needsSwizzling || minimumNumberOfCharacters != nil || maximumNumberOfCharacters != nil || automaticallyResizesToFit || needsFontAdjustments || isVerticallyCentered {
                guard editingNotificationTokens.isEmpty else { return }
                setupTextFieldObserver()
                
                editingNotificationTokens.append(
                NotificationCenter.default.observe(NSTextField.textDidBeginEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.isEditingText = true
                    self.editStartString = self.stringValue
                    self.previousString = self.stringValue
                    self.editingHandlers.didBegin?()
                    if let editingRange = self.currentEditor()?.selectedRange {
                        self.editingRange = editingRange
                    }
                })
                
                editingNotificationTokens.append(
                NotificationCenter.default.observe(NSTextField.textDidChangeNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.updateString()
                    self.resizeToFit()
                    self.adjustFontSize()
                    if self.isVerticallyCentered, !self.automaticallyResizesToFit {
                        self.frame.size.height += 0.0001
                        self.frame.size.height -= 0.0001
                    }
                })
                
                editingNotificationTokens.append(
                    NotificationCenter.default.observe(NSTextField.textDidEndEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.isEditingText = false
                    self.editStartString = self.stringValue
                    self.editingHandlers.didEnd?()
                    self.resizeToFit()
                    self.adjustFontSize()
                })
            } else {
                setupTextFieldObserver()
                editingNotificationTokens.removeAll()
            }
        }
        
        func observeTextCommands() {
            if actionOnEscapeKeyDown != .none || actionOnEnterKeyDown != .none {
                if isMethodReplaced(#selector(NSTextViewDelegate.textView(_:doCommandBy:))) == false {
                    textFieldObserver = nil
                    do {
                        try replaceMethod(
                            #selector(NSTextViewDelegate.textView(_:doCommandBy:)),
                            methodSignature: (@convention(c) (AnyObject, Selector, NSTextView, Selector) -> (Bool)).self,
                            hookSignature: (@convention(block) (AnyObject, NSTextView, Selector) -> (Bool)).self
                        ) { store in { object, textView, selector in
                            if let textField = object as? NSTextField {
                                switch selector {
                                case #selector(NSControl.cancelOperation(_:)):
                                    switch textField.actionOnEscapeKeyDown {
                                    case .endEditingAndReset:
                                        textField.stringValue = textField.editStartString
                                        textField.adjustFontSize()
                                        textField.resignFirstResponding()
                                        return true
                                    case .endEditing:
                                        if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                            return false
                                        } else {
                                            textField.resignFirstResponding()
                                            return true
                                        }
                                    case .none:
                                        break
                                    }
                                case #selector(NSControl.insertNewline(_:)):
                                    switch textField.actionOnEnterKeyDown {
                                    case .endEditing:
                                        if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                            return false
                                        } else {
                                            textField.resignFirstResponding()
                                            return true
                                        }
                                    case .none: break
                                    }
                                default: break
                                }
                            }
                            return store.original(object, #selector(NSTextViewDelegate.textView(_:doCommandBy:)), textView, selector)
                        }
                        }
                        setupTextFieldObserver()
                    } catch {
                        Swift.debugPrint(error)
                    }
                }
            } else if isMethodReplaced(#selector(NSTextViewDelegate.textView(_:doCommandBy:))) {
                textFieldObserver = nil
                resetMethod(#selector(NSTextViewDelegate.textView(_:doCommandBy:)))
                setupTextFieldObserver()
            }
        }
        
        func setupTextFieldObserver() {
            if needsFontAdjustments || automaticallyResizesToFit || endEditingOnOutsideClick || isEditableByDoubleClick {
                if textFieldObserver == nil {
                    textFieldObserver = KeyValueObserver(self)
                }
            } else {
                textFieldObserver = nil
            }
            guard let textFieldObserver = textFieldObserver else { return }
            
            if endEditingOnOutsideClick || isEditableByDoubleClick {
                guard textFieldObserver.isObserving(\.window?.firstResponder) == false else { return }
                textFieldObserver.add( \.window?.firstResponder) { [weak self] old, new in
                    guard let self = self else { return }
                    if self.hasKeyboardFocus != self.hasKeyboardFocusState {
                        self.keyboardFocusChanged()
                        self.hasKeyboardFocusState = self.hasKeyboardFocus
                    }
                }
                hasKeyboardFocusState = hasKeyboardFocus
            } else {
                textFieldObserver.remove(\.window?.firstResponder)
            }
            
            if needsFontAdjustments || automaticallyResizesToFit {
                guard textFieldObserver.isObserving(\.stringValue) == false else { return }
                textFieldObserver.add(\.stringValue, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.preferredMaxLayoutWidth, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.maximumNumberOfLines, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.isBezeled, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.isBordered, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.bezelStyle, handler: { [weak self] old, new in
                    guard let self = self, self.isBezeled, old != new else { return }
                    self.resizeToFit()
                    self.adjustFontSize()
                })
            } else {
                textFieldObserver.remove([\.stringValue, \.isBezeled, \.isBordered, \.bezelStyle, \.preferredMaxLayoutWidth, \.maximumNumberOfLines])
            }
            
            if needsFontAdjustments {
                guard textFieldObserver.isObserving(\.allowsDefaultTighteningForTruncation) == false else { return }
                textFieldObserver.add(\.allowsDefaultTighteningForTruncation, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                textFieldObserver.add(\.frame, handler: { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.adjustFontSize()
                })
            } else {
                textFieldObserver.remove([\.allowsDefaultTighteningForTruncation, \.frame])
            }
            
            if automaticallyResizesToFit {
                guard textFieldObserver.isObserving(\.attributedStringValue) == false else { return }
                textFieldObserver.add(\.attributedStringValue) { [weak self] old, new in
                    guard let self = self, self.automaticallyResizesToFit, !isEditingText else { return }
                    self.resizeToFit()
                }
                textFieldObserver.add(\.placeholderString) { [weak self] old, new in
                    guard let self = self, self.automaticallyResizesToFit, self.preferredMinLayoutWidth == Self.placeholderWidth else { return }
                    self.resizeToFit()
                }
                textFieldObserver.add(\.placeholderAttributedString) { [weak self] old, new in
                    guard let self = self, self.automaticallyResizesToFit, self.preferredMinLayoutWidth == Self.placeholderWidth else { return }
                    self.resizeToFit()
                }
            } else {
                textFieldObserver.remove([\.attributedStringValue, \.placeholderString, \.placeholderAttributedString])
            }
        }
        
        var textFieldObserver: KeyValueObserver<NSTextField>? {
            get { getAssociatedValue("textFieldObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "textFieldObserver") }
        }
        
        var editingNotificationTokens: [NotificationToken] {
            get { getAssociatedValue("editingNotificationTokens", initialValue: []) }
            set {
                setAssociatedValue(newValue, key: "editingNotificationTokens")
            }
        }
        
        var doubleClickEditGestureRecognizer: DoubleClickEditGestureRecognizer? {
            get { getAssociatedValue("doubleClickEditGestureRecognizer", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "doubleClickEditGestureRecognizer") }
        }

        var editStartString: String {
            get { getAssociatedValue("editStartString", initialValue: stringValue) }
            set { setAssociatedValue(newValue, key: "editStartString") }
        }

        var previousString: String {
            get { getAssociatedValue("previousString", initialValue: stringValue) }
            set { setAssociatedValue(newValue, key: "previousString") }
        }

        var editingRange: NSRange {
            get { getAssociatedValue("editingRange", initialValue: currentEditor()?.selectedRange ?? NSRange(location: 0, length: 0)) }
            set { setAssociatedValue(newValue, key: "editingRange") }
        }
        
        class DoubleClickEditGestureRecognizer: ReattachingGestureRecognizer {
            override func mouseDown(with event: NSEvent) {
                if let textField = view as? NSTextField, textField.isEditableByDoubleClick, !textField.isEditable, event.clickCount == 2 {
                    textField.isSelectableEditableState = (textField.isSelectable, textField.isEditable)
                    textField.isSelectable = true
                    textField.isEditable = true
                    textField.makeFirstResponder()
                }
                super.mouseDown(with: event)
            }
        }
    }
#endif
