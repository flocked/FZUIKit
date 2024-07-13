//
//  ShapedLayer.swift
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

public class ShapedLayer: CAShapeLayer {
    /// The shape.
    public var shape: NSView.CornerShape = .rectangle {
        didSet { updateShape() }
    }
    
    /// The color of the shape.
    public var color: CGColor = .black {
        didSet {
            fillColor = shape.needsLayer ? color : nil
            backgroundColor = shape.needsLayer ? nil : color
        }
    }
    
    var _path: NSBezierPath? {
        get { nil }
        set { path = newValue?.cgPath }
    }
    
    public override init() {
        super.init()
    }
    
    public init(shape: NSView.CornerShape) {
        super.init()
        self.shape = shape
        updateShape()
    }
    
    var previousBounds: CGRect = .zero
    public override func layoutSublayers() {
        super.needsLayout()
        guard bounds.size != previousBounds.size else { return }
        previousBounds = bounds
        updateShape()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateShape() {
        switch shape {
        case .circular:
            _path = .circle(bounds.size)
        case .capsule:
            cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0
        case .rounded(let radius):
            cornerRadius = radius
        case .roundedRelative(let value):
            cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0 * value
        case .rectangle:
            cornerRadius = 0
        case .ellipse:
            _path = .ellipse(bounds.size)
        case .star:
            _path = .star(rect: .init(.zero, bounds.size))
        case .starRounded:
            _path = .starRounded(rect: .init(.zero, bounds.size))
        case .path(let path):
            _path = path
        }
        path = shape.needsLayer ? path : nil
        cornerRadius = shape.needsLayer ? 0 : cornerRadius
        fillColor = shape.needsLayer ? color : nil
        backgroundColor = shape.needsLayer ? nil : color
    }
}
#endif
