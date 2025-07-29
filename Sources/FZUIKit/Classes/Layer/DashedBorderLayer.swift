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

    /// The configuration of the border.
    public var configuration: BorderConfiguration {
        get { BorderConfiguration(color: borderedLayer.strokeColor?.nsUIColor, width: borderedLayer.lineWidth, dash: .init(pattern: borderDashPattern, phase: borderedLayer.lineDashPhase, lineCap: borderedLayer.lineCap.cgLineCap, lineJoin: borderedLayer.lineJoin.cgLineJoin), insets: borderInsets) }
        set {
            guard newValue != configuration else { return }
            borderedLayer.lineWidth = newValue.width
            borderedLayer.strokeColor = newValue.resolvedColor()?.cgColor
            borderDashPattern = newValue.dash.pattern
            borderedLayer.lineDashPhase = newValue.dash.phase
            borderedLayer.lineJoin = newValue.dash.lineJoin.shapeLayerLineJoin
            borderedLayer.lineCap = newValue.dash.lineCap.shapeLayerLineCap
            borderInsets = newValue.insets
        }
    }

    var borderInsets: NSDirectionalEdgeInsets = .init(0) {
        didSet {
            guard oldValue != borderInsets else { return }
            layoutBorderedLayer()
        }
    }

    var borderDashPattern: [CGFloat] {
        get { borderedLayer.lineDashPattern?.compactMap({$0.doubleValue}) ?? [] }
        set { borderedLayer.lineDashPattern = newValue as [NSNumber] }
    }

    override public var cornerRadius: CGFloat {
        didSet {
            guard oldValue != cornerRadius else { return }
            layoutBorderedLayer()
        }
    }

    override public var cornerCurve: CALayerCornerCurve {
        didSet {
            borderedLayer.cornerCurve = cornerCurve
        }
    }

    override public var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            layoutBorderedLayer()
        }
    }

    let borderedLayer = CAShapeLayer()

    func layoutBorderedLayer() {

        let frameSize = CGSize(width: bounds.size.width - borderInsets.width, height: bounds.size.height - borderInsets.height)
        let shapeRect = CGRect(origin: CGPoint(x: borderInsets.leading, y: borderInsets.bottom), size: frameSize)


        /*
         let scale = (shapeRect.size.width - borderWidth) / frame.size.width
         let cornerRadius = cornerRadius * scale
         */
        borderedLayer.bounds = CGRect(.zero, shapeRect.size)
        borderedLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)

        borderedLayer.frame =   bounds.inset(by: configuration.insets)

        #if os(macOS)
        borderedLayer.path = NSUIBezierPath(roundedRect:  borderedLayer.frame, cornerRadius: cornerRadius).cgPath
        #else
        borderedLayer.path = NSUIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        #endif
    }

    /**
     Initalizes a dashed border layer with the specified configuration.

     - Parameter configuration: The configuration of the border.
     - Returns: The dashed border layer.
     */
    public init(configuration: BorderConfiguration) {
        super.init()
        self.configuration = configuration
    }

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
        borderedLayer.fillColor = nil
        addSublayer(borderedLayer)
        zPosition = .greatestFiniteMagnitude
        /*
         lineWidth: CGFloat = 1,
         lineCap: CGLineCap = .butt,
         lineJoin: CGLineJoin = .miter,
         miterLimit: CGFloat = 10,
         dash: [CGFloat] = [CGFloat](),
         dashPhase: CGFloat = 0
         */

    }
}
#endif
