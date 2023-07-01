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
import FZSwiftUtils

public extension CALayer {
    /// Sends the layer to the front of it's superlayer.
    func sendToFront() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.addSublayer(self)
    }

    /// Sends the layer to the back of it's superlayer.
    func sendToBack() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.insertSublayer(self, at: 0)
    }
    
    /// Returns the first sublayer of a specific type.
    func firstSublayer<V>(type _: V.Type) -> V? {
        self.sublayers?.first(where: { $0 is V }) as? V
    }
    
    /**
     Adds the specified sublayer and constraints it to the layer.
     
     - Parameters layer: The layer to be added.
     */
    func addSublayer(withConstraint layer: CALayer) {
        self.addSublayer(layer)
        layer.constraintTo(layer: self)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The layer's bounds, cornerRadius and cornerCurve will be constraint to the specified layer. To remove the constraint use `removeConstraints()`.
     
     - Parameters layer: The layer to constraint to.
     */
    func constraintTo(layer: CALayer) {
            let layerUpdateHandler: (()->()) = { [weak self] in
                guard let self = self else { return }
                let frameSize = layer.frame.size
                let shapeRect = CGRect(origin: .zero, size: frameSize)
                let position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
                
                self.cornerRadius = layer.cornerRadius
                self.cornerCurve = layer.cornerCurve
                self.bounds = shapeRect
                self.position = position
                // self.setNeedsDisplay()
            }
            
            if layerObserver?.observedObject != layer {
                layerObserver = KeyValueObserver(layer)
            }
            
        layerObserver?[\.cornerRadius] = { old, new in
                guard old != new else { return }
            layerUpdateHandler()
            }
        
        layerObserver?[\.cornerCurve] = { old, new in
                guard old != new else { return }
            layerUpdateHandler()
            }
            
        layerObserver?[\.bounds] = { old, new in
                guard old != new else { return }
            layerUpdateHandler()
            }
        layerUpdateHandler()
    }
    
    func removeConstraints() {
        self.layerObserver = nil
    }
    
    internal var layerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer.boundsObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer.boundsObserver", object: self) }
    }

    /*
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
    */

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
