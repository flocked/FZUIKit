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
    internal let stepper = NSStepper()
    internal let textField = NSTextField()

    @IBInspectable var showsStepper: Bool = false {
        didSet { guard oldValue != self.showsStepper else { return }
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
        }
    }

    public enum NumericStyle {
        case decimal
    }

    public var minValue: Double? {
        didSet { self.updateTextFormatter() }
    }

    public var maxValue: Double? {
        didSet { self.updateTextFormatter() }
    }

    public var numericStyle: NumberFormatter.Style = .decimal {
        didSet { self.updateTextFormatter() }
    }

    @IBInspectable public override var stringValue: String {
        get { textField.stringValue }
        set { textField.stringValue = newValue }
    }

    public override var intValue: Int32 {
        get { Int32(self.stringValue) ?? -1 }
        set { self.stringValue = String(newValue) }
    }

    public override var integerValue: Int {
        get { Int(self.stringValue) ?? -1 }
        set { self.stringValue = String(newValue) }
    }

    public override var doubleValue: Double {
        get { Double(self.stringValue) ?? -1 }
        set { self.stringValue = String(newValue) }
    }

    public override var floatValue: Float {
        get { Float(self.stringValue) ?? -1 }
        set { self.stringValue = String(newValue) }
    }

    public override var attributedStringValue: NSAttributedString {
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
            self.updatePreferredMaxLayoutWidth()}
    }

    @IBInspectable public var textColor: NSColor? {
        get { textField.textColor}
        set { textField.textColor = newValue }
    }

    @IBInspectable public var backgroundColor: NSColor? {
        get { textField.backgroundColor}
        set { textField.backgroundColor = newValue }
    }

    @IBInspectable public var drawsBackground: Bool {
        get { textField.drawsBackground }
        set { textField.drawsBackground = newValue }
    }

    public override var acceptsFirstResponder: Bool {
        return textField.acceptsFirstResponder
    }

    public var delegate: NSTextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }

    public override func layout() {
        super.layout()
        self.textField.frame.size = self.frame.size - stepper.intrinsicContentSize.width - spacing
        self.stepper.frame.origin.x =  self.textField.frame.size.width + spacing
    }

    public init(value: Int, minValue: Int? = nil, maxValue: Int? = nil, frame frameRect: CGRect = .zero) {
        super.init(frame: frameRect)
        self.sharedInit()
        self.integerValue = value
        if let minValue = minValue {
            self.minValue = Double(minValue)
        }
        if let maxValue = maxValue {
            self.minValue = Double(maxValue)
        }
        self.invalidateIntrinsicContentSize()
        self.frame.size =  self.intrinsicContentSize
    }

    public init(value: Double, minValue: Double? = nil, maxValue: Double? = nil, frame frameRect: CGRect = .zero) {
        super.init(frame: frameRect)
        self.sharedInit()
        self.doubleValue = value
        if let minValue = minValue {
            self.minValue = minValue
        }
        if let maxValue = maxValue {
            self.minValue = maxValue
        }
        self.invalidateIntrinsicContentSize()
        self.frame.size = self.intrinsicContentSize
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.sharedInit()
    }

    internal let spacing: CGFloat = 2.0
    public override var intrinsicContentSize: NSSize {
        var intrinsicContentSize = textField.intrinsicContentSize
        if self.showsStepper {
            intrinsicContentSize.width += stepper.intrinsicContentSize.width + spacing
        }
        return intrinsicContentSize
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }

    internal func sharedInit() {
        stepper.actionBlock = { _ in
            self.stringValue = String(self.stepper.intValue)
        }
        stepper.invalidateIntrinsicContentSize()
        stepper.frame.size = stepper.intrinsicContentSize

        self.addSubview(stepper)
        self.addSubview(textField)

        self.updatePreferredMaxLayoutWidth()
        self.updateTextFormatter()

        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
    }

    internal var _preferredMaxLayoutWidth: CGFloat = 0
    internal func updatePreferredMaxLayoutWidth() {
        if self.showsStepper {
            self.textField.preferredMaxLayoutWidth = _preferredMaxLayoutWidth - spacing - stepper.intrinsicContentSize.width
        } else {
            self.textField.preferredMaxLayoutWidth = _preferredMaxLayoutWidth
        }
    }

    internal func updateTextFormatter() {
        if self.numericStyle == .none, minValue == nil, maxValue == nil {
            self.textField.formatter = nil
        } else {
            let formatter = NumberFormatter()
            if let minValue = self.minValue {
                formatter.minimum = NSNumber(minValue)
            }
            if let maxValue = self.maxValue {
                formatter.minimum = NSNumber(maxValue)
            }
            formatter.numberStyle = self.numericStyle
            self.textField.formatter = formatter
        }
    }
}

#endif
