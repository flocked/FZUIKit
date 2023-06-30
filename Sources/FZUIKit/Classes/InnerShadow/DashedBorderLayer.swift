//
//  File.swift
//  
//
//  Created by Florian Zand on 30.06.23.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A CALayer that displays a inner shadow.
public class DashedBorderLayer: CALayer {
    public var borderInsets: NSDirectionalEdgeInsets = .init(0) {
        didSet {
            guard oldValue != borderInsets else { return }
            layoutBorderedLayer()
        }
    }
    
    public override var borderColor: CGColor? {
        get { borderedLayer.strokeColor }
        set { borderedLayer.strokeColor = newValue }
    }
    
    public override var borderWidth: CGFloat {
        get { borderedLayer.lineWidth }
        set {
            guard newValue != borderWidth else { return }
            borderedLayer.lineWidth = newValue
            layoutBorderedLayer()
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
    
    public var borderDashPattern: [CGFloat]? {
        get { borderedLayer.lineDashPattern?.compactMap({$0.doubleValue}) }
        set { borderedLayer.lineDashPattern = newValue as? [NSNumber] }
    }
    
    public var configuration: ContentConfiguration.Border {
        get { ContentConfiguration.Border(color: self.borderColor?.nsColor, width: self.borderWidth, dashPattern: self.borderDashPattern, insets: self.borderInsets) }
        set { guard newValue != self.configuration else { return  }
            self.borderWidth = newValue.width
            self.borderedLayer.strokeColor = newValue._resolvedColor?.cgColor
            self.borderInsets = newValue.insets
            self.borderDashPattern = newValue.dashPattern
        }
    }
    
    public override func layoutSublayers() {
        self.layoutBorderedLayer()
        super.layoutSublayers()
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
