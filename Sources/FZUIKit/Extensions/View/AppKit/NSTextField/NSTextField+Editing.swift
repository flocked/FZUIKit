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
            get { getAssociatedValue(key: "allowedCharacters", object: self, initialValue: .all) }
            set { 
                guard newValue != allowedCharacters else { return }
                set(associatedValue: newValue, key: "allowedCharacters", object: self)
                swizzleTextField()
            }
        }

        /// The handlers for editing the text.
        public var editingHandlers: EditingHandler {
            get { getAssociatedValue(key: "editingHandlers", object: self, initialValue: EditingHandler()) }
            set { 
                set(associatedValue: newValue, key: "editingHandlers", object: self)
                swizzleTextField()
            }
        }
        
        /// A Boolean value that indicates whether text field should automatically adjust it's size to fit the string value.
        @objc open var automaticallyResizesToFit: Bool {
            get { getAssociatedValue(key: "automaticallyResizesToFit", object: self, initialValue: false) }
            set {
                guard newValue != automaticallyResizesToFit else { return }
                set(associatedValue: newValue, key: "automaticallyResizesToFit", object: self)
                swizzleTextField()
                if newValue {
                    sizeToFit()
                }
            }
        }
        
        /// The preferred minimum width, if `automaticallyResizesToFit` is enabled.
        public var preferredMinLayoutWidth: CGFloat {
            get { getAssociatedValue(key: "preferredMinLayoutWidth", object: self, initialValue: 0) }
            set {
                set(associatedValue: newValue, key: "preferredMinLayoutWidth", object: self)
                resizeToFit()
            }
        }
        
        public var isEditingText: Bool {
            get { getAssociatedValue(key: "isEditingText", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "isEditingText", object: self) }
        }
        
        func resizeToFit() {
            guard automaticallyResizesToFit else { return }
            frame.size = calculatedFittingSize
        }
        
        var calculatedFittingSize: CGSize {
            guard let cell = cell else { return frame.size }
            let maxWidth: CGFloat = preferredMaxLayoutWidth == 0 ? 100000 : preferredMaxLayoutWidth
            var cellSize = cell.cellSize(forBounds: CGRect(0, 0, maxWidth, 10000))
            cellSize.width.round(toNearest: 0.5, .awayFromZero)
            cellSize.height.round(toNearest: 0.5, .awayFromZero)
            cellSize.width = max(cellSize.width, preferredMinLayoutWidth)
            return cellSize
        }

        /// The action to perform when the user presses the enter key.
        public var actionOnEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue(key: "actionOnEnterKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEnterKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEnterKeyDown", object: self)
                swizzleDoCommand()
            }
        }

        /// The action to perform when the user presses the escape key.
        public var actionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue(key: "actionOnEscapeKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEscapeKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEscapeKeyDown", object: self)
                swizzleDoCommand()
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
                swizzleTextField()
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
                swizzleTextField()
            }
        }

        /// A Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
        public var endEditingOnOutsideClick: Bool {
            get { getAssociatedValue(key: "endEditingOnOutsideClick", object: self, initialValue: false) }
            set { 
                guard newValue != endEditingOnOutsideClick else { return }
                set(associatedValue: newValue, key: "endEditingOnOutsideClick", object: self)
                observeKeyboardFocus()
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
                observeKeyboardFocus()
            }
        }
        
        func observeKeyboardFocus() {
            if (endEditingOnOutsideClick || isEditableByDoubleClick) {
                keyboardFocusObservation = observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    guard let self = self else { return }
                    if self.hasKeyboardFocus != self.isKeyboardFocused {
                        self.keyboardFocusChanged()
                        self.isKeyboardFocused = self.hasKeyboardFocus
                    }
                }
                self.isKeyboardFocused = self.hasKeyboardFocus
                self.keyboardFocusChanged()
            } else {
                keyboardFocusObservation = nil
            }
        }
        
        func keyboardFocusChanged() {
            let hasKeyboardFocus = hasKeyboardFocus
            if !hasKeyboardFocus, let isSelectableEditable = isSelectableEditable {
                self.isSelectable = isSelectableEditable.isSelectable
                self.isEditable = isSelectableEditable.isEditable
                self.isSelectableEditable = nil
            }
            if hasKeyboardFocus, endEditingOnOutsideClick {
                guard mouseDownMonitor == nil else { return }
                mouseDownMonitor = NSEvent.localMonitor(for: .leftMouseDown) { [weak self] event in
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
        
        var isSelectableEditable: (isSelectable: Bool, isEditable: Bool)? {
            get { getAssociatedValue(key: "isSelectableEditable", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "isSelectableEditable", object: self) }
        }
        
        var isKeyboardFocused: Bool {
            get { getAssociatedValue(key: "isKeyboardFocused", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "isKeyboardFocused", object: self) }
        }
        
        var keyboardFocusObservation: NSKeyValueObservation? {
            get { getAssociatedValue(key: "keyboardFocusObservation", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "keyboardFocusObservation", object: self) }
        }
        
        var mouseDownMonitor: NSEvent.Monitor? {
            get { getAssociatedValue(key: "mouseDownMonitor", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "mouseDownMonitor", object: self) }
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

        func swizzleTextField() {
            if editingHandlers.needsSwizzle || allowedCharacters.needsSwizzling || minimumNumberOfCharacters != nil || maximumNumberOfCharacters != nil || automaticallyResizesToFit {
                guard keyValueObservations.isEmpty else { return }
                
                keyValueObservations.append(
                observeChanges(for: \.stringValue) { [weak self] old, new in
                    guard let self = self, self.automaticallyResizesToFit, !isEditingText else { return }
                    self.resizeToFit()
                })
                
                keyValueObservations.append(
                observeChanges(for: \.attributedStringValue) { [weak self] old, new in
                    guard let self = self, self.automaticallyResizesToFit, !isEditingText else { return }
                    self.resizeToFit()
                })
                
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
                    if self.automaticallyResizesToFit {
                        self.resizeToFit()
                    }
                    self.invalidateIntrinsicContentSize()
                })
                
                editingNotificationTokens.append(
                NotificationCenter.default.observe(NSTextField.textDidChangeNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.updateString()
                    if self.automaticallyResizesToFit {
                        self.resizeToFit()
                    }
                    self.invalidateIntrinsicContentSize()
                })
                
                editingNotificationTokens.append(
                NotificationCenter.default.observe(NSTextField.textDidEndEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.isEditingText = false
                    self.adjustFontSize()
                    self.editingHandlers.didEnd?()
                    if self.automaticallyResizesToFit {
                        self.resizeToFit()
                    }
                    self.invalidateIntrinsicContentSize()
                })
            } else {
                keyValueObservations.removeAll()
                editingNotificationTokens.removeAll()
            }
        }
        
        func swizzleDoCommand() {
            if actionOnEscapeKeyDown != .none || actionOnEnterKeyDown != .none {
                if isMethodReplaced(#selector(NSTextViewDelegate.textView(_:doCommandBy:))) == false {
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
                    } catch {
                        Swift.debugPrint(error)
                    }
                }
            } else {
                resetMethod(#selector(NSTextViewDelegate.textView(_:doCommandBy:)))
            }
        }

        var isAdjustingFontSize: Bool {
            get { getAssociatedValue(key: "isAdjustingFontSize", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "isAdjustingFontSize", object: self)
            }
        }
        
        var keyValueObservations: [NSKeyValueObservation] {
            get { getAssociatedValue(key: "keyValueObservations", object: self, initialValue: []) }
            set {
                set(associatedValue: newValue, key: "keyValueObservations", object: self)
            }
        }
        
        var editingNotificationTokens: [NotificationToken] {
            get { getAssociatedValue(key: "editingNotificationTokens", object: self, initialValue: []) }
            set {
                set(associatedValue: newValue, key: "editingNotificationTokens", object: self)
            }
        }
        
        var doubleClickEditGestureRecognizer: DoubleClickEditGestureRecognizer? {
            get { getAssociatedValue(key: "doubleClickEditGestureRecognizer", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "doubleClickEditGestureRecognizer", object: self) }
        }

        var editStartString: String {
            get { getAssociatedValue(key: "editStartString", object: self, initialValue: stringValue) }
            set { set(associatedValue: newValue, key: "editStartString", object: self) }
        }

        var previousString: String {
            get { getAssociatedValue(key: "previousString", object: self, initialValue: stringValue) }
            set { set(associatedValue: newValue, key: "previousString", object: self) }
        }

        var editingRange: NSRange {
            get { getAssociatedValue(key: "editingRange", object: self, initialValue: currentEditor()?.selectedRange ?? NSRange(location: 0, length: 0)) }
            set { set(associatedValue: newValue, key: "editingRange", object: self) }
        }
        
        class DoubleClickEditGestureRecognizer: ReattachingGestureRecognizer {
            override func mouseDown(with event: NSEvent) {
                if let textField = view as? NSTextField, textField.isEditableByDoubleClick, !textField.isEditable, event.clickCount == 2 {
                    textField.isSelectableEditable = (textField.isSelectable, textField.isEditable)
                    textField.isSelectable = true
                    textField.isEditable = true
                    textField.makeFirstResponder()
                }
                super.mouseDown(with: event)
            }
        }
    }
#endif
