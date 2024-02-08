//
//  ResizingTextField.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)

    import AppKit

    /// A text field that automatically resizes to fit it's text.
    open class ResizingTextField: NSTextField {
        
        /// A Boolean value that indicates whether the text field automatically resizes to fit it's text.
        public override var automaticallyResizesToFit: Bool {
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
        public enum PlaceHolderResizeOption: Int, Hashable {
            /// Resizes the text field to always fit the placeholder.
            case always
            /// Resizes the text field to fit the placeholder if the text is an empty string ("").
            case emptyText
            /// Never resizes the text field to fit the placeholder.
            case never
        }

        /**
         The minimum width of the text field when it automatically resizes to fit its text.

         When ``automaticallyResizesToFit`` is enabled, the minimum width is limited to this value.
         */
        public var minWidth: CGFloat? {
            didSet { 
                if oldValue != minWidth {
                    invalidateIntrinsicContentSize()
                }
            }
        }

        /**
         The maximum width of the text field when it automatically resizes to fit its text.

         When ``automaticallyResizesToFit`` is enabled and the text field hits the maximum width, it will automatically grow in height.
         */
        public var maxWidth: CGFloat? {
            didSet {
                if oldValue != maxWidth {
                    invalidateIntrinsicContentSize()
                }
            }
        }

        public var isEditing = false

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }
        
        /// Initializes a text field for use as a multiline static label with selectable text that uses the system default font.
         public init(wrappingLabelWithString stringValue: String) {
             super.init(frame: .zero)
             sharedInit()
             self.stringValue = stringValue
        }
        
        public init(labelWithString stringValue: String) {
            super.init(frame: .zero)
            sharedInit()
            self.stringValue = stringValue
        }

        public init(string: String) {
            super.init(frame: .zero)
            sharedInit()
            stringValue = string
        }
        
        public init(labelWithAttributedString attributedStringValue: NSAttributedString) {
            super.init(frame: .zero)
            sharedInit()
            self.attributedStringValue = attributedStringValue
        }

        var observations: [NSKeyValueObservation] = []
        func sharedInit() {
            drawsBackground = false
            isBordered = false
            textLayout = .wraps
            
            observations.append(
                observeChanges(for: \.font) { [weak self] old, new in
                    guard let self = self, !self.isEditing else { return }
                    self.lastContentSize = self.stringValueSize()
                    self.placeholderSize = self.placeholderStringSize()
                    self.invalidateIntrinsicContentSize()
                }
            )
            
            verticalTextAlignment = .center
            actionOnEnterKeyDown = .endEditing
            actionOnEscapeKeyDown = .endEditingAndReset
            focusType = .roundedCorners(4.0)
            (cell as? NSTextFieldCell)?.setWantsNotificationForMarkedText(true)
            translatesAutoresizingMaskIntoConstraints = false

            lastContentSize = stringValueSize()
            placeholderSize = placeholderStringSize()
            automaticallyResizesToFit = true
            invalidateIntrinsicContentSize()
            
            Swift.print("Shared Init", stringValue)
        }

        var placeholderSize: CGSize? {
            didSet {
                if let placeholderSize_ = placeholderSize {
                    placeholderSize = CGSize(width: ceil(placeholderSize_.width), height: ceil(placeholderSize_.height))
                }
            }
        }

        public var lastContentSize = CGSize() {
            didSet {
                lastContentSize = CGSize(width: ceil(lastContentSize.width), height: ceil(lastContentSize.height))
            }
        }

        override public var stringValue: String {
            didSet {
                Swift.print("didSet stringValue")
                guard !isEditing else { return }
                lastContentSize = stringValueSize()
            }
        }

        override public var attributedStringValue: NSAttributedString {
            didSet {
                guard !isEditing else { return }
                lastContentSize = stringValueSize()
            }
        }

        override public var placeholderString: String? {
            didSet {
                guard oldValue != placeholderString else { return }
                placeholderSize = placeholderStringSize()
            }
        }

        override public var placeholderAttributedString: NSAttributedString? {
            didSet {
                guard oldValue != placeholderAttributedString else { return }
                placeholderSize = placeholderStringSize()
            }
        }

        override public var font: NSFont? {
            didSet {
                Swift.print("font0", lastContentSize, isEditing)
                guard !isEditing else { return }
                lastContentSize = stringValueSize()
                Swift.print("font1", lastContentSize)
                placeholderSize = placeholderStringSize()
                Swift.print("font2", lastContentSize)

                invalidateIntrinsicContentSize()
                Swift.print("font3", lastContentSize)
            }
        }

        public func stringValueSize() -> CGSize {
            let stringSize = attributedStringValue.size()
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
            isEditing = true
            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            if let fieldEditor = window?.fieldEditor(false, for: self) as? NSTextView {
                fieldEditor.insertionPointColor = NSColor.clear
            }
        }

        override public func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            isEditing = false
        }

        override public func textDidChange(_ notification: Notification) {
            super.textDidChange(notification)
            invalidateIntrinsicContentSize()
        }

        override public var intrinsicContentSize: CGSize {
            let intrinsicContentSize = super.intrinsicContentSize
            guard automaticallyResizesToFit else { return intrinsicContentSize }
            let minWidth: CGFloat!
            if !stringValue.isEmpty {
                Swift.print("intrinsicContentSize X1")
                minWidth = lastContentSize.width
            } else {
                Swift.print("intrinsicContentSize X2")
                minWidth = ceil(placeholderSize?.width ?? 0)
            }

            var minSize = CGSize(width: minWidth, height: intrinsicContentSize.height)
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

            guard let fieldEditor = window?.fieldEditor(false, for: self) as? NSTextView
            else {
                Swift.print("intrinsicContentSize 0")
                return minSize
            }

            fieldEditor.insertionPointColor = textColor ?? NSColor.textColor

            if !isEditing {
                Swift.print("intrinsicContentSize 1", lastContentSize)
                return minSize
            }

            if fieldEditor.string.isEmpty {
                lastContentSize = minSize
                Swift.print("intrinsicContentSize 2")
                return minSize
            }

            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            var newWidth = ceil(stringValueSize().width)
            if let minWidth = self.minWidth {
                Swift.print("intrinsicContentSize X3")
                newWidth = max(newWidth, minWidth)
            }

            var newSize = CGSize(width: newWidth, height: intrinsicContentSize.height)
            if let maxWidth = maxWidth, newSize.width >= maxWidth {
                if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: maxWidth, height: 1000)) {
                    newSize.height = cellSize.height + 8.0
                }
                newSize.width = maxWidth
            }
            lastContentSize = newSize
            Swift.print("intrinsicContentSize 3")
            return newSize
        }
    }

#endif
