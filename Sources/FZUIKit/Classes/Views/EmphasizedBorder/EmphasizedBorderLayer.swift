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
        didSet {
            emphasizedBorderLayer.cornerRadius = self.cornerRadius
            let diff = self.frame.size.height / (self.frame.size.height - (self.borderWidth * 2))
            emphasizedBorderLayer.cornerRadius = self.cornerRadius * diff
        }
    }
    
    public override var maskedCorners: CACornerMask {
        didSet { emphasizedBorderLayer.maskedCorners = self.maskedCorners }
    }
    
    public override var cornerCurve: CALayerCornerCurve {
        didSet { emphasizedBorderLayer.cornerCurve = self.cornerCurve }
    }
    
    public override var borderWidth: CGFloat {
        didSet {
            emphasizedBorderLayer.borderWidth = self.borderWidth
            self.layoutBorderedLayer()
        }
    }
    
    public override func layoutSublayers() {
        self.layoutBorderedLayer()
        super.layoutSublayers()
    }

    override public func display() {
        super.display()
        layoutBorderedLayer()
    }
    
    internal let emphasizedBorderLayer = CALayer()
    
    internal func layoutBorderedLayer() {
        var emphasizedBorderFrame: CGRect = .zero
        emphasizedBorderFrame.size.width = self.frame.size.width - (self.borderWidth * 2)
        emphasizedBorderFrame.size.height = self.frame.size.height - (self.borderWidth * 2)
        emphasizedBorderFrame.origin.x = self.borderWidth
        emphasizedBorderFrame.origin.y = self.borderWidth
        emphasizedBorderLayer.frame = emphasizedBorderFrame
        
        let diff = (self.frame.size.height - (self.borderWidth )) / self.frame.size.height
        emphasizedBorderLayer.cornerRadius = self.cornerRadius * diff
      //  emphasizedBorderLayer.scale = CGPoint(x: diff, y: diff)
    }
        
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
        self.addSublayer(emphasizedBorderLayer)
    }
}
#endif
