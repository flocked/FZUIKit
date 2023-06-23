//
//  CALayer+.swift
//  
//
//  Created by Florian Zand on 07.06.22.
//

import QuartzCore

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension CALayer {
    func sendToFront() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.addSublayer(self)
    }

    func sendToBack() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.insertSublayer(self, at: 0)
    }

    @discardableResult
    func addSublayer(withConstraint layer: CALayer) -> [NSLayoutConstraint] {
        addSublayer(layer)
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
        layer.masksToBounds = true
        return layer.constraintTo(layer: self)
    }

    @discardableResult
    func constraintTo(layer: CALayer) -> [NSLayoutConstraint] {
        frame = layer.bounds
        let constrains = [
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0),
        ]
        constrains.forEach { $0.isActive = true }
        return constrains
    }

    func removeSublayers(type: CALayer.Type) {
        if let sublayers = sublayers {
            for sublayer in sublayers {
                if sublayer.isKind(of: type) {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
    }

    #if os(macOS)
    internal var parentView: NSView? {
        if let view = delegate as? NSView {
            return view
        }
        return superlayer?.parentView
    }
    #endif
}

#if os(macOS)
public extension CAAutoresizingMask {
    static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
}
#endif
