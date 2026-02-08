//
//  ShapeLayer.swift
//  
//
//  Created by Florian Zand on 08.02.26.
//

import Foundation
import FZSwiftUtils
import SwiftUI

/**
 A `CAShapeLayer` subclass with a SwiftUI `Shape`.
 
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
