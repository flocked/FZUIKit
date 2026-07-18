//
//  SeparatorView.swift
//  FZUIKit
//
//  Created by Florian Zand on 04.07.26.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif
import FZSwiftUtils

/**
 A view that displays a separator line.

 The separator view automatically adapts its orientation when used as an arranged subview of a stack view, drawing a vertical separator in horizontal stack views and a horizontal separator in vertical stack views.
 
 This view is intended to be used as an arranged subview of a stack view.
 */
open class SeparatorView: NSUIView {
    
    private let separatorLayer = CALayer()
    var stackOrientation: NSUIUserInterfaceLayoutOrientation = .horizontal {
        didSet {
            guard oldValue != stackOrientation else { return }
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// The insets of the separator.
    public var insets: NSDirectionalEdgeInsets = .zero {
        didSet {
            guard oldValue != insets else { return }
            setNeedsLayout()
        }
    }
    
    /// The thickness of the separator.
    public var thickness: CGFloat = 1 {
        didSet {
            guard oldValue != thickness else { return }
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    #if os(macOS)
    /// The color of the separator.
    public var color: NSUIColor = .separatorColor {
        didSet {
            guard oldValue != color else { return }
            separatorLayer.backgroundColor = color.resolvedColor(for: self).cgColor
        }
    }
    
    /// Creates a separator view with the specified color, thickness and insets.
    public init(color: NSUIColor = .separatorColor, thickness: CGFloat = 1, insets: NSDirectionalEdgeInsets = .zero) {
        self.color = color
        self.thickness = thickness
        self.insets = insets
        super.init(frame: .zero)
        initialCode()
    }
    #else
    /// The color of the separator.
    public var color: NSUIColor = .separator {
        didSet {
            guard oldValue != color else { return }
            separatorLayer.backgroundColor = color.cgColor
        }
    }
    
    /// Creates a separator view with the specified color, thickness and insets.
    public init(color: NSUIColor = .separator, thickness: CGFloat = 1, insets: NSDirectionalEdgeInsets = .zero) {
        self.color = color
        self.thickness = thickness
        self.insets = insets
        super.init(frame: .zero)
        initialCode()
    }
    #endif

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        thickness = coder.decode("thickness") ?? thickness
        color = coder.decode("color") ?? color
        insets = NSDirectionalEdgeInsets(top: coder.decode("insetsTop") ?? 0.0, leading: coder.decode("insetsLeading") ?? 0.0, bottom: coder.decode("insetsBottom") ?? 0.0, trailing: coder.decode("insetsTrailing") ?? 0.0)
        initialCode()
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(thickness, forKey: "thickness")
        coder.encode(color, forKey: "color")
        coder.encode(insets.top, forKey: "insetsTop")
        coder.encode(insets.bottom, forKey: "insetsBottom")
        coder.encode(insets.leading, forKey: "insetsLeading")
        coder.encode(insets.trailing, forKey: "insetsTrailing")
    }
    
    private func initialCode() {
        translatesAutoresizingMaskIntoConstraints = false
        optionalLayer?.addSublayer(separatorLayer)
        separatorLayer.backgroundColor = color.cgColor
    }

    open override var intrinsicContentSize: CGSize {
        switch stackOrientation {
        case .horizontal:
            return CGSize(width: thickness, height: NSUIView.noIntrinsicMetric)
        case .vertical:
            return CGSize(width: NSUIView.noIntrinsicMetric, height: thickness)
        @unknown default:
            return CGSize(width: NSUIView.noIntrinsicMetric, height: thickness)
        }
    }

    #if os(macOS)
    open override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard let stackView = newSuperview as? NSUIStackView else { return }
        stackOrientation = stackView.orientation
        stackView.swizzleOrientation()
        super.viewWillMove(toSuperview: newSuperview)
    }

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        invalidateIntrinsicContentSize()
    }
    
    open override func layout() {
        super.layout()
        updateSeparatorLayer()
    }
    
    open override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        separatorLayer.backgroundColor = color.resolvedColor(for: self).cgColor
    }
    #else
    override open func willMove(toSuperview newSuperview: UIView?) {
        guard let stackView = newSuperview as? NSUIStackView else { return }
        stackOrientation = stackView.orientation
        #if !os(visionOS)
        stackView.swizzleOrientation()
        #endif
        super.willMove(toSuperview: newSuperview)
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        invalidateIntrinsicContentSize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateSeparatorLayer()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true else { return }
        separatorLayer.backgroundColor = color.resolvedColor(for: self).cgColor
    }
    #endif
    
    private func updateSeparatorLayer() {
        var insets = insets
        if stackOrientation == .horizontal {
            insets.leading = 0
            insets.trailing = 0
        } else {
            insets.top = 0.0
            insets.bottom = 0.0
        }
        #if os(visionOS)
        let rect = bounds.inset(by: insets)
        #else
        let rect = bounds.inset(by: insets, layoutDirection: userInterfaceLayoutDirection)
        #endif
        CATransaction.disabledActions {
            separatorLayer.frame = rect
        }
    }
}

#if !os(macOS)
extension UIView {
    var userInterfaceLayoutDirection:  UIUserInterfaceLayoutDirection {
        effectiveUserInterfaceLayoutDirection
    }
}
#endif

#endif
