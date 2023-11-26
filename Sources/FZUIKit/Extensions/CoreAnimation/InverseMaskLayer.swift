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
        self.backgroundColor = NSUIColor.black.cgColor
        self.frame = CGRect(.zero, CGSize(100000))
        self.setupMaskLayer()
    }
    
    public weak var maskLayer: CALayer? = nil {
        didSet { 
            guard oldValue != maskLayer else { return }
            if oldValue?.superlayer == self {
                oldValue?.removeFromSuperlayer()
            }
            self.setupMaskLayer()
        }
    }
    
    private func setupMaskLayer() {
        if let maskLayer = self.maskLayer {
            self.addSublayer(maskLayer)
            maskLayer.compositingFilter = "xor"
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
