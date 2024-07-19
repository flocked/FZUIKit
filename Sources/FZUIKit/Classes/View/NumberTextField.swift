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
    /// A text field for numbers that shows optionally a stepper.
    public class NumberTextField: NSControl {
        let stepper = NSStepper()
        let textField = NSTextField.editing()
        
        enum NumericStyle {
            case decimal
        }
        
        var numericStyle: NumberFormatter.Style = .decimal {
            didSet { updateTextFormatter() }
        }

        /// A Boolean value that indicates whether the text field shows a stepper next to it.
        @IBInspectable var showsStepper: Bool = false {
            didSet {
                guard oldValue != showsStepper else { return }
                invalidateIntrinsicContentSize()
                needsLayout = true
            }
        }
        
        public override var controlSize: NSControl.ControlSize {
            didSet {
                stepper.controlSize = controlSize
            }
        }
        
        /// Sets the Boolean value that indicates whether the text field shows a stepper next to it.
        @discardableResult
        public func showsStepper(_ showsStepper: Bool) -> Self {
            self.showsStepper = showsStepper
            return self
        }

        /// The lowest number allowed as input by the text field.
        public var minValue: Double? {
            didSet { updateTextFormatter() }
        }
        
        /// Sets the lowest number allowed as input by the text field.
        @discardableResult
        public func minValue(_ minValue: Double?) -> Self {
            self.minValue = minValue
            return self
        }

        /// The highest number allowed as input by the text field.
        public var maxValue: Double? {
            didSet { updateTextFormatter() }
        }
        
        /// Sets the highest number allowed as input by the text field.
        @discardableResult
        public func maxValue(_ maxValue: Double?) -> Self {
            self.maxValue = maxValue
            return self
        }

        @IBInspectable override public var stringValue: String {
            get { textField.stringValue }
            set { textField.stringValue = newValue }
        }

        override public var intValue: Int32 {
            get { textField.intValue }
            set { textField.intValue = newValue }
        }

        override public var integerValue: Int {
            get { textField.integerValue }
            set { textField.integerValue = newValue }
        }

        override public var doubleValue: Double {
            get { textField.doubleValue }
            set { textField.doubleValue = newValue }
        }

        override public var floatValue: Float {
            get { textField.floatValue }
            set { textField.floatValue = newValue }
        }

        override public var attributedStringValue: NSAttributedString {
            get { textField.attributedStringValue }
            set { textField.attributedStringValue = newValue }
        }

        /// The string the text field displays when empty to help the user understand the text field’s purpose.
        @IBInspectable public var placeholderString: String? {
            get { textField.placeholderString }
            set { textField.placeholderString = newValue }
        }
        
        /// Sets the string the text field displays when empty to help the user understand the text field’s purpose.
        @discardableResult
        public func placeholderString(_ placeholder: String?) -> Self {
            self.placeholderString = placeholder
            return self
        }

        /// The attributed string the text field displays when empty to help the user understand the text field’s purpose.
        public var placeholderAttributedString: NSAttributedString? {
            get { textField.placeholderAttributedString }
            set { textField.placeholderAttributedString = newValue }
        }
        
        /// Sets the attributed string the text field displays when empty to help the user understand the text field’s purpose.
        @discardableResult
        public func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
            self.placeholderAttributedString = placeholder
            return self
        }

        /// A Boolean value that controls whether the user can edit the value in the text field.
        @IBInspectable public var isEditable: Bool {
            get { textField.isEditable }
            set { textField.isEditable = newValue }
        }
        
        /// Sets the Boolean value that controls whether the user can edit the value in the text field.
        @discardableResult
        public func isEditable(_ isEditable: Bool) -> Self {
            self.isEditable = isEditable
            return self
        }
        
        @IBInspectable public override var isEnabled: Bool {
            get { textField.isEnabled }
            set {
                textField.isEnabled = newValue
                stepper.isEnabled = newValue
            }
        }

        /// A Boolean value that determines whether the user can select the content of the text field.
        @IBInspectable public var isSelectable: Bool {
            get { textField.isSelectable }
            set { textField.isSelectable = newValue }
        }
        
        /// Sets the Boolean value that determines whether the user can select the content of the text field.
        @discardableResult
        public func isSelectable(_ isSelectable: Bool) -> Self {
            self.isSelectable = isSelectable
            return self
        }
        
        /// The text field bezel.
        public enum BezelType: Int, Hashable {
            /// Square bezel.
            case square
            /// Rounded bezel.
            case rounded
            /// No bezel.
            case none
            
            var style: NSTextField.BezelStyle {
                self == .square ? .squareBezel : .roundedBezel
            }
            var isBezeled: Bool {
                self != .none
            }
        }
        
        /// The bezel type of the text field.
        public var bezelType: BezelType = .none {
            didSet {
                textField.bezelStyle = bezelType.style
                textField.isBezeled = bezelType.isBezeled
                textField.isBordered = bezelType.isBezeled
            }
        }
        
        /// Sets the bezel type of the text field.
        @discardableResult
        public func bezel(_ type: BezelType) -> Self {
            self.bezelType = type
            return self
        }

        public var allowsEditingTextAttributes: Bool {
            get { textField.allowsEditingTextAttributes }
            set { textField.allowsEditingTextAttributes = newValue }
        }

        public var importsGraphics: Bool {
            get { textField.importsGraphics }
            set { textField.importsGraphics = newValue }
        }

        /// The maximum width of the text field’s intrinsic content size.
        public var preferredMaxLayoutWidth: CGFloat = 0 {
            didSet { updatePreferredMaxLayoutWidth() }
        }
        
        /// Sets the maximum width of the text field’s intrinsic content size.
        @discardableResult
        public func preferredMaxLayoutWidth(_ width: CGFloat) -> Self {
            self.preferredMaxLayoutWidth = width
            return self
        }

        /// The text color.
        @IBInspectable public var textColor: NSColor {
            get { textField.textColor ?? .labelColor }
            set { textField.textColor = newValue }
        }
        
        /// Sets the text color.
        @discardableResult
        public func textColor(_ color: NSColor) -> Self {
            self.textColor = color
            return self
        }
        
        
        @IBInspectable public var backgroundColor: NSColor? {
            get { textField.backgroundColor }
            set { 
                textField.backgroundColor = newValue
                textField.drawsBackground = newValue != nil
            }
        }
        
        /// Sets the highest number allowed as input by the text field.
        @discardableResult
        public func backgroundColor(_ color: NSColor?) -> Self {
            self.backgroundColor = color
            return self
        }

        override public var acceptsFirstResponder: Bool {
            textField.acceptsFirstResponder
        }

        /// The text field’s delegate.
        public var delegate: NSTextFieldDelegate? {
            get { textField.delegate }
            set { textField.delegate = newValue }
        }
        
        /// Sets the text field’s delegate.
        @discardableResult
        public func delegate(_ delegate: NSTextFieldDelegate?) -> Self {
            self.delegate = delegate
            return self
        }
        
        /// The handlers for editing the text.
        public var editingHandlers: NSTextField.EditingHandler {
            get { textField.editingHandlers }
            set { textField.editingHandlers = newValue }
        }
        
        /// The action to perform when the user presses the enter key while editing the text field.
        public var editingActionOnEnterKeyDown: NSTextField.EnterKeyAction {
            get { textField.editingActionOnEnterKeyDown }
            set { textField.editingActionOnEnterKeyDown = newValue }
        }
        
        /// Sets the action to perform when the user presses the enter key while editing the text field.
        @discardableResult
        public func editingActionOnEnterKeyDown(_ enterAction: NSTextField.EnterKeyAction) -> Self {
            editingActionOnEnterKeyDown = enterAction
            return self
        }
        
        /// The action to perform when the user presses the escape key while editing the text field.
        public var editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction {
            get { textField.editingActionOnEscapeKeyDown }
            set { textField.editingActionOnEscapeKeyDown = newValue }
        }
        
        /// Sets the action to perform when the user presses the escape key while editing the text field.
        @discardableResult
        public func editingActionOnEscapeKeyDown(_ escapeAction: NSTextField.EscapeKeyAction) -> Self {
            editingActionOnEscapeKeyDown = escapeAction
            return self
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
            stepper.sizeToFit()
            stepper.actionBlock = { [weak self] stepper in
                guard let self = self else { return }
                self.integerValue = stepper.integerValue
            }

            addSubview(stepper)
            addSubview(textField)

            updatePreferredMaxLayoutWidth()
            updateTextFormatter()

            invalidateIntrinsicContentSize()
            needsLayout = true
        }

        func updatePreferredMaxLayoutWidth() {
            if showsStepper {
                textField.preferredMaxLayoutWidth = preferredMaxLayoutWidth - spacing - stepper.intrinsicContentSize.width
            } else {
                textField.preferredMaxLayoutWidth = preferredMaxLayoutWidth
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
                    formatter.maximum = NSNumber(maxValue)
                }
                formatter.numberStyle = numericStyle
                textField.formatter = formatter
            }
        }
    }

#endif
