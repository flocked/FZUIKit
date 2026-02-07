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
    
    /// The configuration of the inner shadow.
    open var configuration: ShadowConfiguration = .none { didSet { setNeedsLayout() } }
    
    /// The shape of the inner shadowl
    open var shape: (any Shape)? { didSet { setNeedsLayout() } }
    
    open override var cornerRadius: CGFloat {
        didSet { if oldValue != cornerRadius && shape == nil { setNeedsLayout() } }
    }
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameter configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        super.init()
        setup()
        self.configuration = configuration
    }
    
    public override init() {
        super.init()
        setup()
    }
    
    init(for layer: CALayer) {
        super.init()
        setup()
        layer.addSublayer(withConstraint: self)
        sendToBack()
        zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(observeSuperlayer: Bool = true) {
        addSublayer(shadowLayer)
        shadowLayer.mask = maskLayer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.backgroundColor = nil
        shadowLayer.shadowPath = nil
        #if os(macOS) || os(iOS)
        guard observeSuperlayer else { return }
        superlayerObservation = observeChanges(for: \.superlayer, handler: { [weak self] _, _ in
            self?.updateViewObservation()
        })
        #endif
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        let innerPath = shape?.path(in: bounds).cgPath ?? NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        let outerRect = bounds.insetBy(-configuration.radius * 4)
        
        let ringPath = CGMutablePath()
        ringPath.addRect(outerRect)
        ringPath.addPath(innerPath)
        
        shadowLayer.frame = bounds
        shadowLayer.path = ringPath
        shadowLayer.fillColor = configuration.color?.cgColor
        shadowLayer.shadowColor = configuration.color?.cgColor
        #if os(macOS) || os(iOS)
        if let parentView = parentView {
            updateShadowColor(for: parentView)
        }
        #endif
        shadowLayer.shadowOffset = configuration.offset.size
        shadowLayer.shadowOpacity = Float(configuration.opacity)
        shadowLayer.shadowRadius = configuration.radius
        
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
