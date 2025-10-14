//
//  LabeledControlView.swift
//
//
//  Created by Florian Zand on 14.10.25.
//  Copyright © 2025 lhc. All rights reserved.
//

#if os(macOS)
import Cocoa
import FZSwiftUtils

/// A container view for an `NSControl` that can display optional leading and trailing labels and images.
public class LabeledControlView: NSView {
  
    private let stackView = NSStackView().orientation(.horizontal).spacing(6).alignment(.centerY).translatesAutoresizingMaskIntoConstraints(false)
    private let leadingTextField = NSTextField.label().isHidden(true).alignment(.right).lineBreakMode(.byCharWrapping)
    private let trailingTextField = NSTextField.label().isHidden(true).alignment(.left).lineBreakMode(.byCharWrapping)
    private let leadingImageView = NSImageView().isHidden(true).imageScaling(.scaleNone)
    private let trailingImageView = NSImageView().isHidden(true).imageScaling(.scaleNone)
    private var controlSizeConstraint: NSLayoutConstraint?
    private var leadingTextWidthConstraint: NSLayoutConstraint?
    private var trailingTextWidthConstraint: NSLayoutConstraint?
    private var controlSizeHook: Hook?
    
    /// Represents the width of the leading or trailing text.
    public enum TextWidth: Hashable, ExpressibleByFloatLiteral, ExpressibleByStringLiteral {
        /// A fixed width.
        case fixed(CGFloat)
        /// The width is calculated dynamically based on the given reference text and the control's `controlSize`.
        case referenceText(String)
        /// The width is automatically sized to fit the label's content.
        case automatically
      
        public init(floatLiteral value: Double) {
            self = .fixed(value)
        }
      
        public init(stringLiteral value: String) {
            self = .referenceText(value)
        }
    }

    /// The control.
    public var control: NSControl {
        didSet {
            guard oldValue != control else { return }
            controlSizeHook?.isActive = false
            update()
        }
    }

    /// The text leading the control.
    public var leadingText: String? {
        get { leadingTextField.stringValue == "" ? nil : leadingTextField.stringValue }
        set {
            leadingTextField.stringValue = newValue ?? ""
            leadingTextField.isHidden = newValue == nil
        }
    }
  
    /// The text trailing the control.
    public var trailingText: String? {
        get { trailingTextField.stringValue == "" ? nil : leadingTextField.stringValue }
        set {
            trailingTextField.stringValue = newValue ?? ""
            trailingTextField.isHidden = newValue == nil
        }
    }
  
    /**
     The width of the leading text.
   
     The default value is ``TextWidth/automatically`` which automatically sizes the width to fit ``leadingText``-
     */
    public var leadingTextWidth: TextWidth = .automatically {
        didSet {
            guard oldValue != leadingTextWidth else { return }
            updateTextWidths()
        }
    }
  
    /**
     The width of the trailing text.
   
     The default value is ``TextWidth/automatically`` which automatically sizes the width to fit ``trailingText``-
     */
    public var trailingTextWidth: TextWidth = .automatically {
        didSet {
            guard oldValue != trailingTextWidth else { return }
            updateTextWidths()
        }
    }

    /// The color of the text leading the control.
    public var leadingTextColor: NSColor {
        get { leadingTextField.textColor ?? .labelColor }
        set { leadingTextField.textColor = newValue }
    }
  
    /// The color of the text trailing the control.
    public var trailingTextColor: NSColor {
        get { trailingTextField.textColor ?? .labelColor }
        set { trailingTextField.textColor = newValue }
    }
  
    /// The image leading the control.
    public var leadingImage: NSImage? {
        get { leadingImageView.image }
        set {
            leadingImageView.image = newValue
            leadingImageView.isHidden = newValue == nil
        }
    }
  
    /// The image trailing the control.
    public var trailingImage: NSImage? {
        get { trailingImageView.image }
        set {
            trailingImageView.image = newValue
            trailingImageView.isHidden = newValue == nil
        }
    }
  
    /// The symbol configuration of the image leading the control.
    @available(macOS 11.0, *)
    public var leadingImageSymbolConfiguration: NSImage.SymbolConfiguration? {
        get { leadingImageView.symbolConfiguration }
        set { leadingImageView.symbolConfiguration = newValue }
    }
  
    /// The symbol configuration of the image trailing the control.
    @available(macOS 11.0, *)
    public var trailingImageSymbolConfiguration: NSImage.SymbolConfiguration? {
        get { trailingImageView.symbolConfiguration }
        set { trailingImageView.symbolConfiguration = newValue }
    }
  
    /// The leading image scaling.
    public var leadingImageScaling: NSImageScaling {
        get { leadingImageView.imageScaling }
        set { leadingImageView.imageScaling = newValue }
    }
  
    /// The trailing image scaling.
    public var trailingImageScaling: NSImageScaling {
        get { trailingImageView.imageScaling }
        set { trailingImageView.imageScaling = newValue }
    }
  
    /// The tint color of the image leading the control.
    public var leadingImageTintColor: NSColor? {
        get { leadingImageView.contentTintColor }
        set { leadingImageView.contentTintColor = newValue }
    }
  
    /// The tint color of the image trailing the control.
    public var trailingImageTintColor: NSColor? {
        get { trailingImageView.contentTintColor }
        set { trailingImageView.contentTintColor = newValue }
    }

    /**
     The minimum width of the control.
   
     The default value is `nil`.
     */
    public var minControlSize: CGFloat? {
        get { controlSizeConstraint?.constant }
        set {
            controlSizeConstraint?.activate(false)
            if let newValue = newValue {
                controlSizeConstraint = (orientation == .horizontal ? control.widthAnchor.constraint(greaterThanOrEqualToConstant: newValue) : control.heightAnchor.constraint(greaterThanOrEqualToConstant: newValue)).activate()
            }
        }
    }
  
    /**
     The orientation/placement of the leading and trailing text.
   
     If set to `horizontal`, the texts and images are to the left and right of the control, otherwise to the bottom and top.
   
     The default value is `horizontal`.
     */
    public var orientation: NSUserInterfaceLayoutOrientation {
        get { stackView.orientation }
        set {
            guard newValue != orientation else { return }
            stackView.orientation = newValue
            stackView.alignment = newValue == .horizontal ? .centerY : .centerX
            minControlSize = minControlSize
        }
    }

    /**
     Creates a `LabeledControlView` with the specified control and optional leading and trailing texts.
     
     - Parameters:
        - control: The control.
        - leadingText: The text leading the control.
        - trailingText: The text trailing the control.
     */
    public init(control: NSControl, leadingText: String? = nil, trailingText: String? = nil) {
        self.control = control
        super.init(frame: .zero)
        self.leadingText = leadingText
        self.trailingText = trailingText
        addSubview(withConstraint: stackView)
        update()
        sizeToFit()
    }
  
    private func updateFontSizes() {
        leadingTextField.font = .systemFont(ofSize: NSFont.systemFontSize(for: control.controlSize))
        trailingTextField.font = leadingTextField.font
        updateTextWidths()
    }
  
    private var fittingMinWidth: CGFloat {
        control is NSSlider ? 200.0 : control.intrinsicContentSize.width
    }
  
    private func updateTextWidths() {
        leadingTextWidthConstraint?.activate(false)
        switch leadingTextWidth {
        case .fixed(let value):
            leadingTextWidthConstraint  = leadingTextField.widthAnchor.constraint(equalToConstant: value).activate()
        case .referenceText(let text):
            let leadingText = leadingText
            self.leadingText = text
            leadingTextWidthConstraint = leadingTextField.widthAnchor.constraint(equalToConstant: leadingTextField.fittingSize.width).activate()
            self.leadingText = leadingText
        case .automatically:
            break
        }
    
        trailingTextWidthConstraint?.activate(false)
        switch trailingTextWidth {
        case .fixed(let value):
            trailingTextWidthConstraint  = trailingTextField.widthAnchor.constraint(equalToConstant: value).activate()
        case .referenceText(let text):
            let trailingText = trailingText
            self.trailingText = text
            trailingTextWidthConstraint = trailingTextField.widthAnchor.constraint(equalToConstant: trailingTextField.fittingSize.width).activate()
            self.trailingText = trailingText
        case .automatically:
            break
        }
    }
  
    private func update() {
        if let slider = control as? NSSlider {
            orientation = slider.isVertical ? .vertical : .horizontal
        }
        updateFontSizes()
        stackView.arrangedViews = [leadingImageView, leadingTextField, control, trailingTextField, trailingImageView]
        do {
            controlSizeHook = try control.cell?.hookAfter(set: \.controlSize) { [weak self] cell, size in
                guard let self = self else { return }
                self.updateFontSizes()
            }
        } catch {
            Swift.print(error)
        }
    }
  
    public override var intrinsicContentSize: NSSize {
        stackView.intrinsicContentSize
    }
  
    public override var fittingSize: NSSize {
        stackView.fittingSize
    }
  
    public func sizeToFit() {
        frame.size = fittingSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    deinit {
        controlSizeHook?.isActive = false
    }
}

extension LabeledControlView {
    /// Sets the text leading the control.
    @discardableResult
    public func leadingText(_ text: String?) -> Self {
        self.leadingText = text
        return self
    }
  
    /// Sets the text trailing the control.
    @discardableResult
    public func trailingText(_ text: String?) -> Self {
        self.trailingText = text
        return self
    }
  
    /**
     Sets the width of the leading text.
   
     The default value is ``TextWidth/automatically``.
     */
    @discardableResult
    public func leadingTextWidth(_ width: TextWidth) -> Self {
        self.leadingTextWidth = width
        return self
    }
  
    /**
     Sets the width of the trailing text.
   
     The default value is ``TextWidth/automatically``.
     */
    @discardableResult
    public func trailingTextWidth(_ width: TextWidth) -> Self {
        self.trailingTextWidth = width
        return self
    }
    
    /// Sets the color of the text leading the control.
    @discardableResult
    public func leadingTextColor(_ color: NSColor) -> Self {
        self.leadingTextColor = color
        return self
    }
  
    /// Sets the color of the text trailing the control.
    @discardableResult
    public func trailingTextColor(_ color: NSColor) -> Self {
        self.trailingTextColor = color
        return self
    }
  
    /// Sets the image leading the control.
    @discardableResult
    public func leadingImage(_ image: NSImage?) -> Self {
        self.leadingImage = image
        return self
    }
  
    /// Sets the image trailing the control.
    @discardableResult
    public func trailingImage(_ image: NSImage?) -> Self {
        self.trailingImage = image
        return self
    }
  
    /// Sets the symbol configuration of the image leading the control.
    @available(macOS 11.0, *)
    @discardableResult
    public func leadingImageSymbolConfiguration(_ symbolConfiguration: NSImage.SymbolConfiguration?) -> Self {
        self.leadingImageSymbolConfiguration = symbolConfiguration
        return self
    }
  
    /// Sets the symbol configuration of the image trailing the control.
    @available(macOS 11.0, *)
    @discardableResult
    public func trailingImageSymbolConfiguration(_ symbolConfiguration: NSImage.SymbolConfiguration?) -> Self {
        self.trailingImageSymbolConfiguration = symbolConfiguration
        return self
    }
  
    /// Sets the leading image scaling.
    @discardableResult
    public func leadingImageScaling(_ imageScaling: NSImageScaling) -> Self {
        self.leadingImageScaling = imageScaling
        return self
    }
  
    /// Sets the trailing image scaling.
    @discardableResult
    public func trailingImageScaling(_ imageScaling: NSImageScaling) -> Self {
        self.trailingImageScaling = imageScaling
        return self
    }
  
    /// Sets the symbol configuration of the image trailing the control.
    @discardableResult
    public func leadingImageTintColor(_ color: NSColor?) -> Self {
        self.leadingImageTintColor = color
        return self
    }
  
    /// Sets the tint color of the image leading the control.
    @discardableResult
    public func trailingImageTintColor(_ color: NSColor?) -> Self {
        self.trailingImageTintColor = color
        return self
    }
  
    /// Sets the tint color of the image trailing the control.
    @discardableResult
    public func minControlSize(_ minControlSize: CGFloat?) -> Self {
        self.minControlSize = minControlSize
        return self
    }
  
    /// Sets the control.
    @discardableResult
    public func control(_ control: NSControl) -> Self {
        self.control = control
        return self
    }
  
    /**
     Sets the orientation/placement of the leading and trailing text.
   
     If set to `horizontal`, the texts and images are to the left and right of the control, otherwise to the bottom and top.
   
     The default value is `horizontal`.
     */
    @discardableResult
    public func orientation(_ orientation: NSUIUserInterfaceLayoutOrientation) -> Self {
        self.orientation = orientation
        return self
    }
}
#endif
