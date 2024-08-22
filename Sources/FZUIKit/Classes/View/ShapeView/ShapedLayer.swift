//
//  ShapedLayer.swift
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

/*
/// A layer with a shape.
public class ShapedLayer: CAShapeLayer {
    /// The shape.
    public var shape: CornerShape = .rectangle {
        didSet { updateShape() }
    }
    
    public override var border: BorderConfiguration {
        didSet { updateBorder() }
    }
    
    func updateBorder() {
        /*
        if shape.needsLayer {
            strokeColor = border.resolvedColor()?.cgColor
            lineWidth = border.width
        } else {
            strokeColor = nil
            lineWidth = 0.0
        }
         */
    }
    
    /// The color of the shape.
    public var color: CGColor = .black {
        didSet {
            fillColor = shape.needsLayer ? color : nil
            backgroundColor = shape.needsLayer ? nil : color
        }
    }
    
    var _path: NSUIBezierPath? {
        get { nil }
        set { 
            #if os(macOS)
            path = newValue?.cgpath
            #else
            path = newValue?.cgPath
            #endif
        }
    }
    
    public override init() {
        super.init()
    }
    
    /**
     Initializes and returns a newly allocated `ShapedLayer` object with the specified shape and color.
     
     - Parameters:
        - shape: The shape.
        - color: The color of the shape.
     */
    public init(shape: CornerShape, color: CGColor = .black) {
        super.init()
        self.shape = shape
        self.color = color
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
        case .normal:
            cornerRadius = 0
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
        updateBorder()
    }
}

/*
extension CAShapeLayer {
    convenience init(shape: CornerShape) {
        self.init()
        self._shape = shape
    }
    
    var _shape: CornerShape {
        get { getAssociatedValue("_shape", initialValue: .normal) }
        set {
            setAssociatedValue(newValue, key: "_shape")
            _updateShape()
        }
    }
    
    @discardableResult
    func _shape(_ shape: CornerShape) -> Self {
        _shape = shape
        return self
    }
    
    func _updateShape() {
        isUpdatingShape = true
        switch _shape {
        case .normal:
            cornerRadius = 0
        case .circular:
            path = NSUIBezierPath.circle(bounds.size).cgPath
        case .capsule:
            cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0
        case .rounded(let radius):
            cornerRadius = radius
        case .roundedRelative(let value):
            cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0 * value
        case .rectangle:
            cornerRadius = 0
        case .ellipse:
            path = NSUIBezierPath.ellipse(bounds.size).cgPath
        case .star:
            path = NSUIBezierPath.star(rect: .init(.zero, bounds.size)).cgPath
        case .starRounded:
            path = NSUIBezierPath.starRounded(rect: .init(.zero, bounds.size)).cgPath
        case .path(let bezierPath):
            path = bezierPath.cgPath
        }
        path = _shape.needsLayer ? path : nil
        cornerRadius = _shape.needsLayer ? 0 : cornerRadius
        fillColor = _shape.needsLayer ? .black : nil
        backgroundColor = _shape.needsLayer ? nil : .black
        isUpdatingShape = false
        if _shape.isNormal {
            shapeLayerObserver = nil
        } else if shapeLayerObserver == nil {
            shapeLayerObserver = KeyValueObserver(self)
            shapeLayerObserver?.add(\.frame) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self._updateShape()
            }
            shapeLayerObserver?.add(\.cornerRadius) { [weak self] old, new in
                guard let self = self, old != new, !self.isUpdatingShape else { return }
                self._shape = .normal
            }
            shapeLayerObserver?.add(\.path) { [weak self] old, new in
                guard let self = self, old != new, !self.isUpdatingShape else { return }
                self._shape = .normal
            }
        }
    }
    
    var shapeLayerObserver: KeyValueObserver<CAShapeLayer>? {
        get { getAssociatedValue("shapeLayerObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "shapeLayerObserver") }
    }
    
    var isUpdatingShape: Bool {
        get { getAssociatedValue("isUpdatingShape", initialValue: false) }
        set { setAssociatedValue(newValue, key: "isUpdatingShape") }
    }
}
 */
 */
#endif
