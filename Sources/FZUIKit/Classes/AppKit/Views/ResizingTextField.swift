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

        /// A Boolean value that indicates whether the user is editing the text.
        public private(set) var isEditing = false

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
            actionOnEnterKeyDown = .endEditing
            actionOnEscapeKeyDown = .endEditingAndReset
            focusType = .roundedCornersRelative(0.5)
            (cell as? NSTextFieldCell)?.setWantsNotificationForMarkedText(true)
            translatesAutoresizingMaskIntoConstraints = false
            // delegate = self

            lastContentSize = stringValueSize()
            placeholderSize = placeholderStringSize()
        }

        override public func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            /*
            if isEditable, canBecome {
                editingStateHandler?(.didBegin)
            }
             */
            return canBecome
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

        override public func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            self.isEditing = true
            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            if let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView {
                fieldEditor.insertionPointColor = NSColor.clear
            }
        }

        override public func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.isEditing = false
        }

        override public func textDidChange(_ notification: Notification) {
            super.textDidChange(notification)
            self.invalidateIntrinsicContentSize()
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
