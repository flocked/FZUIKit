//
//  DashedBorderLayer.swift
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

/// A layer with a dashed border.
public class DashedBorderLayer: CALayer {
    /// The insets of the border.
    public var borderInsets: NSDirectionalEdgeInsets = .init(0) {
        didSet {
            guard oldValue != borderInsets else { return }
            layoutBorderedLayer()
        }
    }
    
    /// The dash pattern of the border.
    public var borderDashPattern: [CGFloat]? {
        get { borderedLayer.lineDashPattern?.compactMap({$0.doubleValue}) }
        set { borderedLayer.lineDashPattern = newValue as? [NSNumber] }
    }
    
    /// The border color.
    public override var borderColor: CGColor? {
        didSet {
            borderedLayer.strokeColor = self.borderColor
            self.borderColor = nil
        }
    }
    
    /// The border width.
    public override var borderWidth: CGFloat {
        didSet {
            borderedLayer.lineWidth = self.borderWidth
            self.borderWidth = 0.0
        }
    }
    
    public override var cornerRadius: CGFloat {
        didSet {
            if oldValue != self.cornerRadius {
                self.layoutBorderedLayer()
            }
        }
    }
    
    public override var cornerCurve: CALayerCornerCurve {
        didSet {
            self.borderedLayer.cornerCurve = self.cornerCurve
        }
    }
    
    /// THe configuration of the border.
    public var configuration: ContentConfiguration.Border {
        get { ContentConfiguration.Border(color: self.borderColor?.nsUIColor, width: self.borderWidth, dashPattern: self.borderDashPattern, insets: self.borderInsets) }
        set { guard newValue != self.configuration else { return  }
            self.borderedLayer.lineWidth = newValue.width
            self.borderedLayer.strokeColor = newValue._resolvedColor?.cgColor
            self.borderInsets = newValue.insets
            self.borderDashPattern = newValue.dashPattern
         //   self.borderedLayer.backgroundColor = NSColor.red.cgColor
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
    
    internal let borderedLayer = CAShapeLayer()
    
    internal func layoutBorderedLayer() {
        let frameSize = CGSize(width: self.frame.size.width-borderInsets.width, height: self.frame.size.height-borderInsets.height)
        let shapeRect = CGRect(origin: CGPoint(x: borderInsets.leading, y: borderInsets.bottom), size: frameSize)
        
        let scale = (shapeRect.size.width-borderWidth)/self.frame.size.width
        let cornerRadius = self.cornerRadius * scale
        
        borderedLayer.bounds = CGRect(.zero, shapeRect.size)
        borderedLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        borderedLayer.path = NSUIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
    }
    
    /**
     Initalizes a dashed border layer with the specified configuration.
     
     - Parameters configuration: The configuration of the border.
     - Returns: The dashed border layer.
     */
    public init(configuration: ContentConfiguration.Border) {
        super.init()
        self.configuration = configuration
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
        borderedLayer.fillColor = .clear
        borderedLayer.lineJoin = CAShapeLayerLineJoin.round
        self.addSublayer(borderedLayer)
    }
}
#endif
