//
//  NumberTextField.swift
//
//
//  Created by Florian Zand on 14.07.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    @IBDesignable
    public class NumberTextField: NSControl {
        let stepper = NSStepper()
        let textField = NSTextField()

        @IBInspectable var showsStepper: Bool = false {
            didSet { guard oldValue != showsStepper else { return }
                invalidateIntrinsicContentSize()
                needsLayout = true
            }
        }

        public enum NumericStyle {
            case decimal
        }

        public var minValue: Double? {
            didSet { updateTextFormatter() }
        }

        public var maxValue: Double? {
            didSet { updateTextFormatter() }
        }

        public var numericStyle: NumberFormatter.Style = .decimal {
            didSet { updateTextFormatter() }
        }

        @IBInspectable override public var stringValue: String {
            get { textField.stringValue }
            set { textField.stringValue = newValue }
        }

        override public var intValue: Int32 {
            get { Int32(self.stringValue) ?? -1 }
            set { self.stringValue = String(newValue) }
        }

        override public var integerValue: Int {
            get { Int(self.stringValue) ?? -1 }
            set { self.stringValue = String(newValue) }
        }

        override public var doubleValue: Double {
            get { Double(self.stringValue) ?? -1 }
            set { self.stringValue = String(newValue) }
        }

        override public var floatValue: Float {
            get { Float(self.stringValue) ?? -1 }
            set { self.stringValue = String(newValue) }
        }

        override public var attributedStringValue: NSAttributedString {
            get { textField.attributedStringValue }
            set { textField.attributedStringValue = newValue }
        }

        @IBInspectable public var placeholderString: String? {
            get { textField.placeholderString }
            set { textField.placeholderString = newValue }
        }

        public var placeholderAttributedString: NSAttributedString? {
            get { textField.placeholderAttributedString }
            set { textField.placeholderAttributedString = newValue }
        }

        @IBInspectable public var isEditable: Bool {
            get { textField.isEditable }
            set { textField.isEditable = newValue }
        }

        @IBInspectable public var isSelectable: Bool {
            get { textField.isSelectable }
            set { textField.isSelectable = newValue }
        }

        @IBInspectable public var isBezeled: Bool {
            get { textField.isBezeled }
            set { textField.isBezeled = newValue }
        }

        public var bezelStyle: NSTextField.BezelStyle {
            get { textField.bezelStyle }
            set { textField.bezelStyle = newValue }
        }

        @IBInspectable public var isBordered: Bool {
            get { textField.isBordered }
            set { textField.isBordered = newValue }
        }

        public var allowsEditingTextAttributes: Bool {
            get { textField.allowsEditingTextAttributes }
            set { textField.allowsEditingTextAttributes = newValue }
        }

        public var importsGraphics: Bool {
            get { textField.importsGraphics }
            set { textField.importsGraphics = newValue }
        }

        public var preferredMaxLayoutWidth: CGFloat {
            get { _preferredMaxLayoutWidth }
            set { _preferredMaxLayoutWidth = newValue
                updatePreferredMaxLayoutWidth()
            }
        }

        @IBInspectable public var textColor: NSColor? {
            get { textField.textColor }
            set { textField.textColor = newValue }
        }

        @IBInspectable public var backgroundColor: NSColor? {
            get { textField.backgroundColor }
            set { textField.backgroundColor = newValue }
        }

        @IBInspectable public var drawsBackground: Bool {
            get { textField.drawsBackground }
            set { textField.drawsBackground = newValue }
        }

        override public var acceptsFirstResponder: Bool {
            textField.acceptsFirstResponder
        }

        public var delegate: NSTextFieldDelegate? {
            get { textField.delegate }
            set { textField.delegate = newValue }
        }

        override public func layout() {
            super.layout()
            textField.frame.size = frame.size - stepper.intrinsicContentSize.width - spacing
            stepper.frame.origin.x = textField.frame.size.width + spacing
        }

        public init(value: Int, minValue: Int? = nil, maxValue: Int? = nil, frame frameRect: CGRect = .zero) {
            super.init(frame: frameRect)
            sharedInit()
            integerValue = value
            if let minValue = minValue {
                self.minValue = Double(minValue)
            }
            if let maxValue = maxValue {
                self.minValue = Double(maxValue)
            }
            invalidateIntrinsicContentSize()
            frame.size = intrinsicContentSize
        }

        public init(value: Double, minValue: Double? = nil, maxValue: Double? = nil, frame frameRect: CGRect = .zero) {
            super.init(frame: frameRect)
            sharedInit()
            doubleValue = value
            if let minValue = minValue {
                self.minValue = minValue
            }
            if let maxValue = maxValue {
                self.minValue = maxValue
            }
            invalidateIntrinsicContentSize()
            frame.size = intrinsicContentSize
        }

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        let spacing: CGFloat = 2.0
        override public var intrinsicContentSize: NSSize {
            var intrinsicContentSize = textField.intrinsicContentSize
            if showsStepper {
                intrinsicContentSize.width += stepper.intrinsicContentSize.width + spacing
            }
            return intrinsicContentSize
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        func sharedInit() {
            stepper.actionBlock = { _ in
                self.stringValue = String(self.stepper.intValue)
            }
            stepper.invalidateIntrinsicContentSize()
            stepper.frame.size = stepper.intrinsicContentSize

            addSubview(stepper)
            addSubview(textField)

            updatePreferredMaxLayoutWidth()
            updateTextFormatter()

            invalidateIntrinsicContentSize()
            needsLayout = true
        }

        var _preferredMaxLayoutWidth: CGFloat = 0
        func updatePreferredMaxLayoutWidth() {
            if showsStepper {
                textField.preferredMaxLayoutWidth = _preferredMaxLayoutWidth - spacing - stepper.intrinsicContentSize.width
            } else {
                textField.preferredMaxLayoutWidth = _preferredMaxLayoutWidth
            }
        }

        func updateTextFormatter() {
            if numericStyle == .none, minValue == nil, maxValue == nil {
                textField.formatter = nil
            } else {
                let formatter = NumberFormatter()
                if let minValue = minValue {
                    formatter.minimum = NSNumber(minValue)
                }
                if let maxValue = maxValue {
                    formatter.minimum = NSNumber(maxValue)
                }
                formatter.numberStyle = numericStyle
                textField.formatter = formatter
            }
        }
    }

#endif
