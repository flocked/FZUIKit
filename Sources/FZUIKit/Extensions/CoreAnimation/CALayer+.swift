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
    extension CALayer {
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
            get {
                updatedShadowConfiguration()
            }
            set {
                // parentView?.dynamicLayerColors[\.shadowColor] = newValue.resolvedColor()
                shadowConfiguration = shadowConfiguration
                shadowColor = resolvedColor(for: newValue.resolvedColor())
                shadowOpacity = Float(newValue.opacity)
                shadowRadius = newValue.radius
                shadowOffset = newValue.offset.size
            }
        }
        
        var shadowConfiguration: ShadowConfiguration {
            get { getAssociatedValue("shadow", initialValue: ShadowConfiguration(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point)) }
            set { setAssociatedValue(newValue, key: "shadow") }
        }

        func updatedShadowConfiguration() -> ShadowConfiguration {
            resolvedColor(for: shadowConfiguration.resolvedColor()) == shadowColor ? shadowConfiguration.color : shadowColor?.nsUIColor
            shadowConfiguration.radius = shadowRadius
            shadowConfiguration.offset = shadowOffset.point
            shadowConfiguration.opacity = CGFloat(shadowOpacity)
            return shadowConfiguration
        }
        
        /// The inner shadow of the layer.
        @objc open var innerShadow: ShadowConfiguration {
            get { innerShadowLayer?.configuration ?? .none() }
            set {
                if newValue.isInvisible {
                    innerShadowLayer?.removeFromSuperlayer()
                } else {
                    if innerShadowLayer == nil {
                        let innerShadowLayer = InnerShadowLayer()
                        addSublayer(withConstraint: innerShadowLayer)
                        innerShadowLayer.sendToBack()
                        innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
                    }
                    innerShadowLayer?.configuration = newValue
                }
            }
        }
        
        var innerShadowConfiguration: ShadowConfiguration {
            get { getAssociatedValue("innerShadow") ?? .none() }
            set { setAssociatedValue(newValue, key: "innerShadow") }
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
            }
        }
        
        var shadowShapeObservation: KeyValueObservation? {
            get { getAssociatedValue("shadowShapeObservation") }
            set { setAssociatedValue(newValue, key: "shadowShapeObservation") }
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
                setupBoderLayer(for: border)
            }
        }
        
        var borderLayer: BorderLayer? {
            get { getAssociatedValue("borderLayer") }
            set { setAssociatedValue(newValue, key: "borderLayer") }
        }
        
        class BorderLayer: CAShapeLayer {
            var _shape: PathShape?
            var observation: KeyValueObservation!
            
            var shape: PathShape? {
                didSet { 
                    _shape = shape?.inset(by: lineWidth*0.5)
                    updateBorderShape()
                }
            }
            
            override var lineWidth: CGFloat {
                didSet {
                    guard oldValue != lineWidth else { return }
                    _shape = shape?.inset(by: lineWidth*0.5)
                    updateBorderShape()
                }
            }
            
            func updateBorderShape() {
                path = _shape?.path(in: bounds)
            }
                        
            init(for layer: CALayer) {
                self.shape = layer.maskShape
                super.init()
                fillColor = nil
                frame = layer.bounds
                zPosition = .greatestFiniteMagnitude
                layer.addSublayer(self)
                observation = layer.observeChanges(for: \.bounds) { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.frame = new
                    self.updateBorderShape()
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        func setupBoderLayer(for border: BorderConfiguration) {
            if (maskShape != nil && !border.isInvisible) || border.needsDashedBorder {
                if borderLayer == nil {
                    borderLayer = BorderLayer(for: self)
                }
                borderLayer?.shape = maskShape
                borderLayer?.border = border
                borderWidth = 0.0
                borderColor = nil
            } else {
                borderLayer?.removeFromSuperlayer()
                borderLayer = nil
                borderColor = resolvedColor(for: border.resolvedColor())
                borderWidth = border.width
            }
        }
        
        func resolvedColor(for color: NSUIColor?) -> CGColor? {
            guard let view = parentView, let color = color else { return nil }
            return color.resolvedColor(for: view).cgColor
        }
        
        var nsuiBackgroundColor: NSUIColor? {
            get {
                if let color: NSUIColor = getAssociatedValue("nsuiBackgroundColor"), resolvedColor(for: color) != backgroundColor {
                    nsuiBackgroundColor = backgroundColor?.nsUIColor
                }
                return getAssociatedValue("nsuiBackgroundColor")
            }
            set {
                setAssociatedValue(newValue, key: "nsuiBackgroundColor")
                backgroundColor = resolvedColor(for: newValue)
            }
        }
        
        func setupObser() {
            if let parentView = parentView, shadowConfiguration.color?.isDynamic == true || innerShadowConfiguration.color?.isDynamic == true || borderConfiguration.color?.isDynamic == true || nsuiBackgroundColor?.isDynamic == true {
                #if os(macOS)
                parentView.effectiveAppearanceObservation = parentView.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                    guard let self = self else { return }
                }
                #endif
            }
        }
        
        class PathShapeMaskLayer: CAShapeLayer {
            var shape: PathShape {
                didSet { path = shape.path(in: bounds) }
            }
            var observation: KeyValueObservation!
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
        
        internal var innerShadowLayer: InnerShadowLayer? {
            firstSublayer(type: InnerShadowLayer.self)
        }
        
        /// The border of the layer.
        @objc open var border: BorderConfiguration {
            get { updatedBorderConfiguration() }
            set {
                guard newValue != border else { return }
                borderConfiguration = newValue
                if let layer = self as? CAShapeLayer {
                    layer.strokeColor = resolvedColor(for: newValue.resolvedColor())
                    layer.lineDashPattern = newValue.dash.pattern  as [NSNumber]
                    layer.lineWidth = newValue.width
                    layer.lineDashPhase = newValue.dash.phase
                    layer.lineJoin = newValue.dash.lineJoin.shapeLayerLineJoin
                    layer.lineCap = newValue.dash.lineCap.shapeLayerLineCap
                } else {
                    setupBoderLayer(for: newValue)
                }
            }
        }
        
        var borderConfiguration: BorderConfiguration {
            get { getAssociatedValue("border", initialValue: BorderConfiguration(color: borderColor?.nsUIColor, width: borderWidth)) }
            set { setAssociatedValue(newValue, key: "border") }
        }
        
        func updatedBorderConfiguration() -> BorderConfiguration {
            let configurationColor = resolvedColor(for: borderConfiguration.resolvedColor())
            if let layer = self as? CAShapeLayer {
                borderConfiguration.color = configurationColor == layer.strokeColor ? configurationColor?.nsUIColor : layer.strokeColor?.nsUIColor
                borderConfiguration.width = layer.lineWidth
                borderConfiguration.dash.lineCap = layer.lineCap.cgLineCap
                borderConfiguration.dash.lineJoin = layer.lineJoin.cgLineJoin
                borderConfiguration.dash.phase = layer.lineDashPhase
                borderConfiguration.dash.pattern = layer.lineDashPattern?.compactMap({ CGFloat($0.doubleValue) }) ?? []
            } else {
                borderConfiguration.color = configurationColor == borderColor ? configurationColor?.nsUIColor : borderColor?.nsUIColor
                borderConfiguration.width = borderWidth
            }
            return borderConfiguration
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
            - type: The layer type to match (e.g., `CAShapeLayer.self`). Only subtrees containing at least one layer of this type will be printed.
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

/*
 public init(color: NSUIColor? = nil,
             colorTransformer: ColorTransformer? = nil,
             width: CGFloat = 0.0,
             dash: Dash = Dash(),
             insets: NSDirectionalEdgeInsets = .init(0)) {
 */
#endif

#if os(macOS)
    public extension CAAutoresizingMask {
        static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
    }
#endif

/*
 extension CALayer {
     class SavedColors {
         enum Color: Int {
             case background
             case shadow
             case border
         }
         var layer: CALayer
         init(for layer: CALayer) {
             self.layer = layer
         }
         var effectiveAppearanceObservation: KeyValueObservation?
         var colors: [Color: (cgColor: CGColor?, nsColor: NSColor?)] = [:] {
             didSet {
                 guard let parentView = layer.parentView else { return }
                 if !colors.contains(where: { $0.value.nsColor?.isDynamic == true }) {
                     effectiveAppearanceObservation = nil
                 } else if effectiveAppearanceObservation == nil {
                     effectiveAppearanceObservation = parentView.observeChanges(for: \.appearance) { [weak self] old, new in
                         guard let self = self else { return }
                         self.updateColors()
                     }
                 }
                 }
         }
         
         func updateColors() {
             if let color = colors[.background] {
                 
             }
         }
                 
         func getColor(for type: Color, current: CGColor?) -> NSUIColor? {
             let color = colors[type, default: (nil, nil)]
             if color.cgColor != current {
                 colors[type] = (current, nil)
                 return current?.nsUIColor
             }
             return color.nsColor
         }
     }
 }
 */

/*
class CALayerConstraint {
    public weak internal(set) var first: CALayer?
    public weak internal(set) var second: CALayer?
    
    public var isActive: Bool  {
        get { observer.observedObject == second }
        set {
            guard newValue != isActive else { return }
            if newValue, let second = second {
                observer.replaceObservedObject(with: second)
            } else {
                observer.removeObservedObject()
            }
        }
    }
    public var insets: NSDirectionalEdgeInsets
    
    var observer: KeyValueObserver<CALayer>!
    
    init(_ first: CALayer, second: CALayer, insets: NSDirectionalEdgeInsets) {
        self.first = first
        self.second = second
        self.insets = insets
        
        let frameUpdate: (() -> Void) = { [weak self] in
            guard let self = self, let first = self.first, let second = self.second else { return }
            var frame = second.bounds
            frame.size.width -= insets.width
            frame.size.height -= insets.height
            frame.center = second.bounds.center
            first.frame = frame
        }
        first.cornerRadius = second.cornerRadius
        first.maskedCorners = second.maskedCorners
        first.cornerCurve = second.cornerCurve
                        
        observer = KeyValueObserver(second)
        observer.add(\.cornerRadius) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.cornerRadius = new
        }
        observer.add(\.cornerCurve) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.cornerCurve = new
        }
        observer.add(\.maskedCorners) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.maskedCorners = new
        }
        observer.add(\.bounds) { old, new in
            guard old != new else { return }
            frameUpdate()
        }
        frameUpdate()
    }
}

var constraint: CALayerConstraint? {
    get { getAssociatedValue("layerConstraint") }
    set { setAssociatedValue(newValue, key: "layerConstraint") }
}
*/
