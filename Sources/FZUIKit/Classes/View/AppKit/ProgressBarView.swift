//
//  ProgressBarView.swift
//
//
//  Created by Florian Zand on 12.06.26.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/**
 A view that displays a progress bar providing visual feedback to the user about the status of an ongoing task.
 
 Unlike [NSProgressIndicator](https://developer.apple.com/documentation/appkit/nsprogressindicator), this view supports custom colors and corner radius for its appearance.
 */
@IBDesignable
open class ProgressBarView: NSProgressIndicator {
    
    private var _minValue: Double
    private var _maxValue: Double
    private var _doubleValue: Double = 0.0
    private var _cornerRadius: CGFloat = -1.0
    private var _color: NSColor = .systemBlue
    private var _backgroundColor: NSColor? = .progressbarBackgroundColor

    /**
     The minimum value for the progress indicator.
     
     The default value is `0.0`.
     */
    @IBInspectable
    @objc dynamic open override var minValue: Double {
        get { _minValue }
        set {
            guard newValue != _minValue else { return }
            _minValue = newValue
            updateProgress(animated: false)
        }
    }
    
    /**
     The maximum value for the progress indicator.
     
     The default value is `1.0`.
     */
    @IBInspectable
    @objc dynamic open override var maxValue: Double {
        get { _maxValue }
        set {
            guard newValue != _maxValue else { return }
            _maxValue = newValue
            updateProgress(animated: false)
        }
    }
    
    @IBInspectable
    open override var doubleValue: Double {
        get { _doubleValue }
        set {
            guard newValue != _doubleValue else { return }
            let clampedValue = min(max(newValue, min(minValue, maxValue)), max(minValue, maxValue))
            let previousValue = _doubleValue
            guard clampedValue != previousValue else { return }
            _doubleValue = clampedValue
            updateProgress(animated: animates && clampedValue > previousValue && window != nil)
        }
    }
    
    open override var userInterfaceLayoutDirection: NSUserInterfaceLayoutDirection {
        didSet {
            guard oldValue != userInterfaceLayoutDirection else { return }
            updateProgress(animated: false)
        }
    }
    
    /**
     A Boolean value that determines whether changes to the progress value are animated.
     
     The default value is `true`.
     */
    @IBInspectable
    @objc public var animates: Bool = true
    
    /// Sets the Boolean value that determines whether changes to the progress value are animated.
    @discardableResult
    open func animates(_ animates: Bool) -> Self {
        self.animates = animates
        return self
    }
    
    /**
     The corner radius of the progress bar.
     
     The default value is `-1.0`, wbich automatically adjusts the corner radius to the height of the progress bar for a capsule appearance.
     */
    @IBInspectable
    open override var cornerRadius: CGFloat {
        get { _cornerRadius }
        set {
            guard newValue != _cornerRadius else { return }
            _cornerRadius = newValue
            needsDisplay = true
        }
    }
    
    /**
     The color of the progress bar.
     
     The default value is [systemBlue](https://developer.apple.com/documentation/appkit/nscolor/systemblue).
     */
    @IBInspectable
    @objc dynamic override open var color: NSColor {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
            needsDisplay = true
        }
    }
        
    /**
     The background color of the progress view.
     
     The default value is `NSColor(white: 0.5, alpha: 0.1)`.
     */
    open override var backgroundColor: NSColor? {
        get { _backgroundColor }
        set {
            guard newValue != _backgroundColor else { return }
            _backgroundColor = newValue
            needsDisplay = true
        }
    }
    
    /**
     A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     
     The default value is `true`.
     */
    @IBInspectable
    @objc dynamic open var isDisplayedWhenFinished = true {
        didSet {
            guard oldValue != isDisplayedWhenFinished else { return }
            needsDisplay = true
        }
    }
    
    /// Sets the Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
    @discardableResult
    @objc open func isDisplayedWhenFinished(_ isDisplayed: Bool) -> Self {
        self.isDisplayedWhenFinished = isDisplayedWhenFinished
        return self
    }
    
    open override var controlSize: NSControl.ControlSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override var intrinsicContentSize: NSSize {
        switch controlSize {
        case .mini, .small:
            NSSize(width: NSView.noIntrinsicMetric, height: 6)
        case .regular:
            NSSize(width: NSView.noIntrinsicMetric, height: 8)
        case .large:
            NSSize(width: NSView.noIntrinsicMetric, height: 10)
        case .extraLarge:
            NSSize(width: NSView.noIntrinsicMetric, height: 12)
        @unknown default:
            NSSize(width: NSView.noIntrinsicMetric, height: 8)
        }
    }
    
    @objc dynamic private var displayedProgressFraction: CGFloat = 0 {
        didSet { needsDisplay = true }
    }
    
    open override var style: NSProgressIndicator.Style {
        get { .bar }
        set { }
    }
    
    open override var isIndeterminate: Bool {
        get { false }
        set { }
    }
    
    private func updateProgress(animated: Bool) {        
        guard animated else {
            displayedProgressFraction = fractionCompleted
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = .easeInEaseOut
            context.duration = 0.5
            animator().displayedProgressFraction = fractionCompleted
        }
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        guard isDisplayedWhenFinished || displayedProgressFraction < 1 else {
            return
        }
        // super.draw(dirtyRect)
        var drawingBounds = bounds
        guard !drawingBounds.isEmpty else { return }
        let maxRadius = drawingBounds.height / 2
        let radius = cornerRadius < 0.0 ? maxRadius : min(cornerRadius, maxRadius)
        if let backgroundColor = _backgroundColor?.resolvedColor(for: self) {
            backgroundColor.setFill()
            NSBezierPath(roundedRect: drawingBounds, cornerRadius: radius).fill()
            NSColor.systemGray.setStroke()
            let lineWidth = 0.5
            let rect = drawingBounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            NSBezierPath(rect: rect).lineWidth(lineWidth).stroke()
        }
        guard displayedProgressFraction > 0 else { return }
        drawingBounds.size.width *= displayedProgressFraction
        if userInterfaceLayoutDirection == .rightToLeft {
            drawingBounds.origin.x = drawingBounds.maxX - bounds.width
        }
        color.resolvedColor(for: self).setFill()
        NSBezierPath(roundedRect: drawingBounds, cornerRadius: radius).fill()
    }
    
    /// Creates a progress view.
    public init() {
        _minValue = 0.0
        _maxValue = 1.0
        super.init(frame: .zero)
        displayedProgressFraction = fractionCompleted
    }
    
    /// Creates a progress view with the specified frame rectangle.
    public override init(frame frameRect: NSRect) {
        _minValue = 0.0
        _maxValue = 1.0
        super.init(frame: frameRect)
        displayedProgressFraction = fractionCompleted
    }
    
    /// Creates a progress view with data in an unarchiver.
    public required init?(coder: NSCoder) {
        _minValue = coder.containsValue(forKey: "minValue") ? coder.decodeDouble(forKey: "minValue") : 1.0
        _maxValue = coder.containsValue(forKey: "maxValue") ? coder.decodeDouble(forKey: "maxValue") : 1.0
        super.init(coder: coder)
        cornerRadius = coder.containsValue(forKey: "cornerRadius") ? coder.decodeDouble(forKey: "cornerRadius") : cornerRadius
        color = coder.decode(forKey: "color") ?? color
        backgroundColor = coder.decode(forKey: "backgroundColor") ?? backgroundColor
        isDisplayedWhenFinished = coder.containsValue(forKey: "isDisplayedWhenFinished") ? coder.decodeBool(forKey: "isDisplayedWhenFinished") : isDisplayedWhenFinished
        animates = coder.containsValue(forKey: "animates") ? coder.decodeBool(forKey: "animates") : animates
        displayedProgressFraction = fractionCompleted
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(minValue, forKey: "minValue")
        coder.encode(maxValue, forKey: "maxValue")
        coder.encode(cornerRadius, forKey: "cornerRadius")
        coder.encode(color, forKey: "color")
        coder.encode(backgroundColor, forKey: "backgroundColor")
        coder.encode(isDisplayedWhenFinished, forKey: "isDisplayedWhenFinished")
        coder.encode(animates, forKey: "animates")
    }
    
    open override class func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        super.defaultAnimation(forKey: key == "displayedProgressFraction" ? "frameOrigin" : key)
    }
    
    open override func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
        super.animation(forKey: key == "displayedProgressFraction" ? "frameOrigin" : key)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        displayedProgressFraction = fractionCompleted
    }
    
    open override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        guard color.isDynamic || backgroundColor?.isDynamic == true else { return }
        needsDisplay = true
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        displayedProgressFraction = fractionCompleted
    }
}

fileprivate extension NSColor {
    static let progressbarBackgroundColor = NSColor(light: .controlBackgroundColor.resolvedColor(for: .darkAqua).withAlphaComponent(0.1), dark: .controlBackgroundColor.resolvedColor(for: .aqua).withAlphaComponent(0.1))
    static let progressbarBackgroundColorAlt = NSColor(light: NSColor(white: 0.0, alpha: 0.1), dark: NSColor(white: 1.0, alpha: 0.1))
}

#endif
