//
//  EmphasizedBorderLayer.swift
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

    /// A layer with an emphasized border.
    public class EmphasizedBorderLayer: CALayer {
        override public var cornerRadius: CGFloat {
            didSet { emphasizedBorderLayer.cornerRadius = cornerRadius }
        }

        override public var maskedCorners: CACornerMask {
            didSet { emphasizedBorderLayer.maskedCorners = maskedCorners }
        }

        override public var cornerCurve: CALayerCornerCurve {
            didSet { emphasizedBorderLayer.cornerCurve = cornerCurve }
        }

        override public var borderWidth: CGFloat {
            didSet { emphasizedBorderLayer.borderWidth = borderWidth * 2 }
        }

        override public var bounds: CGRect {
            didSet {
                guard oldValue != bounds else { return }
                emphasizedBorderLayer.bounds = bounds
            }
        }

        let emphasizedBorderLayer = CALayer()

        override public init() {
            super.init()
            sharedInit()
        }

        override public init(layer: Any) {
            super.init(layer: layer)
            sharedInit()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        func sharedInit() {
            emphasizedBorderLayer.borderColor = NSUIColor.white.withAlphaComponent(0.5).cgColor
            emphasizedBorderLayer.bounds = bounds
            addSublayer(emphasizedBorderLayer)
        }
    }
#endif
