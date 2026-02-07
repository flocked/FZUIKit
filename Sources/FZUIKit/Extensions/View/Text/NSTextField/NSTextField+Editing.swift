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
        /// Handler that is called whenever editing the text did begin.
        public var didBegin: (() -> Void)?
            
        /// Handler that determines whether the text should change. If you provide ``AppKit/NSTextField/minimumNumberOfCharacters``, ``AppKit/NSTextField/maximumNumberOfCharacters`` or ``AppKit/NSTextField/allowedCharacters-swift.property`` the handler is called after checking the string against the specified property conditions.
        public var shouldEdit: ((String) -> (Bool))?
            
        /// Handler that is called whenever the text did change.
        public var didEdit: (() -> Void)?
            
        /// Handler that is called whenever editing the text did end.
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
        
        var shouldReset: Bool { self == .reset || self == .endEditingAndReset }
        var shouldEnd: Bool { self == .endEditing || self == .endEditingAndReset }
    }

    /// The action to perform when the user presses the enter key while editing.
    public enum EnterKeyAction: Int, Hashable {
        /// Ends editing the text.
        case endEditing
        /// Selects all text.
        case selectAll
        /// Inserts a new line.
        case newLine
        /// No action.
        case none
    }
    
    /// The allowed characters the user can enter when editing.
    public struct AllowedCharacters: Equatable, Hashable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        var set: CharacterSet
        var isEmoji: Bool
        
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = Self(.decimalDigits)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = Self(.lowercaseLetters)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let uppercaseLetters = Self(.uppercaseLetters)
        /// Allows punctuation characters (like …,).
        public static let punctuation = Self(.punctuationCharacters)

        /// Allows all letter characters.
        public static let letters: Self = [.lowercaseLetters, .uppercaseLetters]
        /// Allows all alphanumerics characters.
        public static let alphanumerics: Self = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = Self(.symbols)
        /// Allows whitespace characters.
        public static let whitespaces = Self(.whitespaces)
        /// Allows new line characters.
        public static let newLines = Self(.newlines)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = Self(isEmoji: true)
        /// ALl characters.
        public static let all: Self = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines, .punctuation]
        
        var needsSwizzling: Bool {
            self != Self.all
        }

        func trimString(_ string: String) -> String {
            guard set != Self.all.set else { return isEmoji ? string : string.removingEmojis() }
            guard isEmoji else { return string.keepingCharacters(in: set) }
            return String(string.filter { character in
                character.unicodeScalars.allSatisfy { set.contains($0) } || character.isEmoji
            })
        }
        
        public init(_ set: CharacterSet) {
            self.set = set
            self.isEmoji = false
        }
        
        public init(stringLiteral value: String) {
            self.init(value.unicodeScalars)
        }
        
        public init<S: Sequence<Unicode.Scalar>>(_ characters: S) {
            self.init(CharacterSet(characters))
        }
        
        public init(arrayLiteral elements: Self...) {
            set = elements.map({$0.set}).union
            isEmoji = elements.contains(where: {$0.isEmoji })
        }
        
        init(_ set: CharacterSet = .init(), isEmoji: Bool) {
            self.set = set
            self.isEmoji = isEmoji
        }
        
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(lhs.set.union(rhs.set), isEmoji: lhs.isEmoji || rhs.isEmoji)
        }
        
        public static func += (lhs: inout Self, rhs: Self) {
            lhs.set.formUnion(rhs.set)
            lhs.isEmoji = lhs.isEmoji || rhs.isEmoji
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

    /**
     The action to perform when the user presses the enter key while editing.
     
     The default value is `selectAll`.
     */
    public var editingActionOnEnterKeyDown: EnterKeyAction {
        get { getAssociatedValue("actionOnEnterKeyDown", initialValue: .selectAll) }
        set {
            guard editingActionOnEnterKeyDown != newValue else { return }
            setAssociatedValue(newValue, key: "actionOnEnterKeyDown")
            swizzleDoCommandBy()
        }
    }
        
    /// Sets the action to perform when the user pressed the enter key while editing.
    @discardableResult
    public func editingActionOnEnterKeyDown(_ enterAction: EnterKeyAction) -> Self {
        editingActionOnEnterKeyDown = enterAction
        return self
    }

    /**
     The action to perform when the user presses the escape key while editing.
     
     The default value is `none`.
     */
    public var editingActionOnEscapeKeyDown: EscapeKeyAction {
        get { getAssociatedValue("actionOnEscapeKeyDown", initialValue: self is NSSearchField ? .delete : .none) }
        set {
            guard editingActionOnEscapeKeyDown != newValue else { return }
            setAssociatedValue(newValue, key: "actionOnEscapeKeyDown")
            swizzleDoCommandBy()
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
            if let minChars = newValue, minChars > maximumNumberOfCharacters ?? minChars {
                maximumNumberOfCharacters = minChars
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
            if let maxChars = newValue, minimumNumberOfCharacters ?? maxChars > maxChars {
                minimumNumberOfCharacters = maxChars
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

    /// A Boolean value indicating whether the text field should stop editing when the user clicks outside the text field.
    public var endsEditingOnOutsideClick: Bool {
        get { firstResponderResignClickCount > 0 }
        set { firstResponderResignClickCount = newValue ? 1 : 0 }
    }
        
    /// Sets the Boolean value indicating whether the text field should stop editing when the user clicks outside the text field.
    @discardableResult
    public func endsEditingOnOutsideClick(_ endsEditing: Bool) -> Self {
        endsEditingOnOutsideClick = endsEditing
        return self
    }
        
    /// A Boolean value indicating whether the user can edit the string value of the text field by double clicking it.
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
        
    /// Sets Boolean value indicating whether the user can edit the string value of the text field by double clicking it.
    @discardableResult
    public func isEditableByDoubleClick(_ isEditableByDoubleClick: Bool) -> Self {
        self.isEditableByDoubleClick = isEditableByDoubleClick
        return self
    }
        
    func updateString() {
        let newString = allowedCharacters.trimString(stringValue)
        if let maxCharCount = maximumNumberOfCharacters, newString.count > maxCharCount {
            stringValue = String(newString.prefix(maxCharCount))
        } else if let minCharCount = minimumNumberOfCharacters, newString.count < minCharCount {
            stringValue = previousString
            currentEditor()?.selectedRange = editingRange
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
        guard let editingRange = currentEditor()?.selectedRange else { return }
        self.editingRange = editingRange
    }

    func observeEditing() {
        if editingHandlers.needsSwizzle || allowedCharacters.needsSwizzling || minimumNumberOfCharacters != nil || maximumNumberOfCharacters != nil || automaticallyResizesToFit || needsFontAdjustments || isVerticallyCentered || editingActionOnEscapeKeyDown == .endEditingAndReset {
            guard editingNotificationTokens.isEmpty else { return }
            setupTextFieldObserver()
            editingNotificationTokens += .init(NSTextField.textDidBeginEditingNotification, object: self) {  [weak self] _ in
                guard let self = self else { return }
                self.isEditingText = true
                self.editStartString = self.stringValue
                self.previousString = self.stringValue
                self.editingHandlers.didBegin?()
                guard let editingRange = self.currentEditor()?.selectedRange else { return }
                self.editingRange = editingRange
            }
            editingNotificationTokens += .init(NSTextField.textDidChangeNotification, object: self) {  [weak self] _ in
                guard let self = self else { return }
                self.updateString()
                self.resizeToFit()
                self.adjustFontSize()
                guard self.isVerticallyCentered, !self.automaticallyResizesToFit else { return }
                self.frame.size.height += 0.0001
                self.frame.size.height -= 0.0001
            }
            editingNotificationTokens += .init(NSTextField.textDidEndEditingNotification, object: self) {  [weak self] _ in
                guard let self = self else { return }
                self.isEditingText = false
                self.editingHandlers.didEnd?()
                guard previousString != self.stringValue else { return }
              //  self.resizeToFit()
              //  self.adjustFontSize()
            }
        } else {
            setupTextFieldObserver()
            editingNotificationTokens.removeAll()
        }
    }
        
    func swizzleDoCommandBy() {
        if editingActionOnEscapeKeyDown != .none || editingActionOnEnterKeyDown != .selectAll {
            if doCommandHook == nil {
                textFieldObserver = nil
                do {
                    doCommandHook = try hook(#selector(NSTextViewDelegate.textView(_:doCommandBy:)), closure: { original, textField, sel, textView, selector in
                        switch selector {
                        case #selector(NSControl.cancelOperation(_:)):
                            guard textField.editingActionOnEscapeKeyDown != .none else { break }
                            if textField.editingActionOnEscapeKeyDown.shouldReset {
                                textField.stringValue = textField.editStartString
                            } else if textField.editingActionOnEscapeKeyDown == .delete {
                                textField.stringValue = ""
                            }
                            if textField.editingActionOnEscapeKeyDown.shouldEnd {
                                textView.resignAsFirstResponder()
                            }
                            return true
                            guard textField.editingActionOnEscapeKeyDown.shouldEnd else { break }
                            textView.resignAsFirstResponder()
                            return true
                        case #selector(NSControl.insertNewline(_:)):
                            switch textField.editingActionOnEnterKeyDown {
                            case .endEditing:
                                textView.resignAsFirstResponder()
                                return true
                            case .selectAll:
                                return original(textField, sel, textView, selector)
                            case .none:
                                return true
                            case .newLine:
                                textView.insertNewlineIgnoringFieldEditor(textField)
                                return true
                            }
                            guard textField.editingActionOnEnterKeyDown == .endEditing else { break }
                            textView.resignAsFirstResponder()
                            return true
                        default: break
                        }
                        return original(textField, sel, textView, selector)
                    } as @convention(block) ((NSTextField, Selector, NSTextView, Selector) -> Bool, NSTextField, Selector, NSTextView, Selector) -> Bool)
                    setupTextFieldObserver()
                } catch {
                    Swift.debugPrint(error)
                }
            }
        } else if let hook = doCommandHook {
            textFieldObserver = nil
            try? hook.revert()
            doCommandHook = nil
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
                guard let self = self, old != new, self.isEditingText else { return }
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
    
    private var doCommandHook: Hook? {
        get { getAssociatedValue("doCommandHook") }
        set { setAssociatedValue(newValue, key: "doCommandHook") }
    }
    
    private var isEditingText: Bool {
        get { getAssociatedValue("isEditingText", initialValue: false) }
        set { setAssociatedValue(newValue, key: "isEditingText") }
    }
        
    var textFieldObserver: KeyValueObserver<NSTextField>? {
        get { getAssociatedValue("textFieldObserver") }
        set { setAssociatedValue(newValue, key: "textFieldObserver") }
    }
        
    private var editingNotificationTokens: [NotificationToken] {
        get { getAssociatedValue("editingNotificationTokens", initialValue: []) }
        set { setAssociatedValue(newValue, key: "editingNotificationTokens") }
    }

    private var editStartString: String {
        get { getAssociatedValue("editStartString", initialValue: stringValue) }
        set { setAssociatedValue(newValue, key: "editStartString") }
    }

    private var previousString: String {
        get { getAssociatedValue("previousString", initialValue: stringValue) }
        set { setAssociatedValue(newValue, key: "previousString") }
    }

    private var editingRange: NSRange {
        get { getAssociatedValue("editingRange", initialValue: currentEditor()?.selectedRange ?? NSRange(location: 0, length: 0)) }
        set { setAssociatedValue(newValue, key: "editingRange") }
    }
    
    private var doubleClickEditGestureRecognizer: DoubleClickEditGestureRecognizer? {
        get { getAssociatedValue("doubleClickEditGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "doubleClickEditGestureRecognizer") }
    }
        
    class DoubleClickEditGestureRecognizer: NSGestureRecognizer {
        var isSelectableEditableState: (isSelectable: Bool, isEditable: Bool) = (false, false)
        var observations: [KeyValueObservation] = []

        init(_ view: NSTextField) {
            super.init(target: nil, action: nil)
            reattachesAutomatically = true
        }
            
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
            
        override func mouseDown(with event: NSEvent) {
            if let textField = view as? NSTextField, !textField.isEditable, event.clickCount == 2, !textField.isFirstResponder {
                isSelectableEditableState = (textField.isSelectable, textField.isEditable)
                textField.isSelectable = true
                textField.isEditable = true
                textField.makeFirstResponder()
                observations += textField.observeWillChange(for:\.isEditable) { [weak self] _,new in
                    self?.isSelectableEditableState.isEditable = new
                }
                observations += textField.observeWillChange(for:\.isSelectable) { [weak self] _,new in
                    self?.isSelectableEditableState.isSelectable = new
                }
                observations += textField.observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    guard let self = self, let view = self.view as? NSTextField, !view.isFirstResponder else { return }
                    self.observations = []
                    view.isSelectable = isSelectableEditableState.isSelectable
                    view.isEditable = isSelectableEditableState.isEditable
                }
            }
        }
    }
}
#endif
