//
//  Fitting.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)

import AppKit

/// A text field that automatically resizes to fit it's text.
public class ResizingTextField: NSTextField, NSTextFieldDelegate {
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
    public var automaticallyResizesToFit: Bool = true
    
    /**
     The minimum width of the text field when it automatically resizes to fit its text.
     
     When the text field hits the maximum width, it will automatically grow it's height.
     */
    public var minWidth: CGFloat? = nil {
        didSet { if oldValue != minWidth {
            self.invalidateIntrinsicContentSize() } }
    }
    
    /**
     The maximum width of the text field when it automatically resizes to fit its text.

     When `automaticallyResizesToFit` is enabled and the text field hits the maximum width, it will automatically grow in height.
     */
    public var maxWidth: CGFloat? = nil {
        didSet { if oldValue != maxWidth {
            self.invalidateIntrinsicContentSize() } }
    }
        
    /// A Boolean value that indicates whether the user can enter an empty text.
    public var allowsEmptyString: Bool = false
    /// The minimum amount of characters required when the user edits the text.
    public var minAmountChars: Int? = nil
    /// The maximum amount of characters allowed when the user edits the text.
    public var maxAmountChars: Int? = nil
    
    /// A Boolean value that indicates whether the user is editing the text.
    public private(set) var isEditing = false

    /// The focus type of the text field.
    public var focusType: VerticallyCenteredTextFieldCell.FocusType {
        get { textCell?.focusType ?? .default }
        set { textCell?.focusType = newValue }
    }

    /// The vertical alignment of the displayed text inside the text field.
    public var verticalTextAlignment: VerticallyCenteredTextFieldCell.VerticalAlignment {
        get { textCell?.verticalAlignment ?? .default }
        set { textCell?.verticalAlignment = newValue }
    }

    /// The handler called when the edit state changes.
    public var editingStateHandler: ((EditState) -> Void)?
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _init()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

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

    override public class var cellClass: AnyClass? {
        get { VerticallyCenteredTextFieldCell.self }
        set { super.cellClass = newValue }
    }

    internal var textCell: VerticallyCenteredTextFieldCell? {
        cell as? VerticallyCenteredTextFieldCell
    }

    internal var placeholderSize: NSSize? { didSet {
        if let placeholderSize_ = placeholderSize {
            placeholderSize = NSSize(width: ceil(placeholderSize_.width), height: ceil(placeholderSize_.height))
        }
    }}
    
    internal var lastContentSize = NSSize() { didSet {
        lastContentSize = NSSize(width: ceil(self.lastContentSize.width), height: ceil(self.lastContentSize.height))
    }}

    internal func _init() {
        self.drawsBackground = false
        self.isBordered = false
        self.verticalTextAlignment = .center
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

        self.lastContentSize = stringValueSize()
        self.placeholderSize = placeholderStringSize()
    }

    override public var placeholderString: String? { didSet {
        guard oldValue != placeholderString else { return }
        self.placeholderSize = placeholderStringSize()
        Swift.print("placeholderString.size", self.placeholderSize ?? "nil")
        self.invalidateIntrinsicContentSize()
    }}
    
    public override var placeholderAttributedString: NSAttributedString? { didSet {
        guard let placeholderAttributedString = self.placeholderAttributedString else { return }
        var size = size(placeholderAttributedString)
        size.width = size.width + 8.0
        self.placeholderSize = size
        self.invalidateIntrinsicContentSize()
    }}

    override public var stringValue: String { didSet {
        guard !self.isEditing else { return }
        self.lastContentSize = stringValueSize()
    }}
    
    public override var attributedStringValue: NSAttributedString { didSet {
        guard !self.isEditing else { return }
        self.lastContentSize = size(attributedStringValue)
    }}

    override public var font: NSFont? {
        didSet {
            guard !self.isEditing else { return }
            self.lastContentSize = stringValueSize()
            self.placeholderSize = placeholderStringSize()
        }
    }
    
    internal func stringValueSize() -> CGSize {
        let stringSize = self.attributedStringValue.size()
        return CGSize(width: stringSize.width, height: super.intrinsicContentSize.height)
    }
    
    internal func placeholderStringSize() -> CGSize? {
        let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        var attributedString: NSAttributedString? = nil
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

    internal func size(_ string: String) -> NSSize {
        let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let stringSize = NSAttributedString(string: string, attributes: [.font: font]).size()

        Swift.print("string.Size", NSSize(width: stringSize.width, height: super.intrinsicContentSize.height))
        
        return NSSize(width: stringSize.width, height: super.intrinsicContentSize.height)
    }
    
    internal func size(_ attributedString: NSAttributedString) -> NSSize {
        let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let attributedString = attributedString.font(font)
        let stringSize = attributedString.size()
        Swift.print("attributedString.size", NSSize(width: stringSize.width, height: super.intrinsicContentSize.height))

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
        
        if placeholderString != nil || placeholderAttributedString != nil, let placeholderSize = self.placeholderSize {
            minSize.width = min(placeholderSize.width, minWidth)
            Swift.print("intrinsicContentSize placeholder minSize", minSize)
        }
        
        if let minWidth = self.minWidth {
            minSize.width = max(minSize.width, minWidth)
        }

        guard let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView
        else {
            Swift.print("intrinsicContentSize minSize", minSize)
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
        Swift.print("intrinsicContentSize newSize", minSize)
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
