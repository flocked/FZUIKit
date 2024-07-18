//
//  ShapedView.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS) || os(iOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A view with a shape.
open class ShapedView: NSUIView {
    /// The shape.
    open var shape: CornerShape {
        get { shapeLayer?.shape ?? .rectangle }
        set { shapeLayer?.shape = newValue }
    }
    
    /// The color of the shape.
    open var color: NSUIColor {
        get { shapeLayer?.color.nsUIColor ?? .black }
        set { shapeLayer?.color = newValue.cgColor }
    }
    
    /// Initializes and returns a newly allocated `ShapedView` object.
    public init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    /**
     Initializes and returns a newly allocated `ShapedView` object with the specified shape and color.
     
     - Parameters:
        - shape: The shape.
        - color: The color of the shape.
     */
    public init(shape: CornerShape, color: NSUIColor = .black) {
        super.init(frame: .zero)
        sharedInit()
        self.shape = shape
        self.color = color
    }
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        optionalLayer?.masksToBounds = false
        clipsToBounds = false
    }
    
    var shapeLayer: ShapedLayer? {
        layer as? ShapedLayer
    }
    
    #if os(macOS)
    open override func makeBackingLayer() -> CALayer {
        ShapedLayer()
    }
    #else
    open override class var layerClass: AnyClass {
        ShapedLayer.self
    }
    #endif
}

#endif
