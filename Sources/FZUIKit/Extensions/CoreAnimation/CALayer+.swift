//
//  CALayer+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

// import QuartzCore

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
public extension CALayer {
    /// The shadow of the layer.
    dynamic var shadow: ShadowConfiguration {
        get { .init(color: shadowColorDynamic, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point)}
        set {
            shadowColorDynamic = newValue._resolvedColor
            shadowOpacity = Float(newValue.opacity)
            shadowRadius = newValue.radius
            shadowOffset = newValue.offset.size
        }
    }
    
    var shadowColorDynamic: NSUIColor? {
        get { getAssociatedValue(key: "shadowColorDynamic", object: self, initialValue: shadowColor?.nsUIColor) }
        set { set(associatedValue: newValue, key: "shadowColorDynamic", object: self)
            if let parentView = parentView {
                shadowColor = newValue?.resolvedColor(for: parentView).cgColor
            } else {
                shadowColor = newValue?.cgColor
            }
        }
    }
    
    /// The inner shadow of the layer.
    dynamic var innerShadow: ShadowConfiguration {
        get { self.innerShadowLayer?.configuration ?? .none() }
        set { self.configurate(using: newValue, type: .inner) }
    }
    
    /// Sends the layer to the front of it's superlayer.
    func sendToFront() {
        guard let superlayer = superlayer else { return }
        superlayer.addSublayer(self)
    }
    
    /// Sends the layer to the back of it's superlayer.
    func sendToBack() {
        guard let superlayer = superlayer else { return }
        superlayer.insertSublayer(self, at: 0)
    }
    
    /**
     Adds the specified sublayer and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
     - layer: The layer to be added.
     - insets: Insets from the new sublayer border to the layer border.
     */
    func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        self.addSublayer(layer)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Inserts the specified layer at the specified index and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
     - layer: The layer to be added.
     - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
     - insets: Insets from the new sublayer border to the layer border.
     */
    func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
        self.insertSublayer(layer, at: index)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.
     
     - Parameter layer: The layer to constraint to.
     */
    func constraintTo(layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        let layerBoundsUpdate: (()->()) = { [weak self] in
            guard let self = self else { return }
            let frameSize = layer.frame.size
            var shapeRect = CGRect(origin: .zero, size: frameSize)
            if frameSize.width > insets.width, frameSize.height > insets.height {
                shapeRect = shapeRect.inset(by: insets)
            }
            let position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            self.bounds = shapeRect
            self.position = position
        }
        
        let layerUpdate: (()->()) = { [weak self] in
            guard let self = self else { return }
            self.cornerRadius = layer.cornerRadius
            self.maskedCorners = layer.maskedCorners
            self.cornerCurve = layer.cornerCurve
        }
        
        if layerObserver?.observedObject != layer {
            layerObserver = KeyValueObserver(layer)
        }
        
        layerObserver?.add([\.cornerRadius], handler: { keyPath in 
            
        })
        
        layerObserver?.add(\.cornerRadius) { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?.add(\.cornerCurve) { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?.add(\.maskedCorners) { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?.add(\.bounds) { old, new in
            guard old != new else { return }
            layerBoundsUpdate()
        }
        layerBoundsUpdate()
        layerUpdate()
    }
    
    /// Removes the layer constraints.
    func removeConstraints() {
        self.layerObserver = nil
    }
    
    internal var layerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer.boundsObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer.boundsObserver", object: self) }
    }
    
    /// The associated view using the layer.
    var parentView: NSUIView? {
        if let view = delegate as? NSUIView {
            return view
        }
        return superlayer?.parentView
    }
    
    /// A rendered image of the layer.
    var renderedImage: NSUIImage {
        #if os(macOS)
        let btmpImgRep =
        NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.frame.width), pixelsHigh: Int(self.frame.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 32)
        let ctx = NSGraphicsContext(bitmapImageRep: btmpImgRep!)
        let cgContext = ctx!.cgContext
        self.render(in: cgContext)
        let cgImage = cgContext.makeImage()
        let nsimage = NSImage(cgImage: cgImage!, size: CGSize(width: self.frame.width, height: self.frame.height))
        return nsimage
        #else
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, 0)
        self.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
        #endif
    }
    
    /**
     The first superlayer that matches the specificed layer type.
     
     - Parameter layerType: The type of layer to match.
     - Returns: The first parent layer that matches the layer type or `nil` if none match or there isn't a matching parent.
     */
    func firstSuperlayer<V: CALayer>(for layerType: V.Type) -> V? {
        return self.firstSuperlayer(where: {$0 is V}) as? V
    }
    
    /**
     The first superlayer that matches the specificed predicate.
     
     - Parameter predicate: The closure to match.
     - Returns: The first parent layer that is matching the predicate or `nil` if none match or there isn't a matching parent.
     */
    func firstSuperlayer(where predicate: (CALayer)->(Bool)) -> CALayer? {
        if let superlayer = superlayer {
            if predicate(superlayer) == true {
                return superlayer
            }
            return superlayer.firstSuperlayer(where: predicate)
        }
        return nil
    }
    
    /// Returns the first sublayer of a specific type.
    func firstSublayer<V: CALayer>(type _: V.Type) -> V? {
        self.sublayers?.first(where: { $0 is V }) as? V
    }
    
    /**
     An array of all sublayers upto the maximum depth.
     
     - Parameter depth: The maximum depth. A value of 0 will return sublayers of the current layer. A value of 1 e.g. returns sublayers of the current layer and all sublayers of the layers's sublayers.
     */
    func sublayers(depth: Int) -> [CALayer] {
        let sublayers = self.sublayers ?? []
        if depth > 0 {
            return sublayers + sublayers.flatMap { $0.sublayers(depth: depth - 1) }
        } else {
            return sublayers
        }
    }
    
    /**
    An array of all sublayers matching the specified layer type.

     - Parameters:
        - type: The type of sublayers.
        - depth: The maximum depth. A value of 0 will return sublayers of the current layer. A value of 1 e.g. returns sublayers of the current layer and all sublayers of the layers's sublayers.
     */
    func sublayers<V: CALayer>(type _: V.Type, depth: Int = 0) -> [V] {
        self.sublayers(depth: depth).compactMap({$0 as? V})
    }
    
    /**
    An array of all sublayers matching the specified predicte.

     - Parameters:
        - predicate: The predicate to match.
        - depth: The maximum depth. A value of 0 will return sublayers of the current layer. A value of 1 e.g. returns sublayers of the current layer and all sublayers of the layers's sublayers.
     */
    func sublayers(where predicate: (CALayer)->(Bool), depth: Int = 0) -> [CALayer] {
        self.sublayers(depth: depth).filter({predicate($0) == true})
    }
    
    /**
     Removes all sublayers matching the specified layer type.

     - Parameters:
        - type: The type of sublayers to remove.
        - depth: The maximum depth. A value of 0 will return sublayers of the current layer. A value of 1 e.g. returns sublayers of the current layer and all sublayers of the layers's sublayers.
     
     - Returns: The removed layers.
     */
    @discardableResult
    func removeSublayers<V: CALayer>(type: V.Type, depth: Int = 0) -> [V] {
        let removed = sublayers(type: type, depth: depth)
        removed.forEach { $0.removeFromSuperlayer() }
        return removed
    }
    
    /**
     Removes all sublayers matching the specified predicate.
     
     - Parameters:
        - predicate: The predicate to match.
        - depth: The maximum depth. A value of 0 will return sublayers of the current layer. A value of 1 e.g. returns sublayers of the current layer and all sublayers of the layers's sublayers.
     
     - Returns: The removed layers.
     */
    @discardableResult
    func removeSublayers(where predicate: (CALayer)->(Bool), depth: Int = 0) -> [CALayer] {
        let removed = sublayers(where: predicate, depth: depth)
        removed.forEach { $0.removeFromSuperlayer() }
        return removed
    }
    
    /*
     An optional layer whose inverse alpha channel is used to mask the layer’s content.
     
     In contrast to `mask` transparent pixels allow the underlying content to show, while opaque pixels block the content.
     */
    @objc dynamic var inverseMask: CALayer? {
        get { (self.mask as? InverseMaskLayer)?.maskLayer }
        set {
            if let newValue = newValue {
                self.mask = InverseMaskLayer(maskLayer: newValue)
            } else {
                self.mask = nil
            }
        }
    }
}
#endif

#if os(macOS)
public extension CAAutoresizingMask {
    static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
}
#endif


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
