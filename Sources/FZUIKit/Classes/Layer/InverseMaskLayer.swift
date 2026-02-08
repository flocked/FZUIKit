//
//  InverseMaskLayer.swift
//
//
//  Created by Florian Zand on 28.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A layer that inverses a mask layer.
public class InverseMaskLayer: CALayer {
    public init(maskLayer: CALayer) {
        self.maskLayer = maskLayer
        super.init()
        bounds.size = maskLayer.bounds.size
        initialSetup()
    }

    override init() {
        super.init()
        initialSetup()
    }
    
    private func initialSetup() {
        backgroundColor = NSUIColor.black.cgColor
        setupMaskLayer()
    }

    public weak var maskLayer: CALayer? {
        didSet {
            guard oldValue !== maskLayer else { return }
            if oldValue?.superlayer === self {
                oldValue?.compositingFilter = nil
                oldValue?.removeFromSuperlayer()
            }
            setupMaskLayer()
        }
    }

    private func setupMaskLayer() {
        guard let maskLayer = maskLayer else { return }
        addSublayer(maskLayer)
        maskLayer.compositingFilter = "xor"
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
}

class InverseMaskView: NSUIView {
    var _innerShadowLayer: InnerShadowLayer {
        #if os(macOS)
        wantsLayer = true
        #endif
        return layer as! InnerShadowLayer
    }

    #if os(macOS)
    override public func makeBackingLayer() -> CALayer {
        let innerShadowLayer = InnerShadowLayer()
        return innerShadowLayer
    }
    #else
    override public class var layerClass: AnyClass {
        InnerShadowLayer.self
    }
    #endif
}

#endif
