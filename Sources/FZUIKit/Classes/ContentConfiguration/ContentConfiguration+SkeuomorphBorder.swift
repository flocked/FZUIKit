//
//  ContentConfiguration+SkeuomorphBorder.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import Foundation

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a border.
    struct SkeuomorphBorder: Hashable {
        public let color: NSUIColor?
        public let width: CGFloat
        public let cornerRadius: CGFloat
        public let cornerCurve: CALayerCornerCurve
        
        public init(color: NSUIColor?, width: CGFloat, cornerRadius: CGFloat, cornerCurve: CALayerCornerCurve = .circular) {
            self.color = color
            self.width = width
            self.cornerRadius = cornerRadius
            self.cornerCurve = cornerCurve
        }
    }
}

#if os(macOS)
public extension NSView {
    func configurate(using properties: ContentConfiguration.SkeuomorphBorder) {
        self.cornerRadius = properties.cornerRadius
        self.borderColor = properties.color
        self.borderWidth = properties.width
        self.cornerCurve = properties.cornerCurve
        var borderLayer = self.layer?.sublayers?.first(where: {$0.name == "SkeuomorphBorderLayer"})
        borderLayer?.removeFromSuperlayer()

        if (properties.color != nil || properties.width != 0.0) {
            if borderLayer == nil {
                borderLayer = CALayer()
                borderLayer?.name = "SkeuomorphBorderLayer"
            }
            borderLayer?.borderColor = properties.color?.cgColor
            borderLayer?.borderWidth = properties.width
            borderLayer?.cornerRadius = properties.cornerRadius
            borderLayer?.cornerCurve = properties.cornerCurve
            borderLayer?.masksToBounds = true

            if let layer = self.layer, let borderLayer = borderLayer {
                layer.addSublayer(borderLayer)
              //  layer.addSublayer(withConstraint: <#T##CALayer#>)
                

                borderLayer.sendToBack()
                let constraints = borderLayer.constraintTo(layer: layer)
                constraints[0].constant = properties.width
                constraints[1].constant = properties.width
                constraints[2].constant = properties.width
                constraints[3].constant = properties.width
            }
        }
    }
}
#elseif canImport(UIKit)
public extension UIView {
    func configurate(using properties: ContentConfiguration.SkeuomorphBorder) {
        self.cornerRadius = properties.cornerRadius
        self.borderColor = properties.color
        self.borderWidth = properties.width
        self.cornerCurve = properties.cornerCurve
        var borderLayer = self.layer.sublayers?.first(where: {$0.name == "SkeuomorphBorderLayer"})
        borderLayer?.removeFromSuperlayer()

        if (properties.color != nil || properties.width != 0.0) {
            if borderLayer == nil {
                borderLayer = CALayer()
                borderLayer?.name = "SkeuomorphBorderLayer"
            }
            borderLayer?.borderColor = properties.color?.cgColor
            borderLayer?.borderWidth = properties.width
            borderLayer?.cornerRadius = properties.cornerRadius
            borderLayer?.cornerCurve = properties.cornerCurve
            
            if let borderLayer = borderLayer {
                self.layer.addSublayer(borderLayer)
                borderLayer.sendToBack()
                let constraints = borderLayer.constraintTo(layer: layer)
                constraints[0].constant = properties.width
                constraints[1].constant = properties.width
                constraints[2].constant = properties.width
                constraints[3].constant = properties.width
            }
        }


    }
}
#endif
