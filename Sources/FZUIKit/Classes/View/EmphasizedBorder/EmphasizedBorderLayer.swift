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

/// A layer with a emphasized border.
public class EmphasizedBorderLayer: CALayer {
    public override var cornerRadius: CGFloat {
        didSet {  emphasizedBorderLayer.cornerRadius = cornerRadius }
    }

    public override var maskedCorners: CACornerMask {
        didSet { emphasizedBorderLayer.maskedCorners = maskedCorners }
    }

    public override var cornerCurve: CALayerCornerCurve {
        didSet { emphasizedBorderLayer.cornerCurve = cornerCurve }
    }

    public override var borderWidth: CGFloat {
        didSet { emphasizedBorderLayer.borderWidth = borderWidth * 2 }
    }

    override public var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            emphasizedBorderLayer.bounds = bounds
        }
    }

    internal let emphasizedBorderLayer = CALayer()

    public override init() {
        super.init()
        sharedInit()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    internal func sharedInit() {
        emphasizedBorderLayer.borderColor = NSUIColor.white.withAlphaComponent(0.5).cgColor
        emphasizedBorderLayer.bounds = bounds
        addSublayer(emphasizedBorderLayer)
    }
}
#endif
