//
//  BorderLayer.swift
//
//
//  Created by Florian Zand on 30.06.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

/// A layer with a configuratable border.
open class BorderLayer: CALayer {
    private var viewObservation: KeyValueObservation?
    private var superlayerObservation: KeyValueObservation?
    private let borderedLayer = CAShapeLayer()
    private var needsUpdate = false
    private var lastBounds: CGRect = .zero
    private var isVisible = false
    
    /// The configuration of the border.
    public var configuration: BorderConfiguration = .none { didSet { upateBorder(old: oldValue) } }
    
    /// The shape of the border shadow.
    open var shape: (any Shape)? { didSet { updateLayout() } }
    
    private func upateBorder(old: BorderConfiguration) {
        borderedLayer.lineWidth = configuration.width
        borderedLayer.strokeColor = configuration.resolvedColor()?.cgColor
        borderedLayer.lineDashPattern = configuration.dash.pattern as [NSNumber]
        borderedLayer.lineDashPhase = configuration.dash.phase
        borderedLayer.lineJoin = configuration.dash.lineJoin.shapeLayerLineJoin
        borderedLayer.lineCap = configuration.dash.lineCap.shapeLayerLineCap
        borderedLayer.miterLimit = configuration.dash.mitterLimit
        let wasVisible = isVisible
        isVisible = borderedLayer.lineWidth > 0.0 && borderedLayer.strokeColor?.alpha ?? 0.0 > 0.0
        if old.insets != configuration.insets || (!wasVisible != isVisible) { updateLayout() }
        #if os(macOS) || os(iOS)
        guard let parentView = parentView else { return }
        updateBorderColor(for: parentView)
        #endif
    }
    
    open override var cornerRadius: CGFloat {
        didSet { if oldValue != cornerRadius && shape == nil { updateLayout() } }
    }
    
    private func updateLayout() {
        needsUpdate = true
        setNeedsLayout()
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        guard bounds != lastBounds || needsUpdate else { return }
        needsUpdate = false
        lastBounds = bounds
        guard isVisible else {
            borderedLayer.path = nil
            return
        }

        borderedLayer.frame = bounds
        let strokeInset = borderedLayer.lineWidth / 2
        let finalRect = bounds.inset(by: configuration.insets).insetBy(dx: strokeInset, dy: strokeInset)
        guard finalRect.width > 0, finalRect.height > 0 else {
            borderedLayer.path = nil
            return
        }
        if let insettable = shape as? any InsettableShape {
            let insetAmount = max(configuration.insets.top, configuration.insets.leading, configuration.insets.bottom, configuration.insets.trailing) + strokeInset
            borderedLayer.path = insettable.inset(by: insetAmount).path(in: bounds).cgPath
        } else  if let shape {
            borderedLayer.path = shape.path(in: finalRect).cgPath
        } else {
            let scale = min(finalRect.width, finalRect.height) / min(bounds.width, bounds.height)
            borderedLayer.path = NSUIBezierPath(roundedRect: finalRect, cornerRadius: cornerRadius * scale).cgPath
        }
    }
    
    /**
     Initalizes a border layer with the specified configuration.
     
     - Parameter configuration: The configuration of the border.
     - Returns: The border layer.
     */
    public init(configuration: BorderConfiguration) {
        super.init()
        setup()
        self.configuration = configuration
    }
    
    public override init() {
        super.init()
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(for layer: CALayer) {
        super.init()
        setup()
        shape = layer.maskShape
        layer.addSublayer(withConstraint: self)
        sendToFront()
    }
    
    private func setup(observeSuperlayer: Bool = true) {
        addSublayer(borderedLayer)
        borderedLayer.fillColor = nil
        zPosition(.greatestFiniteMagnitude)
        #if os(macOS) || os(iOS)
        guard observeSuperlayer else { return }
        superlayerObservation = observeChanges(for: \.superlayer, handler: { [weak self] _, _ in
            self?.updateViewObservation()
        })
        #endif
    }
    
    var strokeColor: CGColor? {
        get { borderedLayer.strokeColor }
        set { borderedLayer.strokeColor = newValue }
    }
    
    var lineWidth: CGFloat { borderedLayer.lineWidth }
    
    #if os(macOS) || os(iOS)
    private func updateBorderColor(for view: NSUIView) {
        borderedLayer.strokeColor = configuration.resolvedColor()?.resolvedColor(for: view).cgColor
    }

    private func updateViewObservation() {
        if let view = parentView {
            updateBorderColor(for: view)
            #if os(macOS)
            viewObservation = view.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                self?.updateBorderColor(for: view)
            }
            #else
            viewObservation = view.observeChanges(for: \.traitCollection) { [weak self] old, new in
                guard old.userInterfaceStyle != new.userInterfaceStyle else { return }
                self?.updateBorderColor(for: view)
            }
            #endif
        } else {
            viewObservation = nil
        }
    }
    #endif
}

#endif
