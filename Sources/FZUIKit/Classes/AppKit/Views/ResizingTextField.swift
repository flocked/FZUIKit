//
//  ResizingTextField.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)

    import AppKit

    /// A text field that automatically resizes to fit it's text.
    open class ResizingTextField: NSTextField, NSTextFieldDelegate {
        /// The editing state the text field.
        public enum EditState {
            /// The user did begin editing the text.
            case didBegin
            /// The user did end editing the text.
            case didEnd
            /// The user did change the text.
            case changed
        }

        /// A Boolean value that indicates whether the text field automatically resizes to fit it's text.
        @IBInspectable public var automaticallyResizesToFit: Bool = true {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }

        /// Indicates how the text field should resize for fitting the placeholder.
        public var resizesToFitPlaceholder: PlaceHolderResizeOption = .emptyText {
            didSet { if oldValue != resizesToFitPlaceholder, resizesToFitPlaceholder != .never {
                invalidateIntrinsicContentSize()
            } }
        }

        /// The placeholder resize option.
        public enum PlaceHolderResizeOption: Int {
            /// Resizes the text field to always fit the placeholder.
            case always
            /// Resizes the text field to fit the placeholder if the text is an empty string ("").
            case emptyText
            /// Never resizes the text field to fit the placeholder.
            case never
        }

        /**
         The minimum width of the text field when it automatically resizes to fit its text.

         When the text field hits the maximum width, it will automatically grow it's height.
         */
        public var minWidth: CGFloat? {
            didSet { if oldValue != minWidth {
                invalidateIntrinsicContentSize()
            } }
        }

        /**
         The maximum width of the text field when it automatically resizes to fit its text.

         When `automaticallyResizesToFit` is enabled and the text field hits the maximum width, it will automatically grow in height.
         */
        public var maxWidth: CGFloat? {
            didSet { if oldValue != maxWidth {
                invalidateIntrinsicContentSize()
            } }
        }

        /*
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
         var allowedCharacters: AllowedCharacters = .all
         */

        /*
         /// A Boolean value that indicates whether the text field should stop editing when the user clicks outside the text field.
         @IBInspectable public var stopsEditingOnOutsideMouseDown = false {
             didSet { self.setupMouseDownMonitor() } }
          */

        /// A Boolean value that indicates whether the user is editing the text.
        public private(set) var isEditing = false

        /// The handler called when the edit state changes.
        public var editingStateHandler: ((EditState) -> Void)?

        /// The range of the selected text while editing.
        private var _editingSelectedRange: NSRange? {
            get {
                let currentEditor = self.currentEditor() as? NSTextView
                return currentEditor?.selectedRanges.first?.rangeValue
            }
            set {
                if let range = newValue {
                    let currentEditor = self.currentEditor() as? NSTextView
                    currentEditor?.setSelectedRange(range)
                }
            }
        }

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        func sharedInit() {
            drawsBackground = false
            isBordered = false
            textLayout = .wraps
            verticalTextAlignment = .center
            focusType = .roundedCornersRelative(0.5)
            (cell as? NSTextFieldCell)?.setWantsNotificationForMarkedText(true)
            translatesAutoresizingMaskIntoConstraints = false
            delegate = self

            lastContentSize = stringValueSize()
            placeholderSize = placeholderStringSize()
        }

        override public func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable, canBecome {
                editingStateHandler?(.didBegin)
            }
            return canBecome
        }

        func trimString(_ string: String) -> String {
            allowedCharacters.trimString(string)
        }

        func isConforming(_ string: String) -> Bool {
            return actionHandlers.confirm?(string) ?? true
        }

        /// Handlers that get called whenever the user tries to confirm (Enter key) or cancel (ESC key) its editing string.
        public struct ActionHandlers {
            /// The handler that gets called whenever the user tries to cancel (ESC key) its string. Return `true` to allow cancellation. The string will return to it's initial value prior editing. Return `false` to to disallow cancellation. The text will stay in editing state.
            var cancel: ((String) -> (Bool))?
            /// The handler that gets called whenever the user tries to confirm (Enter key) its string. Return `true` to allow the string and `false` if not.
            var confirm: ((String) -> (Bool))?
        }

        /// Handlers that get called whenever the user tries to conform or cancel its string.
        public var actionHandlers = ActionHandlers()

        public func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // let modifierFlags = NSEvent.current?.modifierFlags ?? []

            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if isConforming(stringValue) {
                    self.window?.makeFirstResponder(nil)
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                if actionHandlers.cancel?(stringValue) ?? true {
                    self.isEditing = false
                    self.stringValue = self.previousStringValue
                    self.window?.makeFirstResponder(nil)
                    self.invalidateIntrinsicContentSize()
                    return true
                }
            }

            return false
        }

        var placeholderSize: NSSize? { didSet {
            if let placeholderSize_ = placeholderSize {
                placeholderSize = NSSize(width: ceil(placeholderSize_.width), height: ceil(placeholderSize_.height))
            }
        }}

        var lastContentSize = NSSize() { didSet {
            lastContentSize = NSSize(width: ceil(self.lastContentSize.width), height: ceil(self.lastContentSize.height))
        }}

        override public var stringValue: String { didSet {
            guard !self.isEditing else { return }
            self.lastContentSize = stringValueSize()
        }}

        override public var attributedStringValue: NSAttributedString { didSet {
            guard !self.isEditing else { return }
            self.lastContentSize = stringValueSize()
        }}

        override public var placeholderString: String? { didSet {
            guard oldValue != placeholderString else { return }
            self.placeholderSize = placeholderStringSize()
        }}

        override public var placeholderAttributedString: NSAttributedString? { didSet {
            guard oldValue != placeholderAttributedString else { return }
            self.placeholderSize = placeholderStringSize()
        }}

        override public var font: NSFont? {
            didSet {
                guard !self.isEditing else { return }
                self.lastContentSize = stringValueSize()
                self.placeholderSize = placeholderStringSize()
            }
        }

        func stringValueSize() -> CGSize {
            let stringSize = self.attributedStringValue.size()
            return CGSize(width: stringSize.width, height: super.intrinsicContentSize.height)
        }

        func placeholderStringSize() -> CGSize? {
            let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            var attributedString: NSAttributedString?
            if let placeholderAttributedString = self.placeholderAttributedString {
                attributedString = placeholderAttributedString.font(font)
            } else if let placeholderString = self.placeholderString {
                attributedString = NSAttributedString(string: placeholderString, attributes: [.font: font])
            }
            guard let stringSize = attributedString?.size() else { return nil }
            var placeholderStringSize = CGSize(width: stringSize.width, height: super.intrinsicContentSize.height)
            placeholderStringSize.width += 8.0
            return placeholderStringSize
        }

        var previousStringValue: String = ""
        var previousSelectedRange: NSRange?

        override public func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            self.isEditing = true
            //   self.setupMouseDownMonitor()
            self.previousStringValue = self.stringValue
            self.previousSelectedRange = self._editingSelectedRange
            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            if let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView {
                fieldEditor.insertionPointColor = NSColor.clear
            }
            self.editingStateHandler?(.didBegin)
        }

        override public func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.isEditing = false
            //   self.setupMouseDownMonitor()
            self.editingStateHandler?(.didEnd)
        }

        override public func textDidChange(_ notification: Notification) {
            super.textDidChange(notification)
            let trimmedString = self.trimString(self.stringValue)
            if self.stringValue != trimmedString {
                self.stringValue = trimmedString
            }
            if self.isConforming(self.stringValue) == false {
                self.stringValue = previousStringValue
                self._editingSelectedRange = self.previousSelectedRange
            }
            //   self.previousStringValue = self.stringValue
            self.previousSelectedRange = self._editingSelectedRange

            self.invalidateIntrinsicContentSize()
            self.editingStateHandler?(.changed)
        }

        override public var intrinsicContentSize: NSSize {
            let intrinsicContentSize = super.intrinsicContentSize
            guard automaticallyResizesToFit else { return intrinsicContentSize }
            let minWidth: CGFloat!
            if !self.stringValue.isEmpty {
                minWidth = self.lastContentSize.width
            } else {
                minWidth = ceil(self.placeholderSize?.width ?? 0)
            }

            var minSize = NSSize(width: minWidth, height: intrinsicContentSize.height)
            if let maxWidth = maxWidth, minSize.width >= maxWidth {
                if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: maxWidth, height: 10000)) {
                    minSize.height = cellSize.height + 8.0
                }
                minSize.width = maxWidth
            }

            if let placeholderSize = self.placeholderSize {
                switch resizesToFitPlaceholder {
                case .always:
                    minSize.width = min(placeholderSize.width, minWidth)
                case .emptyText:
                    if stringValue == "" {
                        minSize.width = min(placeholderSize.width, minWidth)
                    }
                case .never: break
                }
            }

            if let minWidth = self.minWidth {
                minSize.width = max(minSize.width, minWidth)
            }

            guard let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView
            else {
                return minSize
            }

            fieldEditor.insertionPointColor = self.textColor ?? NSColor.textColor

            if !self.isEditing {
                return minSize
            }

            if fieldEditor.string.isEmpty {
                self.lastContentSize = minSize
                return minSize
            }

            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            var newWidth = ceil(stringValueSize().width)
            if let minWidth = self.minWidth {
                newWidth = max(newWidth, minWidth)
            }

            var newSize = NSSize(width: newWidth, height: intrinsicContentSize.height)
            if let maxWidth = maxWidth, newSize.width >= maxWidth {
                if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: maxWidth, height: 1000)) {
                    newSize.height = cellSize.height + 8.0
                }
                newSize.width = maxWidth
            }
            self.lastContentSize = newSize
            return newSize
        }
    }

#endif
