//
//  CALayer+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

extension CALayer {
    /// Sets the layer’s frame rectangle.
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    /// Sets the layer’s bounds rectangle.
    @discardableResult
    public func bounds(_ bounds: CGRect) -> Self {
        self.bounds = bounds
        return self
    }
    
    /// Sets the Boolean indicating whether the layer is displayed.
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    /// Sets the Boolean value indicating whether the layer contains completely opaque content.
    @discardableResult
    public func isOpaque(_ isOpaque: Bool) -> Self {
        self.isOpaque = isOpaque
        return self
    }
    
    /// Sets the opacity of the layer.
    public func opacity(_ opacity: Float) -> Self {
        self.opacity = opacity
        return self
    }
    
    /// Sets the radius to use when drawing rounded corners for the layer’s background.
    public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    /// Sets the object that provides the contents of the layer.
    @discardableResult
    public func contents(_ contents: Any?) -> Self {
        self.contents = contents
        return self
    }
    
    /// Sets the that specifies how the layer’s contents are positioned or scaled within its bounds.
    @discardableResult
    public func contentsGravity(_ contentsGravity: CALayerContentsGravity) -> Self {
        self.contentsGravity = contentsGravity
        return self
    }
    
    /// Sets the rectangle, in the unit coordinate space, that defines the portion of the layer’s contents that should be used.
    @discardableResult
    public func contentsRect(_ contentsRect: CGRect) -> Self {
        self.contentsRect = contentsRect
        return self
    }
    
    /// Sets the rectangle that defines how the layer contents are scaled if the layer’s contents are resized.
    public func contentsCenter(_ contentsCenter: CGRect) -> Self {
        self.contentsCenter = contentsCenter
        return self
    }
    
    /// Sets the Boolean indicating whether sublayers are clipped to the layer’s bounds.
    @discardableResult
    public func masksToBounds(_ masksToBounds: Bool) -> Self {
        self.masksToBounds = masksToBounds
        return self
    }
    
    /// Sets the Boolean indicating whether the layer displays its content when facing away from the viewer.
    @discardableResult
    public func isDoubleSided(_ isDoubleSided: Bool) -> Self {
        self.isDoubleSided = isDoubleSided
        return self
    }
    
    /// Sets the masked corners of the layer.
    @discardableResult
    public func maskedCorners(_ maskedCorners: CACornerMask) -> Self {
        self.maskedCorners = maskedCorners
        return self
    }
    
    /// The background color of the receiver.
    @discardableResult
    public func backgroundColor(_ backgroundColor: CGColor?) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    /// Sets the Boolean indicating whether the layer is allowed to perform edge antialiasing.
    @discardableResult
    public func allowsEdgeAntialiasing(_ allows: Bool) -> Self {
        self.allowsEdgeAntialiasing = allows
        return self
    }
    
    /// Sets the Boolean indicating whether the layer is allowed to composite itself as a group separate from its parent.
    @discardableResult
    public func allowsGroupOpacity(_ allows: Bool) -> Self {
        self.allowsGroupOpacity = allows
        return self
    }
    
    /// Sets the layer’s position on the z axis.
    @discardableResult
    public func zPosition(_ zPosition: CGFloat) -> Self {
        self.zPosition = zPosition.clamped(to: -CGFloat(Float.greatestFiniteMagnitude)...CGFloat(Float.greatestFiniteMagnitude))
        return self
    }
    
    /// Sets the anchor point for the layer’s position.
    @discardableResult
    public func anchorPoint(_ anchorPoint: CGPoint) -> Self {
        self.anchorPoint = anchorPoint
        return self
    }
    
    /// Sets the anchor point for the layer’s position along the z axis.
    @discardableResult
    public func anchorPointZ(_ anchorPointZ: CGFloat) -> Self {
        self.anchorPointZ = anchorPointZ
        return self
    }
    
    /// Sets the scale factor applied to the layer.
    @discardableResult
    public func contentsScale(_ contentsScale: CGFloat) -> Self {
        self.contentsScale = contentsScale
        return self
    }
    
    /// Sets transform applied to the layer’s contents.
    @discardableResult
    public func transform(_ transform: CATransform3D) -> Self {
        self.transform = transform
        return self
    }
    
    /// Sets the transform to apply to sublayers when rendering.
    @discardableResult
    public func sublayerTransform(_ transform: CATransform3D) -> Self {
        self.sublayerTransform = transform
        return self
    }
    
    #if os(macOS)
    /// Sets the autoresizing mask of the layer.
    @discardableResult
    public func autoresizingMask(_ mask: CAAutoresizingMask) -> Self {
        self.autoresizingMask = mask
        return self
    }
    #endif
    
    /// Sets the name of the layer.
    @discardableResult
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// The translation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform) on the x- and y-coordinate.
    public var translation: CGPoint {
        get { transform.translation.asPoint }
        set { CATransaction.disabledActions { transform.translation = Translation(newValue.x, newValue.y, transform.translation.z) } }
    }
    
    /// Sets the translation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform) on the x- and y-coordinate.
    @discardableResult
    public func translation(_ translation: CGPoint) -> Self {
        self.translation = translation
        return self
    }
    
    /// The translation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    public var translationXYZ: Translation {
        get { transform.translation }
        set { CATransaction.disabledActions { transform.translation = newValue } }
    }
    
    /// Sets the translation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    @discardableResult
    public func translationXYZ(_ translation: Translation) -> Self {
        self.translationXYZ = translation
        return self
    }
    
    /// The scale of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    public var scale: Scale {
        get { transform.scale.scale }
        set { CATransaction.disabledActions { transform.scale = newValue.vector } }
    }
    
    /// Sets the scale of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    @discardableResult
    public func scale(_ scale: Scale) -> Self {
        self.scale = scale
        return self
    }
    
    /// The rotation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform), in degrees.
    public var rotation: Rotation {
        get { transform.eulerAnglesDegrees.rotation }
        set { CATransaction.disabledActions { transform.eulerAnglesDegrees = newValue.vector } }
    }
    
    /// Sets the rotation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform), in degrees.
    @discardableResult
    public func rotation(_ rotation: Rotation) -> Self {
        self.rotation = rotation
        return self
    }
    
    /// The rotation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform), in radians.
    public var rotationInRadians: Rotation {
        get { transform.eulerAngles.rotation }
        set { CATransaction.disabledActions { transform.eulerAngles = newValue.vector } }
    }
    
    /// Sets the rotation of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform), in radians.
    @discardableResult
    public func rotationInRadians(_ rotation: Rotation) -> Self {
        self.rotationInRadians = rotation
        return self
    }
    
    /// The shearing of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    public var skew: Skew {
        get { transform.skew }
        set { CATransaction.disabledActions { transform.skew = newValue } }
    }
    
    /// Sets the shearing of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform).
    @discardableResult
    public func skew(_ skew: Skew) -> Self {
        self.skew = skew
        return self
    }
    
    /// The perspective of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform) (e.g. .m34).
    public var perspective: Perspective {
        get { transform.perspective }
        set { CATransaction.disabledActions { transform.perspective = newValue } }
    }
    
    /// Sets the perspective of the layer's [transform](https://developer.apple.com/documentation/quartzcore/calayer/transform) (e.g. .m34).
    @discardableResult
    public func perspective(_ Perspective: Skew) -> Self {
        self.perspective = perspective
        return self
    }
    
    /// Sets the image as the [contents](https://developer.apple.com/documentation/quartzcore/calayer/contents) of the layer.
    @discardableResult
    public func image(_ image: CGImage?) -> Self {
        contents = image
        return self
    }
    
    /// Sets the image as the [contents](https://developer.apple.com/documentation/quartzcore/calayer/contents) of the layer.
    @discardableResult
    public func image(_ image: NSUIImage) -> Self {
        #if os(macOS)
        if let screen = parentView?.window?.screen {
            contents = image.scaledLayerContents(for: screen)
        } else {
            contents = image.scaledLayerContents
        }
        #else
        contents = image
        #endif
        return self
    }
    
    /**
     A Boolean value indicating whether the layer is a sublayer of the specified layer.
     
     The method returns `true` if the layer is either an immediate or distant sublayer of `layer`.
     
     - Parameter layer: The layer to test for sublayer relationship within the layer hierarchy.
     - Returns: `true` if the layer is a sublayer, or distant sublayer, of the specified layer.
     */
    func isDescendant(of layer: CALayer) -> Bool {
        var current: CALayer? = self
        while let currentLayer = current {
            if currentLayer === layer {
                return true
            }
            current = currentLayer.superlayer
        }
        return false
    }
    
    /**
     The center point of the layer's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     
     Use this property, instead of the frame property, when you want to change the position of a layer. The center point is always valid, even when scaling or rotation factors are applied to the layer's transform.
     */
    @objc open var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// Sets the the center point of the layer's frame rectangle.
    @discardableResult
    public func center(_ center: CGPoint) -> Self {
        self.center = center
        return self
    }
    
    /// The shadow of the layer.
    @objc open var shadow: ShadowConfiguration {
        get { configurations.shadow }
        set {
            configurations.shadow = newValue
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #else
            setupShadowShapeLayer()
            #endif
        }
    }
    
    /// Sets the shadow of the layer.
    @discardableResult
    public func shadow(_ shadow: ShadowConfiguration) -> Self {
        self.shadow = shadow
        return self
    }
    
    /// The inner shadow of the layer.
    @objc open var innerShadow: ShadowConfiguration {
        get { configurations.innerShadow }
        set { configurations.innerShadow = newValue }
    }
    
    /// Sets the inner shadow of the layer.
    @discardableResult
    public func innerShadow(_ innerShadow: ShadowConfiguration) -> Self {
        self.innerShadow = innerShadow
        return self
    }
    
    fileprivate var innerShadowLayer: InnerShadowLayer? {
        get { getAssociatedValue("innerShadowLayer") }
        set { setAssociatedValue(newValue, key: "innerShadowLayer") }
    }
    
    fileprivate var _innerShadowLayer: InnerShadowLayer {
        getAssociatedValue("_innerShadowLayer", initialValue: InnerShadowLayer(for: self) )
    }
    
    var innerShadowColor: CGColor? {
        get { innerShadowLayer?.shadowColor }
        set { innerShadowLayer?.shadowColor = newValue }
    }
    
    /// Sets the layer whose alpha channel is used to mask the layer’s content.
    @discardableResult
    public func mask(_ mask: CALayer?) -> Self {
        self.mask = mask
        return self
    }
    
    /// The shape that is used for masking the layer.
    public var maskShape: (any Shape)? {
        get { (mask as? ShapeLayer)?.shape }
        set {
            if let newValue = newValue {
                (mask as? ShapeLayer ?? ShapeLayer(layer: self, shape: newValue)).shape = newValue
            } else if mask is ShapeLayer {
                mask = nil
            }
            if !didUpdateShadowShapManually {
                shadowShape = newValue
                didUpdateShadowShapManually = false
            }
            innerShadowLayer?.shape = newValue
            configurations.setupBorder()
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #else
            setupShadowShapeLayer()
            #endif
        }
    }
    
    /// Sets the shape that is used for masking the layer.
    @discardableResult
    public func maskShape(_ shape: (any Shape)?) -> Self {
        self.maskShape = shape
        return self
    }
    
    /// Sets the shape of the layer’s shadow.
    @discardableResult
    public func shadowPath(_ path: CGPath?) -> Self {
        self.shadowPath = path
        return self
    }
    
    /// The shape of the shadow.
    public var shadowShape: (any Shape)? {
        get { getAssociatedValue("shadowShape") }
        set {
            setAssociatedValue(newValue, key: "shadowShape")
            didUpdateShadowShapManually = true
            if let newValue = newValue {
                shadowShapeObservation = observeChanges(for: \.bounds) { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.shadowPath = newValue.path(in: new).cgPath
                }
                shadowPath = newValue.path(in: bounds).cgPath
            } else {
                shadowShapeObservation = nil
            }
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #endif
        }
    }
    
    var didUpdateShadowShapManually: Bool {
        get { getAssociatedValue("didUpdateShadowShapManually") ?? false }
        set { setAssociatedValue(newValue, key: "didUpdateShadowShapManually") }
    }
    
    /// Sets the shape of the shadow.
    @discardableResult
    public func shadowShape(_ shape: (any Shape)?) -> Self {
        self.shadowShape = shape
        return self
    }
    
    fileprivate var shadowShapeObservation: KeyValueObservation? {
        get { getAssociatedValue("shadowShapeObservation") }
        set { setAssociatedValue(newValue, key: "shadowShapeObservation") }
    }
    
    /// The border of the layer.
    @objc open var border: BorderConfiguration {
        get { configurations.border }
        set { configurations.border = newValue }
    }
    
    /// Sets the border of the layer.
    @discardableResult
    public func border(_ border: BorderConfiguration) -> Self {
        self.border = border
        return self
    }
    
    fileprivate var borderLayer: BorderLayer? {
        get { getAssociatedValue("borderLayer") }
        set { setAssociatedValue(newValue, key: "borderLayer") }
    }
    
    var _borderColor: CGColor? {
        get { borderLayer?.configuration.color?.cgColor ?? borderColor }
        set {
            if let borderLayer = borderLayer {
                borderLayer.strokeColor = newValue
            } else {
                borderColor = newValue
            }
        }
    }
    
    /// The gradient of the layer.
    public var gradient: Gradient? {
        get { configurations.gradient }
        set { configurations.gradient = newValue }
    }
    
    var gradientColors: [CGColor] {
        get { (self as? CAGradientLayer ?? _gradientLayer)?.colors as? [CGColor] ?? [] }
        set { (self as? CAGradientLayer ?? _gradientLayer)?.colors = newValue }
    }
    
    private var _gradientLayer: CAGradientLayer? {
        firstSublayer(named: "_gradientLayer") as? CAGradientLayer
    }
    
    #if !os(macOS)
    func setupShadowShapeLayer() {
        guard !(self is ShadowShapeLayer) else { return }
        if shadowShape == nil || maskShape == nil || !shadow.isVisible {
            shadowShapeLayer?.removeFromSuperlayer()
            shadowShapeLayer = nil
        } else if shadowShapeLayer == nil {
            shadowShapeLayer = ShadowShapeLayer(for: self)
        }
        shadowShapeLayer?.shadow = shadow
        shadowShapeLayer?.shadowShape = shadowShape
    }
    
    var shadowShapeLayer: ShadowShapeLayer? {
        get { getAssociatedValue("shadowShapeLayer") }
        set { setAssociatedValue(newValue, key: "shadowShapeLayer") }
    }
    
    class ShadowShapeLayer: CALayer {
        var layerObservation: KeyValueObserver<CALayer>!
        var superlayerObservation: KeyValueObservation?
        weak var layer: CALayer?
        
        init(for layer: CALayer) {
            super.init()
            self.layer = layer
            layerObservation = KeyValueObserver(layer)
            isHidden = layer.isHidden
            opacity = layer.opacity
            zPosition = layer.zPosition - 1
            anchorPoint = layer.anchorPoint
            bounds = layer.bounds
            position = layer.position
            layer.superlayer?.insertSublayer(self, below: layer)
            layerObservation.add(\.superlayer) { [weak self] old, superlayer in
                guard let self = self, let layer = self.layer else { return }
                self.removeFromSuperlayer()
                superlayer?.insertSublayer(self, below: layer)
            }
            layerObservation.add(\.isHidden) { [weak self] old, new in
                self?.isHidden = new
            }
            layerObservation.add(\.opacity) { [weak self] old, new in
                self?.opacity = new
            }
            layerObservation.add(\.bounds) { [weak self] old, new in
                self?.bounds = new
            }
            layerObservation.add(\.position) { [weak self] old, new in
                self?.position = new
            }
            layerObservation.add(\.anchorPoint) { [weak self] old, new in
                self?.anchorPoint = new
            }
            layerObservation.add(\.zPosition) { [weak self] old, new in
                self?.zPosition = new-1
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    #endif

    class Configurations {
        var border: BorderConfiguration {
            get {
                guard let layer = layer else { return .none }
                if let borderLayer = layer.borderLayer {
                    return borderLayer.configuration
                }
                _border.color = layer.parentView?.dynamicColors[\._borderColor] ?? layer._borderColor?.nsUIColor
                _border.width = layer.borderWidth
                return _border
            }
            set {
                guard let layer = layer else { return }
                _border = newValue
                var newValue = newValue
                if !Self.hasActiveGrouping {
                    if layer.resolvedColor(for: newValue.resolvedColor()) == nil, _border.color?.isVisible == true {
                        newValue.color = .clear
                    } else if !_border.isVisible, let color = newValue.resolvedColor() {
                        if let parentView = layer.parentView {
                            _border.color = color.resolvedColor(for: parentView).opacity(0.0)
                        } else {
                            _border.color = color.opacity(0.0)
                        }
                        CATransaction.disabledActions {
                            setupBorder()
                        }
                    }
                }
                layer.parentView?.dynamicColors[\._borderColor] = newValue.resolvedColor()
                setupBorder()
            }
        }
        
        func setupBorder() {
            guard let layer = layer else { return }
            if (layer.maskShape != nil && _border.isVisible) || _border.needsDashedBorder {
                if layer.borderLayer == nil {
                    layer.borderLayer = BorderLayer(for: layer)
                }
                layer.borderLayer?.shape = layer.maskShape
                layer.borderLayer?.configuration = _border
                layer.borderWidth = 0.0
                layer.borderColor = nil
            } else {
                layer.borderColor = layer.borderLayer?.borderColor ?? layer.borderColor
                layer.borderLayer?.removeFromSuperlayer()
                layer.borderLayer = nil
                layer.borderColor = layer.resolvedColor(for: _border.resolvedColor())
                layer.borderWidth = _border.width
            }
        }
        
        var shadow: ShadowConfiguration {
            get {
                guard let layer = layer else { return .none }
                _shadow.color = layer.parentView?.dynamicColors[\.shadowColor] ?? layer.shadowColor?.nsUIColor
                _shadow.radius = layer.shadowRadius
                _shadow.offset = layer.shadowOffset.point
                _shadow.opacity = CGFloat(layer.shadowOpacity)
                return _shadow
            }
            set {
                guard let layer = layer else { return }
                _shadow = newValue
                var newValue = newValue
                if !Self.hasActiveGrouping {
                    if layer.resolvedColor(for: newValue.resolvedColor()) == nil, _shadow.color?.isVisible == true {
                        newValue.color = .clear
                    } else if !_shadow.isVisible, let color = newValue.resolvedColor() {
                        CATransaction.disabledActions {
                            if let parentView = layer.parentView {
                                layer.shadowColor = color.resolvedColor(for: parentView).opacity(0.0).cgColor
                            } else {
                                layer.shadowColor = color.opacity(0.0).cgColor
                            }
                        }
                    }
                }
                layer.parentView?.dynamicColors[\.shadowColor] = newValue.resolvedColor()
                layer.shadowColor = layer.resolvedColor(for: newValue.resolvedColor())
                layer.shadowRadius = newValue.radius
                layer.shadowOffset = newValue.offset.size
                layer.shadowOpacity = Float(newValue.opacity)
                #if os(macOS)
                layer.parentView?.setupShadowShapeView()
                #else
                layer.setupShadowShapeLayer()
                #endif
            }
        }
        
        var innerShadow: ShadowConfiguration {
            get { _innerShadow }
            set {
                guard let layer = layer else { return }
                _innerShadow = newValue
                if !newValue.isVisible {
                    layer.innerShadowLayer?.removeFromSuperlayer()
                    layer.innerShadowLayer = nil
                } else if layer.innerShadowLayer == nil {
                    layer.innerShadowLayer = InnerShadowLayer(for: layer)
                }
                var newValue = newValue
                if !Self.hasActiveGrouping {
                    if layer.resolvedColor(for: newValue.resolvedColor()) == nil, _innerShadow.color?.isVisible == true {
                        newValue.color = .clear
                    } else if !_innerShadow.isVisible, let color = newValue.resolvedColor() {
                        CATransaction.disabledActions {
                            if let parentView = layer.parentView {
                                layer.innerShadowLayer?.shadowColor  = color.resolvedColor(for: parentView).opacity(0.0).cgColor
                            } else {
                                layer.innerShadowLayer?.shadowColor = color.opacity(0.0).cgColor
                            }
                        }
                    }
                }
                layer.parentView?.dynamicColors[\.innerShadowColor] = newValue.color
                layer.innerShadowLayer?.configuration = newValue
            }
        }
        
        var backgroundColor: NSUIColor? {
            get { layer?.parentView?.dynamicColors[\.backgroundColor] ?? layer?.backgroundColor?.nsUIColor }
            set {
                guard let layer = layer else { return }
                var newValue = newValue
                if !Self.hasActiveGrouping {
                    if layer.resolvedColor(for: newValue) == nil, layer.backgroundColor?.alpha ?? 0.0 > 0.0 {
                        newValue = .clear
                    } else if layer.backgroundColor?.alpha ?? 1.0 <= 0.0, let color = newValue {
                        CATransaction.disabledActions {
                            layer.backgroundColor = color.opacity(0.0).cgColor
                        }
                    }
                }
                layer.parentView?.dynamicColors[\.backgroundColor] = newValue
                layer.backgroundColor = layer.resolvedColor(for: newValue)
            }
        }
        
        var gradient: Gradient? {
            get {
                guard let layer = layer else { return nil }
                if let layer = layer as? CAGradientLayer {
                    let colors = layer.parentView?.dynamicColors.gradientColors ?? (layer.colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
                    let locations = layer.locations?.map { CGFloat($0.floatValue) } ?? []
                    _gradient?.stops = zip(colors, locations).map({ .init(color: $0.0, location: $0.1) })
                    _gradient?.startPoint = .init(layer.startPoint.x, layer.startPoint.y)
                    _gradient?.endPoint = .init(layer.endPoint.x, layer.endPoint.y)
                    _gradient?.type = .init(layer.type)
                } else if let gradient = _gradient {
                    _gradient?.colors = layer.parentView?.dynamicColors.gradientColors ?? gradient.colors
                }
                return _gradient
            }
            set {
                guard let layer = layer else { return }
                _gradient = newValue
                layer.parentView?.dynamicColors.gradientColors = newValue?.colors ?? []
                if let newValue = newValue, !newValue.stops.isEmpty {
                    if let layer = layer as? CAGradientLayer {
                        layer._gradient = newValue
                    } else {
                        if let gradientLayer = layer._gradientLayer {
                            gradientLayer._gradient = newValue
                        } else {
                            let gradientLayer = CAGradientLayer().name("_gradientLayer")
                            layer.addSublayer(withConstraint: gradientLayer)
                            gradientLayer.sendToBack()
                            gradientLayer.zPosition(-CGFloat.greatestFiniteMagnitude)
                            gradientLayer._gradient = newValue
                        }
                    }
                } else {
                    if let layer = layer as? CAGradientLayer {
                        layer.colors = nil
                    } else {
                        layer._gradientLayer?.removeFromSuperlayer()
                    }
                }
            }
        }
        
        private weak var layer: CALayer?
        private var _border: BorderConfiguration
        private var _shadow: ShadowConfiguration
        private var _innerShadow: ShadowConfiguration = .none
        private var _gradient: Gradient?
        
        private static var hasActiveGrouping: Bool {
            #if os(macOS)
            NSAnimationContext.hasActiveGrouping
            #else
            false
            #endif
        }
        
        init(for layer: CALayer) {
            self.layer = layer
            _shadow = .init(color: layer.parentView?.dynamicColors[\.shadowColor] ?? layer.shadowColor?.nsUIColor, opacity: CGFloat(layer.shadowOpacity), radius: layer.shadowRadius, offset: layer.shadowOffset.point)
            if let layer = layer as? CAShapeLayer {
                _border = .init(color: layer.parentView?.dynamicColors[\._borderColor] ?? layer.strokeColor?.nsUIColor, width: layer.lineWidth, dash: .init(layer))
            } else {
                _border = .init(color: layer.parentView?.dynamicColors[\._borderColor] ?? layer.borderColor?.nsUIColor, width: layer.borderWidth)
            }
            _gradient = (layer as? CAGradientLayer)?._gradient
        }
    }
    
    var configurations: Configurations {
        getAssociatedValue("LayerConfigurations", initialValue: Configurations(for: self))
    }
    
    func resolvedColor(for color: NSUIColor?) -> CGColor? {
        guard let view = parentView, let color = color else { return nil }
        return color.resolvedColor(for: view).cgColor
    }
    
    /// Sends the layer to the front of it's superlayer.
    @objc open func sendToFront() {
        guard let superlayer = superlayer else { return }
        superlayer.addSublayer(self)
    }
    
    /// Sends the layer to the back of it's superlayer.
    @objc open func sendToBack() {
        guard let superlayer = superlayer else { return }
        superlayer.insertSublayer(self, at: 0)
    }
    
    /**
     Adds the specified sublayer and constraints it to the layer.
     
     The layer's [bounds](https://developer.apple.com/documentation/quartzcore/calayer/bounds) and [position](https://developer.apple.com/documentation/quartzcore/calayer/position) are updated to follow the specified layer.
     
     Optionally, [cornerRadius](https://developer.apple.com/documentation/quartzcore/calayer/cornerradius), [maskedCorners](https://developer.apple.com/documentation/quartzcore/calayer/maskedCorners), and [cornerCurve](https://developer.apple.com/documentation/quartzcore/calayer/cornerCurve) can also be synced.

     To remove the constraints use ``QuartzCore/CALayer/removeConstraints()``.

     - Parameters:
        - layer: The layer to be added.
        - insets: Insets from the new sublayer border to the layer border.
        - includeAppearance: A Boolean value indicating whether to also sync `cornerRadius`, `maskedCorners`, and `cornerCurve`.
     */
    @objc open func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero, includeAppearance: Bool = true) {
        addSublayer(layer)
        layer.constraint(to: self, insets: insets, includeAppearance: includeAppearance)
    }
    
    /**
     Inserts the specified layer at the specified index and constraints it to the layer.
     
     The layer's [bounds](https://developer.apple.com/documentation/quartzcore/calayer/bounds) and [position](https://developer.apple.com/documentation/quartzcore/calayer/position) are updated to follow the specified layer.
     
     Optionally, [cornerRadius](https://developer.apple.com/documentation/quartzcore/calayer/cornerradius), [maskedCorners](https://developer.apple.com/documentation/quartzcore/calayer/maskedCorners), and [cornerCurve](https://developer.apple.com/documentation/quartzcore/calayer/cornerCurve) can also be synced.

     To remove the constraints use ``QuartzCore/CALayer/removeConstraints()``.

     - Parameters:
        - layer: The layer to be added.
        - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
        - insets: Insets from the new sublayer border to the layer border.
        - includeAppearance: A Boolean value indicating whether to also sync `cornerRadius`, `maskedCorners`, and `cornerCurve`.
     */
    @objc open func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero, includeAppearance: Bool = true) {
        guard index >= 0, index < sublayers?.count ?? Int.max else { return }
        insertSublayer(layer, at: index)
        layer.constraint(to: self, insets: insets, includeAppearance: includeAppearance)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The layer's [bounds](https://developer.apple.com/documentation/quartzcore/calayer/bounds) and [position](https://developer.apple.com/documentation/quartzcore/calayer/position) are updated to follow the specified layer.
     
     Optionally, [cornerRadius](https://developer.apple.com/documentation/quartzcore/calayer/cornerradius), [maskedCorners](https://developer.apple.com/documentation/quartzcore/calayer/maskedCorners), and [cornerCurve](https://developer.apple.com/documentation/quartzcore/calayer/cornerCurve) can also be synced.

     To remove the constraints use ``QuartzCore/CALayer/removeConstraints()``.
     
     - Parameters:
        - layer: The layer to constraint to.
        - insets: The insets.
        - includeAppearance: A Boolean value indicating whether to also sync `cornerRadius`, `maskedCorners`, and `cornerCurve`.
     */
    @objc open func constraint(to layer: CALayer, insets: NSDirectionalEdgeInsets = .zero, includeAppearance: Bool = true) {
        let frameUpdate: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            self.bounds = layer.bounds.inset(by: insets)
            self.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
        if includeAppearance {
            cornerRadius = layer.cornerRadius
            maskedCorners = layer.maskedCorners
            cornerCurve = layer.cornerCurve
        }
        if constrainLayerObserver?.observedObject != layer {
            constrainLayerObserver = KeyValueObserver(layer)
        }
        constrainLayerObserver?.add(\.bounds) { old, new in
            guard old != new else { return }
            frameUpdate()
        }
        if includeAppearance {
            constrainLayerObserver?.add(\.cornerRadius) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.cornerRadius = new
            }
            constrainLayerObserver?.add(\.cornerCurve) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.cornerCurve = new
            }
            constrainLayerObserver?.add(\.maskedCorners) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.maskedCorners = new
            }
        } else {
            constrainLayerObserver?.remove([\.cornerRadius, \.cornerCurve, \.maskedCorners])
        }
        frameUpdate()
        if superlayer == layer {
            superLayerObservation = observeChanges(for: \.superlayer) { [weak self] old, new in
                guard let self = self, new != layer else { return }
                self.removeConstraints()
            }
        } else {
            superLayerObservation = nil
        }
    }
    
    /// Removes the layer constraints.
    @objc open func removeConstraints() {
        constrainLayerObserver = nil
        superLayerObservation = nil
    }
    
    private var superLayerObservation: KeyValueObservation? {
        get { getAssociatedValue("superLayerObservation") }
        set { setAssociatedValue(newValue, key: "superLayerObservation") }
    }
    
    private var constrainLayerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue("constrainLayerObserver") }
        set { setAssociatedValue(newValue, key: "constrainLayerObserver") }
    }
    
    /// The associated view using the layer.
    @objc open var parentView: NSUIView? {
        delegate as? NSUIView ?? superlayer?.parentView
    }
    
    /// A rendered image of the layer.
    @objc open var renderedImage: CGImage? {
        let width = Int(bounds.width * contentsScale)
        let height = Int(bounds.height * contentsScale)
        guard width > 0, height > 0 else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        context.scaleBy(x: contentsScale, y: contentsScale)
        render(in: context)
        return context.makeImage()
    }
    
    /**
     The first superlayer that matches the specificed layer type.
     
     - Parameter layerType: The type of layer to match.
     - Returns: The first parent layer that matches the layer type or `nil` if none match or there isn't a matching parent.
     */
    public func firstSuperlayer<V: CALayer>(for _: V.Type) -> V? {
        firstSuperlayer(where: { $0 is V }) as? V
    }
    
    /**
     The first superlayer that matches the specificed predicate.
     
     - Parameter predicate: The closure to match.
     - Returns: The first parent layer that is matching the predicate or `nil` if none match or there isn't a matching parent.
     */
    @objc open func firstSuperlayer(where predicate: (CALayer) -> (Bool)) -> CALayer? {
        if let superlayer = superlayer {
            if predicate(superlayer) == true {
                return superlayer
            }
            return superlayer.firstSuperlayer(where: predicate)
        }
        return nil
    }
    
    /// An array of all enclosing superlayers..
    @objc open func supervlayerChain() -> [CALayer] {
        if let superlayer = superlayer {
            return [superlayer] + superlayer.supervlayerChain()
        }
        return []
    }
    
    /**
     The first sublayer that matches the specificed layer type.
     
     - Parameters:
        - type: The type of layer to match.
        - depth: The maximum depth. As example a value of `0` returns the first sublayer matching of the receiver's sublayers and a value of `1` returns the first sublayer matching of the receiver's sublayers or any of their sublayers. To return the first sublayer matching of all sublayers use `max`.
     - Returns: The first sublayer that matches the layer type or `nil` if no sublayer matches.
     */
    public func firstSublayer<V: CALayer>(type _: V.Type, depth: Int = 0) -> V? {
        firstSublayer(where: { $0 is V }, depth: depth) as? V
    }
    
    /**
     The first sublayer with the specified name.
     
     - Parameters:
        - name: The name of layer to match.
        - depth: The maximum depth. As example a value of `0` returns the first sublayer matching of the receiver's sublayers and a value of `1` returns the first sublayer matching of the receiver's sublayers or any of their sublayers. To return the first sublayer matching of all sublayers use `max`.
     - Returns: The first sublayer that matches the specified name, or `nil` if no sublayer matches.
     */
    public func firstSublayer(named name: String, depth: Int = 0) -> CALayer? {
        firstSublayer(where: { $0.name == name }, depth: depth)
    }
    
    /**
     The first sublayer that matches the specificed layer type.
     
     - Parameters:
        - type: The type of layer to match.
        - depth: The maximum depth. As example a value of `0` returns the first sublayer matching of the receiver's sublayers and a value of `1` returns the first sublayer matching of the receiver's sublayers or any of their sublayers. To return the first sublayer matching of all sublayers use `max`.
     - Returns: The first sublayer that matches the layer type or `nil` if no sublayer matches.
     */
    public func firstSublayer(type: String, depth: Int = 0) -> CALayer? {
        firstSublayer(where: { NSStringFromClass(Swift.type(of: $0)) == type }, depth: depth)
    }
    
    /**
     The first sublayer that matches the specificed predicate.
     
     - Parameters:
        - predicate: TThe closure to match.
        - depth: The maximum depth. As example a value of `0` returns the first sublayer matching of the receiver's sublayers and a value of `1` returns the first sublayer matching of the receiver's sublayers or any of their sublayers. To return the first sublayer matching of all sublayers use `max`.
     
     - Returns: The first sublayer that is matching the predicate or `nil` if no sublayer is matching.
     */
    @objc open func firstSublayer(where predicate: (CALayer) -> (Bool), depth: Int = 0) -> CALayer? {
        if let sublayer = (sublayers ?? []).first(where: predicate) {
            return sublayer
        }
        if depth > 0 {
            for sublayer in sublayers ?? [] {
                if let sublayer = sublayer.firstSublayer(where: predicate, depth: depth - 1) {
                    return sublayer
                }
            }
        }
        return nil
    }
    
    /**
     An array of all sublayers upto the maximum depth.
     
     - Parameter depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
     */
    public func sublayers(depth: Int) -> [CALayer] {
        let sublayers = sublayers ?? []
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
        - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
     */
    public func sublayers<V: CALayer>(type _: V.Type, depth: Int = 0) -> [V] {
        sublayers(depth: depth).compactMap { $0 as? V }
    }
    
    /**
     An array of all sublayers matching the specified layer type.
     
     - Parameters:
        - type: The type of sublayers.
        - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
     */
    public func sublayers(type: String, depth: Int = 0) -> [CALayer] {
        sublayers(where: { NSStringFromClass(Swift.type(of: $0)) == type }, depth: depth)
    }
    
    /**
     An array of all sublayers matching the specified predicte.
     
     - Parameters:
        - predicate: The predicate to match.
        - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
     */
    public func sublayers(where predicate: (CALayer) -> (Bool), depth: Int = 0) -> [CALayer] {
        sublayers(depth: depth).filter { predicate($0) == true }
    }
    
    /**
     An optional layer whose inverse alpha channel is used to mask the layer’s content.
     
     In contrast to `mask` transparent pixels allow the underlying content to show, while opaque pixels block the content.
     */
    @objc var inverseMask: CALayer? {
        get { (mask as? InverseMaskLayer)?.maskLayer }
        set {
            if let newValue = newValue {
                mask = InverseMaskLayer(maskLayer: newValue)
            } else {
                mask = nil
            }
        }
    }
    
    /**
     Prints the hierarchy of the layer and its sublayers to the console.
     
     - Parameters:
        - depth: The maximum depth of the layer hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
        - includeDetails: If `true` prints the full description of each layer; otherwise prints only the type.
     */
    public func printHierarchy(depth: Int = .max, includeDetails: Bool = false) {
        guard depth >= 0 else { return }
        printHierarchy(level: 0, depth: depth, includeDetails: false)
    }
    
    private func printHierarchy(level: Int, depth: Int, includeDetails: Bool) {
        let string = includeDetails ? "\(self)" : "\(type(of: self))"
        Swift.print("\(Array(repeating: " ", count: level).joined(separator: ""))\(string)")
        guard level+1 <= depth else { return }
        for sublayer in _sublayers {
            sublayer.printHierarchy(level: level+1, depth: depth, includeDetails: includeDetails)
        }
    }
    
    /**
     Prints the hierarchy of layers of a specific type starting from this layer.
     
     - Parameters:
        -   type: The layer type to match (e.g., `CAShapeLayer.self`). Only subtrees containing at least one layer of this type will be printed.
        - depth: The maximum depth of the layer hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
        - includeDetails: If `true` prints the full description of each layer; otherwise prints only the type.
     */
    public func printHierarchy<V: CALayer>(type _: V.Type, depth: Int = .max, includeDetails: Bool = false) {
        printHierarchy(predicate: {$0 is V}, depth: depth, includeDetails: includeDetails)
    }
    
    /**
     Prints the hierarchy of layers that match a given predicate starting from this layer.
     
     - Parameters:
        - predicate: A closure that determines whether a layer should be included in the printed hierarchy. Entire subtrees are printed only if at least one layer in the subtree matches the predicate.
        - depth: The maximum depth of the layer hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
        - includeDetails: If `true` prints the full description of each layer; otherwise prints only the type.
     */
    public func printHierarchy(predicate: (CALayer) -> Bool, depth: Int = .max, includeDetails: Bool = false) {
        guard depth >= 0 else { return }
        printHierarchy(level: 0, depth: depth, predicate: predicate, includeDetails: includeDetails)
    }
    
    private func printHierarchy(level: Int, depth: Int, predicate: (CALayer) -> Bool, includeDetails: Bool) {
        let string = includeDetails ? "\(self)" : "\(type(of: self))"
        Swift.print("\(Array(repeating: " ", count: level).joined(separator: ""))\(string)")
        guard level+1 <= depth else { return }
        for sublayer in _sublayers {
            guard sublayer.matchesPredicateRecursively(predicate, level: level+1, depth: depth) else { continue }
            sublayer.printHierarchy(level: level+1, depth: depth, predicate: predicate, includeDetails: includeDetails)
        }
    }
    
    private func matchesPredicateRecursively(_ predicate: (CALayer) -> Bool, level: Int, depth: Int) -> Bool {
        if predicate(self) {
            return true
        }
        guard level+1 <= depth else { return false }
        return _sublayers.contains { $0.matchesPredicateRecursively(predicate, level: level+1, depth: depth) }
    }
    
    var _sublayers: [CALayer] {
        sublayers ?? []
    }
}

public extension CALayer {
    #if os(macOS)
    /**
     The effective appearance of the view this layer is displayed in.
     
     Changes can be observed using `observeChanges(for:handler:)`.  If the layer is attached to a view, it observes the view’s appearance; otherwise, it tracks the layer’s superlayers until a parent view is found.

     Observing this value is useful when deriving colors for `CGColor`-backed properties, since `CGColor` does't automatically update for appearance changes (light/dark mode) compared to `NSColor`.
     
     Example observation:
     
     ```swift
     layer.observeChanges(for: \.parentViewAppearance) {
        old, new in
     }
     ```
     If the layer isn't displayed in a view, the `.aqua` is returned.
     */
    @objc dynamic var parentViewAppearance: NSAppearance {
        parentView?.effectiveAppearance ?? .aqua
    }
    #elseif os(iOS)
    /**
     The user interface style of the view this layer is displayed in.
     
     Changes can be observed using `observeChanges(for:handler:)`.  If the layer is attached to a view, it observes the view’s user interface style; otherwise, it tracks the layer’s superlayers until a parent view is found.

     Observing this value is useful when deriving colors for `CGColor`-backed properties, since `CGColor` does't automatically update for dynamic user interface style changes (light / dark mode) compared to `UIKit`.
   
     Example observation:
     
     ```swift
     layer.observeChanges(for: \.parentViewAppearance) {
        old, new in
     }
     ```
     */
    @objc dynamic var parentViewUserInterfaceStyle: UIUserInterfaceStyle {
        parentView?.traitCollection.userInterfaceStyle ?? .unspecified
    }
    #endif
}

fileprivate extension CAGradientLayer {
    var _gradient: Gradient {
        get {
            let colors = (colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
            let locations = locations?.map { CGFloat($0.floatValue) } ?? []
            let stops = zip(colors, locations).map({ Gradient.ColorStop(color: $0.0, location: $0.1) })
            return Gradient(stops: stops, startPoint: .init(startPoint.x, startPoint.y), endPoint: .init(endPoint.x, endPoint.y), type: .init(type))
        }
        set {
            colors = newValue.stops.map(\.color.cgColor)
            locations = newValue.stops.map { NSNumber($0.location) }
            startPoint = newValue.startPoint.asPoint
            endPoint = newValue.endPoint.asPoint
            type = newValue.type.gradientLayerType
        }
    }
}

#if os(macOS)
public extension CAAutoresizingMask {
    static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
}
#endif
#endif

/*
public class DynColors {
    private weak var layer: CALayer?
    private var viewObservation: KeyValueObservation?
    
    private var observations: [PartialKeyPath<CALayer>: Observer] = [:] {
        didSet { updateViewObservation() }
    }
    
    public init(_ layer: CALayer) {
        self.layer = layer
    }
    
    public subscript(_ keyPath: ReferenceWritableKeyPath<CALayer, CGColor?>) -> NSUIColor? {
        get { observations[keyPath]?.color ?? layer?[keyPath: keyPath]?.nsUIColor }
        set { setColor(newValue, for: keyPath) }
    }
    
    public subscript(_ keyPath: ReferenceWritableKeyPath<CALayer, CGColor>) -> NSUIColor {
        get { observations[keyPath]?.color ?? layer?[keyPath: keyPath].nsUIColor ?? .clear }
        set { setColor(newValue, for: keyPath) }
    }
        
    private func setColor(_ color: NSUIColor?, for keyPath: ReferenceWritableKeyPath<CALayer, CGColor?>) {
        guard let layer = layer else { return }
        func setup() {
            observations[keyPath] = nil
            layer[keyPath: keyPath] = color?.resolvedColor(for: layer.parentView?.effectiveAppearance ?? .aqua).cgColor
            guard var observer = Observer(color) else { return }
            observer.observation = layer.observeChanges(for: keyPath) { [weak self] old, new in
                guard new != observer.light && new != observer.dark else { return }
                self?.observations[keyPath] = nil
            }
            observer.update = { $0[keyPath: keyPath] = $1 ? observer.light : observer.dark }
            observations[keyPath] = observer
        }
        if let match = observations[keyPath] {
            guard match.color != color else { return }
            setup()
        } else {
            setup()
        }
    }
    
    private func setColor(_ color: NSUIColor, for keyPath: ReferenceWritableKeyPath<CALayer, CGColor>) {
        guard let layer = layer else { return }
        func setup() {
            observations[keyPath] = nil
            layer[keyPath: keyPath] = color.resolvedColor(for: layer.parentView?.effectiveAppearance ?? .aqua).cgColor
            guard var observer = Observer(color) else { return }
            observer.observation = layer.observeChanges(for: keyPath) { [weak self] old, new in
                guard new != observer.light && new != observer.dark else { return }
                self?.observations[keyPath] = nil
            }
            observer.update = { $0[keyPath: keyPath] = $1 ? observer.light : observer.dark }
            observations[keyPath] = observer
        }
        if let match = observations[keyPath] {
            guard match.color != color else { return }
            setup()
        } else {
            setup()
        }
    }
    
    private func updateColors(isLight: Bool) {
        guard let layer = layer else { return }
        observations.values.forEach({ $0.update(layer, isLight) })
    }
    
    private func updateViewObservation() {
        if observations.isEmpty {
            viewObservation = nil
        } else if viewObservation == nil {
            viewObservation = layer?.parentView?.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                guard old.isLight != new.isLight else { return }
                self?.updateColors(isLight: new.isLight)
            }
        }
    }
    
    private struct Observer {
        let color: NSUIColor
        let light: CGColor
        let dark: CGColor
        var observation: KeyValueObservation?
        var update: (CALayer, Bool)->() = { _,_ in }
        
        init?(_ color: NSUIColor?) {
            guard let color = color else { return nil }
            let dynamicColors = color.dynamicColors
            guard dynamicColors.isDynamic else { return nil }
            self.color = color
            self.light = dynamicColors.light.cgColor
            self.dark = dynamicColors.dark.cgColor
        }
    }
}
*/
