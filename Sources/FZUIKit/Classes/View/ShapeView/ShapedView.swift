//
//  ShapedView.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public class ShapedView: NSUIView {
    /// The shape.
    public var shape: CornerShape {
        get { shapeLayer?.shape ?? .rectangle }
        set { shapeLayer?.shape = newValue }
    }
    
    /// The color of the shape.
    public var color: NSColor {
        get { shapeLayer?.color.nsColor ?? .black }
        set { shapeLayer?.color = newValue.cgColor }
    }
    
    public init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    public init(shape: CornerShape) {
        super.init(frame: .zero)
        sharedInit()
        self.shape = shape
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        #if os(macOS)
        wantsLayer = true
        #endif
    }
    
    var shapeLayer: ShapedLayer? {
        layer as? ShapedLayer
    }
    
    #if os(macOS)
    public override func makeBackingLayer() -> CALayer {
        ShapedLayer()
    }
    #else
    override public class var layerClass: AnyClass {
        ShapedLayer.self
    }
    #endif
}

#endif
