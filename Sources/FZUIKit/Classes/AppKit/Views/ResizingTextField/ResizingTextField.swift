//
//  Fitting.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public class ResizingTextField: NSTextField, NSTextFieldDelegate {
        public enum EditState {
            case didBegin
            case didEnd
            case changed
        }

        public var editingStateHandler: ((EditState) -> Void)?

        override public func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable && canBecome {
                editingStateHandler?(.didBegin)
            }
            return canBecome
        }

        internal func isConforming(_ string: String) -> Bool {
            if string == "" && allowsEmptyString == false {
                return false
            } else if let minimumChars = minAmountChars, string.count < minimumChars {
                return false
            } else if let maxAmountChars = maxAmountChars, string.count > maxAmountChars {
                return false
            }
            return true
        }

        public func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if isConforming(stringValue) {
                    self.window?.makeFirstResponder(nil)
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                self.isEditing = false
                self.stringValue = self.previousStringValue
                self.window?.makeFirstResponder(nil)
                self.invalidateIntrinsicContentSize()
                return true
            }
            return false
        }

        private(set) var isEditing = false

        override public class var cellClass: AnyClass? {
            get { VerticallyCenteredTextFieldCell.self }
            set { super.cellClass = newValue }
        }

        internal var textCell: VerticallyCenteredTextFieldCell? {
            cell as? VerticallyCenteredTextFieldCell
        }

        public var focusType: VerticallyCenteredTextFieldCell.FocusType {
            get { textCell?.focusType ?? .default }
            set { textCell?.focusType = newValue }
        }

        public var verticalAlignment: VerticallyCenteredTextFieldCell.VerticalAlignment {
            get { textCell?.verticalAlignment ?? .default }
            set { textCell?.verticalAlignment = newValue }
        }

        internal var placeholderSize: NSSize? { didSet {
            if let placeholderSize_ = placeholderSize {
                placeholderSize = NSSize(width: ceil(placeholderSize_.width), height: ceil(placeholderSize_.height))
            }
        }}
        internal var lastContentSize = NSSize() { didSet {
            lastContentSize = NSSize(width: ceil(self.lastContentSize.width), height: ceil(self.lastContentSize.height))
        }}

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            _init()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            _init()
        }

        internal func _init() {
            self.drawsBackground = false
            self.isBordered = false
            self.verticalAlignment = .center
            self.focusType = .roundedCornersRelative(0.5)
            textCell?.setWantsNotificationForMarkedText(true)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.delegate = self

            #if DEBUG
                // self.wantsLayer = true
                // self.layer?.setBorder(with: NSColor.red.cgColor)
            #endif
        }

        override public func awakeFromNib() {
            super.awakeFromNib()
            self._init()
            // If you use `.byClipping`, the width calculation does not seem to be done correctly.
            self.cell?.isScrollable = true
            self.cell?.wraps = true
            self.lineBreakMode = .byTruncatingTail

            self.lastContentSize = size(self.stringValue)
            if let placeholderString = self.placeholderString {
                self.placeholderSize = size(placeholderString)
            }
        }

        public var allowsEmptyString: Bool = false
        public var minAmountChars: Int? = nil
        public var maxAmountChars: Int? = nil
        public var maxWidth: CGFloat? = nil

        override public var placeholderString: String? { didSet {
            guard let placeholderString = self.placeholderString else { return }
            var size = size(placeholderString)
            size.width = size.width + 8.0
            self.placeholderSize = size
        }}

        override public var stringValue: String { didSet {
            if self.isEditing { return }
            self.lastContentSize = size(stringValue)
        }}

        override public var font: NSFont? {
            didSet {
                if self.isEditing { return }
                self.lastContentSize = size(stringValue)
            }
        }

        internal func size(_ string: String) -> NSSize {
            let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            let stringSize = NSAttributedString(string: string, attributes: [.font: font]).size()

            return NSSize(width: stringSize.width, height: super.intrinsicContentSize.height)
        }

        internal var previousStringValue: String = ""
        internal var previousCharStringValue: String = ""
        internal var previousSelectedRange: NSRange? = nil

        override public func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            if stopsEditingOnOutsideMouseDown {
                self.addMouseDownMonitor()
            }
            self.isEditing = true
            self.previousStringValue = self.stringValue
            self.previousCharStringValue = self.stringValue
            self.previousSelectedRange = self.editingSelectedRange
            // This is a tweak to fix the problem of insertion points being drawn at the wrong position.
            if let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView {
                fieldEditor.insertionPointColor = NSColor.clear
            }
            self.editingStateHandler?(.didBegin)
        }

        override public func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.removeMouseDownMonitor()
            self.isEditing = false
            self.editingStateHandler?(.didEnd)
        }

        var editingCursorLocation: Int? {
            let currentEditor = self.currentEditor() as? NSTextView
            return currentEditor?.selectedRanges.first?.rangeValue.location
        }

        var editingSelectedRange: NSRange? {
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

        override public func textDidChange(_ notification: Notification) {
            super.textDidChange(notification)
            if let minAmountChars = minAmountChars, self.stringValue.count < minAmountChars {
                if previousStringValue.count > self.stringValue.count {
                    self.stringValue = previousStringValue
                    self.editingSelectedRange = self.previousSelectedRange
                }
            } else if let maxAmountChars = maxAmountChars, self.stringValue.count > maxAmountChars {
                if previousStringValue.count < self.stringValue.count {
                    self.stringValue = previousStringValue
                    self.editingSelectedRange = self.previousSelectedRange
                }
            }
            //   self.previousStringValue = self.stringValue
            self.previousSelectedRange = self.editingSelectedRange

            self.invalidateIntrinsicContentSize()
            self.editingStateHandler?(.changed)
        }

        public var shouldAutoSize: Bool = true

        override public var intrinsicContentSize: NSSize {
            let intrinsicContentSize = super.intrinsicContentSize
            if shouldAutoSize == false {
                return intrinsicContentSize
            }

            let minWidth: CGFloat!
            if !self.stringValue.isEmpty {
                minWidth = self.lastContentSize.width
            } else {
                minWidth = ceil(self.placeholderSize?.width ?? 0)
            }

            var minSize = NSSize(width: minWidth, height: intrinsicContentSize.height)
            if let maxWidth = maxWidth, minSize.width >= maxWidth {
                if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: maxWidth, height: 1000)) {
                    minSize.height = cellSize.height + 8.0
                }
                minSize.width = maxWidth
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
            let newWidth = ceil(size(self.stringValue).width)
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

        public var stopsEditingOnOutsideMouseDown = false
        internal var mouseDownMonitor: Any? = nil
        internal func addMouseDownMonitor() {
            if mouseDownMonitor == nil {
                mouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown, handler: { event in
                    let point = event.location(in: self)
                    if self.bounds.contains(point) == false {
                        if self.isConforming(self.stringValue) {
                            self.window?.makeFirstResponder(nil)
                        } else {
                            self.stringValue = self.previousStringValue
                            self.window?.makeFirstResponder(nil)
                        }
                    }
                    return event
                })
            }
        }

        internal func removeMouseDownMonitor() {
            if let mouseDownMonitor = mouseDownMonitor {
                NSEvent.removeMonitor(mouseDownMonitor)
                self.mouseDownMonitor = nil
            }
        }
    }

#endif
