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
        }

        override init() {
            super.init()
            backgroundColor = NSUIColor.black.cgColor
            frame = CGRect(.zero, CGSize(100_000))
            setupMaskLayer()
        }

        public weak var maskLayer: CALayer? {
            didSet {
                guard oldValue != maskLayer else { return }
                if oldValue?.superlayer == self {
                    oldValue?.removeFromSuperlayer()
                }
                setupMaskLayer()
            }
        }

        private func setupMaskLayer() {
            if let maskLayer = maskLayer {
                addSublayer(maskLayer)
                maskLayer.compositingFilter = "xor"
            }
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
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
