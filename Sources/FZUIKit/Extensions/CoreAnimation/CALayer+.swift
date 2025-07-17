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

extension CALayer {
    /// The translation of the layer's transform on the x- and y-coordinate.
    var translation: CGPoint {
        get { transform.translation.asPoint }
        set { CATransaction.disabledActions { transform.translation = Translation(newValue.x, newValue.y, transform.translation.z) } }
    }
    
    /// The translation of the layer's transform.
    var translationXYZ: Translation {
        get { transform.translation }
        set { CATransaction.disabledActions { transform.translation = newValue } }
    }
    
    /// The scale of the layer's transform.
    var scale: Scale {
        get { transform.scale.scale }
        set { CATransaction.disabledActions { transform.scale = newValue.vector } }
    }
    
    /// The rotation of the layer's transform, in degrees.
    var rotation: Rotation {
        get { transform.eulerAnglesDegrees.rotation }
        set { CATransaction.disabledActions { transform.eulerAnglesDegrees = newValue.vector } }
    }
    
    /// The rotation of the layer's transform, in radians.
    var rotationInRadians: Rotation {
        get { transform.eulerAngles.rotation }
        set { CATransaction.disabledActions { transform.eulerAngles = newValue.vector } }
    }
    
    /// The shearing of the layer's transform.
    var skew: Skew {
        get { transform.skew }
        set { CATransaction.disabledActions { transform.skew = newValue } }
    }
    
    /// The perspective of the layer's transform (e.g. .m34).
    var perspective: Perspective {
        get { transform.perspective }
        set { CATransaction.disabledActions { transform.perspective = newValue } }
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
    
    /// The shadow of the layer.
    @objc open var shadow: ShadowConfiguration {
        get { configurations.shadow }
        set {
            configurations.shadow = newValue
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #endif
        }
    }
    
    class Configurations {
        var border: BorderConfiguration {
            get {
                guard let layer = layer else { return .none }
                _border.color = layer.parentView?.dynamicColors[\._borderColor] ?? layer._borderColor?.nsUIColor
                if let layer = layer.borderLayer {
                    _border.width = layer.lineWidth
                    _border.dash = .init(layer)
                } else {
                    _border.width = layer.borderWidth
                }
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
                            _border.color = color.resolvedColor(for: parentView).withAlpha(0.0)
                        } else {
                            _border.color = color.withAlpha(0.0)
                        }
                        CATransaction.performNonAnimated {
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
                        CATransaction.performNonAnimated {
                            if let parentView = layer.parentView {
                                layer.shadowColor = color.resolvedColor(for: parentView).withAlpha(0.0).cgColor
                            } else {
                                layer.shadowColor = color.withAlpha(0.0).cgColor
                            }
                        }
                    }
                }
                layer.parentView?.dynamicColors[\.shadowColor] = newValue.resolvedColor()
                layer.shadowColor = layer.resolvedColor(for: newValue.resolvedColor())
                layer.shadowRadius = newValue.radius
                layer.shadowOffset = newValue.offset.size
                layer.shadowOpacity = Float(newValue.opacity)
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
                    layer.innerShadowLayer = _InnerShadowLayer(for: layer)
                }
                var newValue = newValue
                if !Self.hasActiveGrouping {
                    if layer.resolvedColor(for: newValue.resolvedColor()) == nil, _innerShadow.color?.isVisible == true {
                        newValue.color = .clear
                    } else if !_innerShadow.isVisible, let color = newValue.resolvedColor() {
                        CATransaction.performNonAnimated {
                            if let parentView = layer.parentView {
                                layer.innerShadowLayer?.shadowColor  = color.resolvedColor(for: parentView).withAlpha(0.0).cgColor
                            } else {
                                layer.innerShadowLayer?.shadowColor = color.withAlpha(0.0).cgColor
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
                        CATransaction.performNonAnimated {
                            layer.backgroundColor = color.withAlpha(0.0).cgColor
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
                    _gradient?.startPoint = .init(layer.startPoint)
                    _gradient?.endPoint = .init(layer.endPoint)
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
                        if layer._gradientLayer == nil {
                            let gradientLayer = GradientLayer()
                            layer.addSublayer(withConstraint: gradientLayer)
                            gradientLayer.sendToBack()
                            gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                        }
                        layer._gradientLayer?._gradient = newValue
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
    
    var innerShadowLayer: _InnerShadowLayer? {
        get { getAssociatedValue("innerShadowLayer") }
        set { setAssociatedValue(newValue, key: "innerShadowLayer") }
    }
    
    /// The inner shadow of the layer.
    @objc open var innerShadow: ShadowConfiguration {
        get { configurations.innerShadow }
        set { configurations.innerShadow = newValue }
    }
    
    var innerShadowColor: CGColor? {
        get { innerShadowLayer?.shadowColor }
        set { innerShadowLayer?.shadowColor = newValue }
    }
    
    /// The shape that is used for masking the layer.
    public var maskShape: PathShape? {
        get { (mask as? PathShapeMaskLayer)?.shape }
        set {
            if let newValue = newValue {
                (mask as? PathShapeMaskLayer ?? PathShapeMaskLayer(layer: self, shape: newValue)).shape = newValue
            } else if mask is PathShapeMaskLayer {
                mask = nil
            }
            shadowShape = newValue
            innerShadowLayer?._maskShape = newValue
            configurations.setupBorder()
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #endif
        }
    }
    
    /// The shape of the shadow.
    public var shadowShape: PathShape? {
        get { getAssociatedValue("shadowShape") }
        set {
            setAssociatedValue(newValue, key: "shadowShape")
            if let newValue = newValue {
                shadowShapeObservation = observeChanges(for: \.bounds) { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.shadowPath = newValue.path(in: new)
                }
                shadowPath = newValue.path(in: bounds)
            } else {
                shadowShapeObservation = nil
            }
            #if os(macOS)
            parentView?.setupShadowShapeView()
            #endif
        }
    }
    
    var shadowShapeObservation: KeyValueObservation? {
        get { getAssociatedValue("shadowShapeObservation") }
        set { setAssociatedValue(newValue, key: "shadowShapeObservation") }
    }
    
    var borderLayer: BorderLayer? {
        get { getAssociatedValue("borderLayer") }
        set { setAssociatedValue(newValue, key: "borderLayer") }
    }
    
    class BorderLayer: CAShapeLayer {
        var observation: KeyValueObservation!
        
        var configuration: BorderConfiguration = .none {
            didSet {
                let color = configuration.resolvedColor()
                strokeColor = superlayer?.resolvedColor(for: color) ?? color?.cgColor
                lineDashPattern = configuration.dash.pattern  as [NSNumber]
                lineWidth = configuration.width
                lineDashPhase = configuration.dash.phase
                lineJoin = configuration.dash.lineJoin.shapeLayerLineJoin
                lineCap = configuration.dash.lineCap.shapeLayerLineCap
                if oldValue.insets != configuration.insets {
                    updateFrame(update: false)
                }
                guard oldValue.width != configuration.width || oldValue.insets != configuration.insets else { return }
                updatePath()
            }
        }
        
        func updateFrame(update: Bool = true) {
            guard let layer = superlayer else { return }
            var frame = layer.bounds
            frame.size.width -= configuration.insets.width
            frame.size.height -= configuration.insets.height
            frame.origin.x = configuration.insets.leading
            frame.origin.y = configuration.insets.bottom
            self.frame = frame
            guard update else { return }
            updatePath()
        }
        
        var shape: PathShape? {
            didSet { updatePath() }
        }
        
        func updatePath() {
            path = shape?.inset(by: lineWidth*0.5).path(in: bounds)
        }
        
        init(for layer: CALayer) {
            defer { self.shape = layer.maskShape }
            super.init()
            fillColor = nil
            frame = layer.bounds
            zPosition = .greatestFiniteMagnitude
            layer.addSublayer(self)
            strokeColor = layer.borderColor
            lineWidth = layer.borderWidth
            sendToBack()
            observation = layer.observeChanges(for: \.bounds) { [weak self] old, new in
                guard let self = self, old.size != new.size else { return }
                self.updateFrame()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class PathShapeMaskLayer: CAShapeLayer {
        var shape: PathShape {
            didSet { path = shape.path(in: bounds) }
        }
        
        var observation: KeyValueObservation?
        
        init(layer: CALayer, shape: PathShape) {
            self.shape = shape
            super.init()
            
            frame = layer.bounds
            layer.mask = self
            observation = layer.observeChanges(for: \.bounds) { [weak self] old, new in
                guard let self = self, old.size != new.size else { return }
                self.frame = new
                self.path = self.shape.path(in: new)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func resolvedColor(for color: NSUIColor?) -> CGColor? {
        guard let view = parentView, let color = color else { return nil }
        return color.resolvedColor(for: view).cgColor
    }
    
    /// The border of the layer.
    @objc open var border: BorderConfiguration {
        get { configurations.border }
        set { configurations.border = newValue }
    }
    
    var _borderColor: CGColor? {
        get { borderLayer?.strokeColor ?? borderColor }
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
        get {
            if let gradient: Gradient = getAssociatedValue("gradient") {
                return gradient
            } else if let layer = self as? CAGradientLayer {
                let colors = (layer.colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
                let locations = layer.locations?.compactMap { CGFloat($0.floatValue) } ?? []
                let stops = zip(colors, locations).map({ Gradient.ColorStop(color: $0.0, location: $0.1) })
                let gradient = Gradient(stops: stops, startPoint: .init(layer.startPoint), endPoint: .init(layer.endPoint), type: .init(layer.type))
                setAssociatedValue(gradient, key: "gradient")
                return gradient
            }
            return nil
        }
        set {
            setAssociatedValue(newValue, key: "gradient")
            if let newValue = newValue, !newValue.stops.isEmpty {
                if let layer = self as? CAGradientLayer {
                    layer.colors = newValue.stops.compactMap(\.color.cgColor)
                    layer.locations = newValue.stops.compactMap { NSNumber($0.location) }
                    layer.startPoint = newValue.startPoint.point
                    layer.endPoint = newValue.endPoint.point
                    layer.type = newValue.type.gradientLayerType
                } else {
                    if _gradientLayer == nil {
                        let gradientLayer = GradientLayer()
                        addSublayer(withConstraint: gradientLayer)
                        gradientLayer.sendToBack()
                        gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)
                    }
                    _gradientLayer?.gradient = newValue
                }
            } else {
                if let layer = self as? CAGradientLayer {
                    layer.colors = nil
                } else {
                    _gradientLayer?.removeFromSuperlayer()
                }
            }
        }
    }
    
    var gradientColors: [CGColor] {
        get { (self as? CAGradientLayer ?? _gradientLayer)?.colors as? [CGColor] ?? [] }
        set { (self as? CAGradientLayer ?? _gradientLayer)?.colors = newValue }
    }
    
    var _gradientLayer: GradientLayer? {
        firstSublayer(type: GradientLayer.self)
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
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to be added.
        - insets: Insets from the new sublayer border to the layer border.
     */
    @objc open func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        addSublayer(layer)
        layer.constraint(to: self, insets: insets)
    }
    
    /**
     Inserts the specified layer at the specified index and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to be added.
        - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
        - insets: Insets from the new sublayer border to the layer border.
     */
    @objc open func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
        guard index >= 0, index < sublayers?.count ?? Int.max else { return }
        insertSublayer(layer, at: index)
        layer.constraint(to: self, insets: insets)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to constraint to.
        - insets: The insets.
     */
    @objc open func constraint(to layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        let frameUpdate: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            var frame = layer.bounds
            frame.size.width -= insets.width
            frame.size.height -= insets.height
            frame.center = layer.bounds.center
            self.frame = frame
        }
        cornerRadius = layer.cornerRadius
        maskedCorners = layer.maskedCorners
        cornerCurve = layer.cornerCurve
        
        if layerObserver?.observedObject != layer {
            layerObserver = KeyValueObserver(layer)
        }
        layerObserver?.add(\.cornerRadius) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.cornerRadius = new
        }
        layerObserver?.add(\.cornerCurve) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.cornerCurve = new
        }
        layerObserver?.add(\.maskedCorners) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.maskedCorners = new
        }
        layerObserver?.add(\.bounds) { old, new in
            guard old != new else { return }
            frameUpdate()
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
        layerObserver = nil
        superLayerObservation = nil
    }
    
    var superLayerObservation: KeyValueObservation? {
        get { getAssociatedValue("superLayerObservation") }
        set { setAssociatedValue(newValue, key: "superLayerObservation") }
    }
    
    var layerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue("layerObserver") }
        set { setAssociatedValue(newValue, key: "layerObserver") }
    }
    
    /// The associated view using the layer.
    @objc open var parentView: NSUIView? {
        if let view = delegate as? NSUIView {
            return view
        }
        return superlayer?.parentView
    }
    
    /// A rendered image of the layer.
    @objc open var renderedImage: NSUIImage {
#if os(macOS)
        let btmpImgRep =
        NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(frame.width), pixelsHigh: Int(frame.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 32)
        let ctx = NSGraphicsContext(bitmapImageRep: btmpImgRep!)
        let cgContext = ctx!.cgContext
        render(in: cgContext)
        let cgImage = cgContext.makeImage()
        let nsimage = NSImage(cgImage: cgImage!, size: CGSize(width: frame.width, height: frame.height))
        return nsimage
#else
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)
        render(in: UIGraphicsGetCurrentContext()!)
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

fileprivate extension CAGradientLayer {
    var _gradient: Gradient {
        get {
            let colors = (colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
            let locations = locations?.compactMap { CGFloat($0.floatValue) } ?? []
            let stops = zip(colors, locations).map({ Gradient.ColorStop(color: $0.0, location: $0.1) })
            return Gradient(stops: stops, startPoint: .init(startPoint), endPoint: .init(endPoint), type: .init(type))
        }
        set {
            colors = newValue.stops.compactMap(\.color.cgColor)
            locations = newValue.stops.compactMap { NSNumber($0.location) }
            startPoint = newValue.startPoint.point
            endPoint = newValue.endPoint.point
            type = newValue.type.gradientLayerType
        }
    }
}
#endif

#if os(macOS)
public extension CAAutoresizingMask {
    static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
}
#endif
