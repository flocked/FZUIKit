//
//  InnerShadowLayer.swift
//
//
//  Created by Florian Zand on 16.09.21.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

/// A layer with an inner shadow.
open class InnerShadowLayer: CALayer {
    private var viewObservation: KeyValueObservation?
    private var superlayerObservation: KeyValueObservation?
    private let shadowLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    private var needsUpdate = false
    private var isVisible = false
    private var lastBounds: CGRect = .zero
    
    /// The configuration of the inner shadow.
    open var configuration: ShadowConfiguration = .none {
        didSet { updateInnerShadow(old: oldValue) }
    }
    
    func updateInnerShadow(old: ShadowConfiguration) {
        shadowLayer.fillColor = configuration.resolvedColor()?.cgColor
        shadowLayer.shadowColor = shadowLayer.fillColor
        #if os(macOS) || os(iOS)
        if let parentView = parentView {
            updateShadowColor(for: parentView)
        }
        #endif
        shadowLayer.shadowOffset = configuration.offset.size
        shadowLayer.shadowOpacity = Float(configuration.opacity)
        shadowLayer.shadowRadius = configuration.radius
        let wasVisible = isVisible
        isVisible = configuration.opacity > 0.0 && shadowLayer.fillColor?.alpha ?? 0.0 > 0.0
        guard wasVisible != isVisible else { return }
        updateLayer()
    }
    
    func updateLayer() {
        needsUpdate = true
        setNeedsLayout()
    }
    
    /// The shape of the inner shadowl
    open var shape: (any Shape)? {
        didSet { updateLayer() }
    }
    
    open override var cornerRadius: CGFloat {
        didSet { if oldValue != cornerRadius && shape == nil { updateLayer() } }
    }
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameter configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        super.init()
        self.setup()
        self.configuration = configuration
        self.updateInnerShadow(old: .none)
    }
    
    public override init() {
        super.init()
        setup()
    }
    
    init(for layer: CALayer) {
        super.init()
        zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
        setup()
        layer.addSublayer(withConstraint: self)
        sendToBack()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSublayer(shadowLayer)
        shadowLayer.mask = maskLayer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.backgroundColor = nil
        shadowLayer.shadowPath = nil
        #if os(macOS) || os(iOS)
        superlayerObservation = observeChanges(for: \.superlayer, handler: { [weak self] _, _ in
            self?.updateViewObservation()
        })
        #endif
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        guard bounds != lastBounds || needsUpdate else { return }
        needsUpdate = false
        lastBounds = bounds
        guard isVisible else {
            shadowLayer.path = nil
            maskLayer.path = nil
            return
        }
        let innerPath = shape?.path(in: bounds).cgPath ?? NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        let outerRect = bounds.insetBy(-configuration.radius * 4)
        let ringPath = CGMutablePath()
        ringPath.addRect(outerRect)
        ringPath.addPath(innerPath)
        shadowLayer.frame = bounds
        shadowLayer.path = ringPath
        maskLayer.frame = bounds
        maskLayer.path = innerPath
    }
    
    #if os(macOS) || os(iOS)
    func updateShadowColor(for view: NSUIView) {
        let shadowColor = configuration.resolvedColor()?.resolvedColor(for: view).cgColor
        shadowLayer.fillColor = shadowColor
        shadowLayer.shadowColor = shadowColor
    }
    
    func updateViewObservation() {
        if let view = parentView {
            updateShadowColor(for: view)
            #if os(macOS)
            viewObservation = view.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                self?.updateShadowColor(for: view)
            }
            #else
            viewObservation = view.observeChanges(for: \.traitCollection) { [weak self] old, new in
                guard old.userInterfaceStyle != new.userInterfaceStyle else { return }
                self?.updateShadowColor(for: view)
            }
            #endif
        } else {
            viewObservation = nil
        }
    }
    #endif
}
#endif

#if os(macOS) || os(iOS)
/**
 Observes changes to the light/dark mode (interface style) of a layer that is displayed in a view.
 
 If the layer is attached to a view, it observes the view’s appearance; otherwise, it tracks the layer’s superlayers until a parent view is found.
 */
class LayerAppearanceObserver {
    weak var layer: CALayer?
    var handler: (_ layer: CALayer, _ isLight: Bool)->()
    var superlayerObservations: [KeyValueObservation] = []
    var viewUserStyleObservation: KeyValueObservation?
    
    init(layer: CALayer, handler: @escaping (_ layer: CALayer, _ isLight: Bool)->()) {
        self.layer = layer
        self.handler = handler
        self.setupSuperlayerObservation()
    }
    
    private func setupSuperlayerObservation() {
        superlayerObservations = []
        var currentLayer: CALayer? = layer
        while let layer = currentLayer {
            superlayerObservations += layer.observeChanges(for: \.superlayer) { [weak self] old, new in
                self?.setupSuperlayerObservation()
            }
            currentLayer = layer.superlayer
        }
        setupViewAppearanceObservation()
    }
    
    private func setupViewAppearanceObservation() {
        guard let layer = layer else {
            viewUserStyleObservation = nil
            return
        }
        #if os(macOS)
        viewUserStyleObservation = layer.parentView?.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
            self?.handler(layer, new.isLight)
        }
        #else
        viewUserStyleObservation = layer.parentView?.observeChanges(for: \.traitCollection) { [weak self] old, new in
            guard old.userInterfaceStyle != new.userInterfaceStyle else { return }
            self?.handler(layer, new.userInterfaceStyle.isLight)
        }
        #endif
    }
}
#endif
