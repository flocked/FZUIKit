//
//  ShapeLayer.swift
//  
//
//  Created by Florian Zand on 08.02.26.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import FZSwiftUtils
import SwiftUI

#if os(macOS) || os(iOS)
extension CAShapeLayer {
    /**
     The `SwiftUI` [Shape](https://developer.apple.com/documentation/SwiftUI/Shape) displayed by this layer.

     Assigning a shape to this property makes the layer automatically reflect the shape's path, updating whenever the layer's bounds change. The shape will scale and adjust to match the layer’s current size.

     Example usage:
     ```swift
     let layer = CAShapeLayer()
     layer.shape = Circle()
     ```
    */
    public var _shape: (any Shape)? {
        get { getAssociatedValue("_shape") }
        set {
            setAssociatedValue(newValue, key: "_shape")
            try? layoutSublayersHook?.revert()
            if let newValue = newValue {
                do {
                    try hookAfter(#selector(CALayer.layoutSublayers)) { layer, selector in
                        layer.path = newValue.path(in: layer.bounds).cgPath
                    }
                    setNeedsLayout()
                } catch {
                    Swift.print(error)
                }
            }
        }
    }
    
    /**
     Creates a shape layer with the specified `SwiftUI` [Shape](https://developer.apple.com/documentation/SwiftUI/Shape).
     
     Assigning a shape to this property makes the layer automatically reflect the shape's path, updating whenever the layer's bounds change. The shape will scale and adjust to match the layer’s current size.
     */
    public convenience init(_shape: (any Shape)) {
        self.init()
        self._shape = _shape
    }
    
    var layoutSublayersHook: Hook? {
        get { getAssociatedValue("layoutSublayersHook") }
        set { setAssociatedValue(newValue, key: "layoutSublayersHook") }
    }
}
#endif

/**
 A `CAShapeLayer` subclass with a `SwiftUI` [Shape](https://developer.apple.com/documentation/SwiftUI/Shape).
 
 The layer automatically updates its `path` to the ``shape``  whenever its `bounds` changes.
 
 It can be used for vector drawing or as a mask.
*/
open class ShapeLayer: CAShapeLayer {
    private var observation: KeyValueObservation?
    
    /// The shape of the layer.
    open var shape: (any Shape)? {
        didSet { setNeedsLayout() }
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        path = shape?.path(in: bounds).cgPath
    }
    
    /// Creates a shape layer with the specified shape.
    public init(shape: any Shape) {
        self.shape = shape
        super.init()
    }
    
    /// Creates an empty shape layer.
    public override init() {
        super.init()
    }
                
    init(layer: CALayer, shape: any Shape) {
        self.shape = shape
        super.init()
        bounds = layer.bounds
        position = CGPoint(x: bounds.midX, y: bounds.midY)
        layer.mask = self
        observation = layer.observeChanges(for: \.bounds) { [weak self] old, new in
            guard let self = self else { return }
            self.bounds = new
            self.position = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
