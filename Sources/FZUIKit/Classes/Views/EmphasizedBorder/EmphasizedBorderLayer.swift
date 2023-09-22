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
        didSet {  emphasizedBorderLayer.cornerRadius = self.cornerRadius }
    }
    
    public override var maskedCorners: CACornerMask {
        didSet { emphasizedBorderLayer.maskedCorners = self.maskedCorners }
    }
    
    public override var cornerCurve: CALayerCornerCurve {
        didSet { emphasizedBorderLayer.cornerCurve = self.cornerCurve }
    }
    
    public override var borderWidth: CGFloat {
        didSet { emphasizedBorderLayer.borderWidth = self.borderWidth * 2 }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        emphasizedBorderLayer.frame = self.bounds
    }

    override public func display() {
        super.display()
        emphasizedBorderLayer.frame = self.bounds
    }
    
    internal let emphasizedBorderLayer = CALayer()
    
    public override init() {
        super.init()
        self.sharedInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        self.sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    internal func sharedInit() {
        emphasizedBorderLayer.borderColor = NSUIColor.white.withAlphaComponent(0.5).cgColor
        emphasizedBorderLayer.frame = self.bounds
        self.addSublayer(emphasizedBorderLayer)
    }
}
#endif
