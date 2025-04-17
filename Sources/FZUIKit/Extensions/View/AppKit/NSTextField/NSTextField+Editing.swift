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

        /// The action to perform when the user presses the escape key while editing.
        public enum EscapeKeyAction: Int, Hashable {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            /// Ends editing the text and resets it to the the state before editing.
            case endEditingAndReset
            /// Deletes the text.
            case delete
            /// Resets the text to the the state before editing.
            case reset
        }

        /// The action to perform when the user presses the enter key while editing.
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
            
            func isValid(_ string: String) -> Bool {
                trimString(string) == string
            }

            func trimString(_ string: String) -> String {
                guard self != .all else { return string }
                var string = string
                var characterSet = CharacterSet()
                if !contains(.lowercaseLetters) { characterSet += .lowercaseLetters }
                if !contains(.uppercaseLetters) { characterSet += .uppercaseLetters }
                if !contains(.digits) { characterSet += .decimalDigits }
                if !contains(.symbols) { characterSet += .symbols}
                if !characterSet.isEmpty { string = string.trimmingCharacters(in: characterSet) }
                if !contains(.newLines) { string = string.replacingOccurrences(of: "\n", with: "") }
                if !contains(.whitespaces) { string = string.replacingOccurrences(of: " ", with: "") }
                if !contains(.emojis) { string = string.trimmingEmojis() }
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
        
        /// Sets the allowed characters the user can enter when editing.
        @discardableResult
        public func allowedCharacters(_ allowedCharacters: AllowedCharacters) -> Self {
            self.allowedCharacters = allowedCharacters
            return self
        }


        /// The handlers for editing the text.
        public var editingHandlers: EditingHandler {
            get { getAssociatedValue("editingHandlers", initialValue: EditingHandler()) }
            set { 
                setAssociatedValue(newValue, key: "editingHandlers")
                observeEditing()
            }
        }
        
        var isEditingText: Bool {
            get { getAssociatedValue("isEditingText", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isEditingText") }
        }

        /// The action to perform when the user presses the enter key while editing.
        public var editingActionOnEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue("actionOnEnterKeyDown", initialValue: .none) }
            set {
                guard editingActionOnEnterKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEnterKeyDown")
                if let searchField = self as? NSSearchField {
                    if editingActionOnEnterKeyDown == .none && editingActionOnEscapeKeyDown == .none {
                        guard searchField.searchFieldDelegate != nil else { return }
                        searchField.searchFieldDelegate = nil
                    } else if searchField.searchFieldDelegate == nil {
                        searchField.searchFieldDelegate = .init(for: searchField)
                    }
                } else {
                    swizzleDoCommandBy()
                }
            }
        }
        
        /// Sets the action to perform when the user pressed the enter key while editing.
        @discardableResult
        public func editingActionOnEnterKeyDown(_ enterAction: EnterKeyAction) -> Self {
            editingActionOnEnterKeyDown = enterAction
            return self
        }

        /// The action to perform when the user presses the escape key while editing.
        public var editingActionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue("actionOnEscapeKeyDown", initialValue: self is NSSearchField ? .delete : .none) }
            set {
                guard editingActionOnEscapeKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEscapeKeyDown")
                if let searchField = self as? NSSearchField {
                    if editingActionOnEnterKeyDown == .none && editingActionOnEscapeKeyDown == .none {
                        guard searchField.searchFieldDelegate != nil else { return }
                        searchField.searchFieldDelegate = nil
                    } else if searchField.searchFieldDelegate == nil {
                        searchField.searchFieldDelegate = .init(for: searchField)
                    }
                } else {
                    swizzleDoCommandBy()
                }
                observeEditing()
            }
        }
        
        /// Sets the action to perform when the user pressed the escape key while editing.
        @discardableResult
        public func editingActionOnEscapeKeyDown(_ escapeAction: EscapeKeyAction) -> Self {
            editingActionOnEscapeKeyDown = escapeAction
            return self
        }

        /// The minimum numbers of characters needed when the user edits the string value.
        public var minimumNumberOfCharacters: Int? {
            get { getAssociatedValue("minimumNumberOfCharacters") }
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
        
        /// Sets the minimum numbers of characters needed when the user edits the string value.
        @discardableResult
        public func minimumNumberOfCharacters(_ minimum: Int?) -> Self {
            minimumNumberOfCharacters = minimum
            return self
        }

        /// The maximum numbers of characters allowed when the user edits the string value.
        public var maximumNumberOfCharacters: Int? {
            get { getAssociatedValue("maximumNumberOfCharacters") }
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
        
        /// Sets maximum numbers of characters allowed when the user edits the string value.
        @discardableResult
        public func maximumNumberOfCharacters(_ maximum: Int?) -> Self {
            maximumNumberOfCharacters = maximum
            return self
        }

        /// A Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
        public var endsEditingOnOutsideClick: Bool {
            get { firstResponderResignClickCount > 0 }
            set {
                guard newValue != endsEditingOnOutsideClick else { return }
                firstResponderResignClickCount = newValue ? 1 : 0
            }
        }
        
        /// Sets the Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
        @discardableResult
        public func endsEditingOnOutsideClick(_ endsEditing: Bool) -> Self {
            endsEditingOnOutsideClick = endsEditing
            return self
        }
        
        /// A Boolean value that indicates whether the user can edit the string value of the text field by double clicking it.
        public var isEditableByDoubleClick: Bool {
            get { doubleClickEditGestureRecognizer != nil }
            set {
                guard newValue != isEditableByDoubleClick else { return }
                if newValue {
                    doubleClickEditGestureRecognizer = DoubleClickEditGestureRecognizer(self)
                    doubleClickEditGestureRecognizer?.addToView(self)
                } else  {
                    doubleClickEditGestureRecognizer?.removeFromView()
                    doubleClickEditGestureRecognizer = nil
                }
            }
        }
        
        /// Sets Boolean value that indicates whether the user can edit the string value of the text field by double clicking it.
        @discardableResult
        public func isEditableByDoubleClick(_ isEditableByDoubleClick: Bool) -> Self {
            self.isEditableByDoubleClick = isEditableByDoubleClick
            return self
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
            if editingHandlers.needsSwizzle || allowedCharacters.needsSwizzling || minimumNumberOfCharacters != nil || maximumNumberOfCharacters != nil || automaticallyResizesToFit || needsFontAdjustments || isVerticallyCentered || editingActionOnEscapeKeyDown == .endEditingAndReset {
                guard editingNotificationTokens.isEmpty else { return }
                setupTextFieldObserver()
                
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidBeginEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.isEditingText = true
                    self.editStartString = self.stringValue
                    self.previousString = self.stringValue
                    self.editingHandlers.didBegin?()
                    if let editingRange = self.currentEditor()?.selectedRange {
                        self.editingRange = editingRange
                    }
                })
                
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidChangeNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.updateString()
                    self.resizeToFit()
                    self.adjustFontSize()
                    if self.isVerticallyCentered, !self.automaticallyResizesToFit {
                        self.frame.size.height += 0.0001
                        self.frame.size.height -= 0.0001
                    }
                })
                
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidEndEditingNotification, object: self) { [weak self] notification in
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
        
        func swizzleDoCommandBy() {
            if editingActionOnEscapeKeyDown != .none || editingActionOnEnterKeyDown != .none {
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
                                    switch textField.editingActionOnEscapeKeyDown {
                                    case .endEditingAndReset:
                                        textField.stringValue = textField.editStartString
                                        textField.adjustFontSize()
                                        textView.resignFirstResponding()
                                        return true
                                    case .endEditing:
                                        if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                            return false
                                        } else {
                                            textView.resignFirstResponding()
                                            return true
                                        }
                                    case .delete:
                                        textField.stringValue = ""
                                        textField.adjustFontSize()
                                        return false
                                    case .reset:
                                        textField.stringValue = textField.editStartString
                                        textField.adjustFontSize()
                                        return false
                                    case .none:
                                        break
                                    }
                                case #selector(NSControl.insertNewline(_:)):
                                    switch textField.editingActionOnEnterKeyDown {
                                    case .endEditing:
                                        if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                                            return false
                                        } else {
                                            textView.resignFirstResponding()
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
            if !(needsFontAdjustments || automaticallyResizesToFit || endsEditingOnOutsideClick || isEditableByDoubleClick) {
                textFieldObserver = nil
            } else if textFieldObserver == nil {
                textFieldObserver = KeyValueObserver(self)
            }
            
            guard let textFieldObserver = textFieldObserver else { return }
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
            get { getAssociatedValue("textFieldObserver") }
            set { setAssociatedValue(newValue, key: "textFieldObserver") }
        }
        
        var editingNotificationTokens: [NotificationToken] {
            get { getAssociatedValue("editingNotificationTokens", initialValue: []) }
            set { setAssociatedValue(newValue, key: "editingNotificationTokens") }
        }
        
        var doubleClickEditGestureRecognizer: DoubleClickEditGestureRecognizer? {
            get { getAssociatedValue("doubleClickEditGestureRecognizer") }
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
        
        class DoubleClickEditGestureRecognizer: NSGestureRecognizer {
            var isSelectableEditableState: (isSelectable: Bool, isEditable: Bool)?
            var observation: KeyValueObservation?
            var textField: NSTextField? {
                view as? NSTextField
            }
            
            init(_ view: NSTextField) {
                super.init(target: nil, action: nil)
                reattachesAutomatically = true
                observation = view.observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    guard let self = self, let view = self.textField else { return }
                    if let isSelectableEditableState = self.isSelectableEditableState, !view.isFirstResponder {
                        view.isSelectable = isSelectableEditableState.isSelectable
                        view.isEditable = isSelectableEditableState.isEditable
                        self.isSelectableEditableState = nil
                    }
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func mouseDown(with event: NSEvent) {
                if let textField = textField, !textField.isEditable, event.clickCount == 2, !textField.isFirstResponder {
                    isSelectableEditableState = (textField.isSelectable, textField.isEditable)
                    textField.isSelectable = true
                    textField.isEditable = true
                    textField.makeFirstResponder()
                    /*
                    guard let editor = textField.currentEditor() as? NSTextView else { return }
                    let localPoint = textField.convert(event.location(in: textField), to: editor)
                    let charIndex = editor.characterIndexForInsertion(at: localPoint)
                    let range = NSRange(location: charIndex, length: 0)
                    let current = editor.selectedRange
                    editor.selectedRange = range
                     */
                }
                super.mouseDown(with: event)
            }
        }
    }

extension NSSearchField {
    var searchFieldDelegate: SearchFieldDelegate? {
        get { getAssociatedValue("searchFieldDelegate") }
        set { setAssociatedValue(newValue, key: "searchFieldDelegate") }
    }
    
    class SearchFieldDelegate: NSObject, NSSearchFieldDelegate {
        weak var delegate: NSSearchFieldDelegate?
        weak var searchField: NSSearchField?
        var observation: KeyValueObservation?
        
        init(for searchField: NSSearchField) {
            self.searchField = searchField
            self.delegate = searchField.delegate
            super.init()
            searchField.delegate = self
            observation = searchField.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.searchField?.delegate = self
            }
        }
        
        func searchFieldDidStartSearching(_ sender: NSSearchField) {
            delegate?.searchFieldDidStartSearching?(sender)
        }
        
        func searchFieldDidEndSearching(_ sender: NSSearchField) {
            delegate?.searchFieldDidEndSearching?(sender)
        }
        
        func textField(_ textField: NSTextField, textView: NSTextView, shouldSelectCandidateAt index: Int) -> Bool {
            delegate?.textField?(textField, textView: textView, shouldSelectCandidateAt: index) ?? true
        }
        
        func textField(_ textField: NSTextField, textView: NSTextView, candidatesForSelectedRange selectedRange: NSRange) -> [Any]? {
            delegate?.textField?(textField, textView: textView, candidatesForSelectedRange: selectedRange)
        }
        
        func textField(_ textField: NSTextField, textView: NSTextView, candidates: [NSTextCheckingResult], forSelectedRange selectedRange: NSRange) -> [NSTextCheckingResult] {
            delegate?.textField?(textField, textView: textView, candidates: candidates, forSelectedRange: selectedRange) ?? []
        }
        
        func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
            delegate?.control?(control, isValidObject: obj) ?? true
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            delegate?.controlTextDidBeginEditing?(obj)
        }
        
        func controlTextDidChange(_ obj: Notification) {
            delegate?.controlTextDidChange?(obj)
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            delegate?.controlTextDidEndEditing?(obj)
        }
        
        func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
            delegate?.control?(control, textShouldEndEditing: fieldEditor) ?? true
        }
        
        func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
            delegate?.control?(control, textShouldBeginEditing: fieldEditor) ?? true
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            guard let textField = searchField else { return true}
            if commandSelector == #selector(NSControl.cancelOperation(_:)), textField.editingActionOnEscapeKeyDown != .none {
                switch textField.editingActionOnEscapeKeyDown {
                case .endEditingAndReset:
                    textField.stringValue = textField.editStartString
                    textField.adjustFontSize()
                    textView.resignFirstResponding()
                    return true
                case .endEditing:
                    if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                        return false
                    } else {
                        textView.resignFirstResponding()
                        return true
                    }
                case .delete:
                    textField.stringValue = ""
                    textField.adjustFontSize()
                    return false
                case .reset:
                    textField.stringValue = textField.editStartString
                    textField.adjustFontSize()
                    return false
                case .none:
                    break
                }
            } else if commandSelector == #selector(NSControl.insertNewline(_:)), textField.editingActionOnEnterKeyDown != .none {
                if textField.editingHandlers.shouldEdit?(textField.stringValue) == false {
                    return false
                } else {
                    textView.resignFirstResponding()
                    return true
                }
            }
            return delegate?.control?(control, textView: textView, doCommandBy: commandSelector) ?? true
        }
        
        func control(_ control: NSControl, didFailToFormatString string: String, errorDescription error: String?) -> Bool {
            delegate?.control?(control, didFailToFormatString: string, errorDescription: error) ?? true
        }
        
        func control(_ control: NSControl, didFailToValidatePartialString string: String, errorDescription error: String?) {
            delegate?.control?(control, didFailToValidatePartialString: string, errorDescription: error)
        }
        
        func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
            delegate?.control?(control, textView: textView, completions: words, forPartialWordRange: charRange, indexOfSelectedItem: index) ?? []
        }
        
        deinit {
            observation = nil
            searchField?.delegate = delegate
        }
    }
}
#endif
